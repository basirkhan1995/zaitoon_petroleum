import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'glat_event.dart';
part 'glat_state.dart';

class GlatBloc extends Bloc<GlatEvent, GlatState> {
  GlatBloc() : super(GlatInitial()) {
    on<GlatEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
