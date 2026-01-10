part of 'dashboard_stats_bloc.dart';

sealed class DashboardStatsEvent extends Equatable {
  const DashboardStatsEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger dashboard stats loading
final class FetchDashboardStatsEvent extends DashboardStatsEvent {
  const FetchDashboardStatsEvent();
}
