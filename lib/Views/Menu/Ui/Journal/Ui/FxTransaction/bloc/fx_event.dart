part of 'fx_bloc.dart';

sealed class FxEvent extends Equatable {
  const FxEvent();
}

class InitializeFxEvent extends FxEvent {
  @override
  List<Object?> get props => [];
}

class AddFxEntryEvent extends FxEvent {
  final bool isDebit;

  const AddFxEntryEvent({required this.isDebit});

  @override
  List<Object?> get props => [isDebit];
}

class RemoveFxEntryEvent extends FxEvent {
  final int id;
  final bool isDebit;

  const RemoveFxEntryEvent(this.id, {required this.isDebit});

  @override
  List<Object?> get props => [id, isDebit];
}


class UpdateBaseCurrencyEvent extends FxEvent {
  final String? baseCurrency;

  const UpdateBaseCurrencyEvent(this.baseCurrency);

  @override
  List<Object?> get props => [baseCurrency];
}

class UpdateNarrationEvent extends FxEvent {
  final String narration;

  const UpdateNarrationEvent(this.narration);

  @override
  List<Object?> get props => [narration];
}

class UpdateFxEntryEvent extends FxEvent {
  final int id;
  final bool isDebit;
  final int? accountNumber;
  final String? accountName;
  final String? currency;
  final double? amount;
  final String? exchangeRate;
  final String? convertedAmount;
  final String? narration;

  const UpdateFxEntryEvent({
    required this.id,
    required this.isDebit,
    this.accountNumber,
    this.accountName,
    this.convertedAmount,
    this.currency,
    this.exchangeRate,
    this.amount,
    this.narration,
  });

  @override
  List<Object?> get props => [
    id,
    isDebit,
    accountNumber,
    accountName,
    currency,
    exchangeRate,
    convertedAmount,
    amount,
    narration,
  ];
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

class ClearFxApiErrorEvent extends FxEvent {
  @override
  List<Object?> get props => [];
}