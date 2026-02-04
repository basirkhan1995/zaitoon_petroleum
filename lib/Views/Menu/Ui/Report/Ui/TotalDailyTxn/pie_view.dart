import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import '../../../../../../Features/Other/extensions.dart';
import 'bloc/total_daily_bloc.dart';
import 'model/total_daily_compare.dart';


class TotalDailyColumnView extends StatelessWidget {
  final String? fromDate;
  final String? toDate;

  const TotalDailyColumnView({
    super.key,
    this.fromDate,
    this.toDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TotalDailyBloc, TotalDailyState>(
      builder: (context, state) {

        /// 🔴 ERROR
        if (state is TotalDailyError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        /// 🟢 LOADED
        if (state is TotalDailyLoaded) {

          if (state.data.isEmpty) {
            return const SizedBox();
          }

          final data = state.data;

          return ZCover(
            radius: 5,
            margin: const EdgeInsets.all(3),
            borderColor:
            theme.colorScheme.outline.withValues(alpha: .3),

            child: SfCartesianChart(

              /// 🔹 TITLE
              title: ChartTitle(
                text: 'Daily Financial Summary',
                textStyle: theme.textTheme.titleSmall,
              ),

              /// 🔹 TOOLTIP
              tooltipBehavior: TooltipBehavior(
                enable: true,
                builder: (dynamic item, dynamic point,
                    dynamic series, int pointIndex, int seriesIndex) {

                  final d = item as TotalDailyCompare;

                  return Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "${d.today.txnName}\n"
                          "Amount: ${d.today.totalAmount?.toAmount()}\n"
                          "Change: ${d.percentage.toStringAsFixed(1)}%",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),

              /// 🔹 X AXIS
              primaryXAxis: CategoryAxis(
                labelRotation: 0,
                majorGridLines: const MajorGridLines(width: 0),
                rangePadding: ChartRangePadding.additional, // ⭐ better centering
              ),

              /// 🔹 Y AXIS
              primaryYAxis: NumericAxis(
                majorGridLines: const MajorGridLines(width: .5),
                numberFormat: NumberFormat.compact(),
              ),

              /// 🔹 SERIES
              series: <CartesianSeries<TotalDailyCompare, String>>[
                ColumnSeries<TotalDailyCompare, String>(

                  name: 'Amount',
                  dataSource: data,

                  /// X VALUE
                  xValueMapper: (item, _) =>
                  item.today.txnName ?? '',

                  /// Y VALUE
                  yValueMapper: (item, _) =>
                  item.today.totalAmount ?? 0,

                  /// COLOR BASED ON TREND
                  pointColorMapper: (item, _) =>
                  item.isIncrease
                      ? Colors.green
                      : Colors.red,

                  /// LABEL (Amount + Percentage)
                  dataLabelMapper: (item, _) =>
                  "${item.today.totalAmount?.toAmount()}\n"
                      "${item.percentage.toStringAsFixed(1)}%",

                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelAlignment: ChartDataLabelAlignment.outer,
                  ),

                  /// 🔥 SINGLE COLUMN WIDTH FIX
                  width: data.length == 1 ? 0.25 : 0.6,
                  spacing: data.length == 1 ? 0.6 : 0.2,

                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            ),
          );
        }

        /// 🔄 LOADING
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
