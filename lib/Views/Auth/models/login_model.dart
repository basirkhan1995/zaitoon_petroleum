import 'dart:convert';

LoginData loginDataFromMap(String str) => LoginData.fromMap(json.decode(str));

String loginDataToMap(LoginData data) => json.encode(data.toMap());

class LoginData {
  final String? usrName;
  final String? usrFullName;
  final String? usrRole;
  final String? usrEmail;
  final String? perPhone;
  final DateTime? usrEntryDate;
  final int? usrBranch;
  final String? brcName;
  final List<UsrPermissions>? permissions;

  LoginData({
    this.usrName,
    this.usrFullName,
    this.usrRole,
    this.usrEmail,
    this.perPhone,
    this.usrEntryDate,
    this.usrBranch,
    this.brcName,
    this.permissions,
  });

  LoginData copyWith({
    String? usrName,
    String? usrFullName,
    String? usrRole,
    String? usrEmail,
    String? perPhone,
    DateTime? usrEntryDate,
    int? usrBranch,
    String? brcName,
    List<UsrPermissions>? permissions,
  }) =>
      LoginData(
        usrName: usrName ?? this.usrName,
        usrFullName: usrFullName ?? this.usrFullName,
        usrRole: usrRole ?? this.usrRole,
        usrEmail: usrEmail ?? this.usrEmail,
        perPhone: perPhone ?? this.perPhone,
        usrEntryDate: usrEntryDate ?? this.usrEntryDate,
        usrBranch: usrBranch ?? this.usrBranch,
        brcName: brcName ?? this.brcName,
        permissions: permissions ?? this.permissions,
      );

  factory LoginData.fromMap(Map<String, dynamic> json) => LoginData(
    usrName: json["usrName"],
    usrFullName: json["usrFullName"],
    usrRole: json["usrRole"],
    usrEmail: json["usrEmail"],
    perPhone: json["perPhone"],
    usrEntryDate: json["usrEntryDate"] == null ? null : DateTime.parse(json["usrEntryDate"]),
    usrBranch: json["usrBranch"],
    brcName: json["brcName"],
    permissions: json["permissions"] == null ? [] : List<UsrPermissions>.from(json["permissions"]!.map((x) => UsrPermissions.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "usrName": usrName,
    "usrFullName": usrFullName,
    "usrRole": usrRole,
    "usrEmail": usrEmail,
    "perPhone": perPhone,
    "usrEntryDate": usrEntryDate?.toIso8601String(),
    "usrBranch": usrBranch,
    "brcName": brcName,
    "permissions": permissions == null ? [] : List<dynamic>.from(permissions!.map((x) => x.toMap())),
  };
}

class UsrPermissions {
  final int? uprRole;
  final int? uprStatus;
  final String? rsgName;

  UsrPermissions({
    this.uprRole,
    this.uprStatus,
    this.rsgName,
  });

  UsrPermissions copyWith({
    int? uprRole,
    int? uprStatus,
    String? rsgName,
  }) =>
      UsrPermissions(
        uprRole: uprRole ?? this.uprRole,
        uprStatus: uprStatus ?? this.uprStatus,
        rsgName: rsgName ?? this.rsgName,
      );

  factory UsrPermissions.fromMap(Map<String, dynamic> json) => UsrPermissions(
    uprRole: json["uprRole"],
    uprStatus: json["uprStatus"],
    rsgName: json["rsgName"],
  );

  Map<String, dynamic> toMap() => {
    "uprRole": uprRole,
    "uprStatus": uprStatus,
    "rsgName": rsgName,
  };
}

extension LoginPermissionExt on LoginData {
  bool? hasPermission(int uprRole) {
    return permissions?.any((p) => p.uprRole == uprRole && p.uprStatus == 1);
  }
}
