part of 'order_by_id_bloc.dart';

abstract class OrderByIdState extends Equatable {
  const OrderByIdState();
}

class OrderByIdInitial extends OrderByIdState {
  @override
  List<Object> get props => [];
}

class OrderByIdLoading extends OrderByIdState {
  @override
  List<Object> get props => [];
}

class OrderByIdError extends OrderByIdState {
  final String message;
  const OrderByIdError(this.message);

  @override
  List<Object> get props => [message];
}

class OrderByIdLoaded extends OrderByIdState {
  final OrderByIdModel order;
  final List<StorageModel> storages;
  final Map<int, String> productNames;
  final Map<int, String> storageNames;
  final bool isEditing;

  const OrderByIdLoaded({
    required this.order,
    required this.storages,
    required this.productNames,
    required this.storageNames,
    this.isEditing = false,
  });

  double get grandTotal {
    if (order.records == null) return 0.0;
    return order.records!.fold(0.0, (sum, record) {
      final qty = double.tryParse(record.stkQuantity ?? "0") ?? 0;
      final price = double.tryParse(record.stkPurPrice ?? "0") ?? 0;
      return sum + (qty * price);
    });
  }

  OrderByIdLoaded copyWith({
    OrderByIdModel? order,
    List<StorageModel>? storages,
    Map<int, String>? productNames,
    Map<int, String>? storageNames,
    bool? isEditing,
  }) {
    return OrderByIdLoaded(
      order: order ?? this.order,
      storages: storages ?? this.storages,
      productNames: productNames ?? this.productNames,
      storageNames: storageNames ?? this.storageNames,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  @override
  List<Object?> get props => [
    order,
    storages,
    productNames,
    storageNames,
    isEditing,
  ];
}

class OrderByIdSaving extends OrderByIdState {
  final OrderByIdModel order;

  const OrderByIdSaving(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderByIdDeleting extends OrderByIdState {
  final OrderByIdModel order;

  const OrderByIdDeleting(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderByIdSaved extends OrderByIdState {
  final bool success;
  final String message;

  const OrderByIdSaved(this.success, {this.message = ''});

  @override
  List<Object?> get props => [success, message];
}

class OrderByIdDeleted extends OrderByIdState {
  final bool success;
  final String message;

  const OrderByIdDeleted(this.success, {this.message = ''});

  @override
  List<Object?> get props => [success, message];
}