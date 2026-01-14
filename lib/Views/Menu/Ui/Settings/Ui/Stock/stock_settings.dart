import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/ProductCategory/pro_cat_view.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/Products/products.dart';
import '../../../../../../Features/Generic/generic_menu.dart';
import '../../../../../../Features/Other/responsive.dart';
import '../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';
import 'bloc/stock_settings_tab_bloc.dart';

class StockSettingsView extends StatelessWidget {
  const StockSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
        tablet: _Tablet(),
        mobile: _Mobile(),
        desktop: _Desktop());
  }
}

class _Desktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    // final login = state.loginData;
    final menuItems = [
      MenuDefinition(
        value: StockSettingsTabName.products,
        label: AppLocalizations.of(context)!.products,
        screen: const ProductsView(),
        icon: Icons.production_quantity_limits_rounded,
      ),
      MenuDefinition(
        value: StockSettingsTabName.proCategory,
        label: AppLocalizations.of(context)!.categoryTitle,
        screen: const ProCatView(),
        icon: Icons.dialpad_rounded,
      ),
    ];

    return BlocBuilder<StockSettingsTabBloc, StockSettingsTabState>(
      builder: (context, state) {
        return GenericMenuWithScreen(
            isExpanded: false,
            menuWidth: 190,
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 8),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha:.09),
            selectedTextColor: Theme.of(context).colorScheme.onSurface,
            unselectedTextColor: Theme.of(context).colorScheme.secondary,
            selectedValue: state.tab,
            onChanged: (value)=> context.read<StockSettingsTabBloc>().add(StockSettingsTabOnChangedEvent(value)),
            items: menuItems
        );
      },
    );
  }
}

class _Mobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Tablet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

