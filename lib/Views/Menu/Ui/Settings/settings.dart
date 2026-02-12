import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Auth/models/login_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Backup/backup.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/company_tab.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/stock_settings.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/TxnTypes/txn_types_view.dart';
import '../../../../Features/Generic/tab_bar.dart';
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
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = state.loginData;
    return Scaffold(
      body: BlocBuilder<SettingsTabBloc, SettingsTabState>(
        builder: (context, state) {
          final tabs = <ZTabItem<SettingsTabName>>[
            if (login.hasPermission(58) ?? false)
              ZTabItem(
                value: SettingsTabName.general,
                label: AppLocalizations.of(context)!.general,
                screen: const GeneralView(),
              ),
            if (login.hasPermission(61) ?? false)
              ZTabItem(
                value: SettingsTabName.company,
                label: AppLocalizations.of(context)!.company,
                screen: const CompanyTabsView(),
              ),

            if (login.usrRole == "Super")
              ZTabItem(
                value: SettingsTabName.txnTypes,
                label: AppLocalizations.of(context)!.transactionType,
                screen: const TxnTypesView(),
              ),

            if (login.hasPermission(61) ?? false)
            ZTabItem(
              value: SettingsTabName.stock,
              label: AppLocalizations.of(context)!.stock,
              screen: const StockSettingsView(),
            ),

            if (login.hasPermission(32) ?? false)
              ZTabItem(
                value: SettingsTabName.backup,
                label: AppLocalizations.of(context)!.backupTitle,
                screen: const BackupView(),
              ),
            if (login.hasPermission(70) ?? false)
            ZTabItem(
              value: SettingsTabName.about,
              label: AppLocalizations.of(context)!.about,
              screen: const AboutView(),
            ),
          ];

          final availableValues = tabs.map((tab) => tab.value).toList();
          final selected = availableValues.contains(state.tabs)
              ? state.tabs
              : availableValues.first;

          return ZTabContainer<SettingsTabName>(
            /// Tab data
            tabs: tabs,
            selectedValue: selected,

            /// Bloc update
            onChanged: (val) => context
                .read<SettingsTabBloc>()
                .add(SettingsOnChangeEvent(val)),

            title: AppLocalizations.of(context)!.settings,
            description: AppLocalizations.of(context)!.settingsHint,
            /// Colors and style
            style: ZTabStyle.rounded,
            tabBarPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 3),
            borderRadius: 0,
            selectedColor: Theme.of(context).colorScheme.primary,
            unselectedTextColor: Theme.of(context).colorScheme.secondary,
            selectedTextColor: Theme.of(context).colorScheme.surface,
            tabContainerColor: Theme.of(context).colorScheme.surface,
          );
        },
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