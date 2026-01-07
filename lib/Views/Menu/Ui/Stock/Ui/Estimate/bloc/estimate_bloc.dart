import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Estimate/model/estimate_model.dart';

part 'estimate_event.dart';
part 'estimate_state.dart';

class EstimateBloc extends Bloc<EstimateEvent, EstimateState> {
  final Repositories _repo;
  EstimateBloc(this._repo) : super(EstimateInitial()) {
    on<LoadEstimateEvent>((event, emit) async{
      emit(EstimateLoadingState());
      try{
        final estimates = await _repo.getAllEstimates();
        emit(EstimateLoadedState(estimates));
      }catch(e){
        emit(EstimateErrorState(e.toString()));
      }
    });
  }
}
