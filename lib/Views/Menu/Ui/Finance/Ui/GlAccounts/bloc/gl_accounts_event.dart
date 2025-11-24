part of 'gl_accounts_bloc.dart';

sealed class GlAccountsEvent extends Equatable {
  const GlAccountsEvent();
}

class LoadAllGlAccountEvent extends GlAccountsEvent{
  final String local;
  const LoadAllGlAccountEvent(this.local);
  @override
  List<Object?> get props => [local];
}

class LoadGlAccountEvent extends GlAccountsEvent{
  final String local;
  final List<int>? categories;
  final List<int>? excludeAccounts;
  final String? search;

  const LoadGlAccountEvent({required this.local, this.categories, this.excludeAccounts, this.search});
  @override
  List<Object?> get props => [local, categories, excludeAccounts, search];
}
