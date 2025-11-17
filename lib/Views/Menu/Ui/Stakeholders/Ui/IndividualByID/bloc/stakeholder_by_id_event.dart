part of 'stakeholder_by_id_bloc.dart';

sealed class StakeholderByIdEvent extends Equatable {
  const StakeholderByIdEvent();
}

class LoadStakeholderByIdEvent extends StakeholderByIdEvent{
  final int stkId;
  const LoadStakeholderByIdEvent({required this.stkId});
  @override
  List<Object?> get props => [stkId];
}