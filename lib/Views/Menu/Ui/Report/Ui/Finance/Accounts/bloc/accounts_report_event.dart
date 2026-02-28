part of 'accounts_report_bloc.dart';

sealed class AccountsReportEvent extends Equatable {
  const AccountsReportEvent();
}

class LoadAccountsReportEvent extends AccountsReportEvent{
  final String? search;
  final String? currency;
  final double? limit;
  final int? status;
  const LoadAccountsReportEvent({this.search, this.currency, this.limit, this.status});
  @override
  List<Object?> get props => [search,currency,limit, status];
}

class ResetAccountsReportEvent extends AccountsReportEvent{
  @override
  List<Object?> get props => [];
}