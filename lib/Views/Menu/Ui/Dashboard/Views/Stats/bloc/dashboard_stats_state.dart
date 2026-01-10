part of 'dashboard_stats_bloc.dart';

sealed class DashboardStatsState extends Equatable {
  const DashboardStatsState();
}

final class DashboardStatsInitial extends DashboardStatsState {
  @override
  List<Object> get props => [];
}
