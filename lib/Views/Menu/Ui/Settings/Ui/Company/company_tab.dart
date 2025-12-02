import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import '../../../../../../Features/Generic/generic_menu.dart';
import '../../../../../../Localizations/l10n/translations/app_localizations.dart';
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

    final menuItems = [
      MenuDefinition(
        value: CompanySettingsMenuName.profile,
        label: AppLocalizations.of(context)!.profile,
        screen: const CompanySettingsView(),
        icon: Icons.settings,
      ),
      MenuDefinition(
        value: CompanySettingsMenuName.branch,
        label: AppLocalizations.of(context)!.branches,
        screen: const BranchesView(),
        icon: Icons.location_disabled_rounded,
      ),

    ];

    return BlocBuilder<CompanySettingsMenuBloc, CompanySettingsMenuState>(
      builder: (context, state) {
        return GenericMenuWithScreen(
            isExpanded: false,
            menuWidth: context.scaledFont(0.13),
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 8),
            margin: EdgeInsets.zero,
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
