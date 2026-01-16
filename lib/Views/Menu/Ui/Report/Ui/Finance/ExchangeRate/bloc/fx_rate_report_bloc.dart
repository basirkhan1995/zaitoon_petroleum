import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/ExchangeRate/model/rate_report_model.dart';

part 'fx_rate_report_event.dart';
part 'fx_rate_report_state.dart';

class FxRateReportBloc extends Bloc<FxRateReportEvent, FxRateReportState> {
  final Repositories _repo;
  FxRateReportBloc(this._repo) : super(FxRateReportInitial()) {
    on<LoadFxRateReportEvent>((event, emit) async{
      emit(FxRateReportLoadingState());
      try{
       final rates = await _repo.exchangeRateReport(fromDate: event.fromDate, toDate: event.toDate,fromCcy: event.fromCcy, toCcy: event.toCcy);
       emit(FxRateReportLoadedState(rates));
      }catch(e){
        emit(FxRateReportErrorState(e.toString()));
      }
    });
  }
}
