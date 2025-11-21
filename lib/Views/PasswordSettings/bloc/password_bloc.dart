import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';

part 'password_event.dart';
part 'password_state.dart';

class PasswordBloc extends Bloc<PasswordEvent, PasswordState> {
  final Repositories _repo;
  PasswordBloc(this._repo) : super(PasswordInitial()) {
    on<PasswordEvent>((event, emit) {

    });
  }
}
