import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/IncomeExpense/model/prj_inc_exp_model.dart';

part 'project_inc_exp_event.dart';
part 'project_inc_exp_state.dart';

class ProjectIncExpBloc extends Bloc<ProjectIncExpEvent, ProjectIncExpState> {
  final Repositories _repo;
  ProjectIncExpBloc(this._repo) : super(ProjectIncExpInitial()) {

    on<LoadProjectIncExpEvent>((event, emit) async {
      emit(ProjectIncExpLoadingState());
      try {
        final inOut = await _repo.getProjectIncomeExpense(projectId: event.projectId);
        if (inOut != null) {
          emit(ProjectIncExpLoadedState(inOut));
        } else {
          // Handle case with no data - emit loaded state with empty payments
          emit(ProjectIncExpLoadedState(
            ProjectInOutModel(
              prjId: event.projectId,
              payments: [],
            ),
          ));
        }
      } catch (e) {
        emit(ProjectIncExpErrorState(e.toString()));
      }
    });

    on<AddProjectIncExpEvent>((event, emit) async {
      emit(ProjectIncExpLoadingState());
      try {
        final result = await _repo.addProjectIncomeExpense(newData: event.newData);
        // After adding, reload the data
        add(LoadProjectIncExpEvent(event.newData.prjId!));
        emit(ProjectIncExpSuccessState());
      } catch (e) {
        emit(ProjectIncExpErrorState(e.toString()));
      }
    });

    on<UpdateProjectIncExpEvent>((event, emit) async {
      emit(ProjectIncExpLoadingState());
      try {
        final result = await _repo.updateProjectIncomeExpense(newData: event.newData);
        // After updating, reload the data
        add(LoadProjectIncExpEvent(event.newData.prjId!));
        emit(ProjectIncExpSuccessState());
      } catch (e) {
        emit(ProjectIncExpErrorState(e.toString()));
      }
    });
  }
}
