import 'dart:async';
import 'dart:ui';
import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/amount_to_word.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/PrintSettings/print_services.dart';
import 'package:zaitoon_petroleum/Features/PrintSettings/report_model.dart';
import '../../../../Stakeholders/Ui/Accounts/model/acc_model.dart';

abstract class InvoiceItem {
  String get productName;
  double get quantity;
  double get unitPrice;
  double get total;
  String get storageName;
}

class SaleInvoiceItemForPrint implements InvoiceItem {
  @override
  final String productName;
  @override
  final double quantity;
  @override
  final double unitPrice;
  @override
  final double total;
  @override
  final String storageName;
  final double? purchasePrice;
  final double? profit;

  SaleInvoiceItemForPrint({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.storageName,
    this.purchasePrice,
    this.profit,
  });
}

class PurchaseInvoiceItemForPrint implements InvoiceItem {
  @override
  final String productName;
  @override
  final double quantity;
  @override
  final double unitPrice;
  @override
  final double total;
  @override
  final String storageName;

  PurchaseInvoiceItemForPrint({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.storageName,
  });
}

class InvoicePrintService extends PrintServices {
  Future<void> createInvoiceDocument({
    required String invoiceType,
    required String invoiceNumber,
    required String? reference,
    required DateTime? invoiceDate,
    required String customerSupplierName,
    required List<InvoiceItem> items,
    required double grandTotal,
    required double cashPayment,
    required double creditAmount,
    required AccountsModel? account,
    required String language,
    required pw.PageOrientation orientation,
    required ReportModel company,
    required pw.PdfPageFormat pageFormat,
    String? currency,
  }) async {
    try {
      final document = await generateInvoiceDocument(
        invoiceType: invoiceType,
        invoiceNumber: invoiceNumber,
        reference: reference,
        invoiceDate: invoiceDate,
        customerSupplierName: customerSupplierName,
        items: items,
        grandTotal: grandTotal,
        cashPayment: cashPayment,
        creditAmount: creditAmount,
        account: account,
        language: language,
        orientation: orientation,
        company: company,
        pageFormat: pageFormat,
        currency: currency,
      );

      await saveDocument(
        suggestedName: "${invoiceType}_$invoiceNumber.pdf",
        pdf: document,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> printInvoiceDocument({
    required String invoiceType,
    required String invoiceNumber,
    required String? reference,
    required DateTime? invoiceDate,
    required String customerSupplierName,
    required List<InvoiceItem> items,
    required double grandTotal,
    required double cashPayment,
    required double creditAmount,
    required AccountsModel? account,
    required String language,
    required pw.PageOrientation orientation,
    required ReportModel company,
    required Printer selectedPrinter,
    required pw.PdfPageFormat pageFormat,
    required int copies,
    String? currency,
  }) async {
    try {
      final document = await generateInvoiceDocument(
        invoiceType: invoiceType,
        invoiceNumber: invoiceNumber,
        reference: reference,
        invoiceDate: invoiceDate,
        customerSupplierName: customerSupplierName,
        items: items,
        grandTotal: grandTotal,
        cashPayment: cashPayment,
        creditAmount: creditAmount,
        account: account,
        language: language,
        orientation: orientation,
        company: company,
        pageFormat: pageFormat,
        currency: currency,
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

  Future<pw.Document> printInvoicePreview({
    required String invoiceType,
    required String invoiceNumber,
    required String? reference,
    required DateTime? invoiceDate,
    required String customerSupplierName,
    required List<InvoiceItem> items,
    required double grandTotal,
    required double cashPayment,
    required double creditAmount,
    required AccountsModel? account,
    required String language,
    required pw.PageOrientation orientation,
    required ReportModel company,
    required pw.PdfPageFormat pageFormat,
    String? currency,
  }) async {
    return generateInvoiceDocument(
      invoiceType: invoiceType,
      invoiceNumber: invoiceNumber,
      reference: reference,
      invoiceDate: invoiceDate,
      customerSupplierName: customerSupplierName,
      items: items,
      grandTotal: grandTotal,
      cashPayment: cashPayment,
      creditAmount: creditAmount,
      account: account,
      language: language,
      orientation: orientation,
      company: company,
      pageFormat: pageFormat,
      currency: currency,
    );
  }

  Future<pw.Document> generateInvoiceDocument({
    required String invoiceType,
    required String invoiceNumber,
    required String? reference,
    required DateTime? invoiceDate,
    required String customerSupplierName,
    required List<InvoiceItem> items,
    required double grandTotal,
    required double cashPayment,
    required double creditAmount,
    required AccountsModel? account,
    required String language,
    required pw.PageOrientation orientation,
    required ReportModel company,
    required pw.PdfPageFormat pageFormat,
    String? currency,
  }) async {
    final document = pw.Document();
    final prebuiltHeader = await header(report: company);
    final ByteData imageData = await rootBundle.load('assets/images/zaitoonLogo.png');
    final Uint8List imageBytes = imageData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(imageBytes);

    final isSale = invoiceType.toLowerCase().contains('sale');

    document.addPage(
      pw.MultiPage(
        maxPages: 1000,
        margin: pw.EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        pageFormat: pageFormat,
        textDirection: documentLanguage(language: language),
        orientation: orientation,
        build: (context) => [
          _invoiceHeaderWidget(
            language: language,
            invoiceType: invoiceType,
            invoiceNumber: invoiceNumber,
            invoiceDate: invoiceDate,
            reference: reference,
          ),
          _customerSupplierInfo(
            language: language,
            customerSupplierName: customerSupplierName,
            isSale: isSale,
          ),
          pw.SizedBox(height: 5),
          _itemsTable(
            items: items,
            language: language,
            isSale: isSale,
          ),
          pw.SizedBox(height: 15),
          _paymentSummary(
            language: language,
            grandTotal: grandTotal,
            cashPayment: cashPayment,
            creditAmount: creditAmount,
            account: account,
            currency: currency,
          ),
        ],
        header: (context) => prebuiltHeader,
        footer: (context) => footer(
            report: company,
            context: context,
            language: language,
            logoImage: logoImage
        ),
      ),
    );
    return document;
  }

  pw.Widget _invoiceHeaderWidget({
    required String language,
    required String invoiceType,
    required String invoiceNumber,
    required DateTime? invoiceDate,
    required String? reference,
  }) {
    final invoiceTitle = invoiceType.toLowerCase().contains('sale')
        ? getTranslation(locale: 'SEL', language: language)
        : getTranslation(locale: 'PUR', language: language);

    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  text(
                    text: invoiceTitle,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: pw.PdfColors.blue700,
                  ),
                  text(
                    text:
                    "${getTranslation(locale: 'invoiceNumber', language: language)}: $invoiceNumber",
                    fontSize: 10,
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  text(
                    text: getTranslation(locale: 'invDate', language: language),
                    fontSize: 9,
                    color: pw.PdfColors.grey700,
                  ),
                  text(
                    text: DateTime.now().toFormattedDate(),
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  text(
                    text: invoiceDate?.toAfghanShamsi.toFormattedDate() ?? "",
                    fontSize: 10,
                    color: pw.PdfColors.blue600,
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          if (reference != null && reference.isNotEmpty)
            text(
              text:
              "${getTranslation(locale: 'referenceNumber', language: language)}: $reference",
              fontSize: 11,
            ),
        ],
      ),
    );
  }

  pw.Widget _customerSupplierInfo({
    required String language,
    required String customerSupplierName,
    required bool isSale,
  }) {
    final title = isSale
        ? getTranslation(locale: 'customer', language: language)
        : getTranslation(locale: 'supplier', language: language);

    return pw.Container(
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          text(
            text: title,
            fontSize: 10,
            color: pw.PdfColors.grey600,
            fontWeight: pw.FontWeight.bold,
          ),
          pw.SizedBox(width: 4),
          text(
            text: customerSupplierName,
            fontSize: 10,
          ),
        ],
      ),
    );
  }

  pw.Widget _itemsTable({
    required List<InvoiceItem> items,
    required String language,
    required bool isSale,
  }) {
    const numberWidth = 30.0;
    const descriptionWidth = 200.0;
    const qtyWidth = 60.0;
    const priceWidth = 80.0;
    const totalWidth = 90.0;
    const storageWidth = 100.0;

    return pw.Table(
      border: pw.TableBorder.all(color: pw.PdfColors.grey300, width: 1),
      columnWidths: {
        0: pw.FixedColumnWidth(numberWidth),
        1: pw.FixedColumnWidth(descriptionWidth),
        2: pw.FixedColumnWidth(qtyWidth),
        3: pw.FixedColumnWidth(priceWidth),
        4: pw.FixedColumnWidth(totalWidth),
        5: pw.FixedColumnWidth(storageWidth),
      },
      children: [
        // Header Row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: pw.PdfColors.grey50),
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(4),
              child: text(
                text: getTranslation(locale: 'number', language: language),
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(4),
              child: text(
                text: getTranslation(locale: 'description', language: language),
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(4),
              child: text(
                text: getTranslation(locale: 'qty', language: language),
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(4),
              child: text(
                text: getTranslation(locale: 'unitPrice', language: language),
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(4),
              child: text(
                text: getTranslation(locale: 'total', language: language),
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(4),
              child: text(
                text: getTranslation(locale: 'storage', language: language),
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),

        // Data Rows
        for (int i = 0; i < items.length; i++)
          pw.TableRow(
            decoration:
            i.isOdd ? pw.BoxDecoration(color: pw.PdfColors.grey50) : null,
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.all(5),
                child: text(
                  text: (i + 1).toString(),
                  fontSize: 9,
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5),
                child: text(
                  text: items[i].productName,
                  fontSize: 9,
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5),
                child: text(
                  text: items[i].quantity.toString(),
                  fontSize: 9,
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5),
                child: text(
                  text: items[i].unitPrice.toAmount(),
                  fontSize: 9,
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5),
                child: text(
                  text: items[i].total.toAmount(),
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5),
                child: text(
                  text: items[i].storageName,
                  fontSize: 9,
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _paymentSummary({
    required String language,
    required double grandTotal,
    required double cashPayment,
    required double creditAmount,
    required AccountsModel? account,
    String? currency,
  }) {
    final lang = NumberToWords.getLanguageFromLocale(Locale(language));
    final cleanAmount = grandTotal.toString().replaceAll(',', '');
    final parsedAmount = int.tryParse(
      double.tryParse(cleanAmount)?.toStringAsFixed(0) ?? "0",
    ) ??
        0;
    final amountInWords = NumberToWords.convert(parsedAmount, lang);
    final ccy = currency ?? '';

    return pw.Container(
      width: 300,
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          // Payment Breakdown
          pw.Container(
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: pw.PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Grand Total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    text(
                      text: getTranslation(
                          locale: 'grandTotal', language: language),
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    text(
                      text: "${grandTotal.toAmount()} $ccy",
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: pw.PdfColors.blue700,
                    ),
                  ],
                ),

                if (cashPayment > 0)
                  _buildPaymentRow(
                    label: getTranslation(
                        locale: 'cashPayment', language: language),
                    value: cashPayment,
                    ccy: ccy,
                  ),

                if (creditAmount > 0 && account != null)
                  _buildPaymentRow(
                    label:
                    "${getTranslation(locale: 'accountPayment', language: language)} (${account.accNumber})",
                    value: creditAmount,
                    ccy: ccy,
                  ),

                _buildPaymentRow(
                  label: getTranslation(
                      locale: 'totalPayment', language: language),
                  value: cashPayment + creditAmount,
                  ccy: ccy,
                  isBold: true,
                ),
              ],
            ),
          ),

          // Amount in words
          pw.SizedBox(height: 10),
          pw.Container(
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: pw.PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            width: double.infinity,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                text(
                  text: getTranslation(
                      locale: 'amountInWords', language: language),
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                pw.SizedBox(height: 5),
                text(
                  text: amountInWords.isNotEmpty ? "$amountInWords $ccy" : "",
                  fontSize: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPaymentRow({
    required String label,
    required double value,
    String ccy = "",
    bool isBold = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        text(
          text: label,
          fontSize: 11,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        text(
          text: "${value.toAmount()} $ccy",
          fontSize: 11,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isBold ? pw.PdfColors.blue700 : null,
        ),
      ],
    );
  }
}