import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'order_by_id_event.dart';
part 'order_by_id_state.dart';

class OrderByIdBloc extends Bloc<OrderByIdEvent, OrderByIdState> {
  OrderByIdBloc() : super(OrderByIdInitial()) {
    on<OrderByIdEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
