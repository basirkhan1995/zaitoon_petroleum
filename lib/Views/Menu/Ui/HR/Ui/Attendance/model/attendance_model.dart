
import 'dart:convert';

AttendanceModel attendanceModelFromMap(String str) => AttendanceModel.fromMap(json.decode(str));

String attendanceModelToMap(AttendanceModel data) => json.encode(data.toMap());

class AttendanceModel {
  final String? usrName;
  final List<AttendanceRecord>? records;

  AttendanceModel({
    this.usrName,
    this.records,
  });

  AttendanceModel copyWith({
    String? usrName,
    List<AttendanceRecord>? records,
  }) =>
      AttendanceModel(
        usrName: usrName ?? this.usrName,
        records: records ?? this.records,
      );

  factory AttendanceModel.fromMap(Map<String, dynamic> json) => AttendanceModel(
    usrName: json["usrName"],
    records: json["records"] == null ? [] : List<AttendanceRecord>.from(json["records"]!.map((x) => AttendanceRecord.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "usrName": usrName,
    "records": records == null ? [] : List<dynamic>.from(records!.map((x) => x.toMap())),
  };
}

class AttendanceRecord {
  final String? usrName;
  final int? emaId;
  final int? emaEmployee;
  final String? emaCheckedIn;
  final String? emaCheckedOut;
  final String? emaStatus;

  AttendanceRecord({
    this.usrName,
    this.emaId,
    this.emaEmployee,
    this.emaCheckedIn,
    this.emaCheckedOut,
    this.emaStatus,
  });

  AttendanceRecord copyWith({
    String? usrName,
    int? emaId,
    int? emaEmployee,
    String? emaCheckedIn,
    String? emaCheckedOut,
    String? emaStatus,
  }) =>
      AttendanceRecord(
        usrName: usrName ?? this.usrName,
        emaId: emaId ?? this.emaId,
        emaEmployee: emaEmployee ?? this.emaEmployee,
        emaCheckedIn: emaCheckedIn ?? this.emaCheckedIn,
        emaCheckedOut: emaCheckedOut ?? this.emaCheckedOut,
        emaStatus: emaStatus ?? this.emaStatus,
      );

  factory AttendanceRecord.fromMap(Map<String, dynamic> json) => AttendanceRecord(
    usrName: json["usrName"],
    emaId: json["emaID"],
    emaEmployee: json["emaEmployee"],
    emaCheckedIn: json["emaCheckedIn"],
    emaCheckedOut: json["emaCheckedOut"],
    emaStatus: json["emaStatus"],
  );

  Map<String, dynamic> toMap() => {
    "usrName": usrName,
    "emaID": emaId,
    "emaEmployee": emaEmployee,
    "emaCheckedIn": emaCheckedIn,
    "emaCheckedOut": emaCheckedOut,
    "emaStatus": emaStatus,
  };
}
