part of 'fx_bloc.dart';

sealed class FxEvent extends Equatable {
  const FxEvent();
}

class InitializeFxEvent extends FxEvent {
  @override
  List<Object?> get props => [];
}

class AddFxEntryEvent extends FxEvent {
  @override
  List<Object?> get props => [];
}

class RemoveFxEntryEvent extends FxEvent {
  final int id;
  const RemoveFxEntryEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateFxEntryEvent extends FxEvent {
  final int id;
  final int? accountNumber; // Changed to int
  final String? accountName;
  final String? currency;
  final double? debit;
  final double? credit;
  final String? narration;

  const UpdateFxEntryEvent({
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

class SelectFxAccountEvent extends FxEvent {
  final AccountsModel account;
  const SelectFxAccountEvent(this.account);

  @override
  List<Object?> get props => [account];
}

class ClearFxAccountEvent extends FxEvent {
  @override
  List<Object?> get props => [];
}

class SaveFxEvent extends FxEvent {
  final String userName;
  final Completer<String> completer;

  const SaveFxEvent({
    required this.userName,
    required this.completer,
  });

  @override
  List<Object?> get props => [userName];
}

class ResetFxEvent extends FxEvent {
  @override
  List<Object?> get props => [];
}

// Add to transfer_event.dart
class ClearFxApiErrorEvent extends FxEvent {
  @override
  List<Object?> get props => [];
}