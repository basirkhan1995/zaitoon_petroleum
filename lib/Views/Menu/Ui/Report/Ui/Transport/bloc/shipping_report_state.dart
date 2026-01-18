part of 'shipping_report_bloc.dart';

sealed class ShippingReportState extends Equatable {
  const ShippingReportState();
}

final class ShippingReportInitial extends ShippingReportState {
  @override
  List<Object> get props => [];
}

class ShippingReportLoadingState extends ShippingReportState{
  @override
  List<Object> get props => [];
}

final class ShippingReportErrorState extends ShippingReportState {
  final String message;
  const ShippingReportErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class ShippingReportLoadedState extends ShippingReportState {
  final List<ShippingReportModel> shp;
  const ShippingReportLoadedState(this.shp);
  @override
  List<Object> get props => [shp];
}
