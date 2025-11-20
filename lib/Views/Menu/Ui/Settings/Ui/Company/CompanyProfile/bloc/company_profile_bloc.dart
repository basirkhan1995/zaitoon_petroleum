import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/model/com_model.dart';

part 'company_profile_event.dart';
part 'company_profile_state.dart';

class CompanyProfileBloc extends Bloc<CompanyProfileEvent, CompanyProfileState> {
  final Repositories _repo;
  CompanyProfileBloc(this._repo) : super(CompanyProfileInitial()) {

    on<LoadCompanyProfileEvent>((event, emit) async{
      emit(CompanyProfileLoadingState());
     try{
      final com = await _repo.getCompanyProfile();
      emit(CompanyProfileLoadedState(com));
     }catch(e){
       emit(CompanyProfileErrorState(e.toString()));
     }
    });

  }
}
