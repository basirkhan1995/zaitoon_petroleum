import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/PrintSettings/print_services.dart';
import 'package:zaitoon_petroleum/Features/PrintSettings/report_model.dart';
import '../model/ar_ap_model.dart';

class ArApPdfServices extends PrintServices {
  Future<pw.Document> generateArReport({
    required ReportModel report,
    required List<ArApModel> arAccounts,
    required String language,
    required pw.PageOrientation orientation,
    required pw.PdfPageFormat pageFormat,
  }) async {
    final document = pw.Document();
    final prebuiltHeader = await header(report: report);

    // Load logo image
    final ByteData imageData = await rootBundle.load('assets/images/zaitoonLogo.png');
    final Uint8List imageBytes = imageData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(imageBytes);

    // Calculate totals by currency for AR
    final arTotalsByCurrency = calculateTotalByCurrency(arAccounts, isAR: true);

    document.addPage(
      pw.MultiPage(
        maxPages: 1000,
        margin: const pw.EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        pageFormat: pageFormat,
        textDirection: documentLanguage(language: language),
        orientation: orientation,
        build: (context) => [
          pw.SizedBox(height: 5),
          horizontalDivider(),
          pw.SizedBox(height: 10),
          _buildReportTitle(
            language: language,
            reportType: getTranslation(locale: 'debtor', language: language),
          ),
          pw.SizedBox(height: 15),
          _buildSummarySection(
            accounts: arAccounts,
            totalsByCurrency: arTotalsByCurrency,
            language: language,
            isAR: true,
          ),
          pw.SizedBox(height: 15),
          _buildAccountsTable(
            accounts: arAccounts,
            language: language,
            isAR: true,
          ),
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

  Future<pw.Document> generateApReport({
    required ReportModel report,
    required List<ArApModel> apAccounts,
    required String language,
    required pw.PageOrientation orientation,
    required pw.PdfPageFormat pageFormat,
  }) async {
    final document = pw.Document();
    final prebuiltHeader = await header(report: report);

    // Load logo image
    final ByteData imageData = await rootBundle.load('assets/images/zaitoonLogo.png');
    final Uint8List imageBytes = imageData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(imageBytes);

    // Calculate totals by currency for AP
    final apTotalsByCurrency = calculateTotalByCurrency(apAccounts, isAR: false);

    document.addPage(
      pw.MultiPage(
        maxPages: 1000,
        margin: const pw.EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        pageFormat: pageFormat,
        textDirection: documentLanguage(language: language),
        orientation: orientation,
        build: (context) => [
          pw.SizedBox(height: 5),
          horizontalDivider(),
          pw.SizedBox(height: 10),
          _buildReportTitle(
            language: language,
            reportType: getTranslation(locale: 'creditor', language: language),
          ),
          pw.SizedBox(height: 15),
          _buildSummarySection(
            accounts: apAccounts,
            totalsByCurrency: apTotalsByCurrency,
            language: language,
            isAR: false,
          ),
          pw.SizedBox(height: 15),
          _buildAccountsTable(
            accounts: apAccounts,
            language: language,
            isAR: false,
          ),
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

  pw.Widget _buildReportTitle({
    required String language,
    required String reportType,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: pw.PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Icon(
            pw.IconData(0xf2b9), // Document icon
            size: 20,
            color: pw.PdfColors.blue700,
          ),
          pw.SizedBox(width: 10),
          buildTextWidget(
            text: '${getTranslation(locale: 'accountStatement', language: language)} - $reportType',
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: pw.PdfColors.blue700,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummarySection({
    required List<ArApModel> accounts,
    required Map<String, double> totalsByCurrency,
    required String language,
    required bool isAR,
  }) {
    final totalAccounts = accounts.length;
    final reportType = isAR
        ? getTranslation(locale: 'debtor', language: language)
        : getTranslation(locale: 'creditor', language: language);

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: pw.PdfColors.grey300, width: 0.7),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildTextWidget(
            text: '${getTranslation(locale: 'accountSummary', language: language)} ($reportType)',
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
          pw.SizedBox(height: 8),
          horizontalDivider(),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                label: getTranslation(locale: 'accounts', language: language),
                value: totalAccounts.toString(),
                language: language,
              ),
              _buildSummaryItem(
                label: getTranslation(locale: 'reportType', language: language),
                value: reportType,
                language: language,
              ),
              _buildSummaryItem(
                label: getTranslation(locale: 'date', language: language),
                value: DateTime.now().toIso8601String().substring(0, 10),
                language: language,
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          // Currency-wise totals
          pw.Wrap(
            spacing: 15,
            runSpacing: 10,
            children: totalsByCurrency.entries.map((entry) {
              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: pw.PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(4),
                  border: pw.Border.all(color: pw.PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    buildTextWidget(
                      text: entry.key,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    pw.SizedBox(width: 5),
                    buildTextWidget(
                      text: entry.value.abs().toStringAsFixed(2),
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: isAR ? pw.PdfColors.red700 : pw.PdfColors.green700,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildAccountsTable({
    required List<ArApModel> accounts,
    required String language,
    required bool isAR,
  }) {
    const accountNoWidth = 40.0;
    const accountNameWidth = 100.0;
    const signatoryWidth = 80.0;
    const phoneWidth = 60.0;
    const limitWidth = 60.0;
    const statusWidth = 50.0;
    const balanceWidth = 70.0;
    const currencyWidth = 40.0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Table Header
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          decoration: pw.BoxDecoration(
            color: pw.PdfColors.blue50,
            border: pw.Border(
              bottom: pw.BorderSide(width: 1, color: pw.PdfColors.blue300),
            ),
          ),
          child: pw.Row(
            children: [
              pw.SizedBox(
                width: accountNoWidth,
                child: buildTextWidget(
                  text: getTranslation(locale: 'accountNumber', language: language),
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(
                width: accountNameWidth,
                child: buildTextWidget(
                  text: getTranslation(locale: 'accountName', language: language),
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                width: signatoryWidth,
                child: buildTextWidget(
                  text: getTranslation(locale: 'signatory', language: language),
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                width: phoneWidth,
                child: buildTextWidget(
                  text: getTranslation(locale: 'mobile', language: language),
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                width: limitWidth,
                child: buildTextWidget(
                  text: getTranslation(locale: 'accountLimit', language: language),
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  textAlign: pw.TextAlign.right,
                ),
              ),
              pw.SizedBox(
                width: statusWidth,
                child: buildTextWidget(
                  text: getTranslation(locale: 'status', language: language),
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(
                width: balanceWidth,
                child: buildTextWidget(
                  text: getTranslation(locale: 'balance', language: language),
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  textAlign: pw.TextAlign.right,
                ),
              ),
              pw.SizedBox(
                width: currencyWidth,
                child: buildTextWidget(
                  text: getTranslation(locale: 'currency', language: language),
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        // Data Rows
        for (var i = 0; i < accounts.length; i++)
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            decoration: pw.BoxDecoration(
              color: i.isOdd ? pw.PdfColors.grey50 : null,
              border: pw.Border(
                bottom: pw.BorderSide(width: 0.25, color: pw.PdfColors.grey300),
              ),
            ),
            child: pw.Row(
              children: [
                // Account Number
                pw.SizedBox(
                  width: accountNoWidth,
                  child: buildTextWidget(
                    text: accounts[i].accNumber?.toString() ?? "-",
                    fontSize: 8,
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                // Account Name
                pw.SizedBox(
                  width: accountNameWidth,
                  child: buildTextWidget(
                    text: accounts[i].accName ?? "-",
                    fontSize: 8,
                  ),
                ),

                // Signatory
                pw.SizedBox(
                  width: signatoryWidth,
                  child: buildTextWidget(
                    text: accounts[i].fullName ?? "-",
                    fontSize: 8,
                  ),
                ),

                // Phone
                pw.SizedBox(
                  width: phoneWidth,
                  child: buildTextWidget(
                    text: accounts[i].perPhone ?? "-",
                    fontSize: 8,
                  ),
                ),

                // Account Limit
                pw.SizedBox(
                  width: limitWidth,
                  child: buildTextWidget(
                    text: accounts[i].accLimit == "Unlimited"
                        ? getTranslation(locale: 'unlimited', language: language)
                        : accounts[i].accLimit?.toAmount() ?? "0.00",
                    fontSize: 8,
                    textAlign: pw.TextAlign.right,
                  ),
                ),

                // Status
                pw.SizedBox(
                  width: statusWidth,
                  child: _buildStatusBadge(
                    status: accounts[i].accStatus ?? 0,
                    language: language,
                  ),
                ),

                // Balance (with color coding)
                pw.SizedBox(
                  width: balanceWidth,
                  child: buildTextWidget(
                    text: accounts[i].balance.abs().toStringAsFixed(2),
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: accounts[i].balance < 0 ? pw.PdfColors.red700 : pw.PdfColors.green700,
                    textAlign: pw.TextAlign.right,
                  ),
                ),

                // Currency
                pw.SizedBox(
                  width: currencyWidth,
                  child: buildTextWidget(
                    text: accounts[i].accCurrency ?? "-",
                    fontSize: 8,
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  pw.Widget _buildStatusBadge({
    required int status,
    required String language,
  }) {
    final isActive = status == 1;
    final statusText = isActive
        ? getTranslation(locale: 'active', language: language)
        : getTranslation(locale: 'blocked', language: language);

    final color = isActive ? pw.PdfColors.green700 : pw.PdfColors.red700;

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: pw.PdfColors.blue,
        borderRadius: pw.BorderRadius.circular(3),
        border: pw.Border.all(color: color, width: 0.5),
      ),
      child: buildTextWidget(
        text: statusText,
        fontSize: 7,
        color: color,
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildSummaryItem({
    required String label,
    required String value,
    required String language,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        buildTextWidget(
          text: label,
          fontSize: 9,
          color: pw.PdfColors.grey600,
        ),
        pw.SizedBox(height: 2),
        buildTextWidget(
          text: value,
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
      ],
    );
  }

  Map<String, double> calculateTotalByCurrency(List<ArApModel> accounts, {required bool isAR}) {
    final Map<String, double> totals = {};

    for (var account in accounts) {
      // Filter based on AR/AP
      if ((isAR && account.isAR) || (!isAR && account.isAP)) {
        final currency = account.accCurrency ?? 'N/A';
        final currentTotal = totals[currency] ?? 0.0;
        totals[currency] = currentTotal + account.absBalance;
      }
    }

    return totals;
  }

  // Create document for saving
  Future<void> createDocument({
    required ReportModel company,
    required List<ArApModel> accounts,
    required String language,
    required pw.PageOrientation orientation,
    required pw.PdfPageFormat pageFormat,
    required bool isAR, // true for AR, false for AP
  }) async {
    try {
      final document = isAR
          ? await generateArReport(
        report: company,
        arAccounts: accounts.where((e) => e.isAR).toList(),
        language: language,
        orientation: orientation,
        pageFormat: pageFormat,
      )
          : await generateApReport(
        report: company,
        apAccounts: accounts.where((e) => e.isAP).toList(),
        language: language,
        orientation: orientation,
        pageFormat: pageFormat,
      );

      await saveDocument(
        suggestedName: "${isAR ? 'AR' : 'AP'}_Report_${DateTime.now().toIso8601String()}.pdf",
        pdf: document,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  // Print document
  Future<void> printDocument({
    required ReportModel company,
    required List<ArApModel> accounts,
    required String language,
    required pw.PageOrientation orientation,
    required pw.PdfPageFormat pageFormat,
    required Printer selectedPrinter,
    required int copies,
    required String pages,
    required bool isAR,
  }) async {
    try {
      final document = isAR
          ? await generateArReport(
        report: company,
        arAccounts: accounts.where((e) => e.isAR).toList(),
        language: language,
        orientation: orientation,
        pageFormat: pageFormat,
      )
          : await generateApReport(
        report: company,
        apAccounts: accounts.where((e) => e.isAP).toList(),
        language: language,
        orientation: orientation,
        pageFormat: pageFormat,
      );

      for (int i = 0; i < copies; i++) {
        await Printing.directPrintPdf(
          printer: selectedPrinter,
          onLayout: (pw.PdfPageFormat format) async {
            return document.save();
          },
        );

        if (i < copies - 1) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    } catch (e) {
      throw e.toString();
    }
  }
}