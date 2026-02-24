
import 'dart:convert';

List<ProjectServicesModel> projectDetailsModelFromMap(String str) =>
    List<ProjectServicesModel>.from(
        json.decode(str).map((x) => ProjectServicesModel.fromMap(x)));

String projectDetailsModelToMap(List<ProjectServicesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ProjectServicesModel {
  final int? pjdId;
  final int? prjId;
  final String? prjName;
  final int? pjdServices;
  final String? srvName;
  final double? pjdQuantity;
  final double? pjdPricePerQty;
  final double? total;
  final String? prpTrnRef;
  final int? paymentId;
  final int? pjdStatus;

  ProjectServicesModel({
    this.pjdId,
    this.prjId,
    this.prjName,
    this.pjdServices,
    this.srvName,
    this.pjdQuantity,
    this.pjdPricePerQty,
    this.total,
    this.prpTrnRef,
    this.paymentId,
    this.pjdStatus,
  });

  ProjectServicesModel copyWith({
    int? pjdId,
    int? prjId,
    String? prjName,
    int? pjdServices,
    String? srvName,
    double? pjdQuantity,
    double? pjdPricePerQty,
    double? total,
    String? prpTrnRef,
    int? paymentId,
    int? pjdStatus,
  }) =>
      ProjectServicesModel(
        pjdId: pjdId ?? this.pjdId,
        prjId: prjId ?? this.prjId,
        prjName: prjName ?? this.prjName,
        pjdServices: pjdServices ?? this.pjdServices,
        srvName: srvName ?? this.srvName,
        pjdQuantity: pjdQuantity ?? this.pjdQuantity,
        pjdPricePerQty: pjdPricePerQty ?? this.pjdPricePerQty,
        total: total ?? this.total,
        prpTrnRef: prpTrnRef ?? this.prpTrnRef,
        paymentId: paymentId ?? this.paymentId,
        pjdStatus: pjdStatus ?? this.pjdStatus,
      );

  factory ProjectServicesModel.fromMap(Map<String, dynamic> json) =>
      ProjectServicesModel(
        pjdId: json["pjdID"],
        prjId: json["prjID"],
        prjName: json["prjName"],
        pjdServices: json["pjdServices"],
        srvName: json["srvName"],
        pjdQuantity: json["pjdQuantity"] == null
            ? null
            : double.tryParse(json["pjdQuantity"].toString()),
        pjdPricePerQty: json["pjdPricePerQty"] == null
            ? null
            : double.tryParse(json["pjdPricePerQty"].toString()),
        total: json["total"] == null
            ? null
            : double.tryParse(json["total"].toString()),
        prpTrnRef: json["prpTrnRef"],
        paymentId: json["paymentID"],
        pjdStatus: json["pjdStatus"],
      );

  Map<String, dynamic> toMap() => {
    "pjdID": pjdId,
    "prjID": prjId,
    "prjName": prjName,
    "pjdServices": pjdServices,
    "srvName": srvName,
    "pjdQuantity": pjdQuantity?.toStringAsFixed(2),
    "pjdPricePerQty": pjdPricePerQty?.toStringAsFixed(4),
    "total": total?.toStringAsFixed(6),
    "prpTrnRef": prpTrnRef,
    "paymentID": paymentId,
    "pjdStatus": pjdStatus,
  };
}