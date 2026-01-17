import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Dashboard/Views/DailyGross/daily_gross.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Dashboard/Views/Stats/stats.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/ExchangeRate/Ui/exchange_rate.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/TotalDailyTxn/pie_view.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/TotalDailyTxn/total_daily_txn.dart';
import '../Report/Ui/Finance/ExchangeRate/chart.dart';
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

    final visibility = context.read<SettingsVisibleBloc>().state;
    return Scaffold(

      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Expanded(

             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 SizedBox(height: 2),
                 if(visibility.dashboardClock)...[
                   const DigitalClock(),
                   SizedBox(height: 5),
                 ],

                if(visibility.statsCount)...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      spacing: 5,
                      children: [
                        Icon(Icons.line_axis_rounded),
                        Text(AppLocalizations.of(context)!.totalTitle)
                      ],
                    ),
                  ),
                  DashboardStatsView(),
                ],
                if(visibility.todayTotalTransactions)...[
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      spacing: 5,
                      children: [
                        Icon(Icons.line_axis_rounded),
                        Text(AppLocalizations.of(context)!.today)
                      ],
                    ),
                  ),
                  TotalDailyTxnView(),
                ],
                 if(visibility.profitAndLoss)...[
                   SizedBox(height: 5),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
                     child: Row(
                       spacing: 5,
                       children: [
                         Icon(Icons.line_axis_rounded),
                         Text(AppLocalizations.of(context)!.profitAndLoss)
                       ],
                     ),
                   ),
                   DailyGrossView(),
                 ],


                 SizedBox(height: 5),
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                   child: Row(
                     spacing: 5,
                     children: [
                       Icon(Icons.line_axis_rounded),
                       Text(AppLocalizations.of(context)!.exchangeRate)
                     ],
                   ),
                 ),
                 SizedBox(
                     height: 400,
                     child: FxRateDashboardChart()),
               ],
             ),
           ),
            
           SizedBox(
             width: 400,
             child: Column(
               children: [
                 if(visibility.exchangeRate)...[
                   ExchangeRateView(
                     settingButton: true,
                     newRateButton: false,
                   ),
                 ],

                if(visibility.todayTotalTxnChart)...[
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: TotalDailyPieView(),
                  )
                ],
               ],
             ),
           ),
          ],
        ),
      ),
    );
  }
}


