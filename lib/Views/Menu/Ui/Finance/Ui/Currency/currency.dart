import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Auth/models/login_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/ExchangeRate/Ui/exchange_rate.dart';
import '../../../../../../Features/Generic/generic_menu.dart';
import '../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';
import 'Ui/Currencies/Ui/currencies.dart';
import 'bloc/currency_tab_bloc.dart';

class CurrencyTabView extends StatefulWidget {
  const CurrencyTabView({super.key});

  @override
  State<CurrencyTabView> createState() => _CurrencyTabViewState();
}
class _CurrencyTabViewState extends State<CurrencyTabView> {


  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = state.loginData;
    final menuItems = [
      if(login.hasPermission(12) ?? false)...[
        MenuDefinition(
          value: CurrencyTabName.currency,
          label: AppLocalizations.of(context)!.currencyTitle,
          screen: const CurrenciesView(),
          icon: Icons.currency_yen_rounded,
        ),
      ],

    if(login.hasPermission(13) ?? false)...[
      MenuDefinition(
        value: CurrencyTabName.rates,
        label: AppLocalizations.of(context)!.exchangeRate,
        screen: const ExchangeRateView(newRateButton: true,settingButton: false,),
        icon: Icons.ssid_chart_outlined,
      ),
    ]];

    return BlocBuilder<CurrencyTabBloc, CurrencyTabState>(
      builder: (context, state) {
        return GenericMenuWithScreen(
            menuWidth: 190,
            isExpanded: false,
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 8),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha:.09),
            selectedTextColor: Theme.of(context).colorScheme.primary,
            unselectedTextColor: Theme.of(context).colorScheme.secondary,
            selectedValue: state.tabs,
            onChanged: (value)=> context.read<CurrencyTabBloc>().add(CcyOnChangedEvent(value)),
            items: menuItems
        );
      },
    );
  }
}
