import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/model/storage_model.dart';
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
    on<ResetOrderEvent>(_onReset);
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
      ));
    } catch (e) {
      emit(OrderByIdError(e.toString()));
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
      stkQuantity: event.quantity?.toString() ?? record.stkQuantity,
      stkPurPrice: event.price?.toString() ?? record.stkPurPrice,
      stkStorage: event.storageId ?? record.stkStorage,
    );

    records[event.index] = updatedRecord;

    final updatedOrder = current.order.copyWith(records: records);

    emit(current.copyWith(order: updatedOrder));
  }

  void _onAddItem(
      AddOrderItemEvent event,
      Emitter<OrderByIdState> emit,
      ) {
    if (state is! OrderByIdLoaded) return;

    final current = state as OrderByIdLoaded;
    if (!current.isEditing) return;

    final newRecord = OrderRecords(
      stkProduct: 0,
      stkStorage: current.storages.isNotEmpty ? current.storages.first.stgId : 0,
      stkQuantity: "1",
      stkPurPrice: "0",
      stkSalePrice: "0",
      stkEntryType: "IN",
    );

    // Handle nullable records properly
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
        stkProduct: 0,
        stkStorage: current.storages.isNotEmpty ? current.storages.first.stgId : 0,
        stkQuantity: "1",
        stkPurPrice: "0",
        stkSalePrice: "0",
        stkEntryType: "IN",
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

    // Handle nullable records
    final records = current.order.records ?? [];

    // Validate items
    if (records.isEmpty) {
      emit(OrderByIdError('Please add at least one item'));
      emit(savedState);
      event.completer.complete(false);
      return;
    }

    for (var record in records) {
      if (record.stkProduct == 0 || record.stkStorage == 0) {
        emit(OrderByIdError('Please fill all item details (product and storage)'));
        emit(savedState);
        event.completer.complete(false);
        return;
      }
    }

    emit(OrderByIdSaving(current.order));

    try {
      // Convert records to update format
      final updateRecords = records.map((record) {
        return {
          "stkID": record.stkId,
          "stkProduct": record.stkProduct,
          "stkStorage": record.stkStorage,
          "stkQuantity": record.stkQuantity,
          "stkPurPrice": record.stkPurPrice,
        };
      }).toList();

      final success = await repo.updatePurchaseOrder(
        orderId: current.order.ordId!,
        usrName: event.usrName,
        records: updateRecords,
      );

      if (success) {
        emit(OrderByIdSaved(true, message: 'Order updated successfully'));
        // Reload the updated order
        add(LoadOrderByIdEvent(current.order.ordId!));
      } else {
        emit(OrderByIdError('Failed to update order'));
        emit(savedState);
      }

      event.completer.complete(success);
    } catch (e) {
      emit(OrderByIdError(e.toString()));
      emit(savedState);
      event.completer.complete(false);
    }
  }

  void _onReset(
      ResetOrderEvent event,
      Emitter<OrderByIdState> emit,
      ) {
    if (state is OrderByIdLoaded) {
      final current = state as OrderByIdLoaded;
      emit(current.copyWith(isEditing: false));
    }
  }
}