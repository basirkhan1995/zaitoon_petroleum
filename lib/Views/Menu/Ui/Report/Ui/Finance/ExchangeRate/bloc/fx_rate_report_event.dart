part of 'fx_rate_report_bloc.dart';

sealed class FxRateReportEvent extends Equatable {
  const FxRateReportEvent();
}

class LoadFxRateReportEvent extends FxRateReportEvent{
  final String? fromDate;
  final String? toDate;
  final String? fromCcy;
  final String? toCcy;
  const LoadFxRateReportEvent({this.fromDate, this.toDate, this.fromCcy, this.toCcy});
  @override
  List<Object?> get props => [fromDate, toDate, fromCcy, toCcy];
}