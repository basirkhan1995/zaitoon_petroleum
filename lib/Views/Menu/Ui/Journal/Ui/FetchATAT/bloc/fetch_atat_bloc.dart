import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchATAT/model/fetch_atat_model.dart';

part 'fetch_atat_event.dart';
part 'fetch_atat_state.dart';

class FetchAtatBloc extends Bloc<FetchAtatEvent, FetchAtatState> {
  final Repositories _repo;
  FetchAtatBloc(this._repo) : super(FetchAtatInitial()) {

    on<FetchAccToAccEvent>((event, emit) async{
      emit(FetchATATLoadingState());
      try{
       final atat = await _repo.getATATByReference(reference: event.ref);
       print(atat.credit);
       print(atat.debit);
       emit(FetchATATLoadedState(atat));
      }catch(e){
        emit(FetchATATErrorState(e.toString()));
      }

    });
  }
}
