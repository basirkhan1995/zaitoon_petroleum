part of 'adjustment_bloc.dart';

abstract class AdjustmentEvent extends Equatable {
  const AdjustmentEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAdjustmentEvent extends AdjustmentEvent {}

class LoadAdjustmentsEvent extends AdjustmentEvent {}

class SelectExpenseAccountEvent extends AdjustmentEvent {
  final int account;
  const SelectExpenseAccountEvent(this.account);

  @override
  List<Object?> get props => [account];
}

class ClearExpenseAccountEvent extends AdjustmentEvent {}

class AddNewAdjustmentItemEvent extends AdjustmentEvent {}

class RemoveAdjustmentItemEvent extends AdjustmentEvent {
  final String rowId;
  const RemoveAdjustmentItemEvent(this.rowId);

  @override
  List<Object?> get props => [rowId];
}

class UpdateAdjustmentItemEvent extends AdjustmentEvent {
  final String rowId;
  final String? productId;
  final String? productName;
  final double? quantity;
  final double? purPrice;
  final int? storageId;
  final String? storageName;

  const UpdateAdjustmentItemEvent({
    required this.rowId,
    this.productId,
    this.productName,
    this.quantity,
    this.purPrice,
    this.storageId,
    this.storageName,
  });

  @override
  List<Object?> get props => [
    rowId,
    productId,
    productName,
    quantity,
    purPrice,
    storageId,
    storageName,
  ];
}

class ResetAdjustmentEvent extends AdjustmentEvent {}

class SaveAdjustmentEvent extends AdjustmentEvent {
  final String usrName;
  final String xRef;
  final int expenseAccount;
  final List<AdjustmentItem> items;
  final Completer<String> completer;

  const SaveAdjustmentEvent({
    required this.usrName,
    required this.xRef,
    required this.expenseAccount,
    required this.items,
    required this.completer,
  });

  @override
  List<Object?> get props => [usrName, xRef, expenseAccount, items, completer];
}