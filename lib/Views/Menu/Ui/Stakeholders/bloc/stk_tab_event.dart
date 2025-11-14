part of 'stk_tab_bloc.dart';

sealed class StakeholderTabEvent extends Equatable {
  const StakeholderTabEvent();
}

class StkOnChangedEvent extends StakeholderTabEvent{
  final StakeholderTabName tab;
  const StkOnChangedEvent(this.tab);
  @override
  List<Object?> get props => [tab];
}