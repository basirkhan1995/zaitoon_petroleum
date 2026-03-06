part of 'general_tab_bloc.dart';

enum GeneralTabName {system, rolesAndPermissions, profileSettings, password}

class GeneralTabState extends Equatable {
  final GeneralTabName tab;
  const GeneralTabState({this.tab = GeneralTabName.system});
  @override
  List<Object?> get props => [tab];
}

