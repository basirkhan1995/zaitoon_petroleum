import 'dart:convert';
import 'package:equatable/equatable.dart';

class DashboardStatsModel extends Equatable {
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

  // Getter methods with null safety
  int get personalsCount => personals ?? 0;
  int get employeesCount => employees ?? 0;
  int get accountsCount => accounts ?? 0;
  int get usersCount => users ?? 0;

  // Check if we have any data to display
  bool get hasData {
    return personalsCount > 0 ||
        employeesCount > 0 ||
        accountsCount > 0 ||
        usersCount > 0;
  }

  // Check if all values are null (empty response)
  bool get isEmpty {
    return personals == null &&
        employees == null &&
        accounts == null &&
        users == null;
  }

  // Check if this is the initial empty state
  bool get isInitialState {
    return personals == 0 &&
        employees == 0 &&
        accounts == 0 &&
        users == 0;
  }

  @override
  List<Object?> get props => [personals, employees, accounts, users];
}

DashboardStatsModel dashboardStatsModelFromMap(String str) =>
    DashboardStatsModel.fromMap(json.decode(str));

String dashboardStatsModelToMap(DashboardStatsModel data) =>
    json.encode(data.toMap());