import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Shipping/model/shipping_model.dart';

part 'shipping_event.dart';
part 'shipping_state.dart';

class ShippingBloc extends Bloc<ShippingEvent, ShippingState> {
  final Repositories _repo;
  ShippingBloc(this._repo) : super(ShippingInitial()) {

    on<AddShippingEvent>((event, emit) async{
     try{
      final res = await _repo.addShipping(newShipping: event.newShipping);
       final msg = res['msg'];
       if(msg == "success"){
         emit(ShippingSuccessState());
         add(LoadShippingEvent());
       }
     }catch(e){
      emit(ShippingErrorState(e.toString()));
     }
    });

  }
}
