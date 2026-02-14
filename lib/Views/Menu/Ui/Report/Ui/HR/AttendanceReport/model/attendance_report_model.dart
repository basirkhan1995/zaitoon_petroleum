// To parse this JSON data, do
//
//     final attendanceReportModel = attendanceReportModelFromMap(jsonString);

import 'dart:convert';

List<AttendanceReportModel> attendanceReportModelFromMap(String str) => List<AttendanceReportModel>.from(json.decode(str).map((x) => AttendanceReportModel.fromMap(x)));

String attendanceReportModelToMap(List<AttendanceReportModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class AttendanceReportModel {
  final int? emaId;
  final int? emaEmployee;
  final String? fullName;
  final String? empPosition;
  final DateTime? emaDate;
  final String? emaCheckedIn;
  final String? emaCheckedOut;
  final String? totalhours;
  final String? emaStatus;

  AttendanceReportModel({
    this.emaId,
    this.emaEmployee,
    this.fullName,
    this.empPosition,
    this.emaDate,
    this.emaCheckedIn,
    this.emaCheckedOut,
    this.totalhours,
    this.emaStatus,
  });

  AttendanceReportModel copyWith({
    int? emaId,
    int? emaEmployee,
    String? fullName,
    String? empPosition,
    DateTime? emaDate,
    String? emaCheckedIn,
    String? emaCheckedOut,
    String? totalhours,
    String? emaStatus,
  }) =>
      AttendanceReportModel(
        emaId: emaId ?? this.emaId,
        emaEmployee: emaEmployee ?? this.emaEmployee,
        fullName: fullName ?? this.fullName,
        empPosition: empPosition ?? this.empPosition,
        emaDate: emaDate ?? this.emaDate,
        emaCheckedIn: emaCheckedIn ?? this.emaCheckedIn,
        emaCheckedOut: emaCheckedOut ?? this.emaCheckedOut,
        totalhours: totalhours ?? this.totalhours,
        emaStatus: emaStatus ?? this.emaStatus,
      );

  factory AttendanceReportModel.fromMap(Map<String, dynamic> json) => AttendanceReportModel(
    emaId: json["emaID"],
    emaEmployee: json["emaEmployee"],
    fullName: json["fullName"],
    empPosition: json["empPosition"],
    emaDate: json["emaDate"] == null ? null : DateTime.parse(json["emaDate"]),
    emaCheckedIn: json["emaCheckedIn"],
    emaCheckedOut: json["emaCheckedOut"],
    totalhours: json["totalhours"],
    emaStatus: json["emaStatus"],
  );

  Map<String, dynamic> toMap() => {
    "emaID": emaId,
    "emaEmployee": emaEmployee,
    "fullName": fullName,
    "empPosition": empPosition,
    "emaDate": "${emaDate!.year.toString().padLeft(4, '0')}-${emaDate!.month.toString().padLeft(2, '0')}-${emaDate!.day.toString().padLeft(2, '0')}",
    "emaCheckedIn": emaCheckedIn,
    "emaCheckedOut": emaCheckedOut,
    "totalhours": totalhours,
    "emaStatus": emaStatus,
  };
}
