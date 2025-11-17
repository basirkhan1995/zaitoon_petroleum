import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/Currencies/model/ccy_model.dart';

part 'currencies_event.dart';
part 'currencies_state.dart';

class CurrenciesBloc extends Bloc<CurrenciesEvent, CurrenciesState> {
  final Repositories _repo;
  CurrenciesBloc(this._repo) : super(CurrenciesInitial()) {

    on<LoadCurrenciesEvent>((event, emit) async{
      emit(CurrenciesLoadingState());
     try{
      final ccy = await _repo.getCurrencies(status: event.status);
      emit(CurrenciesLoadedState(ccy));
     }catch(e){
       emit(CurrenciesErrorState(e.toString()));
     }

    });
  }
}
