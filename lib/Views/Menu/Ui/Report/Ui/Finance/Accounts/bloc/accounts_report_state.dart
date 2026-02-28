part of 'accounts_report_bloc.dart';

sealed class AccountsReportState extends Equatable {
  const AccountsReportState();
}

final class AccountsReportInitial extends AccountsReportState {
  @override
  List<Object> get props => [];
}

final class AccountsReportLoadingState extends AccountsReportState {
  @override
  List<Object> get props => [];
}

final class AccountsReportLoadedState extends AccountsReportState {
  final List<AccountsReportModel> accounts;
  const AccountsReportLoadedState(this.accounts);
  @override
  List<Object> get props => [accounts];
}

final class AccountsReportErrorState extends AccountsReportState {
  final String message;
  const AccountsReportErrorState(this.message);
  @override
  List<Object> get props => [message];
}


