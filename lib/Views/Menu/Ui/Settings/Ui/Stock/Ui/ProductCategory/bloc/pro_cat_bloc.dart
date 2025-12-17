import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';

part 'pro_cat_event.dart';
part 'pro_cat_state.dart';

class ProCatBloc extends Bloc<ProCatEvent, ProCatState> {
  final Repositories _repo;
  ProCatBloc(this._repo) : super(ProCatInitial()) {
    on<LoadProCatEvent>((event, emit) async{
      try{

      }catch(e){
        emit(ProCatErrorState(e.toString()));
      }
    });
  }
}
