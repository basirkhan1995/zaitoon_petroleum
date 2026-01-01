part of 'purchase_invoice_bloc.dart';

enum PaymentMode { cash, credit, mixed }

abstract class PurchaseInvoiceState extends Equatable {
  const PurchaseInvoiceState();
}

class InvoiceInitial extends PurchaseInvoiceState {
  @override
  List<Object> get props => [];
}

class PurchaseLoading extends PurchaseInvoiceState {
  @override
  List<Object> get props => [];
}

class InvoiceError extends PurchaseInvoiceState {
  final String message;
  const InvoiceError(this.message);

  @override
  List<Object> get props => [message];
}

class PurchaseInvoiceLoaded extends PurchaseInvoiceState {
  final List<PurchaseInvoiceItem> items;
  final AccountsModel? supplierAccount;
  final IndividualsModel? supplier;
  final double payment;
  final PaymentMode paymentMode;
  final List<StorageModel>? storages;

  const PurchaseInvoiceLoaded({
    required this.items,
    this.supplier,
    this.supplierAccount,
    required this.payment,
    this.paymentMode = PaymentMode.credit,
    this.storages,
  });

  double get grandTotal {
    return items.fold(0.0, (sum, item) => sum + item.totalPurchase);
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

  PurchaseInvoiceLoaded copyWith({
    List<PurchaseInvoiceItem>? items,
    AccountsModel? supplierAccount,
    IndividualsModel? supplier,
    double? payment,
    PaymentMode? paymentMode,
    List<StorageModel>? storages,
  }) {
    return PurchaseInvoiceLoaded(
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

class InvoiceSaving extends PurchaseInvoiceLoaded {
  const InvoiceSaving({
    required super.items,
    super.supplier,
    super.supplierAccount,
    required super.payment,
    super.paymentMode,
    super.storages,
  });
}

class InvoiceSaved extends PurchaseInvoiceState {
  final bool success;
  final String? invoiceNumber;

  const InvoiceSaved(this.success, {this.invoiceNumber});

  @override
  List<Object?> get props => [success, invoiceNumber];
}