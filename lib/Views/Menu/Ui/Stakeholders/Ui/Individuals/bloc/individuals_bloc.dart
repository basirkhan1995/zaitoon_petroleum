import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import '../individual_model.dart';
part 'individuals_event.dart';
part 'individuals_state.dart';

class IndividualsBloc extends Bloc<IndividualsEvent, IndividualsState> {
  final Repositories _repo;
  IndividualsBloc(this._repo) : super(IndividualsInitial()) {

    on<LoadIndividualsEvent>((event, emit)async {
      emit(IndividualLoadingState());
      try{
         final stk = await _repo.getStakeholders(indId: event.indId);
         emit(IndividualLoadedState(stk));
       }catch(e){
         emit(IndividualErrorState(e.toString()));
       }
    });


    on<AddIndividualEvent>((event, emit)async {
      emit(IndividualLoadingState());
      try{
       final response = await _repo.addStakeholder(stk: event.newStk);
       final String result = response["msg"];
       if(result == "success"){
         add(LoadIndividualsEvent());
         emit(IndividualSuccessState());
       }
      }catch(e){
        emit(IndividualErrorState(e.toString()));
      }
    });

    on<EditIndividualEvent>((event, emit)async {
      emit(IndividualLoadingState());
      try{
        final response = await _repo.editStakeholder(stk: event.newStk);
        final String result = response["msg"];
        if(result == "success"){
          add(LoadIndividualsEvent());
          emit(IndividualSuccessState());
        }
      }catch(e){
        emit(IndividualErrorState(e.toString()));
      }
    });

  }
}
