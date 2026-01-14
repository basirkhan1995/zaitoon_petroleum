import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/shortcut.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Views/Auth/models/login_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Estimate/View/add_estimate.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Estimate/View/estimate.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/OrderScreen/NewPurchase/new_purchase.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/OrderScreen/NewSale/new_sale.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Orders/Ui/orders.dart';
import '../../../../Features/Generic/tab_bar.dart';
import '../../../../Features/Widgets/outline_button.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../Auth/bloc/auth_bloc.dart';
import 'Ui/OrderScreen/GetOrderById/order_by_id.dart';
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
    final shortcuts = {
      const SingleActivator(LogicalKeyboardKey.f1): () => gotoPurchase(context),
      const SingleActivator(LogicalKeyboardKey.f2): () => gotoSale(context),
      const SingleActivator(LogicalKeyboardKey.f3): () => getInvoiceById(context),
      const SingleActivator(LogicalKeyboardKey.f4): () => getInvoiceById(context),
      const SingleActivator(LogicalKeyboardKey.f5): () => getInvoiceById(context),
      const SingleActivator(LogicalKeyboardKey.f6): () => getInvoiceById(context),
      const SingleActivator(LogicalKeyboardKey.f7): () => getInvoiceById(context),
      const SingleActivator(LogicalKeyboardKey.f8): () => getInvoiceById(context),
    };
    return Scaffold(
      body: GlobalShortcuts(
        shortcuts: shortcuts,
        child: Row(
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
                  ];

                  final available = tabs.map((t) => t.value).toList();
                  final selected = available.contains(state.tabs) ? state.tabs : available.first;
                  return ZTabContainer<StockTabsName>(
                    tabBarPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 2),
                    borderRadius: 0,
                    title: AppLocalizations.of(context)!.orders,
                    description: "Manage Sales, Purchase Invoices & Estimates",
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
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: .1,),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    spreadRadius: 2,
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: .03),
                  ),
                ],
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).colorScheme.surface,
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
                        backgroundColor: color.primary.withValues(alpha: .07),
                        toolTip: "F1",
                        label: Text(locale.newPurchase),
                        icon: Icons.shopping_bag_outlined,
                        width: double.infinity,
                         onPressed: () => Utils.goto(context, NewPurchaseOrderView()),
                      ),
                    if (login.hasPermission(18) ?? false)
                      ZOutlineButton(
                        backgroundColor: color.primary.withValues(alpha: .07),
                        toolTip: "F2",
                        label: Text(locale.newSale),
                        icon: Icons.shopping_bag_outlined,
                        width: double.infinity,
                        onPressed: () => Utils.goto(context, NewSaleView()),
                      ),

                    ZOutlineButton(
                      backgroundColor: color.primary.withValues(alpha: .07),
                      toolTip: "F3",
                      label: Text(locale.estimateTitle),
                      icon: Icons.file_open_outlined,
                      width: double.infinity,
                       onPressed: () => Utils.goto(context, AddEstimateView()),
                    ),
                    ZOutlineButton(
                      backgroundColor: color.primary.withValues(alpha: .07),
                      toolTip: "F4",
                      label: Text(locale.findInvoice),
                      icon: Icons.search_rounded,
                      width: double.infinity,
                       onPressed: () => getInvoiceById(context),
                    ),
                    SizedBox(height: 3),
                    Wrap(
                      spacing: 5,
                      children: [
                        const Icon(Icons.keyboard_return, size: 20),
                        Text(
                          locale.returnGoods,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    ZOutlineButton(
                      backgroundColor: color.primary.withValues(alpha: .07),
                      toolTip: "F5",
                      label: Text(locale.returnPurchase),
                      icon: Icons.keyboard_return_rounded,
                      width: double.infinity,
                      // onPressed: () => onCashDepositWithdraw(trnType: "CHWL"),
                    ),
                    ZOutlineButton(
                      backgroundColor: color.primary.withValues(alpha: .07),
                      toolTip: "F6",
                      label: Text(locale.saleReturn),
                      icon: Icons.keyboard_return_rounded,
                      width: double.infinity,
                      // onPressed: () => onCashDepositWithdraw(trnType: "CHWL"),
                    ),
                    SizedBox(height: 3),
                    Wrap(
                      spacing: 5,
                      children: [
                        const Icon(Icons.call_to_action_outlined, size: 20),
                        Text(
                          locale.stock,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),

                    ZOutlineButton(
                      backgroundColor: color.primary.withValues(alpha: .07),
                      toolTip: "F7",
                      label: Text(locale.shift),
                      icon: Icons.filter_tilt_shift,
                      width: double.infinity,
                      // onPressed: () => onCashDepositWithdraw(trnType: "CHWL"),
                    ),
                    ZOutlineButton(
                      backgroundColor: color.primary.withValues(alpha: .07),
                      toolTip: "F8",
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
      ),
    );
  }
  void getInvoiceById(BuildContext context){
    final invController = TextEditingController();
    final tr = AppLocalizations.of(context)!;
    showDialog(context: context, builder: (context){
      return ZFormDialog(
        padding: EdgeInsets.all(14),
        width: 500,
        onAction: (){
          if(invController.text.isNotEmpty){
            Utils.goto(
              context,
              OrderByIdView(orderId: int.parse(invController.text)),
            );
          }else{
            Navigator.of(context).pop();
          }
        },
        actionLabel: Text(tr.submit),
        title: tr.findInvoice,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ZTextFieldEntitled(
                inputFormat: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                icon: Icons.numbers,
                onSubmit: (e){
                  if(e.isNotEmpty){
                    Utils.goto(
                      context,
                      OrderByIdView(orderId: int.parse(e)),
                    );
                  }else{
                    Navigator.of(context).pop();
                  }
                },
                controller: invController,
                hint: tr.enterInvoiceNumber,
                title: tr.orderId),
            SizedBox(height: 10)
          ],
        ),
      );
    });
  }
  void gotoPurchase(BuildContext context){
    Utils.goto(context, NewPurchaseOrderView());
  }
  void gotoSale(BuildContext context){
    Utils.goto(context, NewSaleView());
  }
}
