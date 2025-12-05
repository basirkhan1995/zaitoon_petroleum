import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/ExchangeRate/model/rate_model.dart';

part 'exchange_rate_event.dart';
part 'exchange_rate_state.dart';

class ExchangeRateBloc extends Bloc<ExchangeRateEvent, ExchangeRateState> {
  final Repositories _repo;
  ExchangeRateBloc(this._repo) : super(ExchangeRateInitial()) {

    on<LoadExchangeRateEvent>((event, emit)async {
      emit(ExchangeRateLoadingState());
      try{
       final rates = await _repo.getExchangeRate(ccyCode: event.ccyCode);
       emit(ExchangeRateLoadedState(rates: rates));
      }catch(e){
        emit(ExchangeRateErrorState(e.toString()));
      }
    });

    on<GetExchangeRateEvent>((event, emit)async {
      emit(ExchangeRateLoadingState());
      try{
        final rate = await _repo.getSingleRate(fromCcy: event.fromCcy,toCcy: event.toCcy);
        emit(ExchangeRateLoadedState(rates: [],rate: rate));
      }catch(e){
        emit(ExchangeRateErrorState(e.toString()));
      }
    });

    on<AddExchangeRateEvent>((event, emit)async {
      emit(ExchangeRateLoadingState());
      try{
        final rates = await _repo.addExchangeRate(newRate: event.newRate);
        if(rates["msg"] == "success"){
          emit(ExchangeRateSuccessState());
        }
      }catch(e){
        emit(ExchangeRateErrorState(e.toString()));
      }
    });

  }
}
