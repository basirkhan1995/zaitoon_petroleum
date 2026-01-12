// To parse this JSON data, do
//
//     final trialBalanceModel = trialBalanceModelFromMap(jsonString);

import 'dart:convert';

List<TrialBalanceModel> trialBalanceModelFromMap(String str) => List<TrialBalanceModel>.from(json.decode(str).map((x) => TrialBalanceModel.fromMap(x)));

String trialBalanceModelToMap(List<TrialBalanceModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class TrialBalanceModel {
  final String? accountNumber;
  final String? accountName;
  final Currency? currency;
  final Category? category;
  final String? debit;
  final String? credit;

  TrialBalanceModel({
    this.accountNumber,
    this.accountName,
    this.currency,
    this.category,
    this.debit,
    this.credit,
  });

  TrialBalanceModel copyWith({
    String? accountNumber,
    String? accountName,
    Currency? currency,
    Category? category,
    String? debit,
    String? credit,
  }) =>
      TrialBalanceModel(
        accountNumber: accountNumber ?? this.accountNumber,
        accountName: accountName ?? this.accountName,
        currency: currency ?? this.currency,
        category: category ?? this.category,
        debit: debit ?? this.debit,
        credit: credit ?? this.credit,
      );

  factory TrialBalanceModel.fromMap(Map<String, dynamic> json) => TrialBalanceModel(
    accountNumber: json["account_number"],
    accountName: json["account_name"],
    currency: currencyValues.map[json["currency"]]!,
    category: categoryValues.map[json["category"]]!,
    debit: json["debit"],
    credit: json["credit"],
  );

  Map<String, dynamic> toMap() => {
    "account_number": accountNumber,
    "account_name": accountName,
    "currency": currencyValues.reverse[currency],
    "category": categoryValues.reverse[category],
    "debit": debit,
    "credit": credit,
  };
}

enum Category {
  ASSET,
  EXPENSE,
  INCOME,
  LIABILITY
}

final categoryValues = EnumValues({
  "Asset": Category.ASSET,
  "Expense": Category.EXPENSE,
  "Income": Category.INCOME,
  "Liability": Category.LIABILITY
});

enum Currency {
  USD
}

final currencyValues = EnumValues({
  "USD": Currency.USD
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
