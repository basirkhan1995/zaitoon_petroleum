import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'branch_limit_event.dart';
part 'branch_limit_state.dart';

class BranchLimitBloc extends Bloc<BranchLimitEvent, BranchLimitState> {
  BranchLimitBloc() : super(BranchLimitInitial()) {
    on<BranchLimitEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
