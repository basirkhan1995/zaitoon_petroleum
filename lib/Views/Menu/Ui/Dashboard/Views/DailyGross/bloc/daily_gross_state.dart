part of 'daily_gross_bloc.dart';

sealed class DailyGrossState extends Equatable {
  const DailyGrossState();
}

final class DailyGrossInitial extends DailyGrossState {
  @override
  List<Object> get props => [];
}
