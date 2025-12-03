import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../../../Services/repositories.dart';
import '../../../../../Stakeholders/Ui/Accounts/model/acc_model.dart';
import '../model/transfer_model.dart';
part 'transfer_event.dart';
part 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final Repositories repo;
  TransferBloc(this.repo) : super(TransferInitial()) {
    on<InitializeTransferEvent>(_onInitialize);
    on<AddTransferEntryEvent>(_onAddEntry);
    on<RemoveTransferEntryEvent>(_onRemoveEntry);
    on<UpdateTransferEntryEvent>(_onUpdateEntry);
    on<SaveTransferEvent>(_onSaveTransfer);
    on<ResetTransferEvent>(_onReset);
    on<ClearApiErrorEvent>(_onClearApiError);
  }

  void _onInitialize(InitializeTransferEvent event, Emitter<TransferState> emit) {
    emit(TransferLoadedState(
      entries: [],
      totalDebit: 0.0,
      totalCredit: 0.0,
    ));
  }

  void _onAddEntry(AddTransferEntryEvent event, Emitter<TransferState> emit) {
    if (state is! TransferLoadedState) return;

    final currentState = state as TransferLoadedState;

    // Create new entry with default currency (use first entry's currency or USD)
    final defaultCurrency = currentState.entries.isNotEmpty
        ? currentState.entries.first.currency ?? 'USD'
        : 'USD';

    final newEntry = TransferEntry(
      rowId: DateTime.now().millisecondsSinceEpoch,
      accountNumber: null,
      accountName: '',
      currency: defaultCurrency,
      debit: 0.0,
      credit: 0.0,
      narration: '',
    );

    final updatedEntries = List<TransferEntry>.from(currentState.entries)..add(newEntry);
    _updateStateWithEntries(updatedEntries, emit);
  }

  void _onRemoveEntry(RemoveTransferEntryEvent event, Emitter<TransferState> emit) {
    if (state is TransferLoadedState) {
      final currentState = state as TransferLoadedState;
      final updatedEntries = currentState.entries.where((entry) => entry.rowId != event.id).toList();
      _updateStateWithEntries(updatedEntries, emit);
    }
  }

  void _onUpdateEntry(UpdateTransferEntryEvent event, Emitter<TransferState> emit) {
    if (state is TransferLoadedState) {
      final currentState = state as TransferLoadedState;
      final updatedEntries = currentState.entries.map((entry) {
        if (entry.rowId == event.id) {
          return entry.copyWith(
            accountNumber: event.accountNumber ?? entry.accountNumber,
            accountName: event.accountName ?? entry.accountName,
            currency: event.currency ?? entry.currency,
            debit: event.debit ?? entry.debit,
            credit: event.credit ?? entry.credit,
            narration: event.narration ?? entry.narration,
          );
        }
        return entry;
      }).toList();

      _updateStateWithEntries(updatedEntries, emit);
    }
  }

  Future<void> _onSaveTransfer(SaveTransferEvent event, Emitter<TransferState> emit) async {
    if (state is! TransferLoadedState) {
      event.completer.completeError('Invalid state');
      return;
    }

    final currentState = state as TransferLoadedState;

    // Validate debit = credit
    if (currentState.totalDebit != currentState.totalCredit) {
      final error = 'Debit and Credit totals must be equal';
      emit(TransferApiErrorState(
        error: error,
        errorType: 'validation',
        entries: currentState.entries,
      ));
      event.completer.completeError(error);
      return;
    }

    // Validate at least one entry
    if (currentState.entries.isEmpty) {
      final error = 'Add at least one transfer entry';
      emit(TransferApiErrorState(
        error: error,
        errorType: 'validation',
        entries: currentState.entries,
      ));
      event.completer.completeError(error);
      return;
    }

    // Validate all entries have account
    for (final entry in currentState.entries) {
      if (entry.accountNumber == null) {
        final error = 'All entries must have an account';
        emit(TransferApiErrorState(
          error: error,
          errorType: 'validation',
          entries: currentState.entries,
        ));
        event.completer.completeError(error);
        return;
      }
    }

    // Show saving state
    emit(TransferSavingState(
      entries: currentState.entries,
      totalDebit: currentState.totalDebit,
      totalCredit: currentState.totalCredit,
    ));

    try {
      // Convert entries to API format
      final records = currentState.entries.map((entry) => {
        'account': entry.accountNumber ?? 0,
        'ccy': entry.currency ?? 'USD',
        'debit': entry.debit,
        'credit': entry.credit,
        'narration': entry.narration,
      }).toList();

      // Call API
      final result = await repo.saveBulkTransfer(
        userName: event.userName,
        records: records,
      );

      // Check API response
      final msg = result['msg']?.toString().toLowerCase() ?? '';

      if (msg.contains('success')) {
        // Success - reset form
        emit(TransferSavedState(true, 'Transaction successful'));
        event.completer.complete('success');
      } else {
        // Handle different error types from API
        String errorType = 'failed';
        String errorMessage = msg;

        if (msg.contains('no limit') || msg.contains('insufficient')) {
          errorType = 'no limit';
          errorMessage = 'Insufficient balance or account limit reached';
        } else if (msg.contains('blocked')) {
          errorType = 'blocked';
          errorMessage = 'Account is blocked';
        } else if (msg.contains('diff ccy')) {
          errorType = 'diff ccy';
          errorMessage = 'Currency mismatch in transaction';
        } else if (msg.contains('failed')) {
          errorType = 'failed';
          errorMessage = 'Transaction failed';
        }

        // Return to loaded state with error
        emit(TransferApiErrorState(
          error: errorMessage,
          errorType: errorType,
          entries: currentState.entries,
        ));
        event.completer.completeError(errorMessage);
      }
    } catch (e) {
      // Return to loaded state on error
      emit(TransferApiErrorState(
        error: e.toString(),
        entries: currentState.entries,
      ));
      event.completer.completeError(e.toString());
    }
  }

  void _onClearApiError(ClearApiErrorEvent event, Emitter<TransferState> emit) {
    if (state is TransferApiErrorState) {
      final errorState = state as TransferApiErrorState;
      // Go back to loaded state with preserved entries
      emit(TransferLoadedState(
        entries: errorState.entries,
        totalDebit: errorState.entries.fold(0.0, (sum, entry) => sum + entry.debit),
        totalCredit: errorState.entries.fold(0.0, (sum, entry) => sum + entry.credit),
      ));
    }
  }

  void _onReset(ResetTransferEvent event, Emitter<TransferState> emit) {
    emit(TransferLoadedState(
      entries: [],
      totalDebit: 0.0,
      totalCredit: 0.0,
    ));
  }

  void _updateStateWithEntries(
      List<TransferEntry> entries,
      Emitter<TransferState> emit,
      ) {
    final totalDebit = entries.fold(0.0, (sum, entry) => sum + entry.debit);
    final totalCredit = entries.fold(0.0, (sum, entry) => sum + entry.credit);

    emit(TransferLoadedState(
      entries: entries,
      totalDebit: totalDebit,
      totalCredit: totalCredit,
    ));
  }
}