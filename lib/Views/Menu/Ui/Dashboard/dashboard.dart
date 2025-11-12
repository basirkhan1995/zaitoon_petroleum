import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';

import '../../../../Localizations/l10n/translations/app_localizations.dart';
import '../Settings/features/Visibility/bloc/settings_visible_bloc.dart';
import 'features/clock.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), tablet: _Tablet(), desktop: _Desktop());
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Desktop extends StatelessWidget {
  const _Desktop();

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final visibility = context.read<SettingsVisibleBloc>().state;
    return Scaffold(
      body: Row(
        children: [
         Column(
           children: [
             if(visibility.dashboardClock)
               const DigitalClock(),
           ],
         )
        ],
      ),
    );
  }
}

