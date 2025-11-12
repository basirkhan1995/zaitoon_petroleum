import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'transaction_tab_event.dart';
part 'transaction_tab_state.dart';

class JournalTabBloc extends Bloc<JournalTabEvent, JournalTabState> {
  JournalTabBloc() : super(JournalTabState(tab: JournalTabName.allTransactions)) {
    on<JournalOnChangedEvent>((event, emit) {
     emit(JournalTabState(tab: event.tab));
    });
  }
}
