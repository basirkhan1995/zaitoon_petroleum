import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';

import '../model/gross_model.dart';

part 'daily_gross_event.dart';
part 'daily_gross_state.dart';

class DailyGrossBloc extends Bloc<DailyGrossEvent, DailyGrossState> {
  final Repositories repository;

  DailyGrossBloc(this.repository)
      : super(DailyGrossInitial()) {
    on<FetchDailyGrossEvent>(_onFetchDailyGross);
  }

  Future<void> _onFetchDailyGross(
      FetchDailyGrossEvent event,
      Emitter<DailyGrossState> emit,
      ) async {
    emit(DailyGrossLoading());

    try {
      final result = await repository.getDailyGross(
        from: event.from,
        to: event.to,
        startGroup: event.startGroup,
        stopGroup: event.stopGroup,
      );

      emit(DailyGrossLoaded(result));
    } catch (e) {
      emit(DailyGrossError(e.toString()));
    }
  }
}
