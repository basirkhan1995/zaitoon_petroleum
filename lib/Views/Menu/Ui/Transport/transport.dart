import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Drivers/drivers.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/vehicles.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/bloc/transport_tab_bloc.dart';
import '../../../../Features/Generic/tab_bar.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import 'Ui/Shipping/Ui/ShippingView/View/all_shipping.dart';


class TransportView extends StatelessWidget {
  const TransportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TransportTabBloc, TransportTabState>(
        builder: (context, state) {
          final tabs = <ZTabItem<TransportTabName>>[
            ZTabItem(
              value: TransportTabName.shipping,
              label: AppLocalizations.of(context)!.shipping,
              screen: const ShippingView(),
            ),
            ZTabItem(
              value: TransportTabName.drivers,
              label: AppLocalizations.of(context)!.drivers,
              screen: const DriversView(),
            ),
            ZTabItem(
              value: TransportTabName.vehicles,
              label: AppLocalizations.of(context)!.vehicles,
              screen: const VehiclesView(),
            ),
          ];

          final available = tabs.map((t) => t.value).toList();
          final selected = available.contains(state.tab)
              ? state.tab
              : available.first;

          return ZTabContainer<TransportTabName>(
            title: AppLocalizations.of(context)!.transportTitle,
            tabBarPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 3),
            description: "Manage Shipments, Drivers & Vehicle",
            borderRadius: 0,
            /// Tab data
            tabs: tabs,
            selectedValue: selected,

            /// Bloc update
            onChanged: (val) => context
                .read<TransportTabBloc>()
                .add(TransportOnChangedEvent(val)),

            /// Colors for underline style
            style: ZTabStyle.rounded,
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
