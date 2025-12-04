part of 'company_settings_menu_bloc.dart';

enum CompanySettingsMenuName{profile,branch,storage}

final class CompanySettingsMenuState extends Equatable {
  final CompanySettingsMenuName tabs;
  const CompanySettingsMenuState({this.tabs = CompanySettingsMenuName.profile});
  @override
  List<Object> get props => [tabs];
}
