import 'package:equatable/equatable.dart';

import '../model/transfer_model.dart';

abstract class TransferState extends Equatable {
  const TransferState();
}

class TransferInitialState extends TransferState {
  @override
  List<Object?> get props => [];
}

class TransferLoadedState extends TransferState {
  final List<TransferEntry> debits;
  final List<TransferEntry> credits;

  double get totalDebit =>
      debits.fold(0, (sum, e) => sum + e.amount);

  double get totalCredit =>
      credits.fold(0, (sum, e) => sum + e.amount);

  const TransferLoadedState({
    required this.debits,
    required this.credits,
  });

  TransferLoadedState copyWith({
    List<TransferEntry>? debits,
    List<TransferEntry>? credits,
  }) {
    return TransferLoadedState(
      debits: debits ?? this.debits,
      credits: credits ?? this.credits,
    );
  }

  @override
  List<Object?> get props => [debits, credits];
}

class TransferSavedState extends TransferState {
  @override
  List<Object?> get props => [];
}
