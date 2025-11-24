part of 'exchange_rate_bloc.dart';

sealed class ExchangeRateState extends Equatable {
  const ExchangeRateState();
}

final class ExchangeRateInitial extends ExchangeRateState {
  @override
  List<Object> get props => [];
}

final class ExchangeRateLoadingState extends ExchangeRateState {
  @override
  List<Object> get props => [];
}

final class ExchangeRateSuccessState extends ExchangeRateState {
  @override
  List<Object> get props => [];
}

final class ExchangeRateErrorState extends ExchangeRateState {
  final String message;
  const ExchangeRateErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class ExchangeRateLoadedState extends ExchangeRateState {
  final List<ExchangeRateModel> rates;
  const ExchangeRateLoadedState(this.rates);
  @override
  List<Object> get props => [rates];
}
