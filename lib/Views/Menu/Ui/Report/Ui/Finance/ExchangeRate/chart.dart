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

/// =======================================================
/// FX RATE DASHBOARD CHART (AREA + LINE)
/// =======================================================
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData({String? fromDate, String? toDate}) {
    final now = DateTime.now();
    final from = DateFormat('yyyy-MM-dd')
        .format(now.subtract(const Duration(days: 30)));
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
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [

          /// ---------------- FILTER ROW ----------------
          Row(
            children: [
              const Spacer(flex: 3),

              Flexible(
                child: CurrencyDropdown(
                  title: 'From',
                  initiallySelectedSingle:
                  CurrenciesModel(ccyCode: fromCcy),
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
                  initiallySelectedSingle:
                  CurrenciesModel(ccyCode: toCcy),
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

          /// ---------------- CHART ----------------
          SizedBox(
            height: 280,
            width: double.infinity,
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
                  return _buildAreaChart(context, state.rates);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// =======================================================
  /// AREA + LINE CHART
  /// =======================================================
  SfCartesianChart _buildAreaChart(
      BuildContext context,
      List<ExchangeRateReportModel> rates,
      ) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final data = rates
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
      trackballBehavior: TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
      ),
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.days,
        dateFormat: DateFormat('MM/dd'),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat('#,##0.00'),
      ),
      series: <CartesianSeries>[
        AreaSeries<_ChartPoint, DateTime>(
          dataSource: data,
          xValueMapper: (d, _) => d.date,
          yValueMapper: (d, _) => d.value,
          borderColor: primaryColor,
          borderWidth: 2,
          gradient: LinearGradient(
            colors: [
              primaryColor.withValues(alpha: 0.35),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          markerSettings: const MarkerSettings(isVisible: true),
          name: '$fromCcy → $toCcy',
        ),
      ],
    );
  }
}

/// =======================================================
/// INTERNAL CHART POINT
/// =======================================================
class _ChartPoint {
  final DateTime date;
  final double value;

  _ChartPoint({
    required this.date,
    required this.value,
  });
}
