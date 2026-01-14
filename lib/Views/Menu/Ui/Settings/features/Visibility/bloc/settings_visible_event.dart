part of 'settings_visible_bloc.dart';

sealed class SettingsVisibleEvent extends Equatable {
  const SettingsVisibleEvent();
}

class SaveSettingsEvent extends SettingsVisibleEvent{
  final SettingsVisibilityState value;
  const SaveSettingsEvent(this.value);
  @override
  List<Object?> get props => [value];
}


class LoadSettingsEvent extends SettingsVisibleEvent{
  @override
  List<Object?> get props => [];
}

class UpdateSettingsEvent extends SettingsVisibleEvent{
  final bool? stock;
  final bool? exchangeRate;
  final bool? currencyUsd;
  final bool? dashboardClock;
  final bool? quickAccess;
  final bool? recentTransactions;
  final DateType? dateType;
  final bool? isDateExpiry;
  final String? dateFormat;
  final bool? profitAndLoss;
  const UpdateSettingsEvent({
    this.stock,
    this.exchangeRate,
    this.isDateExpiry,
    this.currencyUsd,
    this.dashboardClock,
    this.quickAccess,
    this.dateType,
    this.dateFormat,
    this.recentTransactions,
    this.profitAndLoss
  });
  @override
  List<Object?> get props => [
    stock,
    exchangeRate,
    isDateExpiry,
    currencyUsd,
    dashboardClock,
    quickAccess,
    recentTransactions,
    dateType,
    dateFormat,
    profitAndLoss
  ];
}