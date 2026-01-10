import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';

import '../model/dashboard_stats.dart';

part 'dashboard_stats_event.dart';
part 'dashboard_stats_state.dart';

class DashboardStatsBloc extends Bloc<DashboardStatsEvent, DashboardStatsState> {
  final Repositories repository;

  DashboardStatsBloc(this.repository) : super(DashboardStatsInitial()) {
    on<FetchDashboardStatsEvent>(_onFetchDashboardStats);
  }

  Future<void> _onFetchDashboardStats(
      FetchDashboardStatsEvent event,
      Emitter<DashboardStatsState> emit,
      ) async {
    emit(DashboardStatsLoading());

    try {
      final stats = await repository.getDashboardStats();
      emit(DashboardStatsLoaded(stats));
    } catch (e) {
      emit(DashboardStatsError(e.toString()));
    }
  }
}
