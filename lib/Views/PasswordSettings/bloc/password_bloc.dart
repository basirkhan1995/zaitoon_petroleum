import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';

part 'password_event.dart';
part 'password_state.dart';

class PasswordBloc extends Bloc<PasswordEvent, PasswordState> {
  final Repositories _repo;
  PasswordBloc(this._repo) : super(PasswordInitial()) {

    on<ForceChangePasswordEvent>((event, emit) async{
     try{
      final result = await _repo.forceChangePassword(credential: event.credential, newPassword: event.newPassword);
      if(result['msg'] == "success"){
        emit(PasswordChangedSuccessState());
      }
     }catch(e){
       emit(PasswordErrorState(e.toString()));
     }
    });

    on<ChangePasswordEvent>((event, emit) async{
      try{
        final result = await _repo.changePassword(credential: event.usrName, oldPassword: event.oldPassword, newPassword: event.newPassword);
        if(result['msg'] == "success"){
          emit(PasswordChangedSuccessState());
        }
      }catch(e){
        emit(PasswordErrorState(e.toString()));
      }
    });
  }
}
