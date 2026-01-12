
import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/ArApReport/model/ar_ap_model.dart';
import '../../../../../../../../Features/PrintSettings/print_services.dart';
import '../../../../../../../../Features/PrintSettings/report_model.dart';

class PayablesPdfPrinter extends PrintServices {
  Future<void> createDocument({
    required List<ArApModel> payables,
    required String language,
    required pw.PageOrientation orientation,
    required ReportModel company,
    required pw.PdfPageFormat pageFormat,
  }) async {
    try {
      final document = await generatePayablesReport(
        payables: payables,
        company: company,
        language: language,
        orientation: orientation,
        pageFormat: pageFormat,
      );

      // Save the document
      await saveDocument(
        suggestedName: "creditors_${DateTime.now().toDateTime}.pdf",
        pdf: document,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> printDocument({
    required List<ArApModel> payables,
    required String language,
    required pw.PageOrientation orientation,
    required ReportModel company,
    required Printer selectedPrinter,
    required pw.PdfPageFormat pageFormat,
  }) async {
    try {
      final document = await generatePayablesReport(
        payables: payables,
        company: company,
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

  Future<pw.Document> printPreview({
    required String language,
    required ReportModel company,
    required pw.PageOrientation orientation,
    required List<ArApModel> payables,
    required pw.PdfPageFormat pageFormat,
  }) async {
    return generatePayablesReport(
      payables: payables,
      company: company,
      language: language,
      orientation: orientation,
      pageFormat: pageFormat,
    );
  }

  Future<pw.Document> generatePayablesReport({
    required String language,
    required ReportModel company,
    required List<ArApModel> payables,
    required pw.PageOrientation orientation,
    required pw.PdfPageFormat pageFormat,
  }) async {
    final document = pw.Document();
    final prebuiltHeader = await header(report: company);

    // Load your logo
    final ByteData imageData = await rootBundle.load(
      'assets/images/zaitoonLogo.png', // Update with your actual logo path
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
          pw.SizedBox(height: 5),
          horizontalDivider(),
          pw.SizedBox(height: 5),
          pw.Align(
            alignment: language == "en"
                ? pw.Alignment.centerLeft
                : pw.Alignment.centerRight,
            child: buildTextWidget(
              text: "Creditors Report",
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          creditorsTable(payables: payables, language: language),
          pw.SizedBox(height: 20),
          summarySection(payables: payables, language: language),
        ],
        header: (context) => prebuiltHeader,
        footer: (context) => footer(
          report: company,
          context: context,
          language: language,
          logoImage: logoImage,
        ),
      ),
    );
    return document;
  }

  @override
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
                  buildTextWidget(text: report.comName ?? "", fontSize: 20),
                  buildTextWidget(text: DateTime.now().toDateTime, fontSize: 10, tightBounds: true),
                ],
              ),
            ),
            // Logo (right side)
            if (image != null)
              pw.Container(
                width: 60,
                height: 45,
                child: pw.Image(image, fit: pw.BoxFit.contain),
              ),
          ],
        ),
      ],
    );
  }

  @override
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
              height: 23,
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

  pw.Widget creditorsTable({
    required List<ArApModel> payables,
    required String language,
  }) {
    const accountWidth = 120.0;
    const accountNameWidth = 180.0;
    const limitWidth = 100.0;
    const signatoryWidth = 120.0;
    const balanceWidth = 100.0;
    const statusWidth = 60.0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Table Header
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(width: 1.5, color: hexToPdfColor('3B82F6')),
            ),
          ),
          child: pw.Row(
            children: [
              pw.SizedBox(
                width: accountWidth,
                child: buildTextWidget(
                  text: getTranslation(locale: "accountNumber", language: language),
                  textAlign: language == "en" ? pw.TextAlign.left : pw.TextAlign.right,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                width: accountNameWidth,
                child: buildTextWidget(
                  text: getTranslation(locale: "accountName", language: language),
                  textAlign: language == "en" ? pw.TextAlign.left : pw.TextAlign.right,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                width: statusWidth,
                child: buildTextWidget(
                  text: getTranslation(locale: "status", language: language),
                  textAlign: pw.TextAlign.center,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                width: limitWidth,
                child: buildTextWidget(
                  text: getTranslation(locale: "accountLimit", language: language),
                  textAlign: language == "en" ? pw.TextAlign.right : pw.TextAlign.left,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                width: signatoryWidth,
                child: buildTextWidget(
                  text: getTranslation(locale: "signatory", language: language),
                  textAlign: language == "en" ? pw.TextAlign.left : pw.TextAlign.right,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                width: balanceWidth,
                child: buildTextWidget(
                  text: getTranslation(locale: "balance", language: language),
                  textAlign: language == "en" ? pw.TextAlign.right : pw.TextAlign.left,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Data Rows
        for (var i = 0; i < payables.length; i++)
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            decoration: pw.BoxDecoration(
              color: i.isOdd ? pw.PdfColors.grey100 : null,
              border: pw.Border(
                bottom: pw.BorderSide(width: 0.5, color: hexToPdfColor('E5E7EB')),
              ),
            ),
            child: pw.Row(
              children: [
                pw.SizedBox(
                  width: accountWidth,
                  child: buildTextWidget(
                    text: payables[i].accNumber?.toString() ?? "",
                    textAlign: language == "en" ? pw.TextAlign.left : pw.TextAlign.right,
                    fontSize: 9,
                  ),
                ),
                pw.SizedBox(
                  width: accountNameWidth,
                  child: buildTextWidget(
                    text: payables[i].accName ?? "",
                    textAlign: language == "en" ? pw.TextAlign.left : pw.TextAlign.right,
                    fontSize: 9,
                  ),
                ),
                pw.SizedBox(
                  width: statusWidth,
                  child: buildTextWidget(
                    text: payables[i].accStatus == 1 ? "Active" : "Blocked",
                    textAlign: pw.TextAlign.center,
                    fontSize: 8,
                    color: payables[i].accStatus == 1
                        ? pw.PdfColors.green
                        : pw.PdfColors.red,
                  ),
                ),
                pw.SizedBox(
                  width: limitWidth,
                  child: pw.Column(
                    crossAxisAlignment: language == "en"
                        ? pw.CrossAxisAlignment.end
                        : pw.CrossAxisAlignment.start,
                    children: [
                      buildTextWidget(
                        text: payables[i].accLimit?.toAmount() ?? "0.00",
                        textAlign: language == "en" ? pw.TextAlign.right : pw.TextAlign.left,
                        fontSize: 9,
                      ),
                      buildTextWidget(
                        text: payables[i].accCurrency ?? "",
                        textAlign: language == "en" ? pw.TextAlign.right : pw.TextAlign.left,
                        fontSize: 7,
                        color: pw.PdfColors.grey600,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(
                  width: signatoryWidth,
                  child: buildTextWidget(
                    text: payables[i].fullName ?? "",
                    textAlign: language == "en" ? pw.TextAlign.left : pw.TextAlign.right,
                    fontSize: 9,
                  ),
                ),
                pw.SizedBox(
                  width: balanceWidth,
                  child: buildTextWidget(
                    text: "${payables[i].accBalance?.toAmount() ?? "0.00"} ${payables[i].accCurrency ?? ""}",
                    textAlign: language == "en" ? pw.TextAlign.right : pw.TextAlign.left,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: (payables[i].accBalance ?? 0) > 0
                        ? pw.PdfColors.red
                        : pw.PdfColors.green,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  pw.Widget summarySection({
    required List<ArApModel> payables,
    required String language,
  }) {
    final totalBalance = payables.fold<double>(
        0,
            (sum, item) => sum + (item.accBalance ?? 0)
    );
    final totalAccounts = payables.length;
    final activeAccounts = payables.where((item) => item.accStatus == 1).length;
    final blockedAccounts = totalAccounts - activeAccounts;

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: pw.PdfColors.blue50,
        border: pw.Border.all(color: hexToPdfColor('3B82F6'), width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildTextWidget(
                text: "Total Accounts: $totalAccounts",
                fontSize: 10,
              ),
              buildTextWidget(
                text: "Active: $activeAccounts",
                fontSize: 10,
                color: pw.PdfColors.green,
              ),
              buildTextWidget(
                text: "Blocked: $blockedAccounts",
                fontSize: 10,
                color: pw.PdfColors.red,
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: language == "en"
                ? pw.CrossAxisAlignment.end
                : pw.CrossAxisAlignment.start,
            children: [
              buildTextWidget(
                text: "Total Balance:",
                fontSize: 10,
              ),
              buildTextWidget(
                text: totalBalance.toAmount(),
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: totalBalance > 0 ? pw.PdfColors.red : pw.PdfColors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

}