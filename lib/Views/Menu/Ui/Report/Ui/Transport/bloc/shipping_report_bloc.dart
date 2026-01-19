import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Transport/model/shp_report_model.dart';

part 'shipping_report_event.dart';
part 'shipping_report_state.dart';

class ShippingReportBloc extends Bloc<ShippingReportEvent, ShippingReportState> {
  final Repositories _repo;
  ShippingReportBloc(this._repo) : super(ShippingReportInitial()) {


    on<LoadShippingReportEvent>((event, emit) async{
      emit(ShippingReportLoadingState());
      try{
        final shp = await _repo.getShippingReport(fromDate: event.fromDate, toDate: event.toDate, status: event.status, customer: event.customerId, vehicle: event.vehicleId);
        emit(ShippingReportLoadedState(shp));
      }catch(e){
        emit(ShippingReportErrorState(e.toString()));
      }
    });


    on<ResetShippingReportEvent>((event, emit) async{
      try{
        emit(ShippingReportInitial());
      }catch(e){
        emit(ShippingReportErrorState(e.toString()));
      }
    });


  }
}
