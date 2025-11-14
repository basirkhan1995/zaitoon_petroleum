part of 'stk_tab_bloc.dart';

enum StakeholderTabName {entities, accounts}

class StakeholderTabState extends Equatable {
  final StakeholderTabName tab;
  const StakeholderTabState({this.tab = StakeholderTabName.entities});
  @override
  List<Object> get props => [tab];
}
