import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Auth/models/login_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/company_tab.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/stock_settings.dart';
import '../../../../Features/Generic/rounded_tab.dart';
import '../../../../Features/Other/responsive.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../Auth/bloc/auth_bloc.dart';
import 'Ui/About/about.dart';
import 'Ui/General/general.dart';
import 'bloc/settings_tab_bloc.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(),
      tablet: _Tablet(),
    );
  }
}

class _Desktop extends StatelessWidget {
  const _Desktop();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state as AuthenticatedState;
    final login = auth.loginData;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: BlocBuilder<SettingsTabBloc, SettingsTabState>(
          builder: (context, state) {
            final tabs = <TabDefinition<SettingsTabName>>[
              if(login.hasPermission(31) ?? false)
              TabDefinition(
                value: SettingsTabName.general,
                label: AppLocalizations.of(context)!.general,
                screen: const GeneralView(),
              ),
              if(login.hasPermission(32) ?? false)
              TabDefinition(
                value: SettingsTabName.company,
                label: AppLocalizations.of(context)!.company,
                screen: const CompanyTabsView(),
              ),

              TabDefinition(
                value: SettingsTabName.stock,
                label: AppLocalizations.of(context)!.stock,
                screen: const StockSettingsView(),
              ),

              TabDefinition(
                value: SettingsTabName.about,
                label: AppLocalizations.of(context)!.about,
                screen: const AboutView(),
              ),
            ];

            final availableValues = tabs.map((tab) => tab.value).toList();
            final selected = availableValues.contains(state.tabs)
                ? state.tabs
                : availableValues.first;

            return GenericTab<SettingsTabName>(
              borderRadius: 3,

              title: AppLocalizations.of(context)!.settings,
              description: AppLocalizations.of(context)!.settingsHint,
              tabContainerColor: Theme.of(context).colorScheme.surface,
              selectedValue: selected,
              onChanged: (val) => context.read<SettingsTabBloc>().add(SettingsOnChangeEvent(val)),
              tabs: tabs,
              selectedColor: Theme.of(context).colorScheme.primary,
              selectedTextColor: Theme.of(context).colorScheme.surface,
              unselectedTextColor: Theme.of(context).colorScheme.secondary,
            );
          },
        ),
      ),
    );
  }
}
class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


