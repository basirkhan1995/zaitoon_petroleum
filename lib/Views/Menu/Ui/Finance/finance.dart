import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/EndOfYear/end_year.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/Payables/payables.dart';
import '../../../../Features/Generic/rounded_tab.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import 'Ui/Currency/currency.dart';
import 'bloc/financial_tab_bloc.dart';

class FinanceView extends StatelessWidget {
  const FinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: BlocBuilder<FinanceTabBloc, FinanceTabState>(
          builder: (context, state) {

            final tabs = <TabDefinition<FinanceTabName>>[

              TabDefinition(
                value: FinanceTabName.currencies,
                label: AppLocalizations.of(context)!.currencyTitle,
                screen: const CurrencyTabView(),
              ),
              TabDefinition(
                value: FinanceTabName.glAccounts,
                label: AppLocalizations.of(context)!.glAccounts,
                screen: const EndOfYearView(),
              ),
              TabDefinition(
                value: FinanceTabName.endOfYear,
                label: AppLocalizations.of(context)!.fiscalYear,
                screen: const EndOfYearView(),
              ),
                TabDefinition(
                  value: FinanceTabName.payroll,
                  label: AppLocalizations.of(context)!.payRoll,
                  screen: const PayablesView(),
                ),

              TabDefinition(
                value: FinanceTabName.crossCurrency,
                label: AppLocalizations.of(context)!.fxTransaction,
                screen: const PayablesView(),
              ),

            ];

            final availableValues = tabs.map((tab) => tab.value).toList();
            final selected = availableValues.contains(state.tab)
                ? state.tab
                : availableValues.first;

            return GenericTab<FinanceTabName>(
              borderRadius: 3,
              title: AppLocalizations.of(context)!.finance,
              description: AppLocalizations.of(context)!.manageFinance,
              tabContainerColor: Theme.of(context).colorScheme.surface,
              selectedValue: selected,
              onChanged: (val) => context.read<FinanceTabBloc>().add(FinanceOnChangedEvent(val)),
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
