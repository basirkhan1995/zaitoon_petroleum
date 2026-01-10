part of 'dashboard_stats_bloc.dart';

sealed class DashboardStatsState extends Equatable {
  const DashboardStatsState();

  @override
  List<Object?> get props => [];
}

final class DashboardStatsInitial extends DashboardStatsState {}

final class DashboardStatsLoading extends DashboardStatsState {}

final class DashboardStatsLoaded extends DashboardStatsState {
  final DashboardStatsModel stats;
  final bool isRefreshing;

  const DashboardStatsLoaded(this.stats, {this.isRefreshing = false});

  @override
  List<Object?> get props => [stats, isRefreshing];
}


final class DashboardStatsError extends DashboardStatsState {
  final String message;

  const DashboardStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
