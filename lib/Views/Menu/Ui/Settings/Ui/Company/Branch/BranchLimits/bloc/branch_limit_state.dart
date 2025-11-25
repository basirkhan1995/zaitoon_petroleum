part of 'branch_limit_bloc.dart';

sealed class BranchLimitState extends Equatable {
  const BranchLimitState();
}

final class BranchLimitInitial extends BranchLimitState {
  @override
  List<Object> get props => [];
}
