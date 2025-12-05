class TransferEntry {
  final int rowId;
  final int? accountNumber; // Changed to int
  final String? accountName;
  final String? currency;
  final double debit;
  final double credit;
  final String narration;

  TransferEntry({
    required this.rowId,
    this.accountNumber,
    this.accountName,
    this.currency,
    this.debit = 0.0,
    this.credit = 0.0,
    this.narration = '',
  });

  TransferEntry copyWith({
    int? accountNumber,
    String? accountName,
    String? currency,
    double? debit,
    double? credit,
    String? narration,
  }) {
    return TransferEntry(
      rowId: rowId,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      currency: currency ?? this.currency,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      narration: narration ?? this.narration,
    );
  }

  @override
  String toString() => "[$rowId] $accountName ($accountNumber) - $currency $debit";
}