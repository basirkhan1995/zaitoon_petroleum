import 'package:equatable/equatable.dart';

abstract class TransferEvent extends Equatable {
  const TransferEvent();
}

// initialize
class InitializeTransferEvent extends TransferEvent {
  @override
  List<Object?> get props => [];
}

// Add row
class AddDebitRowEvent extends TransferEvent {
  @override
  List<Object?> get props => [];
}

class AddCreditRowEvent extends TransferEvent {
  @override
  List<Object?> get props => [];
}

// Remove row
class RemoveEntryEvent extends TransferEvent {
  final int id;
  final bool isDebit;

  const RemoveEntryEvent({required this.id, required this.isDebit});

  @override
  List<Object?> get props => [id, isDebit];
}

// Update row
class UpdateEntryEvent extends TransferEvent {
  final int id;
  final bool isDebit;
  final String? accountNumber;
  final String? accountName;
  final String? currency;
  final double? amount;

  const UpdateEntryEvent({
    required this.id,
    required this.isDebit,
    this.accountNumber,
    this.accountName,
    this.currency,
    this.amount,
  });

  @override
  List<Object?> get props =>
      [id, isDebit, accountNumber, accountName, currency, amount];
}

// save
class SaveTransferEvent extends TransferEvent {
  @override
  List<Object?> get props => [];
}
