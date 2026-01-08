// estimate_event.dart
part of 'estimate_bloc.dart';

abstract class EstimateEvent extends Equatable {
  const EstimateEvent();
  @override
  List<Object?> get props => [];
}

class LoadEstimatesEvent extends EstimateEvent {}

class LoadEstimateByIdEvent extends EstimateEvent {
  final int orderId;
  const LoadEstimateByIdEvent(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class AddEstimateEvent extends EstimateEvent {
  final String usrName;
  final int perID;
  final String? xRef;
  final List<EstimateRecord> records;
  const AddEstimateEvent({
    required this.usrName,
    required this.perID,
    this.xRef,
    required this.records,
  });
  @override
  List<Object?> get props => [usrName, perID, xRef, records];
}

class UpdateEstimateEvent extends EstimateEvent {
  final String usrName;
  final int orderId;
  final int perID;
  final String? xRef;
  final List<EstimateRecord> records;
  const UpdateEstimateEvent({
    required this.usrName,
    required this.orderId,
    required this.perID,
    this.xRef,
    required this.records,
  });
  @override
  List<Object?> get props => [usrName, orderId, perID, xRef, records];
}

class DeleteEstimateEvent extends EstimateEvent {
  final int orderId;
  final String usrName;
  const DeleteEstimateEvent({required this.orderId, required this.usrName});
  @override
  List<Object?> get props => [orderId, usrName];
}

class ConvertEstimateToSaleEvent extends EstimateEvent {
  final String usrName;
  final int orderId;
  final int perID;
  final int account;
  final String amount;
  final bool isCash;
  const ConvertEstimateToSaleEvent({
    required this.usrName,
    required this.orderId,
    required this.perID,
    required this.account,
    required this.amount,
    this.isCash = false,
  });
  @override
  List<Object?> get props => [usrName, orderId, perID, account, amount, isCash];
}