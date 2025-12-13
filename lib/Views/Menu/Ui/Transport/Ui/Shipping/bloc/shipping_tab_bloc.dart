import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'shipping_tab_event.dart';
part 'shipping_tab_state.dart';

class ShippingTabBloc extends Bloc<ShippingTabEvent, ShippingTabState> {
  ShippingTabBloc() : super(ShippingTabState(tabs: ShippingTabName.shipping)) {
    on<ShippingOnchangeEvent>((event, emit) {
      emit(ShippingTabState(tabs: event.tab));
    });
  }
}
