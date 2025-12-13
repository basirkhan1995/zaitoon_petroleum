import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Generic/tab_bar.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Shipping/Ui/ShippingExpense/shipping_expense.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Shipping/Ui/ShippingView/add_edit_shipping.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Shipping/bloc/shipping_tab_bloc.dart';
import '../../../../../../Localizations/l10n/translations/app_localizations.dart';


class ShippingTabView extends StatelessWidget {
  const ShippingTabView({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: BlocBuilder<ShippingTabBloc, ShippingTabState>(
          builder: (context, state) {

            final tabs = <ZTabItem<ShippingTabName>>[
            //  if(login.hasPermission(14) ?? false)
              ZTabItem(
                  value: ShippingTabName.shipping,
                  label: AppLocalizations.of(context)!.shipping,
                  screen: const AddEditShippingView(),
                ),
            //  if(login.hasPermission(15) ?? false)
              ZTabItem(
                value: ShippingTabName.shippingExpense,
                label: AppLocalizations.of(context)!.expense,
                screen: const ShippingExpenseView(),
              ),

            ];

            final availableValues = tabs.map((tab) => tab.value).toList();
            final selected = availableValues.contains(state.tabs)
                ? state.tabs
                : availableValues.first;

            return ZTabContainer<ShippingTabName>(
              borderRadius: 3,
              title: AppLocalizations.of(context)!.shipping,
              tabContainerColor: Theme.of(context).colorScheme.surface,
              closeButton: true,
              style: ZTabStyle.underline,
              selectedValue: selected,
              onChanged: (val) => context.read<ShippingTabBloc>().add(ShippingOnchangeEvent(val)),
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
