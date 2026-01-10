part of 'daily_gross_bloc.dart';

sealed class DailyGrossState extends Equatable {
  const DailyGrossState();

  @override
  List<Object?> get props => [];
}

final class DailyGrossInitial extends DailyGrossState {}

final class DailyGrossLoading extends DailyGrossState {}

final class DailyGrossLoaded extends DailyGrossState {
  final List<DailyGrossModel> data;

  const DailyGrossLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

final class DailyGrossError extends DailyGrossState {
  final String message;

  const DailyGrossError(this.message);

  @override
  List<Object?> get props => [message];
}
