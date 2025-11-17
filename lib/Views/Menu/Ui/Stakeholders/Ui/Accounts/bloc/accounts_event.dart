part of 'accounts_bloc.dart';

sealed class AccountsEvent extends Equatable {
  const AccountsEvent();
}

class LoadAccountsEvent extends AccountsEvent{
  final int? ownerId;
  final int? accId;
  const LoadAccountsEvent({this.ownerId, this.accId});
  @override
  List<Object?> get props => [ownerId, accId];
}

class AddAccountEvent extends AccountsEvent{
  final AccountsModel newAccount;
  const AddAccountEvent(this.newAccount);
  @override
  List<Object?> get props => [newAccount];
}

class UpdateAccountEvent extends AccountsEvent{
  final AccountsModel newAccount;
  const UpdateAccountEvent(this.newAccount);
  @override
  List<Object?> get props => [newAccount];
}