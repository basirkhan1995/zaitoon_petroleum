part of 'services_report_bloc.dart';

sealed class ServicesReportEvent extends Equatable {
  const ServicesReportEvent();
}

class LoadServicesReportEvent extends ServicesReportEvent{
  final String? fromDate;
  final String? toDate;
  final int? serviceId;
  final int? projectId;
  const LoadServicesReportEvent({this.fromDate,this.toDate, this.serviceId, this.projectId});
  @override
  List<Object?> get props => [fromDate, toDate, serviceId, projectId];
}

class ResetServicesReportEvent extends ServicesReportEvent{
  @override
  List<Object?> get props => [];
}