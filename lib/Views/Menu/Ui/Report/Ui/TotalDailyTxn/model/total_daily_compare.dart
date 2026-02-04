

import 'daily_txn_model.dart';

class TotalDailyCompare {
  final TotalDailyTxnModel today;
  final TotalDailyTxnModel yesterday;

  TotalDailyCompare({
    required this.today,
    required this.yesterday,
  });

  double get percentage {
    final todayAmount = today.totalAmount ?? 0;
    final yesterdayAmount = yesterday.totalAmount ?? 0;

    if (yesterdayAmount == 0) {
      return todayAmount == 0 ? 0 : 100;
    }

    return ((todayAmount - yesterdayAmount) / yesterdayAmount) * 100;
  }

  bool get isIncrease => percentage >= 0;
}
