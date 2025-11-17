part of 'currencies_bloc.dart';

sealed class CurrenciesState extends Equatable {
  const CurrenciesState();
}

final class CurrenciesInitial extends CurrenciesState {
  @override
  List<Object> get props => [];
}

final class CurrenciesLoadingState extends CurrenciesState {
  @override
  List<Object> get props => [];
}

final class CurrenciesSuccessState extends CurrenciesState {
  @override
  List<Object> get props => [];
}

final class CurrenciesErrorState extends CurrenciesState {
  final String message;
  const CurrenciesErrorState(this.message);
  @override
  List<Object> get props => [message];
}

class CurrenciesLoadedState extends CurrenciesState{
  final List<CurrenciesModel> ccy;
  const CurrenciesLoadedState(this.ccy);
  @override
  List<Object> get props => [ccy];
}