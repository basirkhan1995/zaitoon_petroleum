import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/GlAccounts/model/gl_model.dart';

part 'gl_accounts_event.dart';
part 'gl_accounts_state.dart';

class GlAccountsBloc extends Bloc<GlAccountsEvent, GlAccountsState> {
  final Repositories _repo;
  GlAccountsBloc(this._repo) : super(GlAccountsInitial()) {

    on<LoadAllGlAccountEvent>((event, emit) async{
      emit(GlAccountsLoadingState());
      try{
       final gl = await _repo.getAllGlAccounts(local: event.local);
       emit(GlAccountLoadedState(gl));
      }catch(e){
        emit(GlAccountsErrorState(e.toString()));
      }
    });

    on<LoadGlAccountEvent>((event, emit) async{
      emit(GlAccountsLoadingState());
      try{
        final gl = await _repo.getGlAccountsByOptions(local: event.local,categories: event.categories,excludeAccounts: event.excludeAccounts,search: event.search);
        emit(GlAccountLoadedState(gl));
      }catch(e){
        emit(GlAccountsErrorState(e.toString()));
      }
    });

  }
}
