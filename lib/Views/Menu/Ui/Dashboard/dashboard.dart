import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Dashboard/Views/DailyGross/daily_gross.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Dashboard/Views/Stats/stats.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/ExchangeRate/Ui/exchange_rate.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/TotalDailyTxn/column_chart_view.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/TotalDailyTxn/total_daily_txn.dart';
import '../Reminder/reminder_widget.dart';
import '../Report/Ui/Finance/ExchangeRate/chart.dart';

import '../Settings/features/Visibility/bloc/settings_visible_bloc.dart';
import 'features/clock.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(),
    );
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    final visibility = context.read<SettingsVisibleBloc>().state;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (visibility.dashboardClock) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: const DigitalClock(),
              ),
            ],
            if (visibility.exchangeRate) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 3),
                child: ExchangeRateView(settingButton: true, newRateButton: false),
              ),
            ],
            if (visibility.statsCount) ...[
              DashboardStatsView(),
            ],
            if (visibility.profitAndLoss) ...[
              DailyGrossView(),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    final visibility = context.read<SettingsVisibleBloc>().state;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (visibility.dashboardClock) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: const DigitalClock(),
              ),
            ],
            if (visibility.exchangeRate) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13.0,vertical: 3),
                child: ExchangeRateView(settingButton: true, newRateButton: false),
              ),
            ],
            if (visibility.statsCount) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: DashboardStatsView(),
              ),
            ],
            if (visibility.profitAndLoss) ...[
              DailyGrossView(),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: DashboardAlertReminder(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Desktop extends StatelessWidget {
  const _Desktop();

  @override
  Widget build(BuildContext context) {
    final visibility = context.read<SettingsVisibleBloc>().state;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (visibility.statsCount) ...[
                      DashboardStatsView(),
                    ],
                    if (visibility.profitAndLoss) ...[
                      SizedBox(height: 3),
                      DailyGrossView(),
                    ],
                    SizedBox(height: 400, child: FxRateDashboardChart()),
                    TotalDailyColumnView(),
                    const TotalDailyTxnView(),
                  ],
                ),
              ),

              SizedBox(
                width: 500,
                child: Column(
                  children: [
                    if (visibility.dashboardClock) ...[
                      const DigitalClock(),
                      SizedBox(height: 3),
                    ],
                    if (visibility.exchangeRate) ...[
                      ExchangeRateView(settingButton: true, newRateButton: false),
                    ],
                    SizedBox(height: 3),
                    DashboardAlertReminder(),
                    SizedBox(height: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
