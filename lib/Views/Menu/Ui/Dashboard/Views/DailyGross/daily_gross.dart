import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:fl_chart/fl_chart.dart';
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

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    /// ✅ Dispatch event only
    context.read<DailyGrossBloc>().add(
      FetchDailyGrossEvent(
        from: today,
        to: today,
        startGroup: 3, // Profit
        stopGroup: 4,  // Loss
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
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: _DailyGrossContent(),
    );
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: _DailyGrossContent(),
    );
  }
}

class _Desktop extends StatelessWidget {
  const _Desktop();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(5),
      child: _DailyGrossContent(),
    );
  }
}


/// Chart widget for daily profit vs loss
class DailyGrossChart extends StatelessWidget {
  const DailyGrossChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current state (assumes state is DailyGrossLoaded)
    final state = context.read<DailyGrossBloc>().state;

    if (state is! DailyGrossLoaded || state.data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Prepare chart points
    final points = _prepareChartData(state.data);

    return ZCard(
      radius: 8,
      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
      child: SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= points.length) return const SizedBox();
                    final date = points[value.toInt()].date;
                    return Text(
                      DateFormat('MM/dd').format(date),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, interval: null),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.withValues(alpha: .5)),
            ),
            lineBarsData: [
              _lineBarData(points, profit: true), // Profit
              _lineBarData(points, profit: false), // Loss
            ],
          ),
        ),
      ),
    );
  }

  // Prepare points grouped by date
  List<_ChartPoint> _prepareChartData(List<DailyGrossModel> data) {
    final map = <DateTime, _ChartPoint>{};

    for (final item in data) {
      final date = item.date;
      map.putIfAbsent(date, () => _ChartPoint(date: date));

      if (item.category == GrossCategory.profit) {
        map[date]!.profit += item.balance;
      } else {
        map[date]!.loss += item.balance;
      }
    }

    final list = map.values.toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  // Build individual line for profit or loss
  LineChartBarData _lineBarData(List<_ChartPoint> points, {required bool profit}) {
    return LineChartBarData(
      isCurved: true,
      color: profit ? Colors.green : Colors.red,
      barWidth: 3,
      dotData: FlDotData(show: true),
      spots: List.generate(
        points.length,
            (i) => FlSpot(
          i.toDouble(),
          profit ? points[i].profit : points[i].loss,
        ),
      ),
    );
  }
}

// Internal class to hold chart data
class _ChartPoint {
  final DateTime date;
  double profit;
  double loss;

  _ChartPoint({
    required this.date,
    this.profit = 0,
    this.loss = 0,
  });
}


class _DailyGrossContent extends StatelessWidget {
  const _DailyGrossContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailyGrossBloc, DailyGrossState>(
      builder: (context, state) {
        if (state is DailyGrossLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DailyGrossError) {
          return Center(child: Text(state.message));
        }

        if (state is DailyGrossLoaded) {
          if (state.data.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          return const DailyGrossChart();
        }

        return const SizedBox();
      },
    );
  }
}


