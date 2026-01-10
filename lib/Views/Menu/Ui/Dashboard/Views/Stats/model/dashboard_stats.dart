// To parse this JSON data, do
//
//     final dashboardStatsModel = dashboardStatsModelFromMap(jsonString);

import 'dart:convert';

DashboardStatsModel dashboardStatsModelFromMap(String str) => DashboardStatsModel.fromMap(json.decode(str));

String dashboardStatsModelToMap(DashboardStatsModel data) => json.encode(data.toMap());

class DashboardStatsModel {
  final int? personals;
  final int? employees;
  final int? accounts;
  final int? users;

  DashboardStatsModel({
    this.personals,
    this.employees,
    this.accounts,
    this.users,
  });

  DashboardStatsModel copyWith({
    int? personals,
    int? employees,
    int? accounts,
    int? users,
  }) =>
      DashboardStatsModel(
        personals: personals ?? this.personals,
        employees: employees ?? this.employees,
        accounts: accounts ?? this.accounts,
        users: users ?? this.users,
      );

  factory DashboardStatsModel.fromMap(Map<String, dynamic> json) => DashboardStatsModel(
    personals: json["personals"],
    employees: json["employees"],
    accounts: json["accounts"],
    users: json["users"],
  );

  Map<String, dynamic> toMap() => {
    "personals": personals,
    "employees": employees,
    "accounts": accounts,
    "users": users,
  };
}
