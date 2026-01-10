import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'dashboard_stats_event.dart';
part 'dashboard_stats_state.dart';

class DashboardStatsBloc extends Bloc<DashboardStatsEvent, DashboardStatsState> {
  DashboardStatsBloc() : super(DashboardStatsInitial()) {
    on<DashboardStatsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
