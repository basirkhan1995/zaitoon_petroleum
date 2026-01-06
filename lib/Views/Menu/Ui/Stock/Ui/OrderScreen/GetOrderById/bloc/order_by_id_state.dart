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
  final IndividualsModel? selectedSupplier;
  final AccountsModel? selectedAccount;
  final double cashPayment;
  final double creditAmount;

  const OrderByIdLoaded({
    required this.order,
    required this.storages,
    required this.productNames,
    required this.storageNames,
    this.isEditing = false,
    this.selectedSupplier,
    this.selectedAccount,
    this.cashPayment = 0.0,
    this.creditAmount = 0.0,
  });

  double get grandTotal {
    if (order.records == null) return 0.0;
    final isPurchase = order.ordName?.toLowerCase().contains('purchase') ?? true;

    return order.records!.fold(0.0, (sum, record) {
      final qty = double.tryParse(record.stkQuantity ?? "0") ?? 0;
      double price;

      if (isPurchase) {
        price = double.tryParse(record.stkPurPrice ?? "0") ?? 0;
      } else {
        price = double.tryParse(record.stkSalePrice ?? "0") ?? 0;
      }

      return sum + (qty * price);
    });
  }

  // This is for validation - total of cash + credit should equal grandTotal
  double get totalPayment => cashPayment + creditAmount;

  bool get isPaymentValid => (totalPayment - grandTotal).abs() < 0.01;

  // CORRECTED: Use the actual cashPayment and creditAmount fields, not calculations
  PaymentMode get paymentMode {
    if (creditAmount <= 0) {
      return PaymentMode.cash;
    } else if (cashPayment <= 0) {
      return PaymentMode.credit;
    } else {
      return PaymentMode.mixed;
    }
  }

  bool get isCashOnly => paymentMode == PaymentMode.cash;
  bool get isCreditOnly => paymentMode == PaymentMode.credit;
  bool get isMixed => paymentMode == PaymentMode.mixed;

  // Helper to show the actual payment breakdown
  String get paymentSummary {
    if (isCashOnly) {
      return 'Cash: ${cashPayment.toAmount()}';
    } else if (isCreditOnly) {
      return 'Credit: ${creditAmount.toAmount()}';
    } else {
      return 'Cash: ${cashPayment.toAmount()}, Credit: ${creditAmount.toAmount()}';
    }
  }

  OrderByIdLoaded copyWith({
    OrderByIdModel? order,
    List<StorageModel>? storages,
    Map<int, String>? productNames,
    Map<int, String>? storageNames,
    bool? isEditing,
    IndividualsModel? selectedSupplier,
    AccountsModel? selectedAccount,
    double? cashPayment,
    double? creditAmount,
  }) {
    return OrderByIdLoaded(
      order: order ?? this.order,
      storages: storages ?? this.storages,
      productNames: productNames ?? this.productNames,
      storageNames: storageNames ?? this.storageNames,
      isEditing: isEditing ?? this.isEditing,
      selectedSupplier: selectedSupplier ?? this.selectedSupplier,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      cashPayment: cashPayment ?? this.cashPayment,
      creditAmount: creditAmount ?? this.creditAmount,
    );
  }

  @override
  List<Object?> get props => [
    order,
    storages,
    productNames,
    storageNames,
    isEditing,
    selectedSupplier,
    selectedAccount,
    cashPayment,
    creditAmount,
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

enum PaymentMode { cash, credit, mixed }