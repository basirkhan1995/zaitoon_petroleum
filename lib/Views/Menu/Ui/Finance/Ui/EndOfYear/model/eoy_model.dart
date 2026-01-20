class PAndLModel {
  final int? trdBranch;
  final int? accountNumber;
  final String? accountName;
  final String? currency;
  final String? category;
  final String? debit;
  final String? credit;

  PAndLModel({
    this.trdBranch,
    this.accountNumber,
    this.accountName,
    this.currency,
    this.category,
    this.debit,
    this.credit,
  });

  /// ==========================
  /// Computed values
  /// ==========================
  double get debitAmount => double.tryParse(debit ?? "0") ?? 0;
  double get creditAmount => double.tryParse(credit ?? "0") ?? 0;

  bool get isIncome => (category ?? "").toLowerCase() == "income";
  bool get isExpense => (category ?? "").toLowerCase() == "expense";

  /// ==========================
  /// copy / map
  /// ==========================
  PAndLModel copyWith({
    int? trdBranch,
    int? accountNumber,
    String? accountName,
    String? currency,
    String? category,
    String? debit,
    String? credit,
  }) =>
      PAndLModel(
        trdBranch: trdBranch ?? this.trdBranch,
        accountNumber: accountNumber ?? this.accountNumber,
        accountName: accountName ?? this.accountName,
        currency: currency ?? this.currency,
        category: category ?? this.category,
        debit: debit ?? this.debit,
        credit: credit ?? this.credit,
      );

  factory PAndLModel.fromMap(Map<String, dynamic> json) => PAndLModel(
    trdBranch: json["trdBranch"],
    accountNumber: json["account_number"],
    accountName: json["account_name"],
    currency: json["currency"],
    category: json["category"],
    debit: json["debit"],
    credit: json["credit"],
  );

  Map<String, dynamic> toMap() => {
    "trdBranch": trdBranch,
    "account_number": accountNumber,
    "account_name": accountName,
    "currency": currency,
    "category": category,
    "debit": debit,
    "credit": credit,
  };
}

class PAndLSummary {
  final double totalIncome;
  final double totalExpense;

  const PAndLSummary({
    required this.totalIncome,
    required this.totalExpense,
  });

  double get retainedEarnings => totalIncome - totalExpense;
}

extension PAndLListExtension on List<PAndLModel> {
  PAndLSummary get summary {
    double income = 0;
    double expense = 0;

    for (final item in this) {
      if (item.isIncome) {
        income += item.creditAmount;
      } else if (item.isExpense) {
        expense += item.debitAmount;
      }
    }

    return PAndLSummary(
      totalIncome: income,
      totalExpense: expense,
    );
  }
}
