import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'transport_tab_event.dart';
part 'transport_tab_state.dart';

class TransportTabBloc extends Bloc<TransportTabEvent, TransportTabState> {
  TransportTabBloc() : super(TransportTabState(tab: TransportTabName.shipping)) {
    on<TransportOnChangedEvent>((event, emit) {
      emit(TransportTabState(tab: event.tab));
    });
  }
}
