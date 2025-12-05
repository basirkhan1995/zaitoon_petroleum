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

// Add this state to transfer_state.dart
final class FxApiErrorState extends FxState {
  final String error;
  final String? errorType; // 'no limit', 'blocked', 'diff ccy', etc.
  final List<TransferEntry> entries; // Keep entries to preserve data

  const FxApiErrorState({
    required this.error,
    this.errorType,
    required this.entries,
  });

  @override
  List<Object> get props => [error, errorType ?? '', entries];
}

final class FxLoadingState extends FxState {
  @override
  List<Object> get props => [];
}

final class FxLoadedState extends FxState {
  final List<TransferEntry> entries;
  final double totalDebit;
  final double totalCredit;
  final AccountsModel? selectedAccount;

  const FxLoadedState({
    required this.entries,
    required this.totalDebit,
    required this.totalCredit,
    this.selectedAccount,
  });

  FxLoadedState copyWith({
    List<TransferEntry>? entries,
    double? totalDebit,
    double? totalCredit,
    AccountsModel? selectedAccount,
  }) {
    return FxLoadedState(
      entries: entries ?? this.entries,
      totalDebit: totalDebit ?? this.totalDebit,
      totalCredit: totalCredit ?? this.totalCredit,
      selectedAccount: selectedAccount ?? this.selectedAccount,
    );
  }

  @override
  List<Object> get props => [
    entries,
    totalDebit,
    totalCredit,
    selectedAccount?.accNumber ?? 0,
  ];
}

final class FxSavingState extends FxLoadedState {
  const FxSavingState({
    required super.entries,
    required super.totalDebit,
    required super.totalCredit,
    super.selectedAccount,
  });

  @override
  List<Object> get props => [entries, totalDebit, totalCredit];
}

final class FxSavedState extends FxState {
  final bool success;
  final String reference;

  const FxSavedState(this.success, this.reference);

  @override
  List<Object> get props => [success, reference];
}