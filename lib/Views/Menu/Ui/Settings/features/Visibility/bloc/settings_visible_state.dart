part of 'settings_visible_bloc.dart';

enum DateType {
  hijriShamsi,
  gregorian,
}

 class SettingsVisibilityState {
  final bool stock;
  final bool attendance;
  final bool exchangeRate;
  final bool currencyRates;
  final bool dashboardClock;
  final bool recentTransactions;
  final DateType dateType;
  final String dateFormat;
  final bool isDateExpiry;
  final bool quickAccess;
  final bool profitAndLoss;
  final bool todayTotalTransactions;
  final bool statsCount;
  final bool todayTotalTxnChart;

  SettingsVisibilityState({
    this.stock = false,
    this.attendance = false,
    this.exchangeRate = true,
    this.isDateExpiry = false,
    this.currencyRates = false,
    this.dashboardClock = true,
    this.recentTransactions = false,
    this.quickAccess = true,
    this.dateType = DateType.gregorian,
    this.dateFormat = 'yyyy-MM-dd',
    this.profitAndLoss = true,
    this.todayTotalTransactions = true,
    this.statsCount = true,
    this.todayTotalTxnChart = true,
  });

  factory SettingsVisibilityState.fromMap(Map<String, dynamic> map) {
    return SettingsVisibilityState(
      stock: map['stock'] ?? false,
      attendance: map['attendance'] ?? false,
      exchangeRate: map['exchangeRate'] ?? true,
      currencyRates: map['currencyUsd'] ?? false,
      dashboardClock: map['clock'] ?? true,
      isDateExpiry: map['dateExpiry'],
      quickAccess: map['quickAccess'] ?? false,
      recentTransactions: map['recentTransactions'] ?? false,
      dateType: _dateTypeFromString(map['dateType'] ?? 'gregorian'),
      dateFormat: map['dateFormat'] ?? 'yyyy-MM-dd',
      profitAndLoss: map['profitAndLoss'] ?? true,
      statsCount: map['statsCount'] ?? true,
      todayTotalTransactions: map['todayTotalTransactions'] ?? true,
      todayTotalTxnChart: map['todayTotalTxnChart'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'stock': stock,
    'attendance': attendance,
    'currencyAfn': exchangeRate,
    'currencyUsd': currencyRates,
    'clock': dashboardClock,
    'dateType': dateType.name,
    'dateFormat': dateFormat,
    'dateExpiry':isDateExpiry,
    'quickAccess' : quickAccess,
    'recentTransactions':recentTransactions,
    'profitAndLoss': profitAndLoss,
    'statsCount': statsCount,
    'todayTotalTransactions': todayTotalTransactions,
    'todayTotalTxnChart':todayTotalTxnChart
  };

  static DateType _dateTypeFromString(String value) {
    return DateType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => DateType.gregorian,
    );
  }
}
