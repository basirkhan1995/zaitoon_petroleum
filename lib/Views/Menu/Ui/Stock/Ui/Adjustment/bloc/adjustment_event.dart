// adjustment_event.dart
part of 'adjustment_bloc.dart';

abstract class AdjustmentEvent extends Equatable {
  const AdjustmentEvent();
  @override
  List<Object?> get props => [];
}

class InitializeAdjustmentEvent extends AdjustmentEvent {}

class LoadAdjustmentsEvent extends AdjustmentEvent {}

class LoadAdjustmentDetailsEvent extends AdjustmentEvent {
  final int orderId;
  const LoadAdjustmentDetailsEvent(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class AddAdjustmentEvent extends AdjustmentEvent {
  final String usrName;
  final String xReference;
  final int xAccount;
  final List<Map<String, dynamic>> records;

  const AddAdjustmentEvent({
    required this.usrName,
    required this.xReference,
    required this.xAccount,
    required this.records,
  });

  @override
  List<Object?> get props => [usrName, xReference, xAccount, records];
}

class DeleteAdjustmentEvent extends AdjustmentEvent {
  final int orderId;
  final String usrName;
  const DeleteAdjustmentEvent({
    required this.orderId,
    required this.usrName,
  });
  @override
  List<Object?> get props => [orderId, usrName];
}


class ReturnToListEvent extends AdjustmentEvent {}

class ResetAdjustmentFormEvent extends AdjustmentEvent {}