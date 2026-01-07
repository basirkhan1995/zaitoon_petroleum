part of 'estimate_bloc.dart';

sealed class EstimateEvent extends Equatable {
  const EstimateEvent();
}

class LoadEstimateEvent extends EstimateEvent{
  @override
  List<Object?> get props => [];
}