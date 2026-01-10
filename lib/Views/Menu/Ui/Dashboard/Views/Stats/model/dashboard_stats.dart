// To parse this JSON data, do
//
//     final dashboardStatsModel = dashboardStatsModelFromMap(jsonString);

import 'dart:convert';

DashboardStatsModel dashboardStatsModelFromMap(String str) =>
    DashboardStatsModel.fromMap(json.decode(str));

String dashboardStatsModelToMap(DashboardStatsModel data) =>
    json.encode(data.toMap());

class DashboardStatsModel {
  final int? personals;
  final int? employees;
  final int? accounts;
  final int? users;

  const DashboardStatsModel({
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
  }) {
    return DashboardStatsModel(
      personals: personals ?? this.personals,
      employees: employees ?? this.employees,
      accounts: accounts ?? this.accounts,
      users: users ?? this.users,
    );
  }

  /// ✅ SAFE parsing (handles int, string, null)
  factory DashboardStatsModel.fromMap(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return DashboardStatsModel(
      personals: parseInt(json['personals']),
      employees: parseInt(json['employees']),
      accounts: parseInt(json['accounts']),
      users: parseInt(json['users']),
    );
  }

  Map<String, dynamic> toMap() => {
    'personals': personals,
    'employees': employees,
    'accounts': accounts,
    'users': users,
  };

  /// ✅ Dashboard-friendly getters (no null in UI)
  int get personalsCount => personals ?? 0;
  int get employeesCount => employees ?? 0;
  int get accountsCount => accounts ?? 0;
  int get usersCount => users ?? 0;
}
