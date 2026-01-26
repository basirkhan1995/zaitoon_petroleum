import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'bloc/total_daily_bloc.dart';
import 'model/daily_txn_model.dart';

class TotalDailyPieView extends StatelessWidget {
  final String? fromDate;
  final String? toDate;
  const TotalDailyPieView({super.key, this.fromDate, this.toDate});

  @override
  Widget build(BuildContext context) {
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
          if(state.data.isEmpty){
            return const SizedBox();
          }
          final data = state.data;

          // Total for calculating percentages
          final grandTotal = data.fold<double>(
            0,
                (sum, item) => sum + (item.totalAmount ?? 0),
          );


          final colors = [
            Colors.purple,
            Colors.blue,
            Colors.orange,
            Colors.green,
            Colors.red,
            Colors.teal,
            Colors.pink,
            Colors.amber,
            Colors.indigo,
            Colors.cyan,
            Colors.lime,
            Colors.brown,
          ];
          return ZCover(
            radius: 8,
            margin: EdgeInsets.all(3),
            borderColor: Theme.of(context).colorScheme.outline.withValues(alpha: .3),
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                overflowMode: LegendItemOverflowMode.wrap,
                position: LegendPosition.bottom,
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CircularSeries>[
                DoughnutSeries<TotalDailyTxnModel, String>(
                  dataSource: data,
                  xValueMapper: (item, _) => item.txnName ?? '',
                  yValueMapper: (item, _) => item.totalAmount ?? 0,
                  pointColorMapper: (item, index) =>
                  colors[index % colors.length],
                  dataLabelMapper: (item, _) =>
                  "${item.txnName} - ${((item.totalAmount! / grandTotal) * 100).toStringAsFixed(1)}%",
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                  ),
                  radius: '80%',
                  innerRadius: '60%',
                ),
              ],
            ),
          );
        }

        // Loading
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
