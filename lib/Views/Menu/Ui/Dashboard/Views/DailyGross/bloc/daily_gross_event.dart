part of 'daily_gross_bloc.dart';

sealed class DailyGrossEvent extends Equatable {
  const DailyGrossEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch daily profit vs loss
final class FetchDailyGrossEvent extends DailyGrossEvent {
  final String from;
  final String to;
  final int startGroup;
  final int stopGroup;

  const FetchDailyGrossEvent({
    required this.from,
    required this.to,
    required this.startGroup,
    required this.stopGroup,
  });

  @override
  List<Object?> get props => [from, to, startGroup, stopGroup];
}
