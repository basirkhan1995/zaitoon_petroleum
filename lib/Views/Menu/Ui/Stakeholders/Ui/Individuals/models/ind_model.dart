// To parse this JSON data, do
//
//     final stakeholdersModel = stakeholdersModelFromMap(jsonString);

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
  final int? perAddress;
  final String? perPhone;
  final int? usrId;
  final String? usrName;
  final dynamic usrPass;
  final int? usrOwner;
  final String? usrRole;
  final int? usrStatus;
  final int? usrBranch;
  final String? usrEmail;
  final String? usrToken;
  final int? usrFcp;
  final DateTime? usrEntryDate;
  final int? empId;
  final int? empPersonal;
  final int? empSalAccount;
  final String? empEmail;
  final DateTime? empHireDate;
  final String? empDepartment;
  final String? empPosition;
  final String? empSalCalcBase;
  final String? empPmntMethod;
  final String? empSalary;
  final dynamic empTaxInfo;
  final dynamic empFingerprint;
  final int? empStatus;
  final dynamic empEndDate;
  final int? actId;
  final int? actAccount;
  final String? actCurrency;
  final dynamic accCreditLimit;
  final int? actSignatory;
  final int? actCompany;
  final int? actStatus;

  StakeholdersModel({
    this.perId,
    this.perName,
    this.perLastName,
    this.perGender,
    this.perDoB,
    this.perEnidNo,
    this.perAddress,
    this.perPhone,
    this.usrId,
    this.usrName,
    this.usrPass,
    this.usrOwner,
    this.usrRole,
    this.usrStatus,
    this.usrBranch,
    this.usrEmail,
    this.usrToken,
    this.usrFcp,
    this.usrEntryDate,
    this.empId,
    this.empPersonal,
    this.empSalAccount,
    this.empEmail,
    this.empHireDate,
    this.empDepartment,
    this.empPosition,
    this.empSalCalcBase,
    this.empPmntMethod,
    this.empSalary,
    this.empTaxInfo,
    this.empFingerprint,
    this.empStatus,
    this.empEndDate,
    this.actId,
    this.actAccount,
    this.actCurrency,
    this.accCreditLimit,
    this.actSignatory,
    this.actCompany,
    this.actStatus,
  });

  StakeholdersModel copyWith({
    int? perId,
    String? perName,
    String? perLastName,
    String? perGender,
    String? perDoB,
    String? perEnidNo,
    int? perAddress,
    String? perPhone,
    int? usrId,
    String? usrName,
    dynamic usrPass,
    int? usrOwner,
    String? usrRole,
    int? usrStatus,
    int? usrBranch,
    String? usrEmail,
    String? usrToken,
    int? usrFcp,
    DateTime? usrEntryDate,
    int? empId,
    int? empPersonal,
    int? empSalAccount,
    String? empEmail,
    DateTime? empHireDate,
    String? empDepartment,
    String? empPosition,
    String? empSalCalcBase,
    String? empPmntMethod,
    String? empSalary,
    dynamic empTaxInfo,
    dynamic empFingerprint,
    int? empStatus,
    dynamic empEndDate,
    int? actId,
    int? actAccount,
    String? actCurrency,
    dynamic accCreditLimit,
    int? actSignatory,
    int? actCompany,
    int? actStatus,
  }) =>
      StakeholdersModel(
        perId: perId ?? this.perId,
        perName: perName ?? this.perName,
        perLastName: perLastName ?? this.perLastName,
        perGender: perGender ?? this.perGender,
        perDoB: perDoB ?? this.perDoB,
        perEnidNo: perEnidNo ?? this.perEnidNo,
        perAddress: perAddress ?? this.perAddress,
        perPhone: perPhone ?? this.perPhone,
        usrId: usrId ?? this.usrId,
        usrName: usrName ?? this.usrName,
        usrPass: usrPass ?? this.usrPass,
        usrOwner: usrOwner ?? this.usrOwner,
        usrRole: usrRole ?? this.usrRole,
        usrStatus: usrStatus ?? this.usrStatus,
        usrBranch: usrBranch ?? this.usrBranch,
        usrEmail: usrEmail ?? this.usrEmail,
        usrToken: usrToken ?? this.usrToken,
        usrFcp: usrFcp ?? this.usrFcp,
        usrEntryDate: usrEntryDate ?? this.usrEntryDate,
        empId: empId ?? this.empId,
        empPersonal: empPersonal ?? this.empPersonal,
        empSalAccount: empSalAccount ?? this.empSalAccount,
        empEmail: empEmail ?? this.empEmail,
        empHireDate: empHireDate ?? this.empHireDate,
        empDepartment: empDepartment ?? this.empDepartment,
        empPosition: empPosition ?? this.empPosition,
        empSalCalcBase: empSalCalcBase ?? this.empSalCalcBase,
        empPmntMethod: empPmntMethod ?? this.empPmntMethod,
        empSalary: empSalary ?? this.empSalary,
        empTaxInfo: empTaxInfo ?? this.empTaxInfo,
        empFingerprint: empFingerprint ?? this.empFingerprint,
        empStatus: empStatus ?? this.empStatus,
        empEndDate: empEndDate ?? this.empEndDate,
        actId: actId ?? this.actId,
        actAccount: actAccount ?? this.actAccount,
        actCurrency: actCurrency ?? this.actCurrency,
        accCreditLimit: accCreditLimit ?? this.accCreditLimit,
        actSignatory: actSignatory ?? this.actSignatory,
        actCompany: actCompany ?? this.actCompany,
        actStatus: actStatus ?? this.actStatus,
      );

  factory StakeholdersModel.fromMap(Map<String, dynamic> json) => StakeholdersModel(
    perId: json["perID"],
    perName: json["perName"],
    perLastName: json["perLastName"],
    perGender: json["perGender"],
    perDoB: json["perDoB"],
    perEnidNo: json["perENIDNo"],
    perAddress: json["perAddress"],
    perPhone: json["perPhone"],
    usrId: json["usrID"],
    usrName: json["usrName"],
    usrPass: json["usrPass"],
    usrOwner: json["usrOwner"],
    usrRole: json["usrRole"],
    usrStatus: json["usrStatus"],
    usrBranch: json["usrBranch"],
    usrEmail: json["usrEmail"],
    usrToken: json["usrToken"],
    usrFcp: json["usrFCP"],
    usrEntryDate: json["usrEntryDate"] == null ? null : DateTime.parse(json["usrEntryDate"]),
    empId: json["empID"],
    empPersonal: json["empPersonal"],
    empSalAccount: json["empSalAccount"],
    empEmail: json["empEmail"],
    empHireDate: json["empHireDate"] == null ? null : DateTime.parse(json["empHireDate"]),
    empDepartment: json["empDepartment"],
    empPosition: json["empPosition"],
    empSalCalcBase: json["empSalCalcBase"],
    empPmntMethod: json["empPmntMethod"],
    empSalary: json["empSalary"],
    empTaxInfo: json["empTaxInfo"],
    empFingerprint: json["empFingerprint"],
    empStatus: json["empStatus"],
    empEndDate: json["empEndDate"],
    actId: json["actID"],
    actAccount: json["actAccount"],
    actCurrency: json["actCurrency"],
    accCreditLimit: json["accCreditLimit"],
    actSignatory: json["actSignatory"],
    actCompany: json["actCompany"],
    actStatus: json["actStatus"],
  );

  Map<String, dynamic> toMap() => {
    "perID": perId,
    "perName": perName,
    "perLastName": perLastName,
    "perGender": perGender,
    "perDoB": perDoB,
    "perENIDNo": perEnidNo,
    "perAddress": perAddress,
    "perPhone": perPhone,
    "usrID": usrId,
    "usrName": usrName,
    "usrPass": usrPass,
    "usrOwner": usrOwner,
    "usrRole": usrRole,
    "usrStatus": usrStatus,
    "usrBranch": usrBranch,
    "usrEmail": usrEmail,
    "usrToken": usrToken,
    "usrFCP": usrFcp,
    "usrEntryDate": usrEntryDate?.toIso8601String(),
    "empID": empId,
    "empPersonal": empPersonal,
    "empSalAccount": empSalAccount,
    "empEmail": empEmail,
    "empHireDate": "${empHireDate!.year.toString().padLeft(4, '0')}-${empHireDate!.month.toString().padLeft(2, '0')}-${empHireDate!.day.toString().padLeft(2, '0')}",
    "empDepartment": empDepartment,
    "empPosition": empPosition,
    "empSalCalcBase": empSalCalcBase,
    "empPmntMethod": empPmntMethod,
    "empSalary": empSalary,
    "empTaxInfo": empTaxInfo,
    "empFingerprint": empFingerprint,
    "empStatus": empStatus,
    "empEndDate": empEndDate,
    "actID": actId,
    "actAccount": actAccount,
    "actCurrency": actCurrency,
    "accCreditLimit": accCreditLimit,
    "actSignatory": actSignatory,
    "actCompany": actCompany,
    "actStatus": actStatus,
  };
}
