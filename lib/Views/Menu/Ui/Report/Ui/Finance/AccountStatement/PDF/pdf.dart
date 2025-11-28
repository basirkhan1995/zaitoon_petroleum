import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pw;
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import '../../../../../../../../Features/PrintSettings/print_services.dart';
import '../../../../../../../../Features/PrintSettings/report_model.dart';
import '../model/stmt_model.dart';
import 'package:printing/printing.dart';

class AccountStatementPrintSettings extends PrintServices {
  final pdf = pw.Document();

  Future<void> createDocument({
    required AccountStatementModel info,
    required List<AccountStatementModel> statement,
    required String language,
    required pw.PageOrientation orientation,
    required ReportModel company,
    required pw.PdfPageFormat pageFormat,
  }) async {
    try {
      final document = await generateStatement(
          report: company,
          stmtInfo: info,
          language: language,
          orientation: orientation,
          pageFormat: pageFormat
      );

      // Save the document
      await saveDocument(
        suggestedName: "${info.accName}_${info.accNumber}.pdf",
        pdf: document,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> printDocument({
    required AccountStatementModel info,
    required List<AccountStatementModel> statement,
    required String language,
    required pw.PageOrientation orientation,
    required ReportModel company,
    required Printer selectedPrinter,
    required pw.PdfPageFormat pageFormat,
  }) async {
    try {
      final document = await generateStatement(
        report: company,
        stmtInfo: info,
        language: language,
        orientation: orientation,
        pageFormat: pageFormat,
      );
      await Printing.directPrintPdf(
        printer: selectedPrinter,
        onLayout: (pw.PdfPageFormat format) async {
          return document.save();
        },
      );
    } catch (e) {
      throw e.toString();
    }
  }

  //Real Time document show
  Future<pw.Document> printPreview({
    required String language,
    required ReportModel company,
    required pw.PageOrientation orientation,
    required AccountStatementModel info,
    required pw.PdfPageFormat pageFormat,
  }) async {
    return generateStatement(
      report: company,
      language: language,
      orientation: orientation,
      stmtInfo: info,
      pageFormat: pageFormat,
    );
  }

  Future<pw.Document> generateStatement({
    required String language,
    required ReportModel report,
    required AccountStatementModel stmtInfo,
    required pw.PageOrientation orientation,
    required pw.PdfPageFormat pageFormat,
  }) async {
    final document = pw.Document();
    final prebuiltHeader = await header(report: report);

    // Load your image asset
    final ByteData imageData = await rootBundle.load(
      'assets/images/zaitoonLogo.png',
    );
    final Uint8List imageBytes = imageData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(imageBytes);

    document.addPage(
      pw.MultiPage(
        maxPages: 1000,
        margin: pw.EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        pageFormat: pageFormat,
        textDirection: documentLanguage(language: language),
        orientation: orientation,
        build: (context) => [
          horizontalDivider(),
          statementHeaderWidget(language: language, report: stmtInfo, statement: stmtInfo),
          pw.SizedBox(height: 5),
          items(items: stmtInfo, language: language),
        ],
        header: (context) => prebuiltHeader,
        footer: (context) => footer(
          report: report,
          context: context,
          language: language,
          logoImage: logoImage,
        ),
      ),
    );


    return document;
  }

  Future<pw.Widget> header({required ReportModel report}) async {
    final image = (report.comLogo != null && report.comLogo is Uint8List && report.comLogo!.isNotEmpty)
        ? pw.MemoryImage(report.comLogo!)
        : null;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Company info (left side)
            pw.Expanded(
              flex: 3,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  buildTextWidget(text: report.comName ?? "", fontSize: 25,tightBounds: true),
                  buildTextWidget(text: report.statementDate ?? "", fontSize: 10),
                ],
              ),
            ),
            // Logo (right side)
            if (image != null)
              pw.Container(
                width: 50,
                height: 50,
                child: pw.Image(image, fit: pw.BoxFit.contain),
              ),
          ],
        ),
      ],
    );
  }

  pw.Widget footer({
    required ReportModel report,
    required pw.Context context,
    required String language,
    required pw.MemoryImage logoImage,
  }) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            pw.Container(
              height: 23, // Adjust as needed
              child: pw.Image(logoImage),
            ),
            verticalDivider(height: 15, width: 0.6),
            buildTextWidget(
              text: getTranslation(locale: 'producedBy', language: language),
              fontWeight: pw.FontWeight.normal,
              fontSize: 9,
            ),
          ],
        ),
        horizontalDivider(),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            buildTextWidget(text: report.comAddress ?? "", fontSize: 9),
          ],
        ),
        pw.SizedBox(height: 3),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Row(
              children: [
                buildTextWidget(text: report.compPhone ?? "", fontSize: 9),
                verticalDivider(height: 10, width: 1),
                buildTextWidget(text: report.comEmail ?? "", fontSize: 9),
              ],
            ),
            pw.Row(
              children: [
                buildPage(context.pageNumber, context.pagesCount, language),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget totalSummary({
    required String language,
    required AccountStatementModel info,
  }) {
    double parseAmount(String amountStr) {
      try {
        return double.tryParse(amountStr.replaceAll(',', '')) ?? 0.0;
      } catch (e) {
        return 0.0;
      }
    }

    // Calculate totals
    double totalCredit = 0;
    double totalDebit = 0;
    String openingBalance = '0.0';
    String finalBalance = '0.0';


      // Get opening balance from first record
      openingBalance = info.records?.first.total?.toAmount() ?? '0.0';

      for (var item in info.records ?? []) {
        totalCredit += parseAmount(item.credit.toAmount());
        totalDebit += parseAmount(item.debit.toAmount());
        finalBalance = info.avilBalance??"";
      }


    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildTotalSummary(
                label: getTranslation(
                  locale: 'openingBalance',
                  language: language,
                ),
                value: openingBalance,
                ccySymbol: info.ccySymbol,
              ),
              horizontalDivider(width: 170),
              buildTotalSummary(
                label: getTranslation(locale: 'totalDebit', language: language),
                ccySymbol: info.ccySymbol,
                value: totalDebit.toExchangeRate(),
              ),
              horizontalDivider(width: 170),
              buildTotalSummary(
                label: getTranslation(
                  locale: 'totalCredit',
                  language: language,
                ),
                ccySymbol: info.ccySymbol,
                value: totalCredit.toExchangeRate(),
              ),
              horizontalDivider(width: 170),
              buildTotalSummary(
                label: getTranslation(
                  locale: 'closingBalance',
                  language: language,
                ),
                ccySymbol: info.ccySymbol,
                value: "${finalBalance}",
                isEmphasized: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget statementDescription({
    required String language,
    required AccountStatementModel statement,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildSummary(
                distance: 75,
                label: getTranslation(
                  locale: 'accountName',
                  language: language,
                ),
                value: statement.accName??"",
              ),
              horizontalDivider(width: 200),
              buildSummary(
                distance: 75,
                label: getTranslation(
                  locale: 'accountNumber',
                  language: language,
                ),
                value: statement.accNumber.toString(),
              ),
              horizontalDivider(width: 200),
              buildSummary(
                distance: 75,
                label: getTranslation(locale: 'currency', language: language),
                value: "${statement.actCurrency}",
              ),
              horizontalDivider(width: 200),
              buildSummary(
                distance: 75,
                label: getTranslation(
                  locale: 'statementPeriod',
                  language: language,
                ),
                value: " - ",
                isEmphasized: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  statementHeaderWidget({
    required String language,
    required AccountStatementModel statement,
    required AccountStatementModel report,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          statementDescription(language: language, statement: report),
          totalSummary(language: language, info: statement),
        ],
      ),
    );
  }

  pw.Widget items({
    required AccountStatementModel items,
    required String language,
  }) {
    const dealWidth = 40.0;
    const dateWidth = 55.0;
    const trnWidth = 65.0;
    const amountWidth = 45.0;
    const balanceWidth = 55.0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(width: 1.5, color: hexToPdfColor('')),
            ),
          ),
          child: pw.Row(
            children: [
              pw.SizedBox(
                width: dateWidth,
                child: buildTextWidget(
                  text: getTranslation(locale: "date", language: language),
                  textAlign:
                  language == "en" ? pw.TextAlign.left : pw.TextAlign.right,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                width: trnWidth,
                child: buildTextWidget(
                  textAlign: language == "en" ? pw.TextAlign.left : pw.TextAlign.right,
                  text: getTranslation(locale: "reference", language: language),
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Expanded(child: pw.SizedBox(
                child: buildTextWidget(
                  textAlign:
                  language == "en" ? pw.TextAlign.left : pw.TextAlign.right,
                  text: getTranslation(locale: "narration", language: language),
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),),
              pw.SizedBox(
                width: dealWidth,
                child: buildTextWidget(
                  textAlign: language == "en" ? pw.TextAlign.left : pw.TextAlign.right,
                  text: getTranslation(locale: "deal", language: language),
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                width: amountWidth,
                child: buildTextWidget(
                  textAlign: language == "en" ? pw.TextAlign.left : pw.TextAlign.right,
                  text: getTranslation(locale: "debit", language: language),
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                width: amountWidth,
                child: buildTextWidget(
                  textAlign: language == "en" ? pw.TextAlign.left : pw.TextAlign.right,
                  text: getTranslation(locale: "credit", language: language),
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                width: balanceWidth,
                child: buildTextWidget(
                  text:
                  getTranslation(locale: "balance", language: language),
                  fontSize: 9,
                  textAlign: language == "en" ? pw.TextAlign.left : pw.TextAlign.right,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Data Rows
        for (var i = 0; i < (items.records!.length); i++)
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            decoration: pw.BoxDecoration(
              color: i.isOdd ? pw.PdfColors.grey100 : null,
              border: pw.Border(
                // bottom: pw.BorderSide(width: 0.25, color: pw.PdfColors.grey300),
              ),
            ),
            child: pw.Row(
              children: [
                pw.SizedBox(
                  width: dateWidth,
                  child: buildTextWidget(
                    textAlign: language == "en"
                        ? pw.TextAlign.left
                        : pw.TextAlign.right,
                    text: items.records![i].trnEntryDate!.toFormattedDate(),
                    fontSize: language == "en"? 8 : 9,
                  ),
                ),
                pw.SizedBox(
                  width: trnWidth,
                  child: buildTextWidget(
                    textAlign:
                    language == "en"
                        ? pw.TextAlign.left
                        : pw.TextAlign.right,
                    text: items.records![i].trnReference ?? "",
                    fontSize: 8,
                  ),
                ),
                pw.Expanded(
                  child:   pw.SizedBox(
                    child: buildTextWidget(
                      textAlign:
                      language == "en"
                          ? pw.TextAlign.left
                          : pw.TextAlign.right,
                      text:
                      items.records![i].trdNarration == "Opening Balance"
                          ? getTranslation(
                        locale: 'openingBalance',
                        language: language,
                      ) : items.records![i].trdNarration ?? "",
                      fontSize: 7,
                    ),
                  ),
                ),

                pw.SizedBox(
                  width: amountWidth,
                  child: buildTextWidget(
                    textAlign: language == "en" ? pw.TextAlign.left : pw.TextAlign.right,
                    text: items.records![i].debit?.toAmount()??"",
                    fontSize: 8,
                  ),
                ),
                pw.SizedBox(
                  width: amountWidth,
                  child: buildTextWidget(
                    textAlign: language == "en" ? pw.TextAlign.left : pw.TextAlign.right,
                    text: items.records![i].credit?.toAmount() ??"",
                    fontSize: 8,
                  ),
                ),
                pw.SizedBox(
                  width: balanceWidth,
                  child: buildTextWidget(
                    textAlign: language == "en" ? pw.TextAlign.left : pw.TextAlign.right,
                    fontWeight: pw.FontWeight.bold,
                    text: items.records![i].total?.toAmount() ??"",
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
