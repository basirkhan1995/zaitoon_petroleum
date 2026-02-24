part of 'services_bloc.dart';

sealed class ServicesEvent extends Equatable {
  const ServicesEvent();
}
class AddProjectServicesEvent extends ServicesEvent {
  final ServicesModel newData;
  const AddProjectServicesEvent(this.newData);
  @override
  List<Object?> get props => [newData];
}

class UpdateProjectServicesEvent extends ServicesEvent {
  final ServicesModel newData;
  const UpdateProjectServicesEvent(this.newData);
  @override
  List<Object?> get props => [newData];
}

class DeleteProjectServicesEvent extends ServicesEvent {
  final int pjrId;
  final String usrName;
  const DeleteProjectServicesEvent(this.pjrId,this.usrName);
  @override
  List<Object?> get props => [pjrId,usrName];
}

class LoadProjectServicesEvent extends ServicesEvent {
  const LoadProjectServicesEvent();
  @override
  List<Object?> get props => [];
}


