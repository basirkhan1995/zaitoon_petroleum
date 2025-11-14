import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../Features/Generic/generic_menu.dart';
import '../../../../../../Features/Other/responsive.dart';
import '../../../../../../Localizations/l10n/translations/app_localizations.dart';
import 'Ui/Security/password.dart';
import 'Ui/System/system.dart';
import 'bloc/general_tab_bloc.dart';

class GeneralView extends StatelessWidget {
  const GeneralView({super.key});

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

    final menuItems = [
      MenuDefinition(
        value: GeneralTabName.system,
        label: AppLocalizations.of(context)!.systemSettings,
        screen: const SystemView(),
        icon: Icons.tune,
      ),
      MenuDefinition(
        value: GeneralTabName.password,
        label: AppLocalizations.of(context)!.password,
        screen: const PasswordView(),
        icon: Icons.lock,
      ),
    ];

    return BlocBuilder<GeneralTabBloc, GeneralTabState>(
      builder: (context, state) {
        return GenericMenuWithScreen(
            isExpanded: false,
            menuWidth: 190,
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 8),
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha:.09),
            selectedTextColor: Theme.of(context).colorScheme.onSurface,
            unselectedTextColor: Theme.of(context).colorScheme.secondary,
            selectedValue: state.tab,
            onChanged: (value)=> context.read<GeneralTabBloc>().add(GeneralTabOnChangedEvent(value)),
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

