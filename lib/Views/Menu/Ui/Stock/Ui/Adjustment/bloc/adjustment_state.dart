part of 'adjustment_bloc.dart';

abstract class AdjustmentState extends Equatable {
  const AdjustmentState();
}

class AdjustmentInitial extends AdjustmentState {
  @override
  List<Object> get props => [];
}

class AdjustmentLoading extends AdjustmentState {
  @override
  List<Object> get props => [];
}

class AdjustmentListLoaded extends AdjustmentState {
  final List<AdjustmentModel> adjustments;

  const AdjustmentListLoaded(this.adjustments);

  @override
  List<Object> get props => [adjustments];
}

class AdjustmentFormLoaded extends AdjustmentState {
  final List<AdjustmentItem> items;
  final int? expenseAccount;
  final String? xRef;

  const AdjustmentFormLoaded({
    required this.items,
    this.expenseAccount,
    this.xRef,
  });

  // Total adjustment amount (cost of adjusted items)
  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalCost);
  }

  bool get isFormValid {
    if (expenseAccount == null) return false;

    if (items.isEmpty) return false;

    for (var item in items) {
      if (item.productId.isEmpty ||
          item.productName.isEmpty ||
          item.storageId == 0 ||
          item.storageName.isEmpty ||
          item.purPrice == null ||
          item.purPrice! <= 0 ||
          item.quantity <= 0) {
        return false;
      }
    }

    return true;
  }

  AdjustmentFormLoaded copyWith({
    List<AdjustmentItem>? items,
    int? expenseAccount,
    String? xRef,
  }) {
    return AdjustmentFormLoaded(
      items: items ?? this.items,
      expenseAccount: expenseAccount ?? this.expenseAccount,
      xRef: xRef ?? this.xRef,
    );
  }

  @override
  List<Object?> get props => [items, expenseAccount, xRef];
}

class AdjustmentSaving extends AdjustmentFormLoaded {
  const AdjustmentSaving({
    required super.items,
    super.expenseAccount,
    super.xRef,
  });
}

class AdjustmentSaved extends AdjustmentState {
  final bool success;
  final String? adjustmentNumber;

  const AdjustmentSaved(this.success, {this.adjustmentNumber});

  @override
  List<Object?> get props => [success, adjustmentNumber];
}

class AdjustmentError extends AdjustmentState {
  final String message;
  const AdjustmentError(this.message);

  @override
  List<Object> get props => [message];
}