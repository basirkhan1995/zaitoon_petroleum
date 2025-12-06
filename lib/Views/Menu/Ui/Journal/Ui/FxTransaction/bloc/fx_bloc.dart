import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../../../Services/localization_services.dart';
import '../../../../../../../../Services/repositories.dart';
import '../../../../Stakeholders/Ui/Accounts/model/acc_model.dart';
import '../model/fx_model.dart';
part 'fx_event.dart';
part 'fx_state.dart';

class FxBloc extends Bloc<FxEvent, FxState> {
  final Repositories repo;
  FxBloc(this.repo) : super(FxInitial()) {
    on<InitializeFxEvent>(_onInitialize);
    on<AddFxEntryEvent>(_onAddEntry);
    on<RemoveFxEntryEvent>(_onRemoveEntry);
    on<UpdateFxEntryEvent>(_onUpdateEntry);
    on<SaveFxEvent>(_onSaveTransfer);
    on<ResetFxEvent>(_onReset);
    on<ClearFxApiErrorEvent>(_onClearApiError);
  }

  void _onInitialize(InitializeFxEvent event, Emitter<FxState> emit) {
    emit(FxLoadedState(
      entries: [],
      totalDebit: 0.0,
      totalCredit: 0.0,
    ));
  }

  void _onAddEntry(AddFxEntryEvent event, Emitter<FxState> emit) {
    if (state is! FxLoadedState) return;

    final currentState = state as FxLoadedState;

    final newEntry = TransferEntry(
      rowId: DateTime.now().millisecondsSinceEpoch,
      accountNumber: null,
      accountName: '',
      currency: event.initialCurrency ?? 'USD',
      debit: 0.0,
      credit: 0.0,
      narration: '',
    );

    final updatedEntries = List<TransferEntry>.from(currentState.entries)..add(newEntry);
    _updateStateWithEntries(updatedEntries, emit);
  }

  void _onRemoveEntry(RemoveFxEntryEvent event, Emitter<FxState> emit) {
    if (state is FxLoadedState) {
      final currentState = state as FxLoadedState;
      final updatedEntries = currentState.entries.where((entry) => entry.rowId != event.id).toList();
      _updateStateWithEntries(updatedEntries, emit);
    }
  }

  void _onUpdateEntry(UpdateFxEntryEvent event, Emitter<FxState> emit) {
    if (state is FxLoadedState) {
      final currentState = state as FxLoadedState;
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

  // In TransferBloc - update the _onSaveTransfer method
  Future<void> _onSaveTransfer(SaveFxEvent event, Emitter<FxState> emit) async {
    final tr = localizationService.loc;
    if (state is! FxLoadedState) {
      event.completer.completeError('Invalid state');
      return;
    }

    final currentState = state as FxLoadedState;

    // Validate debit = credit
    if (currentState.totalDebit != currentState.totalCredit) {
      final error = tr.debitNoEqualCredit;
      emit(FxApiErrorState(
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
      emit(FxApiErrorState(
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
        emit(FxApiErrorState(
          error: error,
          errorType: 'validation',
          entries: currentState.entries,
        ));
        event.completer.completeError(error);
        return;
      }
    }

    // Show saving state
    emit(FxSavingState(
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
        // Success - reset form with fresh state
        final reference = result['reference']?.toString() ?? 'Transaction successful';
        emit(FxSavedState(true, reference));

        // Reset to fresh state after showing success
        await Future.delayed(const Duration(milliseconds: 500)); // Small delay for UX
        emit(FxLoadedState(
          entries: [],
          totalDebit: 0.0,
          totalCredit: 0.0,
        ));

        event.completer.complete('success');
      } else {
        // Handle different error types from API
        String errorType = 'failed';
        String errorMessage = msg;

        if (msg.contains('no limit') || msg.contains('insufficient')) {
          errorType = 'no limit';
          errorMessage = tr.accountLimitMessage;
        } else if (msg.contains('blocked')) {
          errorType = 'blocked';
          errorMessage = tr.blockedAccountMessage;
        } else if (msg.contains('diff ccy')) {
          errorType = 'diff ccy';
          errorMessage = tr.currencyMismatchMessage;
        } else if (msg.contains('failed')) {
          errorType = 'failed';
          errorMessage = tr.transactionFailedTitle;
        }

        // Return to loaded state with error
        emit(FxApiErrorState(
          error: errorMessage,
          errorType: errorType,
          entries: currentState.entries,
        ));
        event.completer.completeError(errorMessage);
      }
    } catch (e) {
      // Return to loaded state on error
      emit(FxApiErrorState(
        error: e.toString(),
        entries: currentState.entries,
      ));
      event.completer.completeError(e.toString());
    }
  }

  void _onClearApiError(ClearFxApiErrorEvent event, Emitter<FxState> emit) {
    if (state is FxApiErrorState) {
      final errorState = state as FxApiErrorState;
      // Go back to loaded state with preserved entries
      emit(FxLoadedState(
        entries: errorState.entries,
        totalDebit: errorState.entries.fold(0.0, (sum, entry) => sum + entry.debit),
        totalCredit: errorState.entries.fold(0.0, (sum, entry) => sum + entry.credit),
      ));
    }
  }

  void _onReset(ResetFxEvent event, Emitter<FxState> emit) {
    emit(FxLoadedState(
      entries: [],
      totalDebit: 0.0,
      totalCredit: 0.0,
    ));
  }

  void _updateStateWithEntries(
      List<TransferEntry> entries,
      Emitter<FxState> emit,
      ) {
    final totalDebit = entries.fold(0.0, (sum, entry) => sum + entry.debit);
    final totalCredit = entries.fold(0.0, (sum, entry) => sum + entry.credit);

    emit(FxLoadedState(
      entries: entries,
      totalDebit: totalDebit,
      totalCredit: totalCredit,
    ));
  }
}