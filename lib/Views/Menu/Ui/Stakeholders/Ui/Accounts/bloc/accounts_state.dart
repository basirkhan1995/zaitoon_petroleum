part of 'accounts_bloc.dart';

sealed class AccountsState extends Equatable {
  const AccountsState();
}

final class AccountsInitial extends AccountsState {
  @override
  List<Object> get props => [];
}

final class AccountLoadingState extends AccountsState {
  @override
  List<Object> get props => [];
}

final class AccountSuccessState extends AccountsState {
  @override
  List<Object> get props => [];
}

final class AccountErrorState extends AccountsState {
  final String message;
  const AccountErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class AccountLoadedState extends AccountsState {
  final List<AccountsModel> accounts;
  final AccountsModel? selectedAccount;

  const AccountLoadedState(this.accounts, {this.selectedAccount});

  @override
  List<Object?> get props => [accounts, selectedAccount];
}


final class StkAccountLoadedState extends AccountsState {
  final List<StakeholdersAccountsModel> accounts;
  const StkAccountLoadedState(this.accounts);
  @override
  List<Object> get props => [accounts];
}