part of 'drivers_report_bloc.dart';

sealed class DriversReportState extends Equatable {
  const DriversReportState();
}

final class DriversReportInitial extends DriversReportState {
  @override
  List<Object> get props => [];
}
