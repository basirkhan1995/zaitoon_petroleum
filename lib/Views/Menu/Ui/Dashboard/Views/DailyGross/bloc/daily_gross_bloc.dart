import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'daily_gross_event.dart';
part 'daily_gross_state.dart';

class DailyGrossBloc extends Bloc<DailyGrossEvent, DailyGrossState> {
  DailyGrossBloc() : super(DailyGrossInitial()) {
    on<DailyGrossEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
