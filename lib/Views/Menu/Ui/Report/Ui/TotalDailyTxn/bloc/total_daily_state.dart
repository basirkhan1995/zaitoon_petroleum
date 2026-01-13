part of 'total_daily_bloc.dart';

sealed class TotalDailyState extends Equatable {
  const TotalDailyState();
}

final class TotalDailyInitial extends TotalDailyState {
  @override
  List<Object> get props => [];
}

final class TotalDailyLoading extends TotalDailyState {
  @override
  List<Object?> get props => [];
}

final class TotalDailyLoaded extends TotalDailyState {
  final List<TotalDailyTxnModel> data;
  final bool isRefreshing;
  const TotalDailyLoaded(this.data, {this.isRefreshing = false});
  @override
  List<Object?> get props => [data, isRefreshing];
}

final class TotalDailyError extends TotalDailyState {
  final String message;
  const TotalDailyError(this.message);
  @override
  List<Object?> get props => [message];
}
