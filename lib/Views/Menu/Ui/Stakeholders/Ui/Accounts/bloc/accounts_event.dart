part of 'accounts_bloc.dart';

sealed class AccountsEvent extends Equatable {
  const AccountsEvent();
}

class LoadAccountsEvent extends AccountsEvent{
  final int? ownerId;
  const LoadAccountsEvent({this.ownerId});
  @override
  List<Object?> get props => [ownerId];
}

class LoadStkAccountsEvent extends AccountsEvent{
  final String? search;
  const LoadStkAccountsEvent({this.search});
  @override
  List<Object?> get props => [search];
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