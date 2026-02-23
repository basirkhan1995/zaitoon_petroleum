// To parse this JSON data, do
//
//     final servicesModel = servicesModelFromMap(jsonString);

import 'dart:convert';

List<ServicesModel> servicesModelFromMap(String str) => List<ServicesModel>.from(json.decode(str).map((x) => ServicesModel.fromMap(x)));

String servicesModelToMap(List<ServicesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ServicesModel {
  final int? srvId;
  final String? srvName;
  final int? srvStatus;

  ServicesModel({
    this.srvId,
    this.srvName,
    this.srvStatus,
  });

  ServicesModel copyWith({
    int? srvId,
    String? srvName,
    int? srvStatus,
  }) =>
      ServicesModel(
        srvId: srvId ?? this.srvId,
        srvName: srvName ?? this.srvName,
        srvStatus: srvStatus ?? this.srvStatus,
      );

  factory ServicesModel.fromMap(Map<String, dynamic> json) => ServicesModel(
    srvId: json["srvID"],
    srvName: json["srvName"],
    srvStatus: json["srvStatus"],
  );

  Map<String, dynamic> toMap() => {
    "srvID": srvId,
    "srvName": srvName,
    "srvStatus": srvStatus,
  };
}
