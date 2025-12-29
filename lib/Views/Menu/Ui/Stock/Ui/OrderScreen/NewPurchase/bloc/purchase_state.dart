part of 'purchase_bloc.dart';

enum PaymentMode { cash, credit, mixed }

abstract class PurchaseState extends Equatable {
  const PurchaseState();
}

class PurchaseInitial extends PurchaseState {
  @override
  List<Object> get props => [];
}

class PurchaseLoading extends PurchaseState {
  @override
  List<Object> get props => [];
}

class PurchaseError extends PurchaseState {
  final String message;
  const PurchaseError(this.message);

  @override
  List<Object> get props => [message];
}

class PurchaseLoaded extends PurchaseState {
  final List<PurInvoiceItem> items;
  final AccountsModel? supplierAccount;
  final IndividualsModel? supplier;
  final double payment;
  final PaymentMode paymentMode;
  final List<StorageModel>? storages;

  const PurchaseLoaded({
    required this.items,
    this.supplier,
    this.supplierAccount,
    required this.payment,
    this.paymentMode = PaymentMode.credit,
    this.storages,
  });

  double get grandTotal {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  double get cashPayment {
    if (paymentMode == PaymentMode.cash) {
      return grandTotal;
    } else if (paymentMode == PaymentMode.mixed) {
      return payment;
    }
    return 0.0;
  }

  double get creditAmount {
    if (paymentMode == PaymentMode.credit) {
      return grandTotal;
    } else if (paymentMode == PaymentMode.mixed) {
      return grandTotal - payment;
    }
    return 0.0;
  }

  double get currentBalance {
    if (supplierAccount != null) {
      return double.tryParse(supplierAccount!.accAvailBalance ?? "0.0") ?? 0.0;
    }
    return 0.0;
  }

  double get newBalance {
    return currentBalance + creditAmount;
  }

  PurchaseLoaded copyWith({
    List<PurInvoiceItem>? items,
    AccountsModel? supplierAccount,
    IndividualsModel? supplier,
    double? payment,
    PaymentMode? paymentMode,
    List<StorageModel>? storages,
  }) {
    return PurchaseLoaded(
      items: items ?? this.items,
      supplier: supplier ?? this.supplier,
      supplierAccount: supplierAccount ?? this.supplierAccount,
      payment: payment ?? this.payment,
      paymentMode: paymentMode ?? this.paymentMode,
      storages: storages ?? this.storages,
    );
  }

  @override
  List<Object?> get props => [items, supplier, supplierAccount, payment, paymentMode, storages];
}

class PurchaseSaving extends PurchaseLoaded {
  const PurchaseSaving({
    required super.items,
    super.supplier,
    super.supplierAccount,
    required super.payment,
    super.paymentMode,
    super.storages,
  });
}

class PurchaseSaved extends PurchaseState {
  final bool success;
  final String? invoiceNumber;

  const PurchaseSaved(this.success, {this.invoiceNumber});

  @override
  List<Object?> get props => [success, invoiceNumber];
}