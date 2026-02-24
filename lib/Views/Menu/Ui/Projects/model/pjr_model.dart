// To parse this JSON data, do
//
//     final projectsModel = projectsModelFromMap(jsonString);

import 'dart:convert';

List<ProjectsModel> projectsModelFromMap(String str) => List<ProjectsModel>.from(json.decode(str).map((x) => ProjectsModel.fromMap(x)));

String projectsModelToMap(List<ProjectsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ProjectsModel {
  final int? prjId;
  final String? prjName;
  final String? prjLocation;
  final String? prjDetails;
  final DateTime? prjDateLine;
  final DateTime? prjEntryDate;
  final int? prjOwner;
  final String? prjOwnerfullName;
  final int? prjOwnerAccount;
  final String? actCurrency;
  final int? prjStatus;
  final String? usrName;

  ProjectsModel({
    this.prjId,
    this.prjName,
    this.prjLocation,
    this.prjDetails,
    this.prjDateLine,
    this.prjEntryDate,
    this.prjOwner,
    this.prjOwnerfullName,
    this.prjOwnerAccount,
    this.actCurrency,
    this.prjStatus,
    this.usrName,
  });

  ProjectsModel copyWith({
    int? prjId,
    String? prjName,
    String? prjLocation,
    String? prjDetails,
    DateTime? prjDateLine,
    DateTime? prjEntryDate,
    int? prjOwner,
    String? prjOwnerfullName,
    int? prjOwnerAccount,
    String? actCurrency,
    int? prjStatus,
    String? usrName,
  }) =>
      ProjectsModel(
        prjId: prjId ?? this.prjId,
        prjName: prjName ?? this.prjName,
        prjLocation: prjLocation ?? this.prjLocation,
        prjDetails: prjDetails ?? this.prjDetails,
        prjDateLine: prjDateLine ?? this.prjDateLine,
        prjEntryDate: prjEntryDate ?? this.prjEntryDate,
        prjOwner: prjOwner ?? this.prjOwner,
        prjOwnerfullName: prjOwnerfullName ?? this.prjOwnerfullName,
        prjOwnerAccount: prjOwnerAccount ?? this.prjOwnerAccount,
        actCurrency: actCurrency ?? this.actCurrency,
        prjStatus: prjStatus ?? this.prjStatus,
        usrName: usrName ?? this.usrName,
      );

  factory ProjectsModel.fromMap(Map<String, dynamic> json) => ProjectsModel(
    prjId: json["prjID"],
    prjName: json["prjName"],
    prjLocation: json["prjLocation"],
    prjDetails: json["prjDetails"],
    prjDateLine: json["prjDateLine"] == null ? null : DateTime.parse(json["prjDateLine"]),
    prjEntryDate: json["prjEntryDate"] == null ? null : DateTime.parse(json["prjEntryDate"]),
    prjOwner: json["prjOwner"],
    prjOwnerfullName: json["prjOwnerfullName"],
    prjOwnerAccount: json["prjOwnerAccount"],
    actCurrency: json["actCurrency"],
    prjStatus: json["prjStatus"],
    usrName: json["usrName"],
  );

  Map<String, dynamic> toMap() => {
    "prjID": prjId,
    "prjName": prjName,
    "prjLocation": prjLocation,
    "prjDetails": prjDetails,
    "prjDateLine": "${prjDateLine!.year.toString().padLeft(4, '0')}-${prjDateLine!.month.toString().padLeft(2, '0')}-${prjDateLine!.day.toString().padLeft(2, '0')}",
    "prjEntryDate": prjEntryDate?.toIso8601String(),
    "prjOwner": prjOwner,
    "prjOwnerfullName": prjOwnerfullName,
    "prjOwnerAccount": prjOwnerAccount,
    "actCurrency": actCurrency,
    "prjStatus": prjStatus,
    "usrName": usrName,
  };
}
