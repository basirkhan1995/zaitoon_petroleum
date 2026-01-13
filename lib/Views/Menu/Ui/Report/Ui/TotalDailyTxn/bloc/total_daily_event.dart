part of 'total_daily_bloc.dart';

sealed class TotalDailyEvent extends Equatable {
  const TotalDailyEvent();
}

class LoadTotalDailyEvent extends TotalDailyEvent {
  final String fromDate;
  final String toDate;
  const LoadTotalDailyEvent(this.fromDate, this.toDate);
  @override
  List<Object?> get props => [fromDate, toDate];
}