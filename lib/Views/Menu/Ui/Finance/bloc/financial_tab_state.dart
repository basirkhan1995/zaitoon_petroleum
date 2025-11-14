part of 'financial_tab_bloc.dart';

enum FinanceTabName {endOfYear, exchangeRate, currencies}

class FinanceTabState extends Equatable {
  final FinanceTabName tab;
  const FinanceTabState({this.tab = FinanceTabName.endOfYear});
  @override
  List<Object> get props => [tab];
}
