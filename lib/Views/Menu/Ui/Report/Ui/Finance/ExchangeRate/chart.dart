import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/Currencies/model/ccy_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/features/currency_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/ExchangeRate/bloc/fx_rate_report_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/ExchangeRate/model/rate_report_model.dart';

import '../../../../HR/Ui/Users/features/date_range_string.dart';

class FxRateDashboardChart extends StatelessWidget {
  const FxRateDashboardChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: _ChartContent(),
      tablet: _ChartContent(),
      desktop: _ChartContent(),
    );
  }
}

class _ChartContent extends StatefulWidget {
  const _ChartContent();

  @override
  State<_ChartContent> createState() => _ChartContentState();
}

class _ChartContentState extends State<_ChartContent> {
  String? fromCcy = 'USD';
  String? toCcy = 'AFN';
  int rangeDays = 30;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData({String? fromDate, String? toDate}) {
    final now = DateTime.now();
    final from =
    DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: rangeDays)));
    final to = DateFormat('yyyy-MM-dd').format(now);

    context.read<FxRateReportBloc>().add(
      LoadFxRateReportEvent(
        fromDate: fromDate ?? from,
        toDate: toDate ?? to,
        fromCcy: fromCcy,
        toCcy: toCcy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ZCard(
      radius: 8,
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.all(10),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            /// Filters
            Row(
              children: [
                Flexible(
                  child: CurrencyDropdown(
                    title: 'From',
                    initiallySelectedSingle: CurrenciesModel(ccyCode: fromCcy),
                    isMulti: false,
                    onSingleChanged: (e) {
                      setState(() => fromCcy = e?.ccyCode);
                      _loadData();
                    },
                    onMultiChanged: (_) {},
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: CurrencyDropdown(
                    title: 'To',
                    initiallySelectedSingle: CurrenciesModel(ccyCode: toCcy),
                    isMulti: false,
                    onSingleChanged: (e) {
                      setState(() => toCcy = e?.ccyCode);
                      _loadData();
                    },
                    onMultiChanged: (_) {},
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: DateRangeDropdown(
                    title: 'Date Range',
                    height: 38,
                    onChanged: (fromDate, toDate) {
                      _loadData(fromDate: fromDate, toDate: toDate);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Chart (FIXED HEIGHT)
            SizedBox(
              height: 280,
              child: BlocBuilder<FxRateReportBloc, FxRateReportState>(
                builder: (context, state) {
                  if (state is FxRateReportLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is FxRateReportErrorState) {
                    return Center(child: Text(state.message));
                  }

                  if (state is FxRateReportLoadedState) {
                    if (state.rates.isEmpty) {
                      return const Center(child: Text('No data'));
                    }
                    return _buildLineChart(state.rates);
                  }

                  return const Center(child: Text('Select filters'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  SfCartesianChart _buildLineChart(List<ExchangeRateReportModel> rates) {
    final chartData = rates
        .map(
          (e) => _ChartPoint(
        date: e.rateDate,
        value: e.avgRate,
      ),
    )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat('MM/dd'),
        intervalType: DateTimeIntervalType.days,
      ),
      primaryYAxis: NumericAxis(),
      series: [
        LineSeries<_ChartPoint, DateTime>(
          dataSource: chartData,
          xValueMapper: (d, _) => d.date,
          yValueMapper: (d, _) => d.value,
          width: 3,
          markerSettings: const MarkerSettings(isVisible: true),
          name: '$fromCcy → $toCcy',
        ),
      ],
    );
  }
}

class _ChartPoint {
  final DateTime date;
  final double value;

  _ChartPoint({required this.date, required this.value});
}

