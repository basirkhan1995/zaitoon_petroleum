import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';

import '../../../HR/Ui/Users/features/date_range_string.dart';
import 'bloc/daily_gross_bloc.dart';
import 'model/gross_model.dart';

class DailyGrossView extends StatefulWidget {
  const DailyGrossView({super.key});

  @override
  State<DailyGrossView> createState() => _DailyGrossViewState();
}

class _DailyGrossViewState extends State<DailyGrossView> {
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final from = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 30)));
    final to = DateFormat('yyyy-MM-dd').format(now);

    context.read<DailyGrossBloc>().add(
      FetchDailyGrossEvent(
        from: from,
        to: to,
        startGroup: 3,
        stopGroup: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(),
    );
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(8),
    child: _DailyGrossContent(),
  );
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(16),
    child: _DailyGrossContent(),
  );
}

class _Desktop extends StatelessWidget {
  const _Desktop();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(5),
    child: _DailyGrossContent(),
  );
}

/// =======================
/// MAIN CONTENT
/// =======================
class _DailyGrossContent extends StatelessWidget {
  const _DailyGrossContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailyGrossBloc, DailyGrossState>(
      builder: (context, state) {
        if (state is DailyGrossError) {
          return Center(child: Text(state.message));
        }

        if (state is DailyGrossLoaded) {
          if (state.data.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          return Stack(
            children: [
              DailyGrossChart(data: state.data),
              if (state.isRefreshing)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

/// =======================
/// SYNCFUSION CHART
/// =======================
class DailyGrossChart extends StatelessWidget {
  final List<DailyGrossModel> data;

  const DailyGrossChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareChartData(data);

    return ZCard(
      radius: 8,
      borderColor: Theme.of(context).colorScheme.primary.withValues(alpha: .5),
      padding: const EdgeInsets.all(15),
      child: SizedBox(
        height: 360,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                   Expanded(child: Text(AppLocalizations.of(context)!.profitAndLoss,style: Theme.of(context).textTheme.titleMedium,)),
                   SizedBox(
                    width: 150,
                    child: DateRangeDropdown(
                      title: '',
                      height: 38,
                      onChanged: (fromDate, toDate) {
                        context.read<DailyGrossBloc>().add(
                          FetchDailyGrossEvent(
                            from: fromDate,
                            to: toDate,
                            startGroup: 3,
                            stopGroup: 4,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SfCartesianChart(
             // legend: Legend(isVisible: true,position: LegendPosition.top,isResponsive: true),

              tooltipBehavior: TooltipBehavior(enable: true),
              primaryXAxis: DateTimeAxis(
                intervalType: DateTimeIntervalType.days,
                dateFormat: DateFormat('MM/dd'),
              ),
              primaryYAxis: NumericAxis(),
              series: <CartesianSeries<GrossChartData, DateTime>>[
                // PROFIT LINE
                LineSeries<GrossChartData, DateTime>(
                  dataSource: chartData,
                  xValueMapper: (d, _) => d.date,
                  yValueMapper: (d, _) => d.profit,
                  name: AppLocalizations.of(context)!.profit,
                  color: Colors.green,
                  width: 3,
                  markerSettings: const MarkerSettings(isVisible: true),
                ),
                // LOSS LINE
                LineSeries<GrossChartData, DateTime>(
                  dataSource: chartData,
                  xValueMapper: (d, _) => d.date,
                  yValueMapper: (d, _) => d.loss,
                  name: AppLocalizations.of(context)!.loss,
                  color: Colors.red,
                  width: 3,
                  markerSettings: const MarkerSettings(isVisible: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<GrossChartData> _prepareChartData(List<DailyGrossModel> data) {
    final map = <DateTime, GrossChartData>{};

    for (final item in data) {
      final date = DateTime(item.date.year, item.date.month, item.date.day);

      map.putIfAbsent(
        date,
            () => GrossChartData(date: date, profit: 0, loss: 0),
      );

      if (item.category == GrossCategory.profit) {
        map[date] = GrossChartData(
          date: date,
          profit: map[date]!.profit + item.balance,
          loss: map[date]!.loss,
        );
      } else {
        map[date] = GrossChartData(
          date: date,
          profit: map[date]!.profit,
          loss: map[date]!.loss + item.balance,
        );
      }
    }

    final list = map.values.toList()..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }
}

class GrossChartData {
  final DateTime date;
  final double profit;
  final double loss;

  GrossChartData({
    required this.date,
    required this.profit,
    required this.loss,
  });
}
