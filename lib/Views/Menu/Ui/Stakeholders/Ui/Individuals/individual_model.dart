// To parse this JSON data, do
//
//     final individualsModel = individualsModelFromMap(jsonString);

import 'dart:convert';

List<IndividualsModel> individualsModelFromMap(String str) => List<IndividualsModel>.from(json.decode(str).map((x) => IndividualsModel.fromMap(x)));

String individualsModelToMap(List<IndividualsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class IndividualsModel {
  final int? perId;
  final String? perName;
  final String? perLastName;
  final String? perGender;
  final DateTime? perDoB;
  final String? perEnidNo;
  final int? perAddress;
  final String? perPhone;
  final int? addId;
  final String? addName;
  final String? addCity;
  final String? addProvince;
  final String? addCountry;
  final String? perEmail;
  final String? addZipCode;
  final String? imageProfile;
  final int? addMailing;

  IndividualsModel({
    this.perId,
    this.perName,
    this.perLastName,
    this.perGender,
    this.perDoB,
    this.perEnidNo,
    this.perAddress,
    this.perEmail,
    this.perPhone,
    this.imageProfile,
    this.addId,
    this.addName,
    this.addCity,
    this.addProvince,
    this.addCountry,
    this.addZipCode,
    this.addMailing,
  });

  IndividualsModel copyWith({
    int? perId,
    String? perName,
    String? perLastName,
    String? perGender,
    DateTime? perDoB,
    String? perEnidNo,
    int? perAddress,
    String? perPhone,
    int? addId,
    String? addName,
    String? addCity,
    String? addProvince,
    String? addCountry,
    String? addZipCode,
    int? addMailing,
  }) =>
      IndividualsModel(
        perId: perId ?? this.perId,
        perName: perName ?? this.perName,
        perLastName: perLastName ?? this.perLastName,
        perGender: perGender ?? this.perGender,
        perDoB: perDoB ?? this.perDoB,
        perEnidNo: perEnidNo ?? this.perEnidNo,
        perAddress: perAddress ?? this.perAddress,
        perPhone: perPhone ?? this.perPhone,
        addId: addId ?? this.addId,
        addName: addName ?? this.addName,
        addCity: addCity ?? this.addCity,
        addProvince: addProvince ?? this.addProvince,
        addCountry: addCountry ?? this.addCountry,
        addZipCode: addZipCode ?? this.addZipCode,
        addMailing: addMailing ?? this.addMailing,
      );

  factory IndividualsModel.fromMap(Map<String, dynamic> json) => IndividualsModel(
    perId: json["perID"],
    perName: json["perName"],
    perLastName: json["perLastName"],
    perGender: json["perGender"],
    perDoB: json["perDoB"] == null ? null : DateTime.parse(json["perDoB"]),
    perEnidNo: json["perENIDNo"],
    perAddress: json["perAddress"],
    perPhone: json["perPhone"],
    addId: json["addID"],
    addName: json["addName"],
    addCity: json["addCity"],
    addProvince: json["addProvince"],
    addCountry: json["addCountry"],
    addZipCode: json["addZipCode"],
    addMailing: json["addMailing"],
    imageProfile: json["perPhoto"],
    perEmail: json["email"]
  );

  Map<String, dynamic> toMap() => {
    "per_ID": perId,
    "first_name": perName,
    "last_name": perLastName,
    "per_DoB": "${perDoB!.year.toString().padLeft(4, '0')}-${perDoB!.month.toString().padLeft(2, '0')}-${perDoB!.day.toString().padLeft(2, '0')}",
    "per_gender": perGender,
    "per_nidno": perEnidNo,
    "cell_number": perPhone,
    "add_ID": addId,
    "add_name": addName,
    "add_city": addCity,
    "add_province": addProvince,
    "add_country": addCountry,
    "zip_code": addZipCode,
    "email":perEmail,
    "is_mailing": addMailing,
  };
}
