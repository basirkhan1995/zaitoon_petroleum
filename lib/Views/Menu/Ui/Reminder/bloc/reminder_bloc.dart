import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import '../model/reminder_model.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final Repositories _repo;

  ReminderBloc(this._repo) : super(ReminderInitial()) {

    /// LOAD ALERT REMINDERS
    on<LoadAlertReminders>((event, emit) async {
      emit(state.copyWith(loading: true, error: null));

      try {
        final data = await _repo.getAlertReminders(alert: event.alert);

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
      emit(state.copyWith(loading: true));

      try {
        final res = await _repo.addNewReminder(newData: event.model);

        if (res['msg'] == "success") {
          add(const LoadAlertReminders());
          emit(state.copyWith(successMsg: "Reminder Added"));
        } else {
          emit(state.copyWith(error: res['msg']));
        }
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });

    /// UPDATE REMINDER
    on<UpdateReminderEvent>((event, emit) async {
      emit(state.copyWith(loading: true));

      try {
        final res = await _repo.updateReminder(newData: event.model);

        if (res['msg'] == "success") {
          add(const LoadAlertReminders());
          emit(state.copyWith(successMsg: "Reminder Updated"));
        } else {
          emit(state.copyWith(error: res['msg']));
        }
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
  }
}
