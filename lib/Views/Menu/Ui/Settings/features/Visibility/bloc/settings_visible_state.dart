part of 'settings_visible_bloc.dart';

enum DateType {
  hijriShamsi,
  gregorian,
}

 class SettingsVisibilityState {
  final bool stock;
  final bool attendance;
  final bool exchangeRate;
  final bool currencyUsdToOther;
  final bool dashboardClock;
  final bool recentTransactions;
  final DateType dateType;
  final String dateFormat;
  final bool isDateExpiry;
  final bool quickAccess;

  SettingsVisibilityState({
    this.stock = false,
    this.attendance = false,
    this.exchangeRate = true,
    this.isDateExpiry = false,
    this.currencyUsdToOther = false,
    this.dashboardClock = true,
    this.recentTransactions = false,
    this.quickAccess = true,
    this.dateType = DateType.gregorian,
    this.dateFormat = 'yyyy-MM-dd',
  });

  factory SettingsVisibilityState.fromMap(Map<String, dynamic> map) {
    return SettingsVisibilityState(
      stock: map['stock'] ?? false,
      attendance: map['attendance'] ?? false,
      exchangeRate: map['exchangeRate'] ?? true,
      currencyUsdToOther: map['currencyUsd'] ?? false,
      dashboardClock: map['clock'] ?? true,
      isDateExpiry: map['dateExpiry'],
      quickAccess: map['quickAccess'] ?? false,
      recentTransactions: map['recentTransactions'] ?? false,
      dateType: _dateTypeFromString(map['dateType'] ?? 'gregorian'),
      dateFormat: map['dateFormat'] ?? 'yyyy-MM-dd',
    );
  }

  Map<String, dynamic> toMap() => {
    'stock': stock,
    'attendance': attendance,
    'currencyAfn': exchangeRate,
    'currencyUsd': currencyUsdToOther,
    'clock': dashboardClock,
    'dateType': dateType.name,
    'dateFormat': dateFormat,
    'dateExpiry':isDateExpiry,
    'quickAccess' : quickAccess,
    'recentTransactions':recentTransactions,
  };

  static DateType _dateTypeFromString(String value) {
    return DateType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => DateType.gregorian,
    );
  }
}
