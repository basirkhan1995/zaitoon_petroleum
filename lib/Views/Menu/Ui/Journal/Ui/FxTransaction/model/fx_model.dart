import 'package:equatable/equatable.dart';

class TransferEntry extends Equatable {
  final int rowId;
  final int? accountNumber;
  final String? accountName;
  final String? currency;
  final double amount;
  final bool isDebit;
  final String? narration;
  final String? exchangeRate;
  const TransferEntry({
    required this.rowId,
    this.accountNumber,
    this.accountName,
    this.currency,
    this.amount = 0.0,
    this.isDebit = true,
    this.narration = '',
    this.exchangeRate,
  });

  TransferEntry copyWith({
    int? accountNumber,
    String? accountName,
    String? currency,
    double? amount,
    bool? isDebit,
    String? narration,
    String? exchangeRate,
  }) {
    return TransferEntry(
      rowId: rowId,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      isDebit: isDebit ?? this.isDebit,
      narration: narration ?? this.narration,
      exchangeRate: exchangeRate ?? this.exchangeRate,
    );
  }

  @override
  List<Object?> get props => [
    rowId,
    accountNumber,
    accountName,
    currency,
    amount,
    isDebit,
    narration,
    exchangeRate
  ];
}