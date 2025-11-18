part of 'stakeholder_by_id_bloc.dart';

sealed class StakeholderByIdState extends Equatable {
  const StakeholderByIdState();
}

final class StakeholderByIdInitial extends StakeholderByIdState {
  @override
  List<Object> get props => [];
}


final class StakeholderByIdLoadingState extends StakeholderByIdState {
  @override
  List<Object> get props => [];
}

final class StakeholderByIdLoadedState extends StakeholderByIdState{
  final IndividualsModel stk;
  const StakeholderByIdLoadedState(this.stk);
  @override
  List<Object> get props => [stk];
}

final class StakeholderByIdErrorState extends StakeholderByIdState {
  final String message;
  const StakeholderByIdErrorState(this.message);
  @override
  List<Object> get props => [message];
}