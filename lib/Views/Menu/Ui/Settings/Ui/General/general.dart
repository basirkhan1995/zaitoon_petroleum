import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../Features/Generic/generic_menu.dart';
import '../../../../../../Features/Other/responsive.dart';
import '../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../../Auth/models/login_model.dart';
import 'Ui/Security/password.dart';
import 'Ui/System/system.dart';
import 'bloc/general_tab_bloc.dart';

class GeneralView extends StatelessWidget {
  const GeneralView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
        tablet: _Desktop(),
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
    final login = state.loginData;

    final menuItems = [
      if (login.hasPermission(59) ?? false)
      MenuDefinition(
        value: GeneralTabName.system,
        label: AppLocalizations.of(context)!.systemSettings,
        screen: const SystemView(),
        icon: Icons.tune,
      ),
      if (login.hasPermission(60) ?? false)
      MenuDefinition(
        value: GeneralTabName.password,
        label: AppLocalizations.of(context)!.password,
        screen: const PasswordView(),
        icon: Icons.lock,
      ),
    ];
    // 🟢 FIX: Handle empty tabs case
    if (menuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_accounts_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .3),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.accessDenied,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please contact administrator",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .4),
              ),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<GeneralTabBloc, GeneralTabState>(
      builder: (context, state) {
        return GenericMenuWithScreen(
            isExpanded: false,
            menuWidth: 190,
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 8),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 4),
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


