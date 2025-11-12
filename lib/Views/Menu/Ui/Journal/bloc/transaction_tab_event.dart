part of 'transaction_tab_bloc.dart';

sealed class JournalTabEvent extends Equatable {
  const JournalTabEvent();
}

class JournalOnChangedEvent extends JournalTabEvent{
  final JournalTabName tab;
  const JournalOnChangedEvent(this.tab);
  @override
  List<Object?> get props => [tab];
}