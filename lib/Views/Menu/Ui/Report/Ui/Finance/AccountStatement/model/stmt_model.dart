import 'dart:convert';

List<AccountStatementModel> accountStatementModelFromMap(String str) => List<AccountStatementModel>.from(json.decode(str).map((x) => AccountStatementModel.fromMap(x)));
String accountStatementModelToMap(List<AccountStatementModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class AccountStatementModel {
  final int? accNumber;
  final String? accName;
  final String? signatory;
  final String? perPhone;
  final String? perEmail;
  final String? address;
  final String? actCurrency;
  final String? ccySymbol;
  final String? actCreditLimit;
  final String? curBalance;
  final String? avilBalance;
  final int? actStatus;
  final List<Record>? records;

  AccountStatementModel({
    this.accNumber,
    this.accName,
    this.signatory,
    this.perPhone,
    this.perEmail,
    this.address,
    this.actCurrency,
    this.ccySymbol,
    this.actCreditLimit,
    this.curBalance,
    this.avilBalance,
    this.actStatus,
    this.records,
  });

  AccountStatementModel copyWith({
    int? accNumber,
    String? accName,
    String? signatory,
    String? perPhone,
    String? perEmail,
    String? address,
    String? actCurrency,
    String? ccySymbol,
    String? actCreditLimit,
    String? curBalance,
    String? avilBalance,
    int? actStatus,
    List<Record>? records,
  }) =>
      AccountStatementModel(
        accNumber: accNumber ?? this.accNumber,
        accName: accName ?? this.accName,
        signatory: signatory ?? this.signatory,
        perPhone: perPhone ?? this.perPhone,
        perEmail: perEmail ?? this.perEmail,
        address: address ?? this.address,
        actCurrency: actCurrency ?? this.actCurrency,
        ccySymbol: ccySymbol ?? this.ccySymbol,
        actCreditLimit: actCreditLimit ?? this.actCreditLimit,
        curBalance: curBalance ?? this.curBalance,
        avilBalance: avilBalance ?? this.avilBalance,
        actStatus: actStatus ?? this.actStatus,
        records: records ?? this.records,
      );

  factory AccountStatementModel.fromMap(Map<String, dynamic> json) => AccountStatementModel(
    accNumber: json["accNumber"],
    accName: json["accName"],
    signatory: json["signatory"],
    perPhone: json["perPhone"],
    perEmail: json["perEmail"],
    address: json["address"],
    actCurrency: json["actCurrency"],
    ccySymbol: json["ccySymbol"],
    actCreditLimit: json["actCreditLimit"],
    curBalance: json["curBalance"],
    avilBalance: json["avilBalance"],
    actStatus: json["actStatus"],
    records: json["records"] == null ? [] : List<Record>.from(json["records"]!.map((x) => Record.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "accNumber": accNumber,
    "accName": accName,
    "signatory": signatory,
    "perPhone": perPhone,
    "perEmail": perEmail,
    "address": address,
    "actCurrency": actCurrency,
    "ccySymbol": ccySymbol,
    "actCreditLimit": actCreditLimit,
    "curBalance": curBalance,
    "avilBalance": avilBalance,
    "actStatus": actStatus,
    "records": records == null ? [] : List<dynamic>.from(records!.map((x) => x.toMap())),
  };
}

class Record {
  final int? sortOrder;
  final String? trnEntryDate;
  final String? trnReference;
  final String? trdNarration;
  final String? debit;
  final String? credit;
  final String? total;
  final Status? status;

  Record({
    this.sortOrder,
    this.trnEntryDate,
    this.trnReference,
    this.trdNarration,
    this.debit,
    this.credit,
    this.total,
    this.status,
  });

  Record copyWith({
    int? sortOrder,
    String? trnEntryDate,
    String? trnReference,
    String? trdNarration,
    String? debit,
    String? credit,
    String? total,
    Status? status,
  }) =>
      Record(
        sortOrder: sortOrder ?? this.sortOrder,
        trnEntryDate: trnEntryDate ?? this.trnEntryDate,
        trnReference: trnReference ?? this.trnReference,
        trdNarration: trdNarration ?? this.trdNarration,
        debit: debit ?? this.debit,
        credit: credit ?? this.credit,
        total: total ?? this.total,
        status: status ?? this.status,
      );

  factory Record.fromMap(Map<String, dynamic> json) => Record(
    sortOrder: json["sort_order"],
    trnEntryDate: json["trnEntryDate"],
    trnReference: json["trnReference"],
    trdNarration: json["trdNarration"],
    debit: json["debit"],
    credit: json["credit"],
    total: json["total"],
    status: statusValues.map[json["status"]]!,
  );

  Map<String, dynamic> toMap() => {
    "sort_order": sortOrder,
    "trnEntryDate": trnEntryDate,
    "trnReference": trnReference,
    "trdNarration": trdNarration,
    "debit": debit,
    "credit": credit,
    "total": total,
    "status": statusValues.reverse[status],
  };
}

enum Status {
  authorized,
  unAuthorized
}

final statusValues = EnumValues({
  "": Status.authorized,
  "*": Status.unAuthorized
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
