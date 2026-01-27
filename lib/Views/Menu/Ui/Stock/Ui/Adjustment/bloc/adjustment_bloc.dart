import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'adjustment_event.dart';
part 'adjustment_state.dart';

class AdjustmentBloc extends Bloc<AdjustmentEvent, AdjustmentState> {
  AdjustmentBloc() : super(AdjustmentInitial()) {
    on<AdjustmentEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
