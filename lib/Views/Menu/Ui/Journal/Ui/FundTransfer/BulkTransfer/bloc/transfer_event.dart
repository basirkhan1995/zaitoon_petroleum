part of 'transfer_bloc.dart';

sealed class TransferEvent extends Equatable {
  const TransferEvent();
}

class InitializeTransferEvent extends TransferEvent {
  @override
  List<Object?> get props => [];
}

class AddTransferEntryEvent extends TransferEvent {
  @override
  List<Object?> get props => [];
}

class RemoveTransferEntryEvent extends TransferEvent {
  final int id;
  const RemoveTransferEntryEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateTransferEntryEvent extends TransferEvent {
  final int id;
  final int? accountNumber; // Changed to int
  final String? accountName;
  final String? currency;
  final double? debit;
  final double? credit;
  final String? narration;

  const UpdateTransferEntryEvent({
    required this.id,
    this.accountNumber,
    this.accountName,
    this.currency,
    this.debit,
    this.credit,
    this.narration,
  });

  @override
  List<Object?> get props => [
    id,
    accountNumber,
    accountName,
    currency,
    debit,
    credit,
    narration,
  ];
}

class SelectAccountEvent extends TransferEvent {
  final AccountsModel account;
  const SelectAccountEvent(this.account);

  @override
  List<Object?> get props => [account];
}

class ClearAccountEvent extends TransferEvent {
  @override
  List<Object?> get props => [];
}

class SaveTransferEvent extends TransferEvent {
  final String userName;
  final Completer<String> completer;

  const SaveTransferEvent({
    required this.userName,
    required this.completer,
  });

  @override
  List<Object?> get props => [userName];
}

class ResetTransferEvent extends TransferEvent {
  @override
  List<Object?> get props => [];
}

// Add to transfer_event.dart
class ClearApiErrorEvent extends TransferEvent {
  @override
  List<Object?> get props => [];
}