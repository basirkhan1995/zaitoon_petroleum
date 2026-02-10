import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Payroll/model/payroll_model.dart';

part 'payroll_event.dart';
part 'payroll_state.dart';

class PayrollBloc extends Bloc<PayrollEvent, PayrollState> {
  final Repositories _repo;
  String? _currentDate;
  List<PayrollModel>? _cachedPayroll;
  PayrollBloc(this._repo) : super(PayrollInitial()) {

    on<LoadPayrollEvent>((event, emit) async {
      // Only show loading if it's initial load or date changed
      if (state is PayrollInitial ||
          state is PayrollErrorState ||
          _currentDate != event.date) {
        emit(PayrollLoadingState());
      } else {
        // Silent loading - maintain current state
        emit(PayrollSilentLoadingState(
            _cachedPayroll ?? []
        ));
      }

      try {
        final res = await _repo.getPayroll(date: event.date);
        _currentDate = event.date;
        _cachedPayroll = res;
        emit(PayrollLoadedState(res));
      } catch (e) {
        emit(PayrollErrorState(e.toString()));
      }
    });
  }
}
