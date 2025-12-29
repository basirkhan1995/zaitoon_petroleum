import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/individual_model.dart';
import '../../../../../../../../Services/repositories.dart';
import '../../../../../Settings/Ui/Company/Storage/model/storage_model.dart';
import '../../../../../Stakeholders/Ui/Accounts/model/acc_model.dart';
import '../model/pur_invoice_items.dart';

part 'purchase_event.dart';
part 'purchase_state.dart';

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final Repositories repo;

  PurchaseBloc(this.repo) : super(PurchaseInitial()) {
    on<InitializePurchaseEvent>(_onInitialize);
    on<SelectSupplierEvent>(_onSelectSupplier);
    on<SelectSupplierAccountEvent>(_onSelectSupplierAccount);
    on<ClearSupplierEvent>(_onClearSupplier);
    on<AddNewItemEvent>(_onAddNewItem);
    on<RemoveItemEvent>(_onRemoveItem);
    on<UpdateItemEvent>(_onUpdateItem);
    on<UpdatePaymentEvent>(_onUpdatePayment);
    on<ResetPurchaseEvent>(_onReset);
    on<SavePurchaseInvoiceEvent>(_onSaveInvoice);
    on<LoadStoragesEvent>(_onLoadStorages);
  }

  void _onInitialize(InitializePurchaseEvent event, Emitter<PurchaseState> emit) {
    emit(PurchaseLoaded(
      items: [PurInvoiceItem(
        productId: '',
        productName: '',
        qty: 1,
        purPrice: 0,
        storageName: '',
        storageId: 0,
      )],
      payment: 0.0,
    ));
  }

  void _onSelectSupplierAccount(SelectSupplierAccountEvent event, Emitter<PurchaseState> emit) {
    if (state is PurchaseLoaded) {
      final current = state as PurchaseLoaded;
      emit(current.copyWith(supplierAccount: event.supplier));
    }
  }

  void _onSelectSupplier(SelectSupplierEvent event, Emitter<PurchaseState> emit) {
    if (state is PurchaseLoaded) {
      final current = state as PurchaseLoaded;
      emit(current.copyWith(supplier: event.supplier));
    }
  }

  void _onClearSupplier(ClearSupplierEvent event, Emitter<PurchaseState> emit) {
    if (state is PurchaseLoaded) {
      final current = state as PurchaseLoaded;
      emit(current.copyWith(supplier: null));
    }
  }

  void _onAddNewItem(AddNewItemEvent event, Emitter<PurchaseState> emit) {
    if (state is! PurchaseLoaded) return;
    final current = state as PurchaseLoaded;

    final newItem = PurInvoiceItem(
      productId: '',
      productName: '',
      qty: 1,
      purPrice: 0,
      storageName: '',
      storageId: 0,
    );

    final updatedItems = List<PurInvoiceItem>.from(current.items)..add(newItem);
    emit(current.copyWith(items: updatedItems));
  }

  void _onRemoveItem(RemoveItemEvent event, Emitter<PurchaseState> emit) {
    if (state is PurchaseLoaded) {
      final current = state as PurchaseLoaded;
      final updatedItems = current.items.where((item) => item.rowId != event.rowId).toList();

      // Ensure at least one item remains
      if (updatedItems.isEmpty) {
        updatedItems.add(PurInvoiceItem(
          productId: '',
          productName: '',
          qty: 1,
          purPrice: 0,
          storageName: '',
          storageId: 0,
        ));
      }

      emit(current.copyWith(items: updatedItems));
    }
  }

  void _onUpdateItem(UpdateItemEvent event, Emitter<PurchaseState> emit) {
    if (state is PurchaseLoaded) {
      final current = state as PurchaseLoaded;
      final updatedItems = current.items.map((item) {
        if (item.rowId == event.rowId) {
          return PurInvoiceItem(
            itemId: item.rowId,
            productId: event.productId ?? item.productId,
            productName: event.productName ?? item.productName,
            qty: event.qty ?? item.qty,
            purPrice: event.purPrice ?? item.purPrice,
            storageName: event.storageName ?? item.storageName,
            storageId: event.storageId ?? item.storageId,
          );
        }
        return item;
      }).toList();

      emit(current.copyWith(items: updatedItems));
    }
  }

  void _onUpdatePayment(UpdatePaymentEvent event, Emitter<PurchaseState> emit) {
    if (state is PurchaseLoaded) {
      final current = state as PurchaseLoaded;
      emit(current.copyWith(payment: event.payment));
    }
  }

  void _onReset(ResetPurchaseEvent event, Emitter<PurchaseState> emit) {
    emit(PurchaseLoaded(
      items: [PurInvoiceItem(
        productId: '',
        productName: '',
        qty: 1,
        purPrice: 0,
        storageName: '',
        storageId: 0,
      )],
      payment: 0.0,
    ));
  }

  Future<void> _onSaveInvoice(SavePurchaseInvoiceEvent event, Emitter<PurchaseState> emit) async {
    if (state is! PurchaseLoaded) {
      event.completer.complete('');
      return;
    }

    final current = state as PurchaseLoaded;

    // Validate required fields
    if (current.supplier == null) {
      emit(PurchaseError('Please select a supplier'));
      event.completer.complete('');
      return;
    }

    // Validate items
    for (var item in current.items) {
      if (item.productId.isEmpty || item.storageId == 0) {
        emit(PurchaseError('Please fill all item details'));
        event.completer.complete('');
        return;
      }
    }

    emit(PurchaseSaving(
      items: current.items,
      supplier: current.supplier,
      payment: current.payment,
      storages: current.storages,
    ));

    try {
      // Convert PurInvoiceItem to PurchaseRecord for API
      final records = current.items.map((item) {
        return PurchaseRecord(
          proID: int.tryParse(item.productId) ?? 0,
          stgID: item.storageId,
          quantity: item.qty.toDouble(),
          pPrice: item.purPrice,
        );
      }).toList();

      final xRef = event.xRef ?? 'PUR-${DateTime.now().millisecondsSinceEpoch}';

      final result = await repo.purchaseInvoice(
        usrName: event.usrName,
        perID: event.perID,
        xRef: xRef,
        account: current.accountNumber,
        amount: current.grandTotal,
        records: records,
      );

      emit(PurchaseSaved(true, invoiceNumber: result));
      event.completer.complete(result);

      // Reset after successful save
      add(ResetPurchaseEvent());
    } catch (e) {
      emit(current);
      emit(PurchaseError(e.toString()));
      emit(PurchaseSaved(false));
      event.completer.complete('');
    }
  }

  Future<void> _onLoadStorages(LoadStoragesEvent event, Emitter<PurchaseState> emit) async {
    try {
      // Implement storage loading logic here
      // This would call your repository to fetch storages for a product
      // For now, we'll return an empty list
      if (state is PurchaseLoaded) {
        final current = state as PurchaseLoaded;
        emit(current.copyWith(storages: []));
      }
    } catch (e) {
      // Handle error silently or emit error state
    }
  }
}