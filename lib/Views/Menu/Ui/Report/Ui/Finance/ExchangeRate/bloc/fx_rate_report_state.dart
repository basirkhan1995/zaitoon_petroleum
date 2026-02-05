part of 'fx_rate_report_bloc.dart';

sealed class FxRateReportState extends Equatable {
  const FxRateReportState();

  @override
  List<Object?> get props => [];
}

final class FxRateReportInitial extends FxRateReportState {}

final class FxRateReportLoadingState extends FxRateReportState {}

final class FxRateReportErrorState extends FxRateReportState {
  final String message;
  const FxRateReportErrorState(this.message);

  @override
  List<Object> get props => [message];
}

final class FxRateReportLoadedState extends FxRateReportState {
  final List<ExchangeRateReportModel> rates;
  final bool isRefreshing;

  const FxRateReportLoadedState(
      this.rates, {
        this.isRefreshing = false,
      });

  @override
  List<Object> get props => [rates, isRefreshing];
}