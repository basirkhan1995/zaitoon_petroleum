import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Purchase/purchase.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Returns/returns.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Sales/sales.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Shift/shift.dart';
import '../../../../Features/Generic/underline_tab.dart';
import '../../../../Features/Other/cover.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import 'Ui/Products/products.dart';
import 'bloc/stock_tab_bloc.dart';

class StockView extends StatelessWidget {
  const StockView({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          Cover(
            margin: EdgeInsets.symmetric(vertical: 7),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0,vertical: 8),
                  child: Row(
                    children: [
                      Text(locale.stock,style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                ),
                CustomUnderlineTabBar<StockTabsName>(
                  // iconBuilder: (StockTabsName tab){
                  //   switch (tab) {
                  //     case StockTabsName.products: return Icons.inventory_2_outlined;
                  //     case StockTabsName.purchase: return Icons.add_shopping_cart_rounded;
                  //     case StockTabsName.sell: return Icons.add_shopping_cart_rounded;
                  //     case StockTabsName.returnedGoods: return Icons.reset_tv_rounded;
                  //     case StockTabsName.shift: return Icons.swap_horiz_rounded;
                  //   }
                  // },
                  tabs: [
                    StockTabsName.products,
                    StockTabsName.purchase,
                    StockTabsName.sell,
                    StockTabsName.returnedGoods,
                    StockTabsName.shift,
                  ],
                  currentTab: context.watch<StockTabBloc>().state.tabs,
                  onTabChanged: (tab) => context.read<StockTabBloc>().add(StockOnChangeEvent(tab)),
                  labelBuilder: (tab) {
                    final locale = AppLocalizations.of(context)!;
                    switch (tab) {
                      case StockTabsName.products:return locale.products;
                      case StockTabsName.purchase:return locale.buyTitle;
                      case StockTabsName.sell:return locale.sales;
                      case StockTabsName.returnedGoods:return locale.returnGoods;
                      case StockTabsName.shift:return locale.shift;
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<StockTabBloc, StockTabState>(
              builder: (context, state) {
                switch (state.tabs) {
                  case StockTabsName.products:return const ProductsView();
                  case StockTabsName.purchase:return const TodayPurchasedView();
                  case StockTabsName.sell:return const TodaySalesView();
                  case StockTabsName.returnedGoods:return const TodayReturnGoodsView();
                  case StockTabsName.shift:return const TodayShiftView();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
