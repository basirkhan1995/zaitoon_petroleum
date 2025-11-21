import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Auth/models/login_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/model/com_model.dart';
import '../../../Features/Other/secure_storage.dart';
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
            case "incorrect": throw locale.incorrectCredential;
            case "blocked": throw locale.blockedMessage;
            case "unverified": throw locale.unverified;
            default: throw response["msg"];
          }
        }

        // Save credentials if "Remember Me" is checked
        if (event.rememberMe) {
          await SecureStorage.saveCredentials(event.usrName, event.usrPassword);
        } else {
          await SecureStorage.clearCredentials();
        }

        // Success: parse login
        final loginData = LoginData.fromMap(response);
        emit(AuthenticatedState(loginData));

      } catch (e) {
        emit(AuthErrorState(e.toString()));
      }
    });

    on<OnLogoutEvent>((event, emit){
      emit(UnAuthenticatedState());
    });

  }
}
