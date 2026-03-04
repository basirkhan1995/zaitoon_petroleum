part of 'project_txn_bloc.dart';

sealed class ProjectTxnState extends Equatable {
  const ProjectTxnState();
}

final class ProjectTxnInitial extends ProjectTxnState {
  @override
  List<Object> get props => [];
}

final class ProjectTxnLoadingState extends ProjectTxnState{
  @override
  List<Object> get props => [];
}

final class ProjectTxnLoadedState extends ProjectTxnState{
  final ProjectTxnModel txn;
  const ProjectTxnLoadedState(this.txn);
  @override
  List<Object> get props => [txn];
}

final class ProjectTxnErrorState extends ProjectTxnState{
  final String message;
  const ProjectTxnErrorState(this.message);
  @override
  List<Object> get props => [message];
}