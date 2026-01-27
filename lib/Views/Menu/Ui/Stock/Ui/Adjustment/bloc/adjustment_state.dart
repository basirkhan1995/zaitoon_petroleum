part of 'adjustment_bloc.dart';

sealed class AdjustmentState extends Equatable {
  const AdjustmentState();
}

final class AdjustmentInitial extends AdjustmentState {
  @override
  List<Object> get props => [];
}
