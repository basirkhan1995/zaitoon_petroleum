import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/user_model.dart';

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


  }
}
