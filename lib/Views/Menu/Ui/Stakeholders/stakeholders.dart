import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/individuals.dart';
import '../../../../Features/Generic/rounded_tab.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import 'Ui/Accounts/accounts.dart';
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

            final tabs = <TabDefinition<StakeholderTabName>>[
              TabDefinition(
                value: StakeholderTabName.entities,
                label: AppLocalizations.of(context)!.stakeholders,
                screen: const IndividualsView(),
              ),
              // if (role == 0)
              TabDefinition(
                value: StakeholderTabName.accounts,
                label: AppLocalizations.of(context)!.accounts,
                screen: const AccountsView(),
              ),

            ];

            final availableValues = tabs.map((tab) => tab.value).toList();
            final selected = availableValues.contains(state.tab)
                ? state.tab
                : availableValues.first;

            return GenericTab<StakeholderTabName>(
              borderRadius: 3,
              title: AppLocalizations.of(context)!.stakeholders,
              description: AppLocalizations.of(context)!.stakeholderManage,
              tabContainerColor: Theme.of(context).colorScheme.surface,
              selectedValue: selected,
              onChanged: (val) => context.read<StakeholderTabBloc>().add(StkOnChangedEvent(val)),
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
