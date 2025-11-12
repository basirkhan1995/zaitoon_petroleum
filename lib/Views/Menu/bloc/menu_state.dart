part of 'menu_bloc.dart';

enum MenuName {dashboard, finance,journal,stakeholders,stock,settings,report, activity, analytics}

final class MenuState extends Equatable {
  final MenuName tabs;
  MenuState({this.tabs = MenuName.dashboard});
  @override
  List<Object> get props => [tabs];
}
