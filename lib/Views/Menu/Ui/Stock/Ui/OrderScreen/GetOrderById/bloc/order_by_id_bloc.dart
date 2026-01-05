import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/model/storage_model.dart';
import '../../../../../Stakeholders/Ui/Accounts/model/acc_model.dart';
import '../../../../../Stakeholders/Ui/Individuals/individual_model.dart';
import '../model/ord_by_Id_model.dart';

part 'order_by_id_event.dart';
part 'order_by_id_state.dart';

class OrderByIdBloc extends Bloc<OrderByIdEvent, OrderByIdState> {
  final Repositories repo;

  OrderByIdBloc(this.repo) : super(OrderByIdInitial()) {
    on<LoadOrderByIdEvent>(_onLoadOrderById);
    on<UpdateOrderItemEvent>(_onUpdateItem);
    on<AddOrderItemEvent>(_onAddItem);
    on<RemoveOrderItemEvent>(_onRemoveItem);
    on<SaveOrderChangesEvent>(_onSaveChanges);
    on<ToggleEditModeEvent>(_onToggleEditMode);
    on<DeleteOrderEvent>(_onDeleteOrder);
    on<SelectOrderSupplierEvent>(_onSelectSupplier);
    on<SelectOrderAccountEvent>(_onSelectAccount);
    on<ClearOrderAccountEvent>(_onClearAccount);
    on<UpdateOrderPaymentEvent>(_onUpdatePayment);
  }

  Future<void> _onLoadOrderById(
      LoadOrderByIdEvent event,
      Emitter<OrderByIdState> emit,
      ) async {
    emit(OrderByIdLoading());

    try {
      final orders = await repo.getOrderById(orderId: event.orderId);

      if (orders.isEmpty) {
        emit(OrderByIdError('Order not found'));
        return;
      }

      final order = orders.first;

      // Load storages
      final storages = await repo.getStorage();

      // Load product names
      final productNames = <int, String>{};
      final storageNames = <int, String>{};

      // Handle nullable records
      final records = order.records ?? [];

      for (final record in records) {
        // Load product name
        if (record.stkProduct != null && !productNames.containsKey(record.stkProduct)) {
          try {
            final products = await repo.getProduct(proId: record.stkProduct!);
            if (products.isNotEmpty) {
              productNames[record.stkProduct!] = products.first.proName ?? 'Unknown';
            }
          } catch (_) {
            productNames[record.stkProduct!] = 'Unknown';
          }
        }

        // Load storage name
        if (record.stkStorage != null && !storageNames.containsKey(record.stkStorage)) {
          final storage = storages.firstWhere(
                (s) => s.stgId == record.stkStorage,
            orElse: () => StorageModel(stgId: 0, stgName: 'Unknown'),
          );
          storageNames[record.stkStorage!] = storage.stgName ?? 'Unknown';
        }
      }

      emit(OrderByIdLoaded(
        order: order,
        storages: storages,
        productNames: productNames,
        storageNames: storageNames,
        isEditing: false,
        selectedSupplier: null, // Will be populated from order
        selectedAccount: order.acc != null ?
        AccountsModel(accNumber: order.acc) : null,
        cashPayment: _calculateCashPayment(order),
        creditAmount: _calculateCreditAmount(order),
      ));
    } catch (e) {
      emit(OrderByIdError(e.toString()));
    }
  }

  double _calculateCashPayment(OrderByIdModel order) {
    if (order.acc == null || order.acc == 0) {
      // No account means full cash
      return double.tryParse(order.amount ?? "0.0") ?? 0.0;
    } else {
      // Has account, check if payment is mixed
      final total = double.tryParse(order.amount ?? "0.0") ?? 0.0;
      // For simplicity, assume mixed if total > 0 and account exists
      // You might want to adjust this logic based on your business rules
      return 0.0; // Default to credit
    }
  }

  double _calculateCreditAmount(OrderByIdModel order) {
    if (order.acc == null || order.acc == 0) {
      return 0.0;
    }
    return double.tryParse(order.amount ?? "0.0") ?? 0.0;
  }

  void _onToggleEditMode(
      ToggleEditModeEvent event,
      Emitter<OrderByIdState> emit,
      ) {
    if (state is OrderByIdLoaded) {
      final current = state as OrderByIdLoaded;
      emit(current.copyWith(isEditing: !current.isEditing));
    }
  }

  void _onSelectSupplier(
      SelectOrderSupplierEvent event,
      Emitter<OrderByIdState> emit,
      ) {
    if (state is OrderByIdLoaded) {
      final current = state as OrderByIdLoaded;
      emit(current.copyWith(selectedSupplier: event.supplier));
    }
  }

  void _onSelectAccount(
      SelectOrderAccountEvent event,
      Emitter<OrderByIdState> emit,
      ) {
    if (state is OrderByIdLoaded) {
      final current = state as OrderByIdLoaded;
      emit(current.copyWith(selectedAccount: event.account));
    }
  }

  void _onClearAccount(
      ClearOrderAccountEvent event,
      Emitter<OrderByIdState> emit,
      ) {
    if (state is OrderByIdLoaded) {
      final current = state as OrderByIdLoaded;
      emit(current.copyWith(
        selectedAccount: null,
        cashPayment: current.grandTotal,
        creditAmount: 0.0,
      ));
    }
  }

  void _onUpdatePayment(
      UpdateOrderPaymentEvent event,
      Emitter<OrderByIdState> emit,
      ) {
    if (state is OrderByIdLoaded) {
      final current = state as OrderByIdLoaded;

      double cashPayment = event.cashPayment;
      double creditAmount = event.creditAmount;

      // Validate
      final total = cashPayment + creditAmount;
      if ((total - current.grandTotal).abs() > 0.01) {
        // Payment doesn't match total
        emit(OrderByIdError('Total payment must equal grand total'));
        return;
      }

      emit(current.copyWith(
        cashPayment: cashPayment,
        creditAmount: creditAmount,
      ));
    }
  }

  void _onUpdateItem(
      UpdateOrderItemEvent event,
      Emitter<OrderByIdState> emit,
      ) {
    if (state is! OrderByIdLoaded) return;

    final current = state as OrderByIdLoaded;
    if (!current.isEditing) return;

    final currentRecords = current.order.records ?? [];

    if (event.index < 0 || event.index >= currentRecords.length) {
      return;
    }

    final records = List<OrderRecords>.from(currentRecords);
    final record = records[event.index];

    final updatedRecord = record.copyWith(
      stkProduct: event.productId ?? record.stkProduct,
      stkQuantity: event.quantity?.toString() ?? record.stkQuantity,
      stkPurPrice: event.price?.toString() ?? record.stkPurPrice,
      stkStorage: event.storageId ?? record.stkStorage,
    );

    records[event.index] = updatedRecord;

    final updatedOrder = current.order.copyWith(records: records);

    // Update product name if product changed
    Map<int, String> updatedProductNames = Map.from(current.productNames);
    if (event.productId != null && event.productId! > 0) {
      // Load product name if not already loaded
      if (!updatedProductNames.containsKey(event.productId)) {
        // We'll load this later when saving
        updatedProductNames[event.productId!] = 'Loading...';
      }
    }

    emit(current.copyWith(
      order: updatedOrder,
      productNames: updatedProductNames,
    ));
  }

  void _onAddItem(
      AddOrderItemEvent event,
      Emitter<OrderByIdState> emit,
      ) {
    if (state is! OrderByIdLoaded) return;

    final current = state as OrderByIdLoaded;
    if (!current.isEditing) return;

    // Determine if it's purchase or sale based on order name
    final isPurchase = current.order.ordName?.toLowerCase().contains('purchase') ?? true;
    final isSale = current.order.ordName?.toLowerCase().contains('sale') ?? false;

    final newRecord = OrderRecords(
      stkId: 0, // New item
      stkOrder: current.order.ordId,
      stkProduct: 0,
      stkEntryType: isPurchase ? "IN" : (isSale ? "OUT" : "IN"),
      stkStorage: current.storages.isNotEmpty ? current.storages.first.stgId : 0,
      stkQuantity: "1.000",
      stkPurPrice: isPurchase ? "0.0000" : "0.0000",
      stkSalePrice: isSale ? "0.0000" : "0.0000",
    );

    final currentRecords = current.order.records ?? [];
    final records = List<OrderRecords>.from(currentRecords)..add(newRecord);

    final updatedOrder = current.order.copyWith(records: records);

    emit(current.copyWith(order: updatedOrder));
  }

  void _onRemoveItem(
      RemoveOrderItemEvent event,
      Emitter<OrderByIdState> emit,
      ) {
    if (state is! OrderByIdLoaded) return;

    final current = state as OrderByIdLoaded;
    if (!current.isEditing) return;

    final currentRecords = current.order.records ?? [];

    if (event.index < 0 || event.index >= currentRecords.length) {
      return;
    }

    final records = List<OrderRecords>.from(currentRecords);
    records.removeAt(event.index);

    // Ensure at least one item remains
    if (records.isEmpty) {
      records.add(OrderRecords(
        stkId: 0,
        stkOrder: current.order.ordId,
        stkProduct: 0,
        stkEntryType: "IN",
        stkStorage: current.storages.isNotEmpty ? current.storages.first.stgId : 0,
        stkQuantity: "1.000",
        stkPurPrice: "0.0000",
        stkSalePrice: "0.0000",
      ));
    }

    final updatedOrder = current.order.copyWith(records: records);

    emit(current.copyWith(order: updatedOrder));
  }

  Future<void> _onSaveChanges(
      SaveOrderChangesEvent event,
      Emitter<OrderByIdState> emit,
      ) async {
    if (state is! OrderByIdLoaded) {
      event.completer.complete(false);
      return;
    }

    final current = state as OrderByIdLoaded;
    final savedState = current.copyWith();
    final records = current.order.records ?? [];

    // Validate items
    if (records.isEmpty) {
      emit(OrderByIdError('Please add at least one item'));
      emit(savedState);
      event.completer.complete(false);
      return;
    }

    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      if (record.stkProduct == 0) {
        emit(OrderByIdError('Please select a product for item ${i + 1}'));
        emit(savedState);
        event.completer.complete(false);
        return;
      }
      if (record.stkStorage == 0) {
        emit(OrderByIdError('Please select a storage for item ${i + 1}'));
        emit(savedState);
        event.completer.complete(false);
        return;
      }
    }

    // Validate payment
    final totalPayment = current.cashPayment + current.creditAmount;
    if ((totalPayment - current.grandTotal).abs() > 0.01) {
      emit(OrderByIdError('Total payment must equal grand total. Please adjust payment.'));
      emit(savedState);
      event.completer.complete(false);
      return;
    }

    emit(OrderByIdSaving(current.order));

    try {
      // Determine order type
      final isPurchase = current.order.ordName?.toLowerCase().contains('purchase') ?? true;
      final isSale = current.order.ordName?.toLowerCase().contains('sale') ?? false;

      // Convert records to update format
      final updateRecords = records.map((record) {
        final quantity = double.tryParse(record.stkQuantity ?? "0") ?? 0;
        final purPrice = double.tryParse(record.stkPurPrice ?? "0") ?? 0;
        final salePrice = double.tryParse(record.stkSalePrice ?? "0") ?? 0;

        return {
          "stkID": record.stkId ?? 0, // 0 for new items
          "stkOrder": record.stkOrder ?? current.order.ordId,
          "stkProduct": record.stkProduct,
          "stkEntryType": record.stkEntryType ?? (isPurchase ? "IN" : "OUT"),
          "stkStorage": record.stkStorage,
          "stkQuantity": quantity.toStringAsFixed(3),
          "stkPurPrice": isPurchase ? purPrice.toStringAsFixed(4) : "0.0000",
          "stkSalePrice": isSale ? salePrice.toStringAsFixed(4) : "0.0000",
          // Don't include stkExpiryDate as requested
        };
      }).toList();

      // Prepare account info
      int? accountNumber = current.selectedAccount?.accNumber;
      if (current.creditAmount <= 0) {
        accountNumber = 0; // No credit
      }

      // Prepare the update payload according to API
      final payload = {
        "usrName": event.usrName,
        "ordID": current.order.ordId,
        "ordName": current.order.ordName,
        "ordPersonal": current.selectedSupplier?.perId ?? current.order.perId,
        "ordPersonalName": current.selectedSupplier?.perName ?? current.order.personal,
        "ordxRef": current.order.ordxRef,
        "ordTrnRef": current.order.ordTrnRef,
        "account": accountNumber,
        "amount": current.grandTotal.toStringAsFixed(4), // Use calculated total
        "trnStateText": current.order.trnStateText,
        "ordEntryDate": current.order.ordEntryDate?.toIso8601String(),
        "records": updateRecords,
      };

      print('Update payload: ${payload}'); // Debug log

      final success = await repo.updatePurchaseOrder(
        orderId: current.order.ordId!,
        usrName: event.usrName,
        records: updateRecords,
        orderData: payload,
      );

      if (success) {
        emit(OrderByIdSaved(true, message: 'Order updated successfully'));
        // Turn off edit mode and reload
        emit(current.copyWith(isEditing: false));
        add(LoadOrderByIdEvent(current.order.ordId!));
      } else {
        emit(OrderByIdError('Failed to update order'));
        emit(savedState);
      }

      event.completer.complete(success);
    } catch (e) {
      print('Error updating order: $e'); // Debug log
      emit(OrderByIdError(e.toString()));
      emit(savedState);
      event.completer.complete(false);
    }
  }

  Future<void> _onDeleteOrder(
      DeleteOrderEvent event,
      Emitter<OrderByIdState> emit,
      ) async {
    try {
      if (state is! OrderByIdLoaded) return;

      final current = state as OrderByIdLoaded;
      final savedState = current.copyWith();

      emit(OrderByIdDeleting(current.order));

      final success = await repo.deleteOrder(
        orderId: event.orderId,
        usrName: event.usrName,
        ref: event.ref,
        ordName: event.orderName,
      );

      if (success) {
        emit(OrderByIdDeleted(true, message: 'Order deleted successfully'));
      } else {
        emit(OrderByIdError('Failed to delete order. The order transaction may be verified.'));
        emit(savedState);
      }
    } catch (e) {
      if (e.toString().contains('Authorized')) {
        emit(OrderByIdError('Cannot delete order: The transaction is verified and cannot be deleted.'));
      } else {
        emit(OrderByIdError(e.toString()));
      }

      if (state is OrderByIdLoaded) {
        final current = state as OrderByIdLoaded;
        emit(current);
      }
    }
  }
}