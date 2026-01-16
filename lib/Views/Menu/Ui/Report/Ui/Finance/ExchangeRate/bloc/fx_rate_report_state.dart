part of 'fx_rate_report_bloc.dart';

sealed class FxRateReportState extends Equatable {
  const FxRateReportState();
}

final class FxRateReportInitial extends FxRateReportState {
  @override
  List<Object> get props => [];
}
final class FxRateReportLoadingState extends FxRateReportState {
  @override
  List<Object> get props => [];
}

final class FxRateReportErrorState extends FxRateReportState {
  final String message;
  const FxRateReportErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class FxRateReportLoadedState extends FxRateReportState {
  final List<ExchangeRateReportModel> rates;
  const FxRateReportLoadedState(this.rates);
  @override
  List<Object> get props => [rates];
}
