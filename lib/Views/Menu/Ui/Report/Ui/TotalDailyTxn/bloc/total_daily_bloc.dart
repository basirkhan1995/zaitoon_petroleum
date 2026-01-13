import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/TotalDailyTxn/model/daily_txn_model.dart';
import '../../../../../../../Services/repositories.dart';

part 'total_daily_event.dart';
part 'total_daily_state.dart';

class TotalDailyBloc extends Bloc<TotalDailyEvent, TotalDailyState> {
  final Repositories repository;

  TotalDailyBloc(this.repository) : super(TotalDailyInitial()) {
    on<LoadTotalDailyEvent>(_onLoadTotalDaily);
  }

  Future<void> _onLoadTotalDaily(
      LoadTotalDailyEvent event,
      Emitter<TotalDailyState> emit,
      ) async {
    final currentState = state;

    /// 🔹 FIRST LOAD → show loader
    if (currentState is! TotalDailyLoaded) {
      emit(TotalDailyLoading());
    }
    /// 🔹 RELOAD → silent refresh
    else {
      emit(
        TotalDailyLoaded(
          currentState.data,
          isRefreshing: true,
        ),
      );
    }

    try {
      final result = await repository.totalDailyTxnReport(
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      emit(TotalDailyLoaded(result));
    } catch (e) {
      emit(TotalDailyError(e.toString()));
    }
  }
}
