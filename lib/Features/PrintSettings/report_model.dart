
import 'dart:typed_data';

class ReportModel {
  String? comName;
  String? compPhone;
  String? comEmail;
  Uint8List? comLogo;
  String? comAddress;
  String? statementDate;
  String? startDate;
  String? endDate;
  String? statementPeriod;

  ReportModel({
    this.comName,
    this.compPhone,
    this.comEmail,
    this.comLogo,
    this.comAddress,
    this.statementDate,
    this.startDate,
    this.statementPeriod,
    this.endDate,
  });

  ReportModel copyWith({
    String? comName,
    String? compPhone,
    String? comEmail,
    Uint8List? comLogo,
    String? comAddress,
    String? statementDate,
    String? startDate,
    String? statementPeriod,
    String? endDate,
  }) =>
      ReportModel(
        comName: comName ?? this.comName,
        compPhone: compPhone ?? this.compPhone,
        comEmail: comEmail ?? this.comEmail,
        comLogo: comLogo ?? this.comLogo,
        comAddress: comAddress ?? this.comAddress,
        statementDate: statementDate ?? this.statementDate,
        startDate: startDate ?? this.startDate,
        statementPeriod: statementPeriod ?? this.statementPeriod,
        endDate: endDate ?? this.endDate,
      );
}
