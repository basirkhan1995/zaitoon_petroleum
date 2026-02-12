import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/storage.dart';
import '../../../../../../Features/Generic/generic_menu.dart';
import '../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../../Auth/models/login_model.dart';
import 'Branches/Ui/branches.dart';
import 'CompanyProfile/company.dart';
import 'bloc/company_settings_menu_bloc.dart';

class CompanyTabsView extends StatefulWidget {
  const CompanyTabsView({super.key});

  @override
  State<CompanyTabsView> createState() => _CompanyTabsViewState();
}

class _CompanyTabsViewState extends State<CompanyTabsView> {


  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = state.loginData;

    final menuItems = [
      if (login.hasPermission(62) ?? false)
      MenuDefinition(
        value: CompanySettingsMenuName.profile,
        label: AppLocalizations.of(context)!.profile,
        screen: const CompanySettingsView(),
        icon: Icons.settings,
      ),

      if (login.hasPermission(63) ?? false)
      MenuDefinition(
        value: CompanySettingsMenuName.branch,
        label: AppLocalizations.of(context)!.branch,
        screen: const BranchesView(),
        icon: Icons.location_city_rounded,
      ),

      if (login.hasPermission(64) ?? false)
      MenuDefinition(
        value: CompanySettingsMenuName.storage,
        label: AppLocalizations.of(context)!.storages,
        screen: const StorageView(),
        icon: Icons.inventory_2_rounded,
      ),

    ];

    return BlocBuilder<CompanySettingsMenuBloc, CompanySettingsMenuState>(
      builder: (context, state) {
        return GenericMenuWithScreen(
            isExpanded: false,
            menuWidth: context.scaledFont(0.13),
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 8),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha:.09),
            selectedTextColor: Theme.of(context).colorScheme.primary,
            unselectedTextColor: Theme.of(context).colorScheme.secondary,
            selectedValue: state.tabs,
            onChanged: (value)=> context.read<CompanySettingsMenuBloc>().add(CompanySettingsOnChangedEvent(value)),
            items: menuItems
        );
      },
    );
  }
}
