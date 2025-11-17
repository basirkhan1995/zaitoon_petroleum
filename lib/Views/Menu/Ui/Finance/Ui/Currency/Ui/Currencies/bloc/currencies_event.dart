part of 'currencies_bloc.dart';

sealed class CurrenciesEvent extends Equatable {
  const CurrenciesEvent();
}

class LoadCurrenciesEvent extends CurrenciesEvent{
  final int? status;
  const LoadCurrenciesEvent({this.status});
  @override
  List<Object?> get props => [status];
}

class UpdateCurrenciesStatusEvent extends CurrenciesEvent{
  final int status;
  final String ccyCode;
  const UpdateCurrenciesStatusEvent({required this.status, required this.ccyCode});
  @override
  List<Object?> get props => [status,ccyCode];
}