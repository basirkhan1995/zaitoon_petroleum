import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/shortcut.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Views/Auth/models/login_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Adjustment/add_adjustment.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Estimate/View/add_estimate.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Estimate/View/estimate.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/GoodsShift/add_shift.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/OrderScreen/NewPurchase/new_purchase.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/OrderScreen/NewSale/new_sale.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Orders/Ui/orders.dart';
import '../../../../Features/Generic/tab_bar.dart';
import '../../../../Features/Widgets/outline_button.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../Auth/bloc/auth_bloc.dart';
import 'Ui/Adjustment/adjustment.dart';
import 'Ui/GoodsShift/goods_shift.dart';
import 'Ui/OrderScreen/GetOrderById/order_by_id.dart';
import 'bloc/stock_tab_bloc.dart';

class StockView extends StatefulWidget {
  const StockView({super.key});

  @override
  State<StockView> createState() => _StockViewState();
}

class _StockViewState extends State<StockView> {
  bool _isExpanded = true;
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final locale = AppLocalizations.of(context)!;
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = state.loginData;
    double opacity = .05;

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

                    if (login.hasPermission(46) ?? false)
                      ZTabItem(
                        value: StockTabsName.orders,
                        label: locale.orderTitle,
                        screen: const OrdersView(),
                      ),

                    if (login.hasPermission(48) ?? false)
                    ZTabItem(
                      value: StockTabsName.estimates,
                      label: locale.estimateTitle,
                      screen: const EstimateView(),
                    ),

                    if (login.hasPermission(49) ?? false)
                    ZTabItem(
                      value: StockTabsName.shift,
                      label: locale.shift,
                      screen: const GoodsShiftView(),
                    ),

                    if (login.hasPermission(50) ?? false)
                    ZTabItem(
                      value: StockTabsName.adjustment,
                      label: locale.adjustment,
                      screen: const AdjustmentView(),
                    ),
                  ];

                  final available = tabs.map((t) => t.value).toList();
                  final selected = available.contains(state.tabs) ? state.tabs : available.first;
                  return ZTabContainer<StockTabsName>(
                    tabBarPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 2),
                    borderRadius: 0,
                    title: locale.inventory,
                    description: locale.inventorySubtitle,
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
            AnimatedContainer(
              clipBehavior: Clip.hardEdge,
              duration: const Duration(milliseconds: 300),
              width: _isExpanded ? 170 : 70,
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
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    /// Toggle arrow
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0), // CHANGED: Reduced horizontal
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: _isExpanded
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.start,
                        children: [
                          if (_isExpanded)
                            Flexible(
                              child: Text(
                                locale.shortcuts,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: .06),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: IconButton(
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              icon: Icon(_isExpanded
                                  ? Icons.chevron_right
                                  : Icons.chevron_left),
                              onPressed: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if(_isExpanded)...[
                      Wrap(
                        spacing: 5,
                        children: [
                          Icon(Icons.shopify_rounded, size: 20,color: color.outline),
                          if(_isExpanded)
                            Text(
                              locale.invoiceTitle,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                        ],
                      ),
                    ],

                    if (login.hasPermission(51) ?? false)
                      ZOutlineButton(
                        backgroundColor: color.primary.withValues(alpha: opacity),
                        toolTip: "F1 - ${locale.newPurchase}",
                        label: Text(locale.newPurchase),
                        icon: Icons.shopping_bag_outlined,
                        width: double.infinity,
                         onPressed: () => Utils.goto(context, NewPurchaseOrderView()),
                      ),

                    if (login.hasPermission(52) ?? false)
                      ZOutlineButton(
                        backgroundColor: color.primary.withValues(alpha: opacity),
                        toolTip: "F2 - ${locale.newSale}",
                        label: Text(locale.newSale),
                        icon: Icons.shopping_bag_outlined,
                        width: double.infinity,
                        onPressed: () => Utils.goto(context, NewSaleView()),
                      ),

                    if (login.hasPermission(53) ?? false)
                    ZOutlineButton(
                      backgroundColor: color.primary.withValues(alpha: opacity),
                      toolTip: "F3 - ${locale.newEstimate}",
                      label: Text(locale.newEstimate),
                      icon: Icons.file_open_outlined,
                      width: double.infinity,
                       onPressed: () => Utils.goto(context, AddEstimateView()),
                    ),

                    if (login.hasPermission(56) ?? false)
                    ZOutlineButton(
                      backgroundColor: color.primary.withValues(alpha: opacity),
                      toolTip: "F4 - ${locale.findInvoice}",
                      label: Text(locale.findInvoice),
                      icon: Icons.filter_alt_outlined,
                      width: double.infinity,
                       onPressed: () => getInvoiceById(context),
                    ),

                    if(_isExpanded)...[
                      SizedBox(height: 3),
                      Wrap(
                        spacing: 5,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 18,color: color.outline,),
                          Text(
                            locale.stock,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ],

                    if (login.hasPermission(54) ?? false)
                    ZOutlineButton(
                      backgroundColor: color.primary.withValues(alpha: opacity),
                      toolTip: "F7 - ${locale.shift}",
                      label: Text(locale.shift),
                      icon: Icons.edit_location_outlined,
                      width: double.infinity,
                       onPressed: () => Utils.goto(context, AddGoodsShiftView()),
                    ),

                    if (login.hasPermission(55) ?? false)
                    ZOutlineButton(
                      backgroundColor: color.primary.withValues(alpha: opacity),
                      toolTip: "F8 - ${locale.adjustment}",
                      label: Text(locale.adjustment),
                      icon: Icons.settings_backup_restore_rounded,
                      width: double.infinity,
                      onPressed: () => Utils.goto(context, AddAdjustmentView()),
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
