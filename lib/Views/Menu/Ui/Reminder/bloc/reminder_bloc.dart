import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import '../model/reminder_model.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final Repositories _repo;
  int? _currentAlertFilter; // Track current alert filter

  ReminderBloc(this._repo) : super(ReminderInitial()) {

    /// LOAD ALERT REMINDERS
    on<LoadAlertReminders>((event, emit) async {
      emit(state.copyWith(loading: true, error: null));
      try {
        final data = await _repo.getAlertReminders(alert: event.alert);
        _currentAlertFilter = event.alert; // Store current filter

        emit(state.copyWith(
          reminders: data,
          loading: false,
        ));
      } catch (e) {
        emit(state.copyWith(
          loading: false,
          error: e.toString(),
        ));
      }
    });

    /// ADD REMINDER
    on<AddReminderEvent>((event, emit) async {
      emit(state.copyWith(loading: true, error: null));

      try {
        final res = await _repo.addNewReminder(newData: event.model);

        if (res['msg'] == "success") {
          // Reload with current filter if exists, otherwise use alert: 1
          final alertToLoad = _currentAlertFilter ?? 1;
          final data = await _repo.getAlertReminders(alert: alertToLoad);

          emit(state.copyWith(
            reminders: data,
            loading: false,
            successMsg: "Reminder Added",
          ));
        } else {
          emit(state.copyWith(
            loading: false,
            error: res['msg'],
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          loading: false,
          error: e.toString(),
        ));
      }
    });

    /// UPDATE REMINDER
    on<UpdateReminderEvent>((event, emit) async {
      emit(state.copyWith(loading: true, error: null, successMsg: null));

      try {
        final res = await _repo.updateReminder(newData: event.model);

        if (res['msg'] == "success") {
          // Reload with current filter if exists, otherwise use alert: 1
          final alertToLoad = _currentAlertFilter ?? 1;
          final data = await _repo.getAlertReminders(alert: alertToLoad);

          emit(state.copyWith(
            reminders: data,
            loading: false,
            successMsg: "Reminder Updated",
          ));
        } else {
          emit(state.copyWith(
            loading: false,
            error: res['msg'],
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          loading: false,
          error: e.toString(),
        ));
      }
    });
  }
}