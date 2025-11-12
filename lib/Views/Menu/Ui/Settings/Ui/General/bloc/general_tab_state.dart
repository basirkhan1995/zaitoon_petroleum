part of 'general_tab_bloc.dart';

enum GeneralTabName {system, blocked, password, advanced}

class GeneralTabState extends Equatable {
  final GeneralTabName tab;
  const GeneralTabState({this.tab = GeneralTabName.system});
  @override
  List<Object?> get props => [tab];
}

