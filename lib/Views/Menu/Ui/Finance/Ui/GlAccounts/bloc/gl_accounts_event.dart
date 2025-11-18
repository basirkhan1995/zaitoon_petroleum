part of 'gl_accounts_bloc.dart';

sealed class GlAccountsEvent extends Equatable {
  const GlAccountsEvent();
}

class LoadGlAccountEvent extends GlAccountsEvent{
  final String local;
  const LoadGlAccountEvent(this.local);
  @override
  List<Object?> get props => [local];
}