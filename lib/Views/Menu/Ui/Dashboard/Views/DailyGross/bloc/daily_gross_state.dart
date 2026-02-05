part of 'daily_gross_bloc.dart';

sealed class DailyGrossState extends Equatable {
  const DailyGrossState();

  @override
  List<Object?> get props => [];
}

/// Initial state
final class DailyGrossInitial extends DailyGrossState {}

/// Only used for FIRST load
final class DailyGrossLoading extends DailyGrossState {}

/// Loaded state with silent refresh support
final class DailyGrossLoaded extends DailyGrossState {
  final List<DailyGrossModel> data;
  final bool isRefreshing;

  const DailyGrossLoaded(
      this.data, {
        this.isRefreshing = false,
      });

  @override
  List<Object?> get props => [data, isRefreshing];
}

/// Error state
final class DailyGrossError extends DailyGrossState {
  final String message;

  const DailyGrossError(this.message);

  @override
  List<Object?> get props => [message];
}