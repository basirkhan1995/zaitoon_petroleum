import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/PrintSettings/print_services.dart';
import '../../../../../../../Features/PrintSettings/report_model.dart';
import '../model/get_order_model.dart';

class OrderTxnPrintSettings extends PrintServices {

  Future<pw.Document> generateStatement({
    required String language,
    required ReportModel report,
    required OrderTxnModel data,
    required pw.PageOrientation orientation,
    required pw.PdfPageFormat pageFormat,
  }) async {
    final document = pw.Document();
    final prebuiltHeader = await header(report: report);

    final ByteData imageData = await rootBundle.load('assets/images/zaitoonLogo.png');
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
          pw.SizedBox(height: 5),
          buildResponseData(data: data, language: language),
          signatory(language: language, data: data)
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

  // Real Time document show
  Future<pw.Document> printPreview({
    required String language,
    required ReportModel company,
    required pw.PageOrientation orientation,
    required OrderTxnModel data,
    required pw.PdfPageFormat pageFormat,
  }) async {
    return generateStatement(
      report: company,
      language: language,
      orientation: orientation,
      data: data,
      pageFormat: pageFormat,
    );
  }

  // To Print
  Future<void> printDocument({
    required OrderTxnModel data,
    required String language,
    required pw.PageOrientation orientation,
    required ReportModel company,
    required Printer selectedPrinter,
    required pw.PdfPageFormat pageFormat,
    required int copies,
    required String pages,
  }) async {
    try {
      final document = await generateStatement(
        report: company,
        data: data,
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
          await Future.delayed(Duration(milliseconds: 100));
        }
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> createDocument({
    required OrderTxnModel data,
    required String language,
    required pw.PageOrientation orientation,
    required ReportModel company,
    required pw.PdfPageFormat pageFormat,
  }) async {
    try {
      final document = await generateStatement(
        report: company,
        data: data,
        language: language,
        orientation: orientation,
        pageFormat: pageFormat,
      );

      // Save the document
      await saveDocument(
        suggestedName: "Order_Transaction_${data.trnReference ?? 'Unknown'}.pdf",
        pdf: document,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  // Signature
  signatory({required language, required OrderTxnModel data}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              horizontalDivider(width: 120),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  buildTextWidget(
                    text: getTranslation(locale: 'createdBy', language: language),
                    fontSize: 7,
                  ),
                  buildTextWidget(
                    text: " ${data.maker ?? 'N/A'} ",
                    fontSize: 7,
                  ),
                ],
              ),
            ],
          ),
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              horizontalDivider(width: 120),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  buildTextWidget(
                    text: getTranslation(locale: 'authorizedBy', language: language),
                    fontSize: 7,
                  ),
                  // buildTextWidget(
                  //   text: data.checker ?? getTranslation(locale: 'pendingTitle', language: language),
                  //   fontSize: 7,
                  // ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget buildResponseData({required OrderTxnModel data, required String language}) {
    final billItems = data.bill ?? [];
    final records = data.records ?? [];

    // Calculate total
    double total = 0;
    for (final item in billItems) {
      final parsed = double.tryParse(item.totalPrice ?? '');
      total += parsed ?? 0;
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Padding(
        padding: pw.EdgeInsets.all(15),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    buildTextWidget(
                      text: data.trnReference ?? 'N/A',
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: pw.PdfColors.blue800,
                    ),
                    pw.SizedBox(height: 5),
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: pw.PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                      child: buildTextWidget(
                        text: data.trntName ?? data.trnType ?? 'N/A',
                        fontSize: 10,
                        color: pw.PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      children: [
                        buildTextWidget(
                          text: "${getTranslation(locale: 'branch', language: language)}: ",
                          fontSize: 9,
                        ),
                        buildTextWidget(
                          text: data.branch ?? 'N/A',
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(data.trnStatus ?? 0, language),
                    pw.SizedBox(height: 5),
                    buildTextWidget(
                      text: data.trnEntryDate?.toDateTime ?? 'N/A',
                      fontSize: 9,
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 15),

            // Total Amount Card
            pw.Container(
              decoration: pw.BoxDecoration(
                color: pw.PdfColors.grey50,
                borderRadius: pw.BorderRadius.circular(5),
              ),
              padding: pw.EdgeInsets.all(12),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      buildTextWidget(
                        text: getTranslation(locale: 'totalAmount', language: language),
                        fontSize: 11,
                        color: pw.PdfColors.grey600,
                      ),
                      pw.SizedBox(height: 3),
                      pw.Row(
                        children: [
                          buildTextWidget(
                            text: total.toAmount(),
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: pw.PdfColors.blue800,
                          ),
                          pw.SizedBox(width: 5),
                          buildTextWidget(
                            text: data.ccy ?? 'USD',
                            fontSize: 14,
                            color: pw.PdfColors.grey700,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Main Content (Two Columns)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Bill Items Column
                pw.Expanded(
                  flex: 3,
                  child: _buildBillItemsSection(billItems, data.ccy ?? '', language),
                ),

                pw.SizedBox(width: 10),

                // Accounting Records Column
                pw.Expanded(
                  flex: 2,
                  child: _buildAccountingSection(records, data.ccy ?? '', language),
                ),
              ],
            ),

            // User Info
            pw.SizedBox(height: 20),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: pw.PdfColors.grey300, width: 0.5),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              padding: pw.EdgeInsets.all(12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  buildTextWidget(
                    text: getTranslation(locale: 'userInfo', language: language),
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: pw.PdfColors.blue800,
                  ),
                  pw.SizedBox(height: 8),
                  _buildDetailRow(
                    label: getTranslation(locale: 'createdBy', language: language),
                    value: data.maker ?? 'N/A',
                  ),
                  _buildDetailRow(
                    label: getTranslation(locale: 'currencyTitle', language: language),
                    value: "${data.ccySymbol ?? "\$"} ${data.ccyName ?? data.ccy ?? 'N/A'}",
                  ),
                ],
              ),
            ),

            // Remark (if any)
            if (data.remark?.isNotEmpty == true) ...[
              pw.SizedBox(height: 20),
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: pw.PdfColors.grey300, width: 0.5),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                padding: pw.EdgeInsets.all(12),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    buildTextWidget(
                      text: getTranslation(locale: 'remark', language: language),
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: pw.PdfColors.blue800,
                    ),
                    pw.SizedBox(height: 8),
                    buildTextWidget(
                      text: data.remark!,
                      fontSize: 9,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  pw.Widget _buildStatusBadge(int status, String language) {
    final isAuthorized = status == 1;
    final color = isAuthorized ? pw.PdfColors.green : pw.PdfColors.orange;

    return pw.Container(
      padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(

        borderRadius: pw.BorderRadius.circular(3),
        border: pw.Border.all(color: pw.PdfColors.grey),
      ),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Icon(
            isAuthorized ? pw.IconData(0xf058) : pw.IconData(0xf254),
            size: 8,
            color: color,
          ),
          pw.SizedBox(width: 4),
          buildTextWidget(
            text: isAuthorized
                ? getTranslation(locale: 'authorizedTitle', language: language)
                : getTranslation(locale: 'pendingTitle', language: language),
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBillItemsSection(List<Bill> billItems, String currency, String language) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: pw.PdfColors.grey300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Icon(
                pw.IconData(0xf290), // shopping cart icon
                size: 12,
                color: pw.PdfColors.blue800,
              ),
              pw.SizedBox(width: 6),
              buildTextWidget(
                text: getTranslation(locale: 'items', language: language),
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: pw.PdfColors.blue800,
              ),
            ],
          ),
          pw.SizedBox(height: 12),

          if (billItems.isEmpty)
            pw.Center(
              child: buildTextWidget(
                text: getTranslation(locale: 'noItems', language: language),
                fontSize: 9,
                color: pw.PdfColors.grey600,
              ),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: pw.PdfColors.grey200),
              children: [
                // Header Row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: pw.PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(6),
                      child: buildTextWidget(
                        text: getTranslation(locale: 'productName', language: language),
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(6),
                      child: buildTextWidget(
                        text: getTranslation(locale: 'storage', language: language),
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(6),
                      child: buildTextWidget(
                        text: getTranslation(locale: 'qty', language: language),
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(6),
                      child: buildTextWidget(
                        text: getTranslation(locale: 'unitPrice', language: language),
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(6),
                      child: buildTextWidget(
                        text: getTranslation(locale: 'totalTitle', language: language),
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                // Data Rows
                ...billItems.map((item) {
                  final itemTotal = double.tryParse(item.totalPrice ?? '') ?? 0;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: billItems.indexOf(item) % 2 == 0
                          ? pw.PdfColors.white
                          : pw.PdfColors.grey50,
                    ),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: buildTextWidget(
                          text: item.productName ?? 'N/A',
                          fontSize: 8,
                          textAlign: pw.TextAlign.left,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: buildTextWidget(
                          text: item.storageName ?? 'N/A',
                          fontSize: 8,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: buildTextWidget(
                          text: "${item.quantity ?? "0"} T",
                          fontSize: 8,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: buildTextWidget(
                          text: item.unitPrice?.toAmount() ?? "0.00",
                          fontSize: 8,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: buildTextWidget(
                          text: "${item.totalPrice?.toAmount()}",
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  pw.Widget _buildAccountingSection(List<Record> records, String currency, String language) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: pw.PdfColors.grey300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Icon(
                pw.IconData(0xf1ad), // building columns icon
                size: 12,
                color: pw.PdfColors.blue800,
              ),
              pw.SizedBox(width: 6),
              buildTextWidget(
                text: getTranslation(locale: 'accountingEntries', language: language),
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: pw.PdfColors.blue800,
              ),
            ],
          ),
          pw.SizedBox(height: 12),

          if (records.isEmpty)
            pw.Center(
              child: buildTextWidget(
                text: getTranslation(locale: 'noRecords', language: language),
                fontSize: 9,
                color: pw.PdfColors.grey600,
              ),
            )
          else
            pw.Column(
              children: records.map((record) {
                final isDebit = record.debitCredit?.toLowerCase() == 'debit';
                return pw.Container(
                  margin: pw.EdgeInsets.only(bottom: 6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: pw.PdfColors.grey200),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: buildTextWidget(
                                text: record.accountName ?? 'N/A',
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: pw.BoxDecoration(
                                color: isDebit
                                    ? pw.PdfColors.red50
                                    : pw.PdfColors.green50,
                                borderRadius: pw.BorderRadius.circular(3),
                              ),
                              child: buildTextWidget(
                                text: record.debitCredit ?? 'N/A',
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: isDebit
                                    ? pw.PdfColors.red700
                                    : pw.PdfColors.green700,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            // buildTextWidget(
                            //   text: record.accountNumber ?? 'N/A',
                            //   fontSize: 8,
                            //   color: pw.PdfColors.grey600,
                            // ),
                            buildTextWidget(
                              text: "${record.amount?.toAmount()} $currency",
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: isDebit
                                  ? pw.PdfColors.red700
                                  : pw.PdfColors.green700,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildDetailRow({required String label, required String value}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: buildTextWidget(
              text: '$label:',
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: buildTextWidget(
              text: value,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Future<pw.Widget> header({required ReportModel report}) async {
    final image = (report.comLogo != null &&
        report.comLogo is Uint8List &&
        report.comLogo!.isNotEmpty)
        ? pw.MemoryImage(report.comLogo!)
        : null;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Company info (left side)
            pw.Expanded(
              flex: 3,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  buildTextWidget(text: report.comName ?? "", fontSize: 20, tightBounds: true),
                  pw.SizedBox(height: 3),
                  buildTextWidget(text: report.statementDate ?? "", fontSize: 10),
                ],
              ),
            ),
            // Logo (right side)
            if (image != null)
              pw.Container(
                width: 40,
                height: 40,
                child: pw.Image(image, fit: pw.BoxFit.contain),
              ),
          ],
        ),
        pw.SizedBox(height: 5)
      ],
    );
  }

  pw.Widget footer({required ReportModel report, required pw.Context context, required String language, required pw.MemoryImage logoImage}) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            pw.Container(
              height: 20,
              child: pw.Image(logoImage),
            ),
            verticalDivider(height: 15, width: 0.6),
            buildTextWidget(
              text: getTranslation(locale: 'producedBy', language: language),
              fontWeight: pw.FontWeight.normal,
              fontSize: 8,
            ),
          ],
        ),
        pw.SizedBox(height: 3),
        horizontalDivider(),
        pw.SizedBox(height: 3),
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
}