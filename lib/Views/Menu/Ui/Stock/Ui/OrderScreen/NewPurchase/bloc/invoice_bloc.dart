import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/individual_model.dart';
import '../../../../../../../../Services/repositories.dart';
import '../../../../../Settings/Ui/Company/Storage/model/storage_model.dart';
import '../../../../../Stakeholders/Ui/Accounts/model/acc_model.dart';
import '../model/invoice_items.dart';
part 'invoice_event.dart';
part 'invoice_state.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final Repositories repo;

  InvoiceBloc(this.repo) : super(InvoiceInitial()) {
    on<InitializeInvoiceEvent>(_onInitialize);
    on<SelectSupplierEvent>(_onSelectSupplier);
    on<SelectSupplierAccountEvent>(_onSelectSupplierAccount);
    on<ClearSupplierEvent>(_onClearSupplier);
    on<AddNewItemEvent>(_onAddNewItem);
    on<RemoveItemEvent>(_onRemoveItem);
    on<UpdateItemEvent>(_onUpdateItem);
    on<UpdatePaymentEvent>(_onUpdatePayment);
    on<ResetInvoiceEvent>(_onReset);
    on<SaveInvoiceEvent>(_onSaveInvoice);
    on<LoadStoragesEvent>(_onLoadStorages);
  }

  void _onInitialize(InitializeInvoiceEvent event, Emitter<InvoiceState> emit) {
    emit(InvoiceLoaded(
      items: [InvoiceItem(
        productId: '',
        productName: '',
        qty: 1,
        purPrice: 0,
        storageName: '',
        storageId: 1,
      )],
      payment: 0.0,
      paymentMode: PaymentMode.cash,
    ));
  }

  void _onSelectSupplierAccount(SelectSupplierAccountEvent event, Emitter<InvoiceState> emit) {
    if (state is InvoiceLoaded) {
      final current = state as InvoiceLoaded;
      emit(current.copyWith(
        supplierAccount: event.supplier,
        paymentMode: PaymentMode.credit, // Switch to credit when account selected
      ));
    }
  }

  void _onSelectSupplier(SelectSupplierEvent event, Emitter<InvoiceState> emit) {
    if (state is InvoiceLoaded) {
      final current = state as InvoiceLoaded;
      emit(current.copyWith(supplier: event.supplier));
    }
  }

  void _onClearSupplier(ClearSupplierEvent event, Emitter<InvoiceState> emit) {
    if (state is InvoiceLoaded) {
      final current = state as InvoiceLoaded;
      emit(current.copyWith(supplier: null, supplierAccount: null));
    }
  }

  void _onAddNewItem(AddNewItemEvent event, Emitter<InvoiceState> emit) {
    if (state is! InvoiceLoaded) return;
    final current = state as InvoiceLoaded;

    final newItem = InvoiceItem(
      productId: '',
      productName: '',
      qty: 1,
      purPrice: 0,
      storageName: '',
      storageId: 0,
    );

    final updatedItems = List<InvoiceItem>.from(current.items)..add(newItem);
    emit(current.copyWith(items: updatedItems));
  }

  void _onRemoveItem(RemoveItemEvent event, Emitter<InvoiceState> emit) {
    if (state is InvoiceLoaded) {
      final current = state as InvoiceLoaded;
      final updatedItems = current.items.where((item) => item.rowId != event.rowId).toList();

      // Ensure at least one item remains
      if (updatedItems.isEmpty) {
        updatedItems.add(InvoiceItem(
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

  void _onUpdateItem(UpdateItemEvent event, Emitter<InvoiceState> emit) {
    if (state is InvoiceLoaded) {
      final current = state as InvoiceLoaded;
      final updatedItems = current.items.map((item) {
        if (item.rowId == event.rowId) {
          return InvoiceItem(
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

  void _onUpdatePayment(UpdatePaymentEvent event, Emitter<InvoiceState> emit) {
    if (state is InvoiceLoaded) {
      final current = state as InvoiceLoaded;
      emit(current.copyWith(payment: event.payment));
    }
  }

  void _onReset(ResetInvoiceEvent event, Emitter<InvoiceState> emit) {
    emit(InvoiceLoaded(
      items: [InvoiceItem(
        productId: '',
        productName: '',
        qty: 1,
        purPrice: 0,
        salePrice: 0,
        storageName: '',
        storageId: 0,
      )],
      payment: 0.0,
      paymentMode: PaymentMode.credit,
    ));
  }

  Future<void> _onSaveInvoice(SaveInvoiceEvent event, Emitter<InvoiceState> emit) async {
    if (state is! InvoiceLoaded) {
      event.completer.complete('');
      return;
    }

    final current = state as InvoiceLoaded;

    // Save current state before attempting to save
    final savedState = current.copyWith();

    // Validate required fields
    if (current.supplier == null) {
      emit(InvoiceError('Please select a supplier'));
      emit(savedState); // Restore saved state
      event.completer.complete('');
      return;
    }

    if (current.supplierAccount == null && current.paymentMode == PaymentMode.credit) {
      emit(InvoiceError('Please select a supplier account for credit payment'));
      emit(savedState); // Restore saved state
      event.completer.complete('');
      return;
    }

    // Validate items
    for (var item in current.items) {
      if (item.productId.isEmpty || item.storageId == 0) {
        emit(InvoiceError('Please fill all item details (product, quantity, price, storage)'));
        emit(savedState); // Restore saved state
        event.completer.complete('');
        return;
      }
    }

    // Calculate credit amount based on payment mode
    double creditAmount = 0;
    if (current.paymentMode == PaymentMode.credit) {
      // Full amount as credit
      creditAmount = current.grandTotal;
    } else if (current.paymentMode == PaymentMode.mixed) {
      // Partial payment, remaining as credit
      creditAmount = current.grandTotal - current.payment;
    }

    // Validate credit amount
    if (creditAmount < 0) {
      emit(InvoiceError('Credit amount cannot be negative'));
      emit(savedState); // Restore saved state
      event.completer.complete('');
      return;
    }

    // Show saving state
    emit(InvoiceSaving(
      items: current.items,
      supplier: current.supplier,
      supplierAccount: current.supplierAccount,
      payment: current.payment,
      paymentMode: current.paymentMode,
      storages: current.storages,
    ));

    try {
      // Convert PurInvoiceItem to Invoice Record for API
      final records = current.items.map((item) {
        return InvoiceRecord(
          proID: int.tryParse(item.productId) ?? 0,
          stgID: item.storageId,
          quantity: item.qty.toDouble(),
          pPrice: item.purPrice,
        );
      }).toList();

      final xRef = event.xRef ?? 'PUR-${DateTime.now().millisecondsSinceEpoch}';

      final result = await repo.addInvoice(
        orderName: event.orderName,
        usrName: event.usrName,
        perID: event.ordPersonal,
        xRef: xRef,
        account: current.supplierAccount?.accNumber,
        amount: creditAmount, // Only the credit portion goes to account
        records: records,
      );

      emit(InvoiceSaved(true, invoiceNumber: result));
      event.completer.complete(result);

      // Reset after successful save
      add(ResetInvoiceEvent());
    } catch (e) {
      // Restore saved state on error
      emit(InvoiceError(e.toString()));
      emit(savedState);
      event.completer.complete('');
    }
  }

  Future<void> _onLoadStorages(LoadStoragesEvent event, Emitter<InvoiceState> emit) async {
    try {
      // Implement storage loading logic here
      // This would call your repository to fetch storages for a product
      // For now, we'll return an empty list
      if (state is InvoiceLoaded) {
        final current = state as InvoiceLoaded;
        emit(current.copyWith(storages: []));
      }
    } catch (e) {
      // Handle error silently or emit error state
    }
  }
}