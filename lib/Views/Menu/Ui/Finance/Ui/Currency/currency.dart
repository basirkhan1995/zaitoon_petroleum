import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/ExchangeRate/exchange_rate.dart';
import '../../../../../../Features/Generic/generic_menu.dart';
import '../../../../../../Localizations/l10n/translations/app_localizations.dart';
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

    final menuItems = [
      MenuDefinition(
        value: CurrencyTabName.currency,
        label: AppLocalizations.of(context)!.currencyTitle,
        screen: const CurrenciesView(),
        icon: Icons.currency_yen_rounded,
      ),
      MenuDefinition(
        value: CurrencyTabName.rates,
        label: AppLocalizations.of(context)!.exchangeRate,
        screen: const ExchangeRateView(),
        icon: Icons.ssid_chart_outlined,
      ),
    ];

    return BlocBuilder<CurrencyTabBloc, CurrencyTabState>(
      builder: (context, state) {
        return GenericMenuWithScreen(
            menuWidth: 190,
            isExpanded: false,
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 8),
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
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
