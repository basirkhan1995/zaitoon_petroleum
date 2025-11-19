import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Auth/models/login_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Purchase/purchase.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Returns/returns.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Sales/sales.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Shift/shift.dart';
import '../../../../Features/Generic/tab_bar.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../Auth/bloc/auth_bloc.dart';
import 'Ui/Products/products.dart';
import 'bloc/stock_tab_bloc.dart';

class StockView extends StatelessWidget {
  const StockView({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final auth = context.watch<AuthBloc>().state as AuthenticatedState;
    final login = auth.loginData;
    return Scaffold(
      body: BlocBuilder<StockTabBloc, StockTabState>(
        builder: (context, state) {
          final tabs = <ZTabItem<StockTabsName>>[
            if (login.hasPermission(11) ?? false)
              ZTabItem(
                value: StockTabsName.products,
                label: locale.products,
                screen: const ProductsView(),
              ),
            if (login.hasPermission(12) ?? false)
              ZTabItem(
                value: StockTabsName.purchase,
                label: locale.buyTitle,
                screen: const TodayPurchasedView(),
              ),
            if (login.hasPermission(13) ?? false)
              ZTabItem(
                value: StockTabsName.sell,
                label: locale.sales,
                screen: const TodaySalesView(),
              ),

            ZTabItem(
              value: StockTabsName.returnedGoods,
              label: locale.returnGoods,
              screen: const TodayReturnGoodsView(),
            ),
            ZTabItem(
              value: StockTabsName.shift,
              label: locale.shift,
              screen: const TodayShiftView(),
            ),
          ];

          final available = tabs.map((t) => t.value).toList();
          final selected = available.contains(state.tabs)
              ? state.tabs
              : available.first;
          return ZTabContainer<StockTabsName>(
            margin: EdgeInsets.only(top: 6),
            title: AppLocalizations.of(context)!.stock,

            /// Tab data
            tabs: tabs,
            selectedValue: selected,

            /// Bloc update
            onChanged: (val) => context.read<StockTabBloc>().add(StockOnChangeEvent(val)),

            /// Colors for underline style
            style: ZTabStyle.underline,
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
