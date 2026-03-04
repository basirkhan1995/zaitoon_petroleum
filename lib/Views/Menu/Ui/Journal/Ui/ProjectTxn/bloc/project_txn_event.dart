part of 'project_txn_bloc.dart';

sealed class ProjectTxnEvent extends Equatable {
  const ProjectTxnEvent();
}

class LoadProjectTxnEvent extends ProjectTxnEvent{
  final String ref;
  const LoadProjectTxnEvent(this.ref);

  @override
  List<Object?> get props => [ref];
}