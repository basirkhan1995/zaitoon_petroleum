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

class LoadAccountsFilterEvent extends AccountsEvent{
  final int? start;
  final int? end;
  final String? input;
  final String? locale;
  final List<String>? exclude;
  final String? ccy;

  const LoadAccountsFilterEvent({this.start, this.end, this.input, this.locale, this.exclude, this.ccy});
  @override
  List<Object?> get props => [start,end,input, locale, exclude, ccy];
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
