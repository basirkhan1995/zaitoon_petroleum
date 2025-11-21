part of 'individuals_bloc.dart';

sealed class IndividualsEvent extends Equatable {
  const IndividualsEvent();
}

class LoadIndividualsEvent extends IndividualsEvent{
  final int? indId;
  const LoadIndividualsEvent({this.indId});
  @override
  List<Object?> get props => [];
}

class SearchIndividualsEvent extends IndividualsEvent {
  final String query;
  const SearchIndividualsEvent(this.query);
  @override
  List<Object?> get props => [query];
}


class AddIndividualEvent extends IndividualsEvent{
  final IndividualsModel newStk;
  const AddIndividualEvent(this.newStk);
  @override
  List<Object?> get props => [newStk];
}

class EditIndividualEvent extends IndividualsEvent{
  final IndividualsModel newStk;
  const EditIndividualEvent(this.newStk);
  @override
  List<Object?> get props => [newStk];
}