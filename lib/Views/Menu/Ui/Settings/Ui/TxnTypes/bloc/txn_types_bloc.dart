import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'txn_types_event.dart';
part 'txn_types_state.dart';

class TxnTypesBloc extends Bloc<TxnTypesEvent, TxnTypesState> {
  TxnTypesBloc() : super(TxnTypesInitial()) {
    on<TxnTypesEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
