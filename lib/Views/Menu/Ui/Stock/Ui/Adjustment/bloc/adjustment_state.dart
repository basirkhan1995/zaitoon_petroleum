// adjustment_state.dart
part of 'adjustment_bloc.dart';

abstract class AdjustmentState extends Equatable {
  const AdjustmentState();
  @override
  List<Object?> get props => [];
}

class AdjustmentInitial extends AdjustmentState {}

class AdjustmentLoadingState extends AdjustmentState {}

class AdjustmentSavingState extends AdjustmentState {}

class AdjustmentSavedState extends AdjustmentState {
  final String message;
  const AdjustmentSavedState({required this.message});
  @override
  List<Object?> get props => [message];
}

class AdjustmentDeletingState extends AdjustmentState {}

class AdjustmentDeletedState extends AdjustmentState {
  final String message;
  const AdjustmentDeletedState({required this.message});
  @override
  List<Object?> get props => [message];
}

class AdjustmentDetailLoadingState extends AdjustmentState {}

class AdjustmentDetailLoadedState extends AdjustmentState {
  final AdjustmentModel adjustment;
  final List<AdjustmentItem> items;

  const AdjustmentDetailLoadedState({
    required this.adjustment,
    required this.items,
  });

  @override
  List<Object?> get props => [adjustment, items];
}

class AdjustmentErrorState extends AdjustmentState {
  final String error;
  const AdjustmentErrorState(this.error);
  @override
  List<Object?> get props => [error];
}

class AdjustmentLoadedState extends AdjustmentState {
  final List<AdjustmentModel> adjustments;
  const AdjustmentLoadedState(this.adjustments);
  @override
  List<Object?> get props => [adjustments];
}

class AdjustmentFormLoadedState extends AdjustmentState {
  final List<AdjustmentItem> items;

  const AdjustmentFormLoadedState({
    required this.items,
  });

  @override
  List<Object?> get props => [items];
}