// To parse this JSON data, do
//
//     final userPermissionsModel = userPermissionsModelFromMap(jsonString);

import 'dart:convert';

List<UserPermissionsModel> userPermissionsModelFromMap(String str) => List<UserPermissionsModel>.from(json.decode(str).map((x) => UserPermissionsModel.fromMap(x)));

String userPermissionsModelToMap(List<UserPermissionsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class UserPermissionsModel {
  final int? uprRole;
  final String? usrName;
  final int? uprStatus;
  final String? rsgName;

  UserPermissionsModel({
    this.uprRole,
    this.usrName,
    this.uprStatus,
    this.rsgName,
  });

  UserPermissionsModel copyWith({
    int? uprRole,
    String? usrName,
    int? uprStatus,
    String? rsgName,
  }) =>
      UserPermissionsModel(
        uprRole: uprRole ?? this.uprRole,
        usrName: usrName ?? this.usrName,
        uprStatus: uprStatus ?? this.uprStatus,
        rsgName: rsgName ?? this.rsgName,
      );

  factory UserPermissionsModel.fromMap(Map<String, dynamic> json) => UserPermissionsModel(
    uprRole: json["uprRole"],
    usrName: json["usrName"],
    uprStatus: json["uprStatus"],
    rsgName: json["rsgName"],
  );

  Map<String, dynamic> toMap() => {
    "uprRole": uprRole,
    "usrName": usrName,
    "uprStatus": uprStatus,
    "rsgName": rsgName,
  };
}
