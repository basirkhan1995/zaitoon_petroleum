
import 'dart:convert';

List<StakeholdersModel> stakeholdersModelFromMap(String str) => List<StakeholdersModel>.from(json.decode(str).map((x) => StakeholdersModel.fromMap(x)));

String stakeholdersModelToMap(List<StakeholdersModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class StakeholdersModel {
  final int? perId;
  final String? perName;
  final String? perLastName;
  final String? perGender;
  final String? perDoB;
  final String? perEnidNo;
  final String? perPhone;

  StakeholdersModel({
    this.perId,
    this.perName,
    this.perLastName,
    this.perGender,
    this.perDoB,
    this.perEnidNo,
    this.perPhone,
  });

  StakeholdersModel copyWith({
    int? perId,
    String? perName,
    String? perLastName,
    String? perGender,
    String? perDoB,
    String? perEnidNo,
    String? perPhone,
  }) =>
      StakeholdersModel(
        perId: perId ?? this.perId,
        perName: perName ?? this.perName,
        perLastName: perLastName ?? this.perLastName,
        perGender: perGender ?? this.perGender,
        perDoB: perDoB ?? this.perDoB,
        perEnidNo: perEnidNo ?? this.perEnidNo,
        perPhone: perPhone ?? this.perPhone,
      );

  factory StakeholdersModel.fromMap(Map<String, dynamic> json) => StakeholdersModel(
    perId: json["perID"],
    perName: json["perName"],
    perLastName: json["perLastName"],
    perGender: json["perGender"],
    perDoB: json["perDoB"],
    perEnidNo: json["perENIDNo"],
    perPhone: json["perPhone"],
  );

  Map<String, dynamic> toMap() => {
    "perID": perId,
    "perName": perName,
    "perLastName": perLastName,
    "perGender": perGender,
    "perDoB": perDoB,
    "perENIDNo": perEnidNo,
    "perPhone": perPhone,
  };
}
