part of 'services_bloc.dart';

sealed class ServicesEvent extends Equatable {
  const ServicesEvent();
}
class AddServicesEvent extends ServicesEvent {
  final ServicesModel newData;
  const AddServicesEvent(this.newData);
  @override
  List<Object?> get props => [newData];
}

class UpdateServicesEvent extends ServicesEvent {
  final ServicesModel newData;
  const UpdateServicesEvent(this.newData);
  @override
  List<Object?> get props => [newData];
}

class DeleteServicesEvent extends ServicesEvent {
  final int pjrId;
  final String usrName;
  const DeleteServicesEvent(this.pjrId,this.usrName);
  @override
  List<Object?> get props => [pjrId,usrName];
}

class LoadServicesEvent extends ServicesEvent {
  const LoadServicesEvent();
  @override
  List<Object?> get props => [];
}


