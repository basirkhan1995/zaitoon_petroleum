import 'package:bloc/bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FundTransfer/BulkTransfer/bloc/transfer_event.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FundTransfer/BulkTransfer/bloc/transfer_state.dart';

import '../model/transfer_model.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  int _rowIndex = 1;

  TransferBloc() : super(TransferInitialState()) {
    on<InitializeTransferEvent>(_onInit);
    on<AddDebitRowEvent>(_onAddDebit);
    on<AddCreditRowEvent>(_onAddCredit);
    on<RemoveEntryEvent>(_onRemove);
    on<UpdateEntryEvent>(_onUpdate);
    on<SaveTransferEvent>(_onSave);
  }

  void _onInit(InitializeTransferEvent event, Emitter emit) {
    emit(TransferLoadedState(
      debits: [],
      credits: [],
    ));
  }

  void _onAddDebit(AddDebitRowEvent event, Emitter emit) {
    if (state is! TransferLoadedState) return;
    final s = state as TransferLoadedState;

    emit(s.copyWith(
      debits: [
        ...s.debits,
        TransferEntry(rowId: _rowIndex++),
      ],
    ));
  }

  void _onAddCredit(AddCreditRowEvent event, Emitter emit) {
    if (state is! TransferLoadedState) return;
    final s = state as TransferLoadedState;

    emit(s.copyWith(
      credits: [
        ...s.credits,
        TransferEntry(rowId: _rowIndex++),
      ],
    ));
  }

  void _onRemove(RemoveEntryEvent event, Emitter emit) {
    if (state is! TransferLoadedState) return;
    final s = state as TransferLoadedState;

    if (event.isDebit) {
      emit(s.copyWith(
        debits: s.debits.where((e) => e.rowId != event.id).toList(),
      ));
    } else {
      emit(s.copyWith(
        credits: s.credits.where((e) => e.rowId != event.id).toList(),
      ));
    }
  }

  void _onUpdate(UpdateEntryEvent event, Emitter emit) {
    if (state is! TransferLoadedState) return;
    final s = state as TransferLoadedState;

    List<TransferEntry> updateList(List<TransferEntry> list) {
      return list.map((entry) {
        if (entry.rowId == event.id) {
          return entry.copyWith(
            accountName: event.accountName,
            accountNumber: event.accountNumber,
            currency: event.currency,
            amount: event.amount,
          );
        }
        return entry;
      }).toList();
    }

    emit(s.copyWith(
      debits: event.isDebit ? updateList(s.debits) : s.debits,
      credits: event.isDebit ? s.credits : updateList(s.credits),
    ));
  }

  void _onSave(SaveTransferEvent event, Emitter emit) async {
    // call repo.saveTransfer(...)
    emit(TransferSavedState());
  }
}
