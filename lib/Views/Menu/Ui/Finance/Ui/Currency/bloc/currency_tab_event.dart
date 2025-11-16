part of 'currency_tab_bloc.dart';

sealed class CurrencyTabEvent extends Equatable {
  const CurrencyTabEvent();
}

class CcyOnChangedEvent extends CurrencyTabEvent{
  final CurrencyTabName tab;
  const CcyOnChangedEvent(this.tab);
  @override
  List<Object?> get props => [tab];
}


