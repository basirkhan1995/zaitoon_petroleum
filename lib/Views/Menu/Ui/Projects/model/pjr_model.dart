
import 'dart:convert';

List<ProjectsModel> projectsModelFromMap(String str) => List<ProjectsModel>.from(json.decode(str).map((x) => ProjectsModel.fromMap(x)));

String projectsModelToMap(List<ProjectsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ProjectsModel {
  final int? prjId;
  final String? prjName;
  final String? prjLocation;
  final int? prjOwner;
  final String? prjDetails;
  final DateTime? prjDateLine;
  final DateTime? prjEntryDate;
  final int? prjStatus;
  final int? prjOwnerAccount;
  final String? usrName;

  ProjectsModel({
    this.prjId,
    this.prjName,
    this.prjLocation,
    this.prjOwner,
    this.prjDetails,
    this.prjDateLine,
    this.prjEntryDate,
    this.prjStatus,
    this.prjOwnerAccount,
    this.usrName,
  });

  ProjectsModel copyWith({
    int? prjId,
    String? prjName,
    String? prjLocation,
    int? prjOwner,
    String? prjDetails,
    DateTime? prjDateLine,
    DateTime? prjEntryDate,
    int? prjStatus,
    int? prjOwnerAccount,
    String? usrName,
  }) =>
      ProjectsModel(
        prjId: prjId ?? this.prjId,
        prjName: prjName ?? this.prjName,
        prjLocation: prjLocation ?? this.prjLocation,
        prjOwner: prjOwner ?? this.prjOwner,
        prjDetails: prjDetails ?? this.prjDetails,
        prjDateLine: prjDateLine ?? this.prjDateLine,
        prjEntryDate: prjEntryDate ?? this.prjEntryDate,
        prjStatus: prjStatus ?? this.prjStatus,
        prjOwnerAccount: prjOwnerAccount ?? this.prjOwnerAccount,
        usrName: usrName ?? this.usrName,
      );

  factory ProjectsModel.fromMap(Map<String, dynamic> json) => ProjectsModel(
    prjId: json["prjID"],
    prjName: json["prjName"],
    prjLocation: json["prjLocation"],
    prjOwner: json["prjOwner"],
    prjDetails: json["prjDetails"],
    prjDateLine: json["prjDateLine"] == null ? null : DateTime.parse(json["prjDateLine"]),
    prjEntryDate: json["prjEntryDate"] == null ? null : DateTime.parse(json["prjEntryDate"]),
    prjStatus: json["prjStatus"],
    prjOwnerAccount: json["prjOwnerAccount"],
    usrName: json["usrName"],
  );

  Map<String, dynamic> toMap() => {
    "prjID": prjId,
    "prjName": prjName,
    "prjLocation": prjLocation,
    "prjOwner": prjOwner,
    "prjDetails": prjDetails,
    "prjDateLine": "${prjDateLine!.year.toString().padLeft(4, '0')}-${prjDateLine!.month.toString().padLeft(2, '0')}-${prjDateLine!.day.toString().padLeft(2, '0')}",
    "prjEntryDate": prjEntryDate?.toIso8601String(),
    "prjStatus": prjStatus,
    "prjOwnerAccount": prjOwnerAccount,
    "usrName": usrName,
  };
}
