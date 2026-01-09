
part of 'estimate_bloc.dart';

abstract class EstimateState extends Equatable {
  const EstimateState();
  @override
  List<Object?> get props => [];
}

class EstimateInitial extends EstimateState {}

class EstimateLoading extends EstimateState {}

class EstimateDetailLoading extends EstimateState {}

class EstimateError extends EstimateState {
  final String message;
  const EstimateError(this.message);
  @override
  List<Object?> get props => [message];
}

class EstimatesLoaded extends EstimateState {
  final List<EstimateModel> estimates;
  const EstimatesLoaded(this.estimates);
  @override
  List<Object?> get props => [estimates];
}

class EstimateDetailLoaded extends EstimateState {
  final EstimateModel estimate;
  const EstimateDetailLoaded(this.estimate);
  @override
  List<Object?> get props => [estimate];
}

class EstimateSaving extends EstimateState {}

class EstimateSaved extends EstimateState {
  final String message;
  const EstimateSaved({required this.message});
  @override
  List<Object?> get props => [message];
}

class EstimateDeleting extends EstimateState {}

class EstimateDeleted extends EstimateState {
  final String message;
  const EstimateDeleted({required this.message});
  @override
  List<Object?> get props => [message];
}

class EstimateConverting extends EstimateState {}

class EstimateConverted extends EstimateState {
  final String message;
  const EstimateConverted({required this.message});
  @override
  List<Object?> get props => [message];
}