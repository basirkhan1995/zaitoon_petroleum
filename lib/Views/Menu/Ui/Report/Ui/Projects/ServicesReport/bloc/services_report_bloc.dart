import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Projects/ServicesReport/model/services_report_model.dart';

part 'services_report_event.dart';
part 'services_report_state.dart';

class ServicesReportBloc extends Bloc<ServicesReportEvent, ServicesReportState> {
  ServicesReportBloc() : super(ServicesReportInitial()) {
    on<ServicesReportEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
