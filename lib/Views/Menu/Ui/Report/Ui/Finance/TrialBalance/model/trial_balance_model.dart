

class TrialBalanceModel {
  final String accountNumber;
  final String accountName;
  final String currency;
  final String category;
  final double debit;
  final double credit;

  TrialBalanceModel({
    required this.accountNumber,
    required this.accountName,
    required this.currency,
    required this.category,
    required this.debit,
    required this.credit,
  });

  factory TrialBalanceModel.fromMap(Map<String, dynamic> json) => TrialBalanceModel(
    accountNumber: json["account_number"] ?? "",
    accountName: json["account_name"] ?? "",
    currency: json["currency"] ?? "USD",
    category: json["category"] ?? "",
    debit: double.tryParse(json["debit"] ?? "0.0") ?? 0.0,
    credit: double.tryParse(json["credit"] ?? "0.0") ?? 0.0,
  );

  Map<String, dynamic> toMap() => {
    "account_number": accountNumber,
    "account_name": accountName,
    "currency": currency,
    "category": category,
    "debit": debit.toString(),
    "credit": credit.toString(),
  };
}

// trial_balance_helper.dart
class TrialBalanceHelper {
  static double getTotalDebit(List<TrialBalanceModel> data) {
    return data.fold(0.0, (sum, item) => sum + item.debit);
  }

  static double getTotalCredit(List<TrialBalanceModel> data) {
    return data.fold(0.0, (sum, item) => sum + item.credit);
  }

  static double getDifference(List<TrialBalanceModel> data) {
    return getTotalDebit(data) - getTotalCredit(data);
  }

  static double getDifferencePercentage(List<TrialBalanceModel> data) {
    final totalDebit = getTotalDebit(data);
    if (totalDebit == 0) return 0.0;
    return (getDifference(data).abs() / totalDebit) * 100;
  }

  // Helper to format amount with thousand separators
  static String formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }
}