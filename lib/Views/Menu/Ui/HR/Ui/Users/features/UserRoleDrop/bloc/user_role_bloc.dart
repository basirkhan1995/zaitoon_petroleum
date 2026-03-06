import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/features/UserRoleDrop/user_role_drop.dart';

part 'user_role_event.dart';
part 'user_role_state.dart';

class UserRoleBloc extends Bloc<UserRoleEvent, UserRoleState> {
  final Repositories _repo;
  UserRoleBloc(this._repo) : super(UserRoleInitial()) {
    on<LoadUserRolesEvent>((event, emit) async{
      try{
        final role = await _repo.getUserRole();
        emit(UserRoleLoadedState(role));
      }catch(e){
        emit(UserRoleErrorState(e.toString()));
      }
    });

    on<AddUserRoleEvent>((event, emit) async{
      try{
       final role = await _repo.addNewRole(usrName: event.usrName, roleName: event.roleName);
       final msg = role["msg"];
       if(msg == "success"){
         emit(UserRoleSuccessState());
         add(LoadUserRolesEvent());
       }else{
         emit(UserRoleErrorState(msg));
       }
      }catch(e){
        emit(UserRoleErrorState(e.toString()));
      }
    });

    on<UpdateUserRoleEvent>((event, emit) async{
      try{

      }catch(e){
        emit(UserRoleErrorState(e.toString()));
      }
    });
  }
}
