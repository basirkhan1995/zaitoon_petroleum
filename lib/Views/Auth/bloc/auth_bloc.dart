import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Auth/models/login_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/model/com_model.dart';

import '../../../Services/localization_services.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Repositories _repo;
  AuthBloc(this._repo) : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      final locale = localizationService.loc;
      emit(AuthLoadingState());

      try {
        final response = await _repo.login(
          username: event.usrName,
          password: event.usrPassword,
        );

        if (response.containsKey("msg") && response["msg"] != null) {
          switch (response["msg"]) {
            case "incorrect user or Password": throw locale.incorrectCredential;
            case "incorrect password": throw locale.incorrectPassword;

            default: throw response["msg"];
          }
        }

        // Success: parse login
        final loginData = LoginData.fromMap(response);
        emit(AuthenticatedState(loginData));

      } catch (e) {
        emit(AuthErrorState(e.toString()));
      }
    });

  }
}
