import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'bloc/total_daily_bloc.dart';
import 'model/daily_txn_model.dart';

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
        if (state is TotalDailyError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

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
              title: ChartTitle(
                text: 'Daily Financial Summary',
                textStyle: theme.textTheme.titleSmall,
              ),

              tooltipBehavior: TooltipBehavior(
                enable: true,
                format: 'point.x : point.y',
              ),
              primaryXAxis: CategoryAxis(
                labelRotation: 0,
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: const MajorGridLines(width: .5),
                numberFormat: NumberFormat.compact(),
              ),
              series: <CartesianSeries<TotalDailyTxnModel, String>>[
                ColumnSeries<TotalDailyTxnModel, String>(
                  name: 'Amount',
                  dataSource: data,
                  xValueMapper: (item, _) => item.txnName ?? '',
                  yValueMapper: (item, _) => item.totalAmount ?? 0,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  width: 0.6,
                  color: theme.colorScheme.primary,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelAlignment: ChartDataLabelAlignment.outer,
                  ),
                ),
              ],

            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
