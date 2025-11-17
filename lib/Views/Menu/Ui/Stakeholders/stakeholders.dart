import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/Ui/individuals.dart';
import '../../../../Features/Generic/tab_bar.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import 'Ui/Accounts/Ui/accounts.dart';
import 'bloc/stk_tab_bloc.dart';

class StakeholdersView extends StatelessWidget {
  const StakeholdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: BlocBuilder<StakeholderTabBloc, StakeholderTabState>(
          builder: (context, state) {
            final tabs = <ZTabItem<StakeholderTabName>>[
              ZTabItem(
                value: StakeholderTabName.entities,
                label: AppLocalizations.of(context)!.stakeholders,
                screen: const IndividualsView(),
              ),
              ZTabItem(
                value: StakeholderTabName.accounts,
                label: AppLocalizations.of(context)!.accounts,
                screen: const AccountsView(),
              ),
            ];

            final available = tabs.map((t) => t.value).toList();
            final selected = available.contains(state.tab)
                ? state.tab
                : available.first;

            return ZTabContainer<StakeholderTabName>(
              title: AppLocalizations.of(context)!.stakeholders,

              /// Tab data
              tabs: tabs,
              selectedValue: selected,

              /// Bloc update
              onChanged: (val) => context
                  .read<StakeholderTabBloc>()
                  .add(StkOnChangedEvent(val)),

              /// Colors for underline style
              style: ZTabStyle.underline,
              selectedColor: Theme.of(context).colorScheme.primary,
              unselectedTextColor: Theme.of(context).colorScheme.secondary,
              selectedTextColor: Theme.of(context).colorScheme.surface,
              tabContainerColor: Theme.of(context).colorScheme.surface,
            );
          },
        ),
      ),
    );
  }
}
