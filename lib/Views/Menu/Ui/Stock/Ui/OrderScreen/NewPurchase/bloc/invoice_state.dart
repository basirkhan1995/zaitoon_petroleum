part of 'invoice_bloc.dart';

enum PaymentMode { cash, credit, mixed }

abstract class InvoiceState extends Equatable {
  const InvoiceState();
}

class InvoiceInitial extends InvoiceState {
  @override
  List<Object> get props => [];
}

class PurchaseLoading extends InvoiceState {
  @override
  List<Object> get props => [];
}

class InvoiceError extends InvoiceState {
  final String message;
  const InvoiceError(this.message);

  @override
  List<Object> get props => [message];
}

class InvoiceLoaded extends InvoiceState {
  final List<InvoiceItem> items;
  final AccountsModel? supplierAccount;
  final IndividualsModel? supplier;
  final double payment;
  final PaymentMode paymentMode;
  final List<StorageModel>? storages;

  const InvoiceLoaded({
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

  InvoiceLoaded copyWith({
    List<InvoiceItem>? items,
    AccountsModel? supplierAccount,
    IndividualsModel? supplier,
    double? payment,
    PaymentMode? paymentMode,
    List<StorageModel>? storages,
  }) {
    return InvoiceLoaded(
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

class InvoiceSaving extends InvoiceLoaded {
  const InvoiceSaving({
    required super.items,
    super.supplier,
    super.supplierAccount,
    required super.payment,
    super.paymentMode,
    super.storages,
  });
}

class InvoiceSaved extends InvoiceState {
  final bool success;
  final String? invoiceNumber;

  const InvoiceSaved(this.success, {this.invoiceNumber});

  @override
  List<Object?> get props => [success, invoiceNumber];
}