part of 'ar_ap_bloc.dart';

sealed class ArApState extends Equatable {
  const ArApState();

  @override
  List<Object?> get props => [];
}

/// =====================
/// INITIAL
/// =====================
final class ArApInitial extends ArApState {}

/// =====================
/// LOADING
/// =====================
final class ArApLoadingState extends ArApState {}

/// =====================
/// LOADED
/// =====================
final class ArApLoadedState extends ArApState {
  final List<ArApModel> arAccounts;
  final List<ArApModel> apAccounts;

  const ArApLoadedState({
    required this.arAccounts,
    required this.apAccounts,
  });

  @override
  List<Object?> get props => [arAccounts, apAccounts];
}

/// =====================
/// ERROR
/// =====================
final class ArApErrorState extends ArApState {
  final String error;

  const ArApErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
