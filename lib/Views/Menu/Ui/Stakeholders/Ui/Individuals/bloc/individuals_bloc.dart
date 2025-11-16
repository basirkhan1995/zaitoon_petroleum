import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/Models/ind_model.dart';
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
  }
}
