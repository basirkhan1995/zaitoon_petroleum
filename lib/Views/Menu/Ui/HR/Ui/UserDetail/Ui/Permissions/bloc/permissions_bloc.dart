import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';

import '../per_model.dart';
part 'permissions_event.dart';
part 'permissions_state.dart';

class PermissionsBloc extends Bloc<PermissionsEvent, PermissionsState> {
  final Repositories _repo;
  PermissionsBloc(this._repo) : super(PermissionsInitial()) {

    on<LoadPermissionsEvent>((event, emit) async{
      emit(PermissionsLoadingState());
      try{
      final permissions = await _repo.getPermissions(usrName: event.usrName);
      emit(PermissionsLoadedState(permissions));
      }catch(e){
       emit(PermissionsErrorState(e.toString()));
      }
    });

    on<UpdatePermissionsStatusEvent>((event, emit) async{
      try{
        final permissions = await _repo.updatePermissionStatus(
            usrId: event.usrId, uprRole: event.uprRole,uprStatus: event.uprStatus,usrName: event.usrName);
        if(permissions["msg"] == "success") {
          add(LoadPermissionsEvent(event.usrName));
        }
      }catch(e){
        emit(PermissionsErrorState(e.toString()));
      }
    });

  }
}
