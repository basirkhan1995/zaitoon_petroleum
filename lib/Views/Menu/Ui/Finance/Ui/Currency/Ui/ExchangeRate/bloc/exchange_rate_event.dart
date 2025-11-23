part of 'exchange_rate_bloc.dart';

sealed class ExchangeRateEvent extends Equatable {
  const ExchangeRateEvent();
}

class LoadExchangeRateEvent extends ExchangeRateEvent{
  final String ccyCode;
  const LoadExchangeRateEvent(this.ccyCode);
  @override
  List<Object?> get props => [ccyCode];
}

class AddExchangeRateEvent extends ExchangeRateEvent{
  final ExchangeRateModel newRate;
  const AddExchangeRateEvent(this.newRate);
  @override
  List<Object> get props => [newRate];
}