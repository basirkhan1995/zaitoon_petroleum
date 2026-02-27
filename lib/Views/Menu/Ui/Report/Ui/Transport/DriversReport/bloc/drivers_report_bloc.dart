import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'drivers_report_event.dart';
part 'drivers_report_state.dart';

class DriversReportBloc extends Bloc<DriversReportEvent, DriversReportState> {
  DriversReportBloc() : super(DriversReportInitial()) {
    on<DriversReportEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
