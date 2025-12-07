import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../../../Services/repositories.dart';
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
    on<UpdateBaseCurrencyEvent>(_onUpdateBaseCurrency);
    on<UpdateNarrationEvent>(_onUpdateNarration);
    on<SaveFxEvent>(_onSaveTransfer);
    on<ResetFxEvent>(_onReset);
    on<ClearFxApiErrorEvent>(_onClearApiError);
  }

  void _onInitialize(InitializeFxEvent event, Emitter<FxState> emit) {
    emit(FxLoadedState(
      baseCurrency: null,
      narration: '',
      debitEntries: [],
      creditEntries: [],
      totalDebitBase: 0.0,
      totalCreditBase: 0.0,
    ));
  }

  void _onAddEntry(AddFxEntryEvent event, Emitter<FxState> emit) {
    if (state is! FxLoadedState && state is! FxSavingState && state is! FxApiErrorState) return;

    final currentState = state;
    List<TransferEntry> currentDebitEntries = [];
    List<TransferEntry> currentCreditEntries = [];
    String? currentBaseCurrency;
    String currentNarration = '';
    double currentTotalDebitBase = 0.0;
    double currentTotalCreditBase = 0.0;

    if (currentState is FxLoadedState) {
      currentDebitEntries = currentState.debitEntries;
      currentCreditEntries = currentState.creditEntries;
      currentBaseCurrency = currentState.baseCurrency;
      currentNarration = currentState.narration;
      currentTotalDebitBase = currentState.totalDebitBase;
      currentTotalCreditBase = currentState.totalCreditBase;
    } else if (currentState is FxSavingState) {
      currentDebitEntries = currentState.debitEntries;
      currentCreditEntries = currentState.creditEntries;
      currentBaseCurrency = currentState.baseCurrency;
      currentNarration = currentState.narration;
      currentTotalDebitBase = currentState.totalDebitBase;
      currentTotalCreditBase = currentState.totalCreditBase;
    } else if (currentState is FxApiErrorState) {
      currentDebitEntries = currentState.debitEntries;
      currentCreditEntries = currentState.creditEntries;
      currentBaseCurrency = currentState.baseCurrency;
      currentNarration = currentState.narration;
      currentTotalDebitBase = currentState.totalDebitBase;
      currentTotalCreditBase = currentState.totalCreditBase;
    }

    final newEntry = TransferEntry(
      rowId: DateTime.now().millisecondsSinceEpoch,
      accountNumber: null,
      accountName: '',
      currency: null,
      amount: 0.0,
      isDebit: event.isDebit,
      narration: '',
    );

    if (event.isDebit) {
      final updatedEntries = List<TransferEntry>.from(currentDebitEntries)..add(newEntry);
      emit(FxLoadedState(
        baseCurrency: currentBaseCurrency,
        narration: currentNarration,
        debitEntries: updatedEntries,
        creditEntries: currentCreditEntries,
        totalDebitBase: currentTotalDebitBase,
        totalCreditBase: currentTotalCreditBase,
      ));
    } else {
      final updatedEntries = List<TransferEntry>.from(currentCreditEntries)..add(newEntry);
      emit(FxLoadedState(
        baseCurrency: currentBaseCurrency,
        narration: currentNarration,
        debitEntries: currentDebitEntries,
        creditEntries: updatedEntries,
        totalDebitBase: currentTotalDebitBase,
        totalCreditBase: currentTotalCreditBase,
      ));
    }
  }

  void _onRemoveEntry(RemoveFxEntryEvent event, Emitter<FxState> emit) {
    if (state is! FxLoadedState && state is! FxSavingState && state is! FxApiErrorState) return;

    final currentState = state;
    List<TransferEntry> currentDebitEntries = [];
    List<TransferEntry> currentCreditEntries = [];
    String? currentBaseCurrency;
    String currentNarration = '';
    double currentTotalDebitBase = 0.0;
    double currentTotalCreditBase = 0.0;

    if (currentState is FxLoadedState) {
      currentDebitEntries = currentState.debitEntries;
      currentCreditEntries = currentState.creditEntries;
      currentBaseCurrency = currentState.baseCurrency;
      currentNarration = currentState.narration;
      currentTotalDebitBase = currentState.totalDebitBase;
      currentTotalCreditBase = currentState.totalCreditBase;
    } else if (currentState is FxSavingState) {
      currentDebitEntries = currentState.debitEntries;
      currentCreditEntries = currentState.creditEntries;
      currentBaseCurrency = currentState.baseCurrency;
      currentNarration = currentState.narration;
      currentTotalDebitBase = currentState.totalDebitBase;
      currentTotalCreditBase = currentState.totalCreditBase;
    } else if (currentState is FxApiErrorState) {
      currentDebitEntries = currentState.debitEntries;
      currentCreditEntries = currentState.creditEntries;
      currentBaseCurrency = currentState.baseCurrency;
      currentNarration = currentState.narration;
      currentTotalDebitBase = currentState.totalDebitBase;
      currentTotalCreditBase = currentState.totalCreditBase;
    }

    if (event.isDebit) {
      final updatedEntries = currentDebitEntries
          .where((entry) => entry.rowId != event.id)
          .toList();
      emit(FxLoadedState(
        baseCurrency: currentBaseCurrency,
        narration: currentNarration,
        debitEntries: updatedEntries,
        creditEntries: currentCreditEntries,
        totalDebitBase: currentTotalDebitBase,
        totalCreditBase: currentTotalCreditBase,
      ));
    } else {
      final updatedEntries = currentCreditEntries
          .where((entry) => entry.rowId != event.id)
          .toList();
      emit(FxLoadedState(
        baseCurrency: currentBaseCurrency,
        narration: currentNarration,
        debitEntries: currentDebitEntries,
        creditEntries: updatedEntries,
        totalDebitBase: currentTotalDebitBase,
        totalCreditBase: currentTotalCreditBase,
      ));
    }
  }

  void _onUpdateEntry(UpdateFxEntryEvent event, Emitter<FxState> emit) {
    if (state is! FxLoadedState && state is! FxSavingState && state is! FxApiErrorState) return;

    final currentState = state;
    List<TransferEntry> currentDebitEntries = [];
    List<TransferEntry> currentCreditEntries = [];
    String? currentBaseCurrency;
    String currentNarration = '';
    double currentTotalDebitBase = 0.0;
    double currentTotalCreditBase = 0.0;

    if (currentState is FxLoadedState) {
      currentDebitEntries = currentState.debitEntries;
      currentCreditEntries = currentState.creditEntries;
      currentBaseCurrency = currentState.baseCurrency;
      currentNarration = currentState.narration;
      currentTotalDebitBase = currentState.totalDebitBase;
      currentTotalCreditBase = currentState.totalCreditBase;
    } else if (currentState is FxSavingState) {
      currentDebitEntries = currentState.debitEntries;
      currentCreditEntries = currentState.creditEntries;
      currentBaseCurrency = currentState.baseCurrency;
      currentNarration = currentState.narration;
      currentTotalDebitBase = currentState.totalDebitBase;
      currentTotalCreditBase = currentState.totalCreditBase;
    } else if (currentState is FxApiErrorState) {
      currentDebitEntries = currentState.debitEntries;
      currentCreditEntries = currentState.creditEntries;
      currentBaseCurrency = currentState.baseCurrency;
      currentNarration = currentState.narration;
      currentTotalDebitBase = currentState.totalDebitBase;
      currentTotalCreditBase = currentState.totalCreditBase;
    }

    if (event.isDebit) {
      final updatedEntries = currentDebitEntries.map((entry) {
        if (entry.rowId == event.id) {
          return entry.copyWith(
            accountNumber: event.accountNumber ?? entry.accountNumber,
            accountName: event.accountName ?? entry.accountName,
            currency: event.currency ?? entry.currency,
            amount: event.amount ?? entry.amount,
            narration: event.narration ?? entry.narration,
          );
        }
        return entry;
      }).toList();
      emit(FxLoadedState(
        baseCurrency: currentBaseCurrency,
        narration: currentNarration,
        debitEntries: updatedEntries,
        creditEntries: currentCreditEntries,
        totalDebitBase: currentTotalDebitBase,
        totalCreditBase: currentTotalCreditBase,
      ));
    } else {
      final updatedEntries = currentCreditEntries.map((entry) {
        if (entry.rowId == event.id) {
          return entry.copyWith(
            accountNumber: event.accountNumber ?? entry.accountNumber,
            accountName: event.accountName ?? entry.accountName,
            currency: event.currency ?? entry.currency,
            amount: event.amount ?? entry.amount,
            narration: event.narration ?? entry.narration,
          );
        }
        return entry;
      }).toList();
      emit(FxLoadedState(
        baseCurrency: currentBaseCurrency,
        narration: currentNarration,
        debitEntries: currentDebitEntries,
        creditEntries: updatedEntries,
        totalDebitBase: currentTotalDebitBase,
        totalCreditBase: currentTotalCreditBase,
      ));
    }
  }

  void _onUpdateBaseCurrency(UpdateBaseCurrencyEvent event, Emitter<FxState> emit) {
    if (state is! FxLoadedState && state is! FxSavingState && state is! FxApiErrorState) return;

    final currentState = state;
    List<TransferEntry> currentDebitEntries = [];
    List<TransferEntry> currentCreditEntries = [];
    String? currentBaseCurrency;
    String currentNarration = '';
    double currentTotalDebitBase = 0.0;
    double currentTotalCreditBase = 0.0;

    if (currentState is FxLoadedState) {
      currentDebitEntries = currentState.debitEntries;
      currentCreditEntries = currentState.creditEntries;
      currentBaseCurrency = currentState.baseCurrency;
      currentNarration = currentState.narration;
      currentTotalDebitBase = currentState.totalDebitBase;
      currentTotalCreditBase = currentState.totalCreditBase;
    } else if (currentState is FxSavingState) {
      currentDebitEntries = currentState.debitEntries;
      currentCreditEntries = currentState.creditEntries;
      currentBaseCurrency = currentState.baseCurrency;
      currentNarration = currentState.narration;
      currentTotalDebitBase = currentState.totalDebitBase;
      currentTotalCreditBase = currentState.totalCreditBase;
    } else if (currentState is FxApiErrorState) {
      currentDebitEntries = currentState.debitEntries;
      currentCreditEntries = currentState.creditEntries;
      currentBaseCurrency = currentState.baseCurrency;
      currentNarration = currentState.narration;
      currentTotalDebitBase = currentState.totalDebitBase;
      currentTotalCreditBase = currentState.totalCreditBase;
    }

    emit(FxLoadedState(
      baseCurrency: event.baseCurrency,
      narration: currentNarration,
      debitEntries: currentDebitEntries,
      creditEntries: currentCreditEntries,
      totalDebitBase: currentTotalDebitBase,
      totalCreditBase: currentTotalCreditBase,
    ));
  }

  void _onUpdateNarration(UpdateNarrationEvent event, Emitter<FxState> emit) {
    if (state is! FxLoadedState && state is! FxSavingState && state is! FxApiErrorState) return;

    final currentState = state;
    List<TransferEntry> currentDebitEntries = [];
    List<TransferEntry> currentCreditEntries = [];
    String? currentBaseCurrency;
    String currentNarration = '';
    double currentTotalDebitBase = 0.0;
    double currentTotalCreditBase = 0.0;

    if (currentState is FxLoadedState) {
      currentDebitEntries = currentState.debitEntries;
      currentCreditEntries = currentState.creditEntries;
      currentBaseCurrency = currentState.baseCurrency;
      currentNarration = currentState.narration;
      currentTotalDebitBase = currentState.totalDebitBase;
      currentTotalCreditBase = currentState.totalCreditBase;
    } else if (currentState is FxSavingState) {
      currentDebitEntries = currentState.debitEntries;
      currentCreditEntries = currentState.creditEntries;
      currentBaseCurrency = currentState.baseCurrency;
      currentNarration = currentState.narration;
      currentTotalDebitBase = currentState.totalDebitBase;
      currentTotalCreditBase = currentState.totalCreditBase;
    } else if (currentState is FxApiErrorState) {
      currentDebitEntries = currentState.debitEntries;
      currentCreditEntries = currentState.creditEntries;
      currentBaseCurrency = currentState.baseCurrency;
      currentNarration = currentState.narration;
      currentTotalDebitBase = currentState.totalDebitBase;
      currentTotalCreditBase = currentState.totalCreditBase;
    }

    emit(FxLoadedState(
      baseCurrency: currentBaseCurrency,
      narration: event.narration,
      debitEntries: currentDebitEntries,
      creditEntries: currentCreditEntries,
      totalDebitBase: currentTotalDebitBase,
      totalCreditBase: currentTotalCreditBase,
    ));
  }

  Future<void> _onSaveTransfer(SaveFxEvent event, Emitter<FxState> emit) async {
    if (state is! FxLoadedState) {
      event.completer.completeError('Invalid state');
      return;
    }

    final currentState = state as FxLoadedState;

    // Validate base currency is selected
    if (currentState.baseCurrency == null || currentState.baseCurrency!.isEmpty) {
      final error = 'Please select base currency';
      emit(FxApiErrorState(
        error: error,
        errorType: 'validation',
        baseCurrency: currentState.baseCurrency,
        narration: currentState.narration,
        debitEntries: currentState.debitEntries,
        creditEntries: currentState.creditEntries,
        totalDebitBase: currentState.totalDebitBase,
        totalCreditBase: currentState.totalCreditBase,
      ));
      event.completer.completeError(error);
      return;
    }

    // Validate at least one debit and one credit entry
    if (currentState.debitEntries.isEmpty || currentState.creditEntries.isEmpty) {
      final error = 'Add at least one debit and one credit entry';
      emit(FxApiErrorState(
        error: error,
        errorType: 'validation',
        baseCurrency: currentState.baseCurrency,
        narration: currentState.narration,
        debitEntries: currentState.debitEntries,
        creditEntries: currentState.creditEntries,
        totalDebitBase: currentState.totalDebitBase,
        totalCreditBase: currentState.totalCreditBase,
      ));
      event.completer.completeError(error);
      return;
    }

    // Validate all entries have accounts
    for (final entry in currentState.debitEntries) {
      if (entry.accountNumber == null) {
        final error = 'All debit entries must have an account';
        emit(FxApiErrorState(
          error: error,
          errorType: 'validation',
          baseCurrency: currentState.baseCurrency,
          narration: currentState.narration,
          debitEntries: currentState.debitEntries,
          creditEntries: currentState.creditEntries,
          totalDebitBase: currentState.totalDebitBase,
          totalCreditBase: currentState.totalCreditBase,
        ));
        event.completer.completeError(error);
        return;
      }
    }

    for (final entry in currentState.creditEntries) {
      if (entry.accountNumber == null) {
        final error = 'All credit entries must have an account';
        emit(FxApiErrorState(
          error: error,
          errorType: 'validation',
          baseCurrency: currentState.baseCurrency,
          narration: currentState.narration,
          debitEntries: currentState.debitEntries,
          creditEntries: currentState.creditEntries,
          totalDebitBase: currentState.totalDebitBase,
          totalCreditBase: currentState.totalCreditBase,
        ));
        event.completer.completeError(error);
        return;
      }
    }

    // Show saving state
    emit(FxSavingState(
      baseCurrency: currentState.baseCurrency,
      narration: currentState.narration,
      debitEntries: currentState.debitEntries,
      creditEntries: currentState.creditEntries,
      totalDebitBase: currentState.totalDebitBase,
      totalCreditBase: currentState.totalCreditBase,
    ));

    try {
      // Combine debit and credit entries for API
      final allEntries = [
        ...currentState.debitEntries.map((entry) => entry),
        ...currentState.creditEntries.map((entry) => entry),
      ];

      final records = allEntries.map((entry) => {
        'account': entry.accountNumber ?? 0,
        'ccy': entry.currency ?? currentState.baseCurrency!,
        'debit': entry.isDebit ? entry.amount : 0.0,
        'credit': !entry.isDebit ? entry.amount : 0.0,
        'narration': entry.narration ?? currentState.narration,
      }).toList();

      final result = await repo.saveFxTransfer(
        userName: event.userName,
        records: records,
      );

      final msg = result['msg']?.toString().toLowerCase() ?? '';
      if (msg.contains('success')) {
        final reference = result['reference']?.toString() ?? 'Transaction successful';
        emit(FxSavedState(true, reference));

        await Future.delayed(const Duration(milliseconds: 500));

        emit(FxLoadedState(
          baseCurrency: currentState.baseCurrency,
          narration: '',
          debitEntries: [],
          creditEntries: [],
          totalDebitBase: 0.0,
          totalCreditBase: 0.0,
        ));

        event.completer.complete('success');
      } else {
        String errorType = 'failed';
        String errorMessage = msg;

        // You can add more specific error handling here

        emit(FxApiErrorState(
          error: errorMessage,
          errorType: errorType,
          baseCurrency: currentState.baseCurrency,
          narration: currentState.narration,
          debitEntries: currentState.debitEntries,
          creditEntries: currentState.creditEntries,
          totalDebitBase: currentState.totalDebitBase,
          totalCreditBase: currentState.totalCreditBase,
        ));
        event.completer.completeError(errorMessage);
      }
    } catch (e) {
      emit(FxApiErrorState(
        error: e.toString(),
        baseCurrency: currentState.baseCurrency,
        narration: currentState.narration,
        debitEntries: currentState.debitEntries,
        creditEntries: currentState.creditEntries,
        totalDebitBase: currentState.totalDebitBase,
        totalCreditBase: currentState.totalCreditBase,
      ));
      event.completer.completeError(e.toString());
    }
  }

  void _onClearApiError(ClearFxApiErrorEvent event, Emitter<FxState> emit) {
    if (state is FxApiErrorState) {
      final errorState = state as FxApiErrorState;
      emit(FxLoadedState(
        baseCurrency: errorState.baseCurrency,
        narration: errorState.narration,
        debitEntries: errorState.debitEntries,
        creditEntries: errorState.creditEntries,
        totalDebitBase: errorState.totalDebitBase,
        totalCreditBase: errorState.totalCreditBase,
      ));
    }
  }

  void _onReset(ResetFxEvent event, Emitter<FxState> emit) {
    if (state is FxLoadedState || state is FxSavingState || state is FxApiErrorState) {
      final currentState = state;
      String? currentBaseCurrency;

      if (currentState is FxLoadedState) {
        currentBaseCurrency = currentState.baseCurrency;
      } else if (currentState is FxSavingState) {
        currentBaseCurrency = currentState.baseCurrency;
      } else if (currentState is FxApiErrorState) {
        currentBaseCurrency = currentState.baseCurrency;
      }

      emit(FxLoadedState(
        baseCurrency: currentBaseCurrency,
        narration: '',
        debitEntries: [],
        creditEntries: [],
        totalDebitBase: 0.0,
        totalCreditBase: 0.0,
      ));
    }
  }
}