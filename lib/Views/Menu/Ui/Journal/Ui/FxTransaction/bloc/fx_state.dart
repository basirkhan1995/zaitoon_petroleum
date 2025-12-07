part of 'fx_bloc.dart';

sealed class FxState extends Equatable {
  const FxState();
}

final class FxInitial extends FxState {
  @override
  List<Object> get props => [];
}

final class FxErrorState extends FxState {
  final String error;
  const FxErrorState(this.error);

  @override
  List<Object> get props => [error];
}

final class FxLoadedState extends FxState {
  final String? baseCurrency;
  final String narration;
  final List<TransferEntry> debitEntries;
  final List<TransferEntry> creditEntries;
  final double totalDebitBase;
  final double totalCreditBase;

  const FxLoadedState({
    this.baseCurrency,
    this.narration = '',
    required this.debitEntries,
    required this.creditEntries,
    required this.totalDebitBase,
    required this.totalCreditBase,
  });

  FxLoadedState copyWith({
    String? baseCurrency,
    String? narration,
    List<TransferEntry>? debitEntries,
    List<TransferEntry>? creditEntries,
    double? totalDebitBase,
    double? totalCreditBase,
  }) {
    return FxLoadedState(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      narration: narration ?? this.narration,
      debitEntries: debitEntries ?? this.debitEntries,
      creditEntries: creditEntries ?? this.creditEntries,
      totalDebitBase: totalDebitBase ?? this.totalDebitBase,
      totalCreditBase: totalCreditBase ?? this.totalCreditBase,
    );
  }

  @override
  List<Object> get props => [
    baseCurrency ?? '',
    narration,
    debitEntries,
    creditEntries,
    totalDebitBase,
    totalCreditBase,
  ];
}

final class FxApiErrorState extends FxState {
  final String error;
  final String? errorType;
  final String? baseCurrency;
  final String narration;
  final List<TransferEntry> debitEntries;
  final List<TransferEntry> creditEntries;
  final double totalDebitBase;
  final double totalCreditBase;

  const FxApiErrorState({
    required this.error,
    this.errorType,
    required this.baseCurrency,
    required this.narration,
    required this.debitEntries,
    required this.creditEntries,
    required this.totalDebitBase,
    required this.totalCreditBase,
  });

  @override
  List<Object> get props => [
    error,
    errorType ?? '',
    baseCurrency ?? '',
    narration,
    debitEntries,
    creditEntries,
    totalDebitBase,
    totalCreditBase,
  ];
}

final class FxSavingState extends FxLoadedState {
  const FxSavingState({
    super.baseCurrency,
    super.narration,
    required super.debitEntries,
    required super.creditEntries,
    required super.totalDebitBase,
    required super.totalCreditBase,
  });

  @override
  List<Object> get props => [
    baseCurrency ?? '',
    narration,
    debitEntries,
    creditEntries,
    totalDebitBase,
    totalCreditBase,
  ];
}

final class FxSavedState extends FxState {
  final bool success;
  final String reference;

  const FxSavedState(this.success, this.reference);

  @override
  List<Object> get props => [success, reference];
}