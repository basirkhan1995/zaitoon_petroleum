part of 'sale_invoice_bloc.dart';

enum PaymentMode { cash, credit, mixed }

abstract class SaleInvoiceState extends Equatable {
  const SaleInvoiceState();
}

class SaleInvoiceInitial extends SaleInvoiceState {
  @override
  List<Object> get props => [];
}

class SaleInvoiceError extends SaleInvoiceState {
  final String message;
  const SaleInvoiceError(this.message);

  @override
  List<Object> get props => [message];
}

class SaleInvoiceLoaded extends SaleInvoiceState {
  final List<SaleInvoiceItem> items;
  final AccountsModel? customerAccount;
  final IndividualsModel? customer;
  final double payment;
  final PaymentMode paymentMode;
  final List<StorageModel>? storages;

  const SaleInvoiceLoaded({
    required this.items,
    this.customer,
    this.customerAccount,
    required this.payment,
    this.paymentMode = PaymentMode.cash,
    this.storages,
  });

  // TotalDailyTxn purchase cost (total cost price)
  double get totalPurchaseCost {
    return items.fold(0.0, (sum, item) => sum + item.totalPurchase);
  }

  // TotalDailyTxn sale amount (total selling price)
  double get totalSaleAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalSale);
  }

  // Grand total (use sale amount for the invoice total)
  double get grandTotal {
    return totalSaleAmount;
  }

  // Profit calculation
  double get totalProfit {
    return totalSaleAmount - totalPurchaseCost;
  }

  // Profit percentage
  double get profitPercentage {
    if (totalPurchaseCost > 0) {
      return (totalProfit / totalPurchaseCost) * 100;
    }
    return 0.0;
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
    if (customerAccount != null) {
      return double.tryParse(customerAccount!.accAvailBalance ?? "0.0") ?? 0.0;
    }
    return 0.0;
  }

  double get newBalance {
    return currentBalance + creditAmount;
  }

  bool get isFormValid {
    if (customer == null) return false;

    if (paymentMode != PaymentMode.cash && customerAccount == null) return false;

    if (items.isEmpty) return false;

    for (var item in items) {
      if (item.productId.isEmpty ||
          item.productName.isEmpty ||
          item.storageId == 0 ||
          item.storageName.isEmpty ||
          item.salePrice == null ||
          item.salePrice! <= 0 ||
          item.qty <= 0) {
        return false;
      }
    }

    if (paymentMode == PaymentMode.mixed) {
      if (payment <= 0 || payment >= grandTotal) return false;
    }

    return true;
  }

  SaleInvoiceLoaded copyWith({
    List<SaleInvoiceItem>? items,
    AccountsModel? customerAccount,
    IndividualsModel? customer,
    double? payment,
    PaymentMode? paymentMode,
    List<StorageModel>? storages,
  }) {
    return SaleInvoiceLoaded(
      items: items ?? this.items,
      customer: customer ?? this.customer,
      customerAccount: customerAccount ?? this.customerAccount,
      payment: payment ?? this.payment,
      paymentMode: paymentMode ?? this.paymentMode,
      storages: storages ?? this.storages,
    );
  }

  @override
  List<Object?> get props => [items, customer, customerAccount, payment, paymentMode, storages];
}
class SaleInvoiceSaving extends SaleInvoiceLoaded {
  const SaleInvoiceSaving({
    required super.items,
    super.customer,
    super.customerAccount,
    required super.payment,
    super.paymentMode,
    super.storages,
  });
}

class SaleInvoiceSaved extends SaleInvoiceState {
  final bool success;
  final String? invoiceNumber;

  const SaleInvoiceSaved(this.success, {this.invoiceNumber});

  @override
  List<Object?> get props => [success, invoiceNumber];
}