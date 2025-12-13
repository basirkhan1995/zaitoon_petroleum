import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'shipping_expense_event.dart';
part 'shipping_expense_state.dart';

class ShippingExpenseBloc extends Bloc<ShippingExpenseEvent, ShippingExpenseState> {
  ShippingExpenseBloc() : super(ShippingExpenseInitial()) {
    on<ShippingExpenseEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
