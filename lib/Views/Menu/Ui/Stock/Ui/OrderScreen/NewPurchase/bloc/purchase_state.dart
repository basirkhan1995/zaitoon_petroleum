part of 'purchase_bloc.dart';

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
  final List<StorageModel>? storages;

  const PurchaseLoaded({
    required this.items,
    this.supplier,
    this.supplierAccount,
    required this.payment,
    this.storages,
  });

  double get grandTotal {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  double get netBalance {
    if (supplier == null) return 0.0;
    final balance = double.tryParse(supplierAccount?.accAvailBalance?.toAmount() ??"0.0") ?? 0.0;
    return balance + grandTotal - payment;
  }

  int get accountNumber {
    if (supplier == null) return 0;
    return supplierAccount?.accNumber ?? 0;
  }

  PurchaseLoaded copyWith({
    List<PurInvoiceItem>? items,
    AccountsModel? supplierAccount,
    IndividualsModel? supplier,
    double? payment,
    List<StorageModel>? storages,
  }) {
    return PurchaseLoaded(
      items: items ?? this.items,
      supplier: supplier ?? this.supplier,

      payment: payment ?? this.payment,
      storages: storages ?? this.storages,
    );
  }

  @override
  List<Object?> get props => [items, supplier, payment, storages];
}

class PurchaseSaving extends PurchaseLoaded {
  const PurchaseSaving({
    required super.items,
    super.supplier,
    required super.payment,
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