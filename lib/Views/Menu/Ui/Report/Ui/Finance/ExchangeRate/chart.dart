import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/ExchangeRate/model/rate_report_model.dart';

class ExchangeRateGraph extends StatefulWidget {
  final List<ExchangeRateReportModel> rates;
  final String? fromCurrency;
  final String? toCurrency;

  const ExchangeRateGraph({
    super.key,
    required this.rates,
    this.fromCurrency,
    this.toCurrency,
  });

  @override
  ExchangeRateGraphState createState() => ExchangeRateGraphState();
}

class ExchangeRateGraphState extends State<ExchangeRateGraph> {
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  late TrackballBehavior _trackballBehavior;
  List<ChartData> _chartData = [];
  String _selectedSeriesType = 'Line';
  bool _showAverageRate = false;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      format: 'point.x\npoint.y',
      canShowMarker: true,
      header: '',
      color: Colors.white,
      borderColor: Colors.blue,
      borderWidth: 1,
      textStyle: const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );

    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      enableDoubleTapZooming: true,
      zoomMode: ZoomMode.x,
      enableMouseWheelZooming: true,
    );

    _trackballBehavior = TrackballBehavior(
      enable: true,
      tooltipSettings: const InteractiveTooltip(
        enable: true,
        format: 'point.x : point.y',
        color: Colors.white,
        borderColor: Colors.blue,
        borderWidth: 1,
      ),
      lineType: TrackballLineType.vertical,
      activationMode: ActivationMode.singleTap,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
    );

    _prepareChartData();
  }

  @override
  void didUpdateWidget(ExchangeRateGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rates != widget.rates ||
        oldWidget.fromCurrency != widget.fromCurrency ||
        oldWidget.toCurrency != widget.toCurrency) {
      _prepareChartData();
    }
  }

  void _prepareChartData() {
    // Filter rates by selected currencies if provided
    List<ExchangeRateReportModel> filteredRates = widget.rates.where((rate) {
      if (widget.fromCurrency != null && rate.fromCode != widget.fromCurrency) {
        return false;
      }
      if (widget.toCurrency != null && rate.toCode != widget.toCurrency) {
        return false;
      }
      return true;
    }).toList();

    // Sort by date
    filteredRates.sort((a, b) => a.rateDate.compareTo(b.rateDate));

    // Prepare chart data
    _chartData = filteredRates.map((rate) {
      return ChartData(
        date: rate.rateDate,
        exchangeRate: rate.crExchange,
        averageRate: rate.avgRate,
        fromCurrency: rate.fromCode,
        toCurrency: rate.toCode,
        currencyPair: '${rate.fromCode}/${rate.toCode}',
      );
    }).toList();

    if (mounted) {
      setState(() {});
    }
  }

  List<CartesianSeries<ChartData, DateTime>> _getChartSeries() {
    if (_selectedSeriesType == 'Area') {
      return _getAreaSeries();
    } else if (_selectedSeriesType == 'Spline') {
      return _getSplineSeries();
    } else {
      return _getLineSeries();
    }
  }

  List<CartesianSeries<ChartData, DateTime>> _getLineSeries() {
    final series = <CartesianSeries<ChartData, DateTime>>[
      LineSeries<ChartData, DateTime>(
        dataSource: _chartData,
        xValueMapper: (ChartData data, _) => data.date,
        yValueMapper: (ChartData data, _) => data.exchangeRate,
        name: 'Exchange Rate',
        color: Colors.blue,
        width: 2,
        markerSettings: const MarkerSettings(
          isVisible: true,
          shape: DataMarkerType.circle,
          borderWidth: 2,
          borderColor: Colors.blue,
          color: Colors.white,
          height: 6,
          width: 6,
        ),
        dataLabelSettings: const DataLabelSettings(
          isVisible: false,
        ),
      ),
    ];

    if (_showAverageRate && _chartData.any((data) => data.averageRate > 0)) {
      series.add(
        LineSeries<ChartData, DateTime>(
          dataSource: _chartData.where((data) => data.averageRate > 0).toList(),
          xValueMapper: (ChartData data, _) => data.date,
          yValueMapper: (ChartData data, _) => data.averageRate,
          name: 'Average Rate',
          color: Colors.green,
          width: 2,
          dashArray: const [5, 5],
          markerSettings: const MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.diamond,
            borderWidth: 2,
            borderColor: Colors.green,
            color: Colors.white,
            height: 6,
            width: 6,
          ),
        ),
      );
    }

    return series;
  }

  List<CartesianSeries<ChartData, DateTime>> _getAreaSeries() {
    final series = <CartesianSeries<ChartData, DateTime>>[
      AreaSeries<ChartData, DateTime>(
        dataSource: _chartData,
        xValueMapper: (ChartData data, _) => data.date,
        yValueMapper: (ChartData data, _) => data.exchangeRate,
        name: 'Exchange Rate',
        color: Colors.blue.withValues(alpha: .3),
        borderColor: Colors.blue,
        borderWidth: 2,
        markerSettings: const MarkerSettings(
          isVisible: true,
          shape: DataMarkerType.circle,
          borderWidth: 2,
          borderColor: Colors.blue,
          color: Colors.white,
          height: 6,
          width: 6,
        ),
      ),
    ];

    if (_showAverageRate && _chartData.any((data) => data.averageRate > 0)) {
      series.add(
        AreaSeries<ChartData, DateTime>(
          dataSource: _chartData.where((data) => data.averageRate > 0).toList(),
          xValueMapper: (ChartData data, _) => data.date,
          yValueMapper: (ChartData data, _) => data.averageRate,
          name: 'Average Rate',
          color: Colors.green.withValues(alpha: .3),
          borderColor: Colors.green,
          borderWidth: 2,
          dashArray: const [5, 5],
          markerSettings: const MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.diamond,
            borderWidth: 2,
            borderColor: Colors.green,
            color: Colors.white,
            height: 6,
            width: 6,
          ),
        ),
      );
    }

    return series;
  }

  List<CartesianSeries<ChartData, DateTime>> _getSplineSeries() {
    final series = <CartesianSeries<ChartData, DateTime>>[
      SplineSeries<ChartData, DateTime>(
        dataSource: _chartData,
        xValueMapper: (ChartData data, _) => data.date,
        yValueMapper: (ChartData data, _) => data.exchangeRate,
        name: 'Exchange Rate',
        color: Colors.blue,
        width: 2,
        markerSettings: const MarkerSettings(
          isVisible: true,
          shape: DataMarkerType.circle,
          borderWidth: 2,
          borderColor: Colors.blue,
          color: Colors.white,
          height: 6,
          width: 6,
        ),
      ),
    ];

    if (_showAverageRate && _chartData.any((data) => data.averageRate > 0)) {
      series.add(
        SplineSeries<ChartData, DateTime>(
          dataSource: _chartData.where((data) => data.averageRate > 0).toList(),
          xValueMapper: (ChartData data, _) => data.date,
          yValueMapper: (ChartData data, _) => data.averageRate,
          name: 'Average Rate',
          color: Colors.green,
          width: 2,
          dashArray: const [5, 5],
          markerSettings: const MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.diamond,
            borderWidth: 2,
            borderColor: Colors.green,
            color: Colors.white,
            height: 6,
            width: 6,
          ),
        ),
      );
    }

    return series;
  }

  @override
  Widget build(BuildContext context) {
    if (_chartData.isEmpty) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: .1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No data available for selected filters',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Graph Header with Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exchange Rate History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCurrencyPairTitle(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Series Type Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSeriesType,
                          items: ['Line', 'Area', 'Spline']
                              .map((type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSeriesType = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Toggle Average Rate
                    FilterChip(
                      label: const Text('Show Average'),
                      selected: _showAverageRate,
                      onSelected: (selected) {
                        setState(() {
                          _showAverageRate = selected;
                        });
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: Colors.blue[100],
                      checkmarkColor: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SfCartesianChart(
                title: ChartTitle(
                  text: 'Rate History',
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                  alignment: ChartAlignment.near,
                ),
                primaryXAxis: DateTimeAxis(
                  title: AxisTitle(text: 'Date'),
                  dateFormat: DateFormat('MMM dd'),
                  intervalType: DateTimeIntervalType.days,
                  majorGridLines: const MajorGridLines(width: 0),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Exchange Rate'),
                  labelFormat: '{value}',
                  numberFormat: NumberFormat('#,##0.######'),
                  majorGridLines: const MajorGridLines(width: 1, color: Colors.grey),
                ),
                series: _getChartSeries(),
                tooltipBehavior: _tooltipBehavior,
                zoomPanBehavior: _zoomPanBehavior,
                trackballBehavior: _trackballBehavior,
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  orientation: LegendItemOrientation.horizontal,
                  toggleSeriesVisibility: true,
                ),
              ),
            ),
          ),

          // Statistics
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Current Rate',
                  _chartData.isNotEmpty
                      ? _chartData.last.exchangeRate.toStringAsFixed(6)
                      : 'N/A',
                  Colors.blue,
                ),
                _buildStatCard(
                  'Average',
                  _calculateAverage().toStringAsFixed(6),
                  Colors.green,
                ),
                _buildStatCard(
                  'High',
                  _calculateHigh().toStringAsFixed(6),
                  Colors.red,
                ),
                _buildStatCard(
                  'Low',
                  _calculateLow().toStringAsFixed(6),
                  Colors.orange,
                ),
                _buildStatCard(
                  'Change',
                  _calculateChange(),
                  _calculateChange().startsWith('+')
                      ? Colors.green
                      : Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrencyPairTitle() {
    if (widget.fromCurrency != null && widget.toCurrency != null) {
      return '${widget.fromCurrency} to ${widget.toCurrency}';
    } else if (_chartData.isNotEmpty) {
      final firstPair = _chartData.first;
      return '${firstPair.fromCurrency} to ${firstPair.toCurrency}';
    }
    return 'Multiple Currency Pairs';
  }

  double _calculateAverage() {
    if (_chartData.isEmpty) return 0;
    final sum = _chartData
        .map((data) => data.exchangeRate)
        .reduce((a, b) => a + b);
    return sum / _chartData.length;
  }

  double _calculateHigh() {
    if (_chartData.isEmpty) return 0;
    return _chartData
        .map((data) => data.exchangeRate)
        .reduce((a, b) => a > b ? a : b);
  }

  double _calculateLow() {
    if (_chartData.isEmpty) return 0;
    return _chartData
        .map((data) => data.exchangeRate)
        .reduce((a, b) => a < b ? a : b);
  }

  String _calculateChange() {
    if (_chartData.length < 2) return '0.00%';
    final first = _chartData.first.exchangeRate;
    final last = _chartData.last.exchangeRate;
    final change = last - first;
    final percentage = (change / first * 100);
    final prefix = change >= 0 ? '+' : '';
    return '$prefix${change.toStringAsFixed(6)}\n($prefix${percentage.toStringAsFixed(2)}%)';
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final DateTime date;
  final double exchangeRate;
  final double averageRate;
  final String fromCurrency;
  final String toCurrency;
  final String currencyPair;

  ChartData({
    required this.date,
    required this.exchangeRate,
    required this.averageRate,
    required this.fromCurrency,
    required this.toCurrency,
    required this.currencyPair,
  });
}

