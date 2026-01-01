import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Views/Auth/models/login_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Estimate/estimate.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/OrderScreen/NewPurchase/new_invoice.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/OrderScreen/NewSale/new_sale.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Orders/Ui/orders.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Shift/shift.dart';
import '../../../../Features/Generic/tab_bar.dart';
import '../../../../Features/Widgets/outline_button.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../Auth/bloc/auth_bloc.dart';
import 'bloc/stock_tab_bloc.dart';

class StockView extends StatelessWidget {
  const StockView({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final locale = AppLocalizations.of(context)!;
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = state.loginData;
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: BlocBuilder<StockTabBloc, StockTabState>(
              builder: (context, state) {
                final tabs = <ZTabItem<StockTabsName>>[

                  if (login.hasPermission(12) ?? false)
                    ZTabItem(
                      value: StockTabsName.orders,
                      label: locale.orderTitle,
                      screen: const OrdersView(),
                    ),

                  ZTabItem(
                    value: StockTabsName.estimates,
                    label: locale.estimateTitle,
                    screen: const EstimateView(),
                  ),
                  ZTabItem(
                    value: StockTabsName.shift,
                    label: locale.shift,
                    screen: const TodayShiftView(),
                  ),
                ];

                final available = tabs.map((t) => t.value).toList();
                final selected = available.contains(state.tabs) ? state.tabs : available.first;
                return ZTabContainer<StockTabsName>(
                  margin: EdgeInsets.only(top: 6),
                  tabBarPadding: EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                  borderRadius: 0,
                  title: AppLocalizations.of(context)!.inventory,
                  /// Tab data
                  tabs: tabs,
                  selectedValue: selected,

                  /// Bloc update
                  onChanged: (val) => context.read<StockTabBloc>().add(StockOnChangeEvent(val)),

                  /// Colors for underline style
                  style: ZTabStyle.rounded,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  unselectedTextColor: Theme.of(context).colorScheme.secondary,
                  selectedTextColor: Theme.of(context).colorScheme.surface,
                  tabContainerColor: Theme.of(context).colorScheme.surface,
                );
              },
            ),
          ),

          const SizedBox(width: 3),

          // RIGHT SIDE — SHORTCUT BUTTONS PANEL
          Container(
            width: 190,
            margin: EdgeInsets.symmetric(horizontal: 3,vertical: 5),
            height: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(5),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Wrap(
                    spacing: 5,
                    children: [
                      const Icon(Icons.cached_rounded, size: 20),
                      Text(
                        locale.invoiceTitle,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  if (login.hasPermission(19) ?? false)
                    ZOutlineButton(
                      backgroundColor: color.primary.withValues(alpha: .1),
                      toolTip: "F1",
                      label: Text(locale.purchaseTitle),
                      icon: Icons.shopping_bag,
                      width: double.infinity,
                       onPressed: () => Utils.goto(context, NewOrderView(ordName: "Purchase")),
                    ),
                  if (login.hasPermission(18) ?? false)
                    ZOutlineButton(
                      backgroundColor: color.primary.withValues(alpha: .1),
                      toolTip: "F2",
                      label: Text(locale.sellTitle),
                      icon: Icons.shopping_bag,
                      width: double.infinity,
                      onPressed: () => Utils.goto(context, NewOrderView(ordName: "Sale")),
                    ),

                  ZOutlineButton(
                    backgroundColor: color.primary.withValues(alpha: .1),
                    toolTip: "F2",
                    label: Text(locale.estimateTitle),
                    icon: Icons.real_estate_agent_outlined,
                    width: double.infinity,
                    // onPressed: () => onCashDepositWithdraw(trnType: "CHWL"),
                  ),
                  ZOutlineButton(
                    backgroundColor: color.primary.withValues(alpha: .1),
                    toolTip: "F2",
                    label: Text(locale.returnGoods),
                    icon: Icons.read_more_outlined,
                    width: double.infinity,
                    // onPressed: () => onCashDepositWithdraw(trnType: "CHWL"),
                  ),
                  SizedBox(height: 3),
                  Wrap(
                    spacing: 5,
                    children: [
                      const Icon(Icons.reset_tv, size: 20),
                      Text(
                        locale.operation,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),

                  ZOutlineButton(
                    backgroundColor: color.primary.withValues(alpha: .1),
                    toolTip: "F2",
                    label: Text(locale.shift),
                    icon: Icons.filter_tilt_shift,
                    width: double.infinity,
                    // onPressed: () => onCashDepositWithdraw(trnType: "CHWL"),
                  ),
                  ZOutlineButton(
                    backgroundColor: color.primary.withValues(alpha: .1),
                    toolTip: "F2",
                    label: Text(locale.adjustment),
                    icon: Icons.auto_fix_high,
                    width: double.infinity,
                    // onPressed: () => onCashDepositWithdraw(trnType: "CHWL"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
