part of 'shipping_report_bloc.dart';

sealed class ShippingReportEvent extends Equatable {
  const ShippingReportEvent();
}

class LoadShippingReportEvent extends ShippingReportEvent{
  final String? fromDate;
  final String? toDate;
  final int? customerId;
  final int? vehicleId;
  final int? driverId;
  final int? status;
  const LoadShippingReportEvent({this.fromDate, this.toDate, this.customerId, this.vehicleId, this.driverId, this.status});
  @override
  List<Object?> get props => [fromDate, toDate, customerId, vehicleId, driverId, status];
}

class ResetShippingReportEvent extends ShippingReportEvent{
  @override
  List<Object?> get props => [];
}