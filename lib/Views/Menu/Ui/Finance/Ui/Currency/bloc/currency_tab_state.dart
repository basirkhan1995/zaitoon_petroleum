part of 'currency_tab_bloc.dart';

enum CurrencyTabName {currency, rates}

final class CurrencyTabState extends Equatable {
  final CurrencyTabName tabs;
  const CurrencyTabState({this.tabs = CurrencyTabName.currency});
  @override
  List<Object> get props => [tabs];
}
