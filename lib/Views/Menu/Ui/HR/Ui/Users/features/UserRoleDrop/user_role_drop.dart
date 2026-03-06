// To parse this JSON data, do
//
//     final userRoleModel = userRoleModelFromMap(jsonString);

import 'dart:convert';

List<UserRoleModel> userRoleModelFromMap(String str) => List<UserRoleModel>.from(json.decode(str).map((x) => UserRoleModel.fromMap(x)));

String userRoleModelToMap(List<UserRoleModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class UserRoleModel {
  final int? rolId;
  final String? rolName;
  final int? rolStatus;

  UserRoleModel({
    this.rolId,
    this.rolName,
    this.rolStatus,
  });

  UserRoleModel copyWith({
    int? rolId,
    String? rolName,
    int? rolStatus,
  }) =>
      UserRoleModel(
        rolId: rolId ?? this.rolId,
        rolName: rolName ?? this.rolName,
        rolStatus: rolStatus ?? this.rolStatus,
      );

  factory UserRoleModel.fromMap(Map<String, dynamic> json) => UserRoleModel(
    rolId: json["rolID"],
    rolName: json["rolName"],
    rolStatus: json["rolStatus"],
  );

  Map<String, dynamic> toMap() => {
    "rolID": rolId,
    "rolName": rolName,
    "rolStatus": rolStatus,
  };
}
