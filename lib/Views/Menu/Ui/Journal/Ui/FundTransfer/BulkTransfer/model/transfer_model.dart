class TransferEntry {
  final int rowId;
  final String? accountNumber;
  final String? accountName;
  final String? currency;
  final double amount;

  TransferEntry({
    required this.rowId,
    this.accountNumber,
    this.accountName,
    this.currency,
    this.amount = 0.0,
  });

  TransferEntry copyWith({
    String? accountNumber,
    String? accountName,
    String? currency,
    double? amount,
  }) {
    return TransferEntry(
      rowId: rowId,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
    );
  }

  @override
  String toString() =>
      "[$rowId] $accountName ($accountNumber) - $currency $amount";
}
