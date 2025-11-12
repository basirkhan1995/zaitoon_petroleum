part of 'transaction_tab_bloc.dart';

enum JournalTabName {allTransactions, authorized, pending}

class JournalTabState extends Equatable {
  final JournalTabName tab;
  const JournalTabState({this.tab = JournalTabName.allTransactions});
  @override
  List<Object?> get props => [tab];

}
