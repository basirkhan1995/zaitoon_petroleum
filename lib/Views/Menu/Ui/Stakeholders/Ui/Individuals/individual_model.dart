
import 'dart:convert';

List<IndividualsModel> stakeholdersModelFromMap(String str) => List<IndividualsModel>.from(json.decode(str).map((x) => IndividualsModel.fromMap(x)));

String stakeholdersModelToMap(List<IndividualsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class IndividualsModel {
  final int? perId;
  final String? perName;
  final String? perLastName;
  final String? perGender;
  final String? perDoB;
  final String? perEnidNo;
  final String? perPhone;
  final String? city;
  final String? province;
  final String? country;
  final String? address;
  final int? isMailing;
  final int? zipCode;

  IndividualsModel({
    this.perId,
    this.perName,
    this.perLastName,
    this.perGender,
    this.perDoB,
    this.perEnidNo,
    this.perPhone,
    this.country,
    this.province,
    this.city,
    this.address,
    this.isMailing,
    this.zipCode,
  });

  IndividualsModel copyWith({
    int? perId,
    String? perName,
    String? perLastName,
    String? perGender,
    String? perDoB,
    String? perEnidNo,
    String? perPhone,
    String? city,
    String? province,
    String? country,
    String? address,
    int? zipCode,
    int? isMailing
  }) =>
      IndividualsModel(
          perId: perId ?? this.perId,
          perName: perName ?? this.perName,
          perLastName: perLastName ?? this.perLastName,
          perGender: perGender ?? this.perGender,
          perDoB: perDoB ?? this.perDoB,
          perEnidNo: perEnidNo ?? this.perEnidNo,
          perPhone: perPhone ?? this.perPhone,
          address: address ?? this.address,
          city: city?? this.city,
          country: country ?? this.country,
          province: province ?? this.province,
          zipCode: zipCode ?? this.zipCode,
          isMailing: isMailing ?? this.isMailing
      );

  factory IndividualsModel.fromMap(Map<String, dynamic> json) => IndividualsModel(
      perId: json["perID"],
      perName: json["perName"],
      perLastName: json["perLastName"],
      perGender: json["perGender"],
      perDoB: json["perDoB"],
      perEnidNo: json["perENIDNo"],
      perPhone: json["perPhone"],
      address: json["add_name"]
  );

  Map<String, dynamic> toMap() => {
    "perID": perId,
    "first_name": perName,
    "last_name": perLastName,
    "per_DoB": "1998-08-21",
    "per_gender": "Male",
    "per_nidno": perEnidNo,
    "cell_number": perPhone,
    "add_name": address,
    "add_city": city,
    "add_province": province,
    "add_country": country,
    "zip_code": zipCode,
    "is_mailing": 1
  };
}
