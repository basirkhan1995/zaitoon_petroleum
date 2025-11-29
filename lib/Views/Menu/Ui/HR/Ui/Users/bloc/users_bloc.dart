import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/localization_services.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import '../model/user_model.dart';


part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final Repositories _repo;
  UsersBloc(this._repo) : super(UsersInitial()) {
    
    on<LoadUsersEvent>((event, emit) async{
      emit(UsersLoadingState());
      try{
       final users = await _repo.getUsers(usrOwner: event.usrOwner);
       emit(UsersLoadedState(users));
      }catch(e){
        emit(UsersErrorState(e.toString()));
      }
    });

    on<AddUserEvent>((event, emit) async{
      final locale = localizationService.loc;
      emit(UsersLoadingState());
      try{
        final response = await _repo.addUser(newUser: event.newUser);
        final String msg = response['msg'];
        if (msg == "success") {
          emit(UserSuccessState());
          add(LoadUsersEvent());
        }else if(msg == "email exists"){
          emit(UsersErrorState(locale.emailExists));
        }else if(msg == "user exists"){
          emit(UsersErrorState(locale.usernameExists));
        }
      }catch(e){
        emit(UsersErrorState(e.toString()));
      }
    });

    on<UpdateUserEvent>((event, emit) async{
      emit(UsersLoadingState());
      try{
        final response = await _repo.editUser(newUser: event.newUser);
        final String msg = response['msg'];
        if (msg == "success") {
          emit(UserSuccessState());
          add(LoadUsersEvent());
        }
      }catch(e){
        emit(UsersErrorState(e.toString()));
      }
    });

  }
}
