import 'dart:convert';

List<PayrollModel> payrollModelFromMap(String str) => List<PayrollModel>.from(json.decode(str).map((x) => PayrollModel.fromMap(x)));

String payrollModelToMap(List<PayrollModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class PayrollModel {
  final int? perId;
  final String? fullName;
  final String? monthYear;
  final int? salaryAccount;
  final String? salary;
  final String? currency;
  final String? calculationBase;
  final int? totalDays;
  final String? hoursInMonth;
  final String? workedHours;
  final String? salaryPayable;
  final String? overtimePayable;
  final String? totalPayable;
  final int? payment;

  PayrollModel({
    this.perId,
    this.fullName,
    this.monthYear,
    this.salaryAccount,
    this.salary,
    this.currency,
    this.calculationBase,
    this.totalDays,
    this.hoursInMonth,
    this.workedHours,
    this.salaryPayable,
    this.overtimePayable,
    this.totalPayable,
    this.payment,
  });

  PayrollModel copyWith({
    int? perId,
    String? fullName,
    String? monthYear,
    int? salaryAccount,
    String? salary,
    String? currency,
    String? calculationBase,
    int? totalDays,
    String? hoursInMonth,
    String? workedHours,
    String? salaryPayable,
    String? overtimePayable,
    String? totalPayable,
    int? payment,
  }) =>
      PayrollModel(
        perId: perId ?? this.perId,
        fullName: fullName ?? this.fullName,
        monthYear: monthYear ?? this.monthYear,
        salaryAccount: salaryAccount ?? this.salaryAccount,
        salary: salary ?? this.salary,
        currency: currency ?? this.currency,
        calculationBase: calculationBase ?? this.calculationBase,
        totalDays: totalDays ?? this.totalDays,
        hoursInMonth: hoursInMonth ?? this.hoursInMonth,
        workedHours: workedHours ?? this.workedHours,
        salaryPayable: salaryPayable ?? this.salaryPayable,
        overtimePayable: overtimePayable ?? this.overtimePayable,
        totalPayable: totalPayable ?? this.totalPayable,
        payment: payment ?? this.payment,
      );

  factory PayrollModel.fromMap(Map<String, dynamic> json) => PayrollModel(
    perId: json["perID"],
    fullName: json["fullName"],
    monthYear: json["monthYear"],
    salaryAccount: json["salaryAccount"],
    salary: json["salary"],
    currency: json["currency"],
    calculationBase: json["calculationBase"],
    totalDays: json["totalDays"],
    hoursInMonth: json["hoursInMonth"],
    workedHours: json["workedHours"],
    salaryPayable: json["salaryPayable"],
    overtimePayable: json["overtimePayable"],
    totalPayable: json["totalPayable"],
    payment: json["payment"],
  );

  Map<String, dynamic> toMap() => {
    "perID": perId,
    "fullName": fullName,
    "monthYear": monthYear,
    "salaryAccount": salaryAccount,
    "salary": salary,
    "currency": currency,
    "calculationBase": calculationBase,
    "totalDays": totalDays,
    "hoursInMonth": hoursInMonth,
    "workedHours": workedHours,
    "salaryPayable": salaryPayable,
    "overtimePayable": overtimePayable,
    "totalPayable": totalPayable,
    "payment": payment,
  };
}
