import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Auth/bloc/auth_bloc.dart';
import 'package:zaitoon_petroleum/Views/Auth/models/login_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/EndOfYear/end_year.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/FxTransaction/fx_transaction.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/GlAccounts/gl_accounts.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Payroll/payroll.dart';
import '../../../../Features/Generic/rounded_tab.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import 'Ui/Currency/currency.dart';
import 'bloc/financial_tab_bloc.dart';

class FinanceView extends StatelessWidget {
  const FinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state as AuthenticatedState;
    final login = auth.loginData;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: BlocBuilder<FinanceTabBloc, FinanceTabState>(
          builder: (context, state) {
            final tabs = <TabDefinition<FinanceTabName>>[
              if (login.hasPermission(33) ?? false)
              TabDefinition(
                value: FinanceTabName.currencies,
                label: AppLocalizations.of(context)!.currencyTitle,
                screen: const CurrencyTabView(),
              ),
              if (login.hasPermission(6) ?? false)
                TabDefinition(
                  value: FinanceTabName.glAccounts,
                  label: AppLocalizations.of(context)!.glAccounts,
                  screen: const GlAccountsView(),
                ),
              if (login.hasPermission(10) ?? false)
              TabDefinition(
                value: FinanceTabName.crossCurrency,
                label: AppLocalizations.of(context)!.fxTransaction,
                screen: const FxTransactionView(),
              ),
              if (login.hasPermission(7) ?? false)
              TabDefinition(
                value: FinanceTabName.payroll,
                label: AppLocalizations.of(context)!.payRoll,
                screen: const PayrollView(),
              ),
              if (login.hasPermission(9) ?? false)
              TabDefinition(
                value: FinanceTabName.endOfYear,
                label: AppLocalizations.of(context)!.fiscalYear,
                screen: const EndOfYearView(),
              ),
            ];

            // ✅ ADD THIS CHECK HERE
            if (tabs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded,size: 50,color: Theme.of(context).colorScheme.error,),
                    Text(
                        AppLocalizations.of(context)!.deniedPermissionTitle,
                        style: Theme.of(context).textTheme.titleMedium
                    ),
                    Text(
                      AppLocalizations.of(context)!.deniedPermissionMessage,
                      style: Theme.of(context).textTheme.bodyMedium
                    ),
                  ],
                ),
              );
            }

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
              onChanged: (val) => context.read<FinanceTabBloc>().add(
                FinanceOnChangedEvent(val),
              ),
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
