// To parse this JSON data, do
//
//     final usersReportModel = usersReportModelFromMap(jsonString);

import 'dart:convert';

List<UsersReportModel> usersReportModelFromMap(String str) => List<UsersReportModel>.from(json.decode(str).map((x) => UsersReportModel.fromMap(x)));

String usersReportModelToMap(List<UsersReportModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class UsersReportModel {
  final int? no;
  final int? personalId;
  final String? username;
  final String? fullName;
  final int? branch;
  final String? email;
  final String? phone;
  final String? role;
  final String? verification;
  final String? fcp;
  final int? afl;
  final String? status;
  final DateTime? createDate;

  UsersReportModel({
    this.no,
    this.personalId,
    this.username,
    this.fullName,
    this.branch,
    this.email,
    this.phone,
    this.role,
    this.verification,
    this.fcp,
    this.afl,
    this.status,
    this.createDate,
  });

  UsersReportModel copyWith({
    int? no,
    int? personalId,
    String? username,
    String? fullName,
    int? branch,
    String? email,
    String? phone,
    String? role,
    String? verification,
    String? fcp,
    int? afl,
    String? status,
    DateTime? createDate,
  }) =>
      UsersReportModel(
        no: no ?? this.no,
        personalId: personalId ?? this.personalId,
        username: username ?? this.username,
        fullName: fullName ?? this.fullName,
        branch: branch ?? this.branch,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        verification: verification ?? this.verification,
        fcp: fcp ?? this.fcp,
        afl: afl ?? this.afl,
        status: status ?? this.status,
        createDate: createDate ?? this.createDate,
      );

  factory UsersReportModel.fromMap(Map<String, dynamic> json) => UsersReportModel(
    no: json["No"],
    personalId: json["personal_id"],
    username: json["username"],
    fullName: json["fullName"],
    branch: json["branch"],
    email: json["email"],
    phone: json["phone"],
    role: json["role"],
    verification: json["verification"],
    fcp: json["fcp"],
    afl: json["afl"],
    status: json["status"],
    createDate: json["createDate"] == null ? null : DateTime.parse(json["createDate"]),
  );

  Map<String, dynamic> toMap() => {
    "No": no,
    "personal_id": personalId,
    "username": username,
    "fullName": fullName,
    "branch": branch,
    "email": email,
    "phone": phone,
    "role": role,
    "verification": verification,
    "fcp": fcp,
    "afl": afl,
    "status": status,
    "createDate": "${createDate!.year.toString().padLeft(4, '0')}-${createDate!.month.toString().padLeft(2, '0')}-${createDate!.day.toString().padLeft(2, '0')}",
  };
}
