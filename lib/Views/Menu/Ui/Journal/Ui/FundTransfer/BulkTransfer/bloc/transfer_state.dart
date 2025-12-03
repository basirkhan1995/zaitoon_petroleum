part of 'transfer_bloc.dart';

sealed class TransferState extends Equatable {
  const TransferState();
}

final class TransferInitial extends TransferState {
  @override
  List<Object> get props => [];
}

final class TransferErrorState extends TransferState {
  final String error;
  const TransferErrorState(this.error);

  @override
  List<Object> get props => [error];
}

// Add this state to transfer_state.dart
final class TransferApiErrorState extends TransferState {
  final String error;
  final String? errorType; // 'no limit', 'blocked', 'diff ccy', etc.
  final List<TransferEntry> entries; // Keep entries to preserve data

  const TransferApiErrorState({
    required this.error,
    this.errorType,
    required this.entries,
  });

  @override
  List<Object> get props => [error, errorType ?? '', entries];
}

final class TransferLoadingState extends TransferState {
  @override
  List<Object> get props => [];
}

final class TransferLoadedState extends TransferState {
  final List<TransferEntry> entries;
  final double totalDebit;
  final double totalCredit;
  final AccountsModel? selectedAccount;

  const TransferLoadedState({
    required this.entries,
    required this.totalDebit,
    required this.totalCredit,
    this.selectedAccount,
  });

  TransferLoadedState copyWith({
    List<TransferEntry>? entries,
    double? totalDebit,
    double? totalCredit,
    AccountsModel? selectedAccount,
  }) {
    return TransferLoadedState(
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

final class TransferSavingState extends TransferLoadedState {
  const TransferSavingState({
    required super.entries,
    required super.totalDebit,
    required super.totalCredit,
    super.selectedAccount,
  });

  @override
  List<Object> get props => [entries, totalDebit, totalCredit];
}

final class TransferSavedState extends TransferState {
  final bool success;
  final String reference;

  const TransferSavedState(this.success, this.reference);

  @override
  List<Object> get props => [success, reference];
}