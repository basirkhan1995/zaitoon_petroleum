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
import '../../../../Settings/Ui/Company/Storage/model/storage_model.dart';
import '../../../../Stakeholders/Ui/Accounts/model/acc_model.dart';
import '../../../../Stakeholders/Ui/Individuals/model/individual_model.dart';
import '../GetOrderById/model/ord_by_id_model.dart';

class OrderPrintService extends PrintServices {
  Future<void> createDocument({
    required OrderByIdModel order,
    required String language,
    required pw.PageOrientation orientation,
    required ReportModel company,
    required pw.PdfPageFormat pageFormat,
    required List<StorageModel> storages,
    required Map<int, String> productNames,
    required Map<int, String> storageNames,
    required double cashPayment,
    required double creditAmount,
    required AccountsModel? selectedAccount,
    required IndividualsModel? selectedSupplier,
  }) async {
    try {
      final document = await generateOrderDocument(
        order: order,
        company: company,
        language: language,
        orientation: orientation,
        pageFormat: pageFormat,
        storages: storages,
        productNames: productNames,
        storageNames: storageNames,
        cashPayment: cashPayment,
        creditAmount: creditAmount,
        selectedAccount: selectedAccount,
        selectedSupplier: selectedSupplier,
      );

      // Save the document
      await saveDocument(
        suggestedName: "${order.ordName}_${order.ordId}.pdf",
        pdf: document,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> printDocument({
    required OrderByIdModel order,
    required String language,
    required pw.PageOrientation orientation,
    required ReportModel company,
    required Printer selectedPrinter,
    required pw.PdfPageFormat pageFormat,
    required int copies,
    required List<StorageModel> storages,
    required Map<int, String> productNames,
    required Map<int, String> storageNames,
    required double cashPayment,
    required double creditAmount,
    required AccountsModel? selectedAccount,
    required IndividualsModel? selectedSupplier,
  }) async {
    try {
      final document = await generateOrderDocument(
        order: order,
        company: company,
        language: language,
        orientation: orientation,
        pageFormat: pageFormat,
        storages: storages,
        productNames: productNames,
        storageNames: storageNames,
        cashPayment: cashPayment,
        creditAmount: creditAmount,
        selectedAccount: selectedAccount,
        selectedSupplier: selectedSupplier,
      );

      // Use copies parameter for multiple print jobs
      for (int i = 0; i < copies; i++) {
        await Printing.directPrintPdf(
          printer: selectedPrinter,
          onLayout: (pw.PdfPageFormat format) async {
            return document.save();
          },
        );

        // Optional: Add a small delay between copies if needed
        if (i < copies - 1) {
          await Future.delayed(Duration(milliseconds: 100));
        }
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Real Time document show for preview
  Future<pw.Document> printPreview({
    required OrderByIdModel order,
    required String language,
    required ReportModel company,
    required pw.PageOrientation orientation,
    required pw.PdfPageFormat pageFormat,
    required List<StorageModel> storages,
    required Map<int, String> productNames,
    required Map<int, String> storageNames,
    required double cashPayment,
    required double creditAmount,
    required AccountsModel? selectedAccount,
    required IndividualsModel? selectedSupplier,
  }) async {
    return generateOrderDocument(
      order: order,
      company: company,
      language: language,
      orientation: orientation,
      pageFormat: pageFormat,
      storages: storages,
      productNames: productNames,
      storageNames: storageNames,
      cashPayment: cashPayment,
      creditAmount: creditAmount,
      selectedAccount: selectedAccount,
      selectedSupplier: selectedSupplier,
    );
  }

  Future<pw.Document> generateOrderDocument({
    required OrderByIdModel order,
    required String language,
    required ReportModel company,
    required pw.PageOrientation orientation,
    required pw.PdfPageFormat pageFormat,
    required List<StorageModel> storages,
    required Map<int, String> productNames,
    required Map<int, String> storageNames,
    required double cashPayment,
    required double creditAmount,
    required AccountsModel? selectedAccount,
    required IndividualsModel? selectedSupplier,
  }) async {
    final document = pw.Document();
    final prebuiltHeader = await header(report: company);

    // Load your image asset
    final ByteData imageData = await rootBundle.load('assets/images/zaitoonLogo.png');
    final Uint8List imageBytes = imageData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(imageBytes);

    // Calculate totals
    final isPurchase = order.ordName?.toLowerCase().contains('purchase') ?? true;
    final grandTotal = _calculateOrderTotal(order, isPurchase);
    final subTotal = grandTotal; // If no tax/discount, subTotal = grandTotal

    document.addPage(
      pw.MultiPage(
        maxPages: 1000,
        margin: pw.EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        pageFormat: pageFormat,
        textDirection: documentLanguage(language: language),
        orientation: orientation,
        build: (context) => [
          horizontalDivider(),
          invoiceHeaderWidget(
            language: language,
            order: order,
            company: company,
            isPurchase: isPurchase,
          ),

          customerSupplierInfo(
            order: order,
            language: language,
            isPurchase: isPurchase,
            selectedSupplier: selectedSupplier,
          ),
          pw.SizedBox(height: 10),
          itemsTable(
            order: order,
            language: language,
            productNames: productNames,
            storageNames: storageNames,
            isPurchase: isPurchase,
          ),
          pw.SizedBox(height: 15),
          paymentSummary(
            order: order,
            language: language,
            grandTotal: grandTotal,
            subTotal: subTotal,
            cashPayment: cashPayment,
            creditAmount: creditAmount,
            selectedAccount: selectedAccount,
          ),
          pw.SizedBox(height: 20),
          termsAndConditions(language: language),
          pw.SizedBox(height: 20),
          signatureSection(language: language),
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
                  buildTextWidget(text: report.comName ?? "", fontSize: 25, tightBounds: true),
                  pw.SizedBox(height: 3),
                  buildTextWidget(text: report.comAddress ?? "", fontSize: 10),
                  buildTextWidget(text: "${report.compPhone ?? ""} | ${report.comEmail ?? ""}", fontSize: 9),
                ],
              ),
            ),
            // Logo (right side)
            if (image != null)
              pw.Container(
                width: 80,
                height: 80,
                child: pw.Image(image, fit: pw.BoxFit.contain),
              ),
          ],
        ),
        pw.SizedBox(height: 5)
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
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            buildTextWidget(text: report.comAddress ?? "", fontSize: 9),
            buildPage(context.pageNumber, context.pagesCount, language),
          ],
        ),
      ],
    );
  }

  pw.Widget invoiceHeaderWidget({
    required String language,
    required OrderByIdModel order,
    required ReportModel company,
    required bool isPurchase,
  }) {
    final invoiceType = isPurchase
        ? getTranslation(locale: 'PUR', language: language)
        : getTranslation(locale: 'SEL', language: language);

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
                  buildTextWidget(
                    text: invoiceType,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: pw.PdfColors.blue700,
                  ),
                  buildTextWidget(
                    text: "${getTranslation(locale: 'invoiceNumber', language: language)}: ${order.ordId}",
                    fontSize: 14,
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  buildTextWidget(
                    text: getTranslation(locale: 'date', language: language),
                    fontSize: 10,
                  ),
                  buildTextWidget(
                    text: order.ordEntryDate?.toDateTime ?? DateTime.now().toFormattedDate(),
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  buildTextWidget(
                    text: order.ordEntryDate?.toAfghanShamsi.toFormattedDate() ?? "",
                    fontSize: 10,
                    color: pw.PdfColors.blue600,
                  ),
                ],
              ),
            ],
          ),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              buildTextWidget(
                text: "${getTranslation(locale: 'referenceNumber', language: language)}: ${order.ordTrnRef ?? ""}",
                fontSize: 11,
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget customerSupplierInfo({
    required OrderByIdModel order,
    required String language,
    required bool isPurchase,
    required IndividualsModel? selectedSupplier,
  }) {
    final title = isPurchase
        ? getTranslation(locale: 'supplier', language: language)
        : getTranslation(locale: 'customer', language: language);

    final name = selectedSupplier?.perName ?? order.personal ?? "";

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildTextWidget(
            text: title,
            fontSize: 10,
            color: pw.PdfColors.grey600,
            fontWeight: pw.FontWeight.bold,
          ),
          pw.SizedBox(height: 2),
          buildTextWidget(
            text: name,
            fontSize: 13,
          ),
        ],
      ),
    );
  }

  pw.Widget itemsTable({
    required OrderByIdModel order,
    required String language,
    required Map<int, String> productNames,
    required Map<int, String> storageNames,
    required bool isPurchase,
  }) {
    const numberWidth = 30.0;
    const descriptionWidth = 200.0;
    const qtyWidth = 60.0;
    const priceWidth = 80.0;
    const totalWidth = 90.0;
    const storageWidth = 100.0;

    final records = order.records ?? [];

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
          decoration: pw.BoxDecoration(color: pw.PdfColors.grey200),
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: buildTextWidget(
                text: getTranslation(locale: 'number', language: language),
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: buildTextWidget(
                text: getTranslation(locale: 'productName', language: language),
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: buildTextWidget(
                text: getTranslation(locale: 'qty', language: language),
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: buildTextWidget(
                text: getTranslation(locale: 'unitPrice', language: language),
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: buildTextWidget(
                text: getTranslation(locale: 'total', language: language),
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: buildTextWidget(
                text: getTranslation(locale: 'storage', language: language),
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),

        // Data Rows
        for (int i = 0; i < records.length; i++)
          pw.TableRow(
            decoration: i.isOdd
                ? pw.BoxDecoration(color: pw.PdfColors.grey50)
                : null,
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: buildTextWidget(
                  text: (i + 1).toString(),
                  fontSize: 9,
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: buildTextWidget(
                  text: productNames[records[i].stkProduct] ?? "Unknown",
                  fontSize: 9,
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: buildTextWidget(
                  text: records[i].stkQuantity?.toString() ?? "0",
                  fontSize: 9,
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: buildTextWidget(
                  text: isPurchase
                      ? (double.tryParse(records[i].stkPurPrice ?? "0") ?? 0).toAmount()
                      : (double.tryParse(records[i].stkSalePrice ?? "0") ?? 0).toAmount(),
                  fontSize: 9,
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: buildTextWidget(
                  text: _calculateItemTotal(records[i], isPurchase).toAmount(),
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: buildTextWidget(
                  text: storageNames[records[i].stkStorage] ?? "Unknown",
                  fontSize: 9,
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget paymentSummary({
    required OrderByIdModel order,
    required String language,
    required double grandTotal,
    required double subTotal,
    required double cashPayment,
    required double creditAmount,
    required AccountsModel? selectedAccount,
  }) {
    final isPurchase = order.ordName?.toLowerCase().contains('purchase') ?? true;
    final ccy = isPurchase ? "" : "";
    final lang = NumberToWords.getLanguageFromLocale(Locale(language));

    // Use cleaned amount for number to words conversion
    final cleanAmount = grandTotal.toString().replaceAll(',', '');
    final parsedAmount = int.tryParse(
      double.tryParse(cleanAmount)?.toStringAsFixed(0) ?? "0",
    ) ?? 0;

    final amountInWords = NumberToWords.convert(parsedAmount, lang);

    return pw.Container(
      width: 300,
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          // Subtotal
          _buildSummaryRow(
            label: getTranslation(locale: 'subTotal', language: language),
            value: subTotal,
            ccy: ccy,
          ),
          pw.SizedBox(height: 5),

          // Grand Total
          pw.Container(
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: pw.PdfColors.grey100,
              border: pw.Border.all(color: pw.PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                buildTextWidget(
                  text: getTranslation(locale: 'grandTotal', language: language),
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
                buildTextWidget(
                  text: "${grandTotal.toAmount()} $ccy",
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: pw.PdfColors.blue700,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),

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
                buildTextWidget(
                  text: getTranslation(locale: 'payment', language: language),
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
                pw.SizedBox(height: 5),

                if (cashPayment > 0)
                  _buildPaymentRow(
                    label: getTranslation(locale: 'cashPayment', language: language),
                    value: cashPayment,
                    ccy: ccy,
                  ),

                if (creditAmount > 0 && selectedAccount != null)
                  _buildPaymentRow(
                    label: "${getTranslation(locale: 'accountPayment', language: language)} (${selectedAccount.accNumber})",
                    value: creditAmount,
                    ccy: ccy,
                  ),

                pw.SizedBox(height: 5),
                pw.Divider(color: pw.PdfColors.grey300),
                pw.SizedBox(height: 5),
                _buildPaymentRow(
                  label: getTranslation(locale: 'totalPayment', language: language),
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
                buildTextWidget(
                  text: getTranslation(locale: 'amountInWords', language: language),
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                pw.SizedBox(height: 5),
                buildTextWidget(
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

  pw.Widget termsAndConditions({required String language}) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: pw.PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildTextWidget(
            text: getTranslation(locale: 'termsAndConditions', language: language),
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
          pw.SizedBox(height: 5),
          buildTextWidget(
            text: _getTermsAndConditions(language),
            fontSize: 9,
          ),
        ],
      ),
    );
  }

  pw.Widget signatureSection({required String language}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 200,
              height: 1,
              color: pw.PdfColors.black,
            ),
            buildTextWidget(
              text: getTranslation(locale: 'customerSignature', language: language),
              fontSize: 10,
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Container(
              width: 200,
              height: 1,
              color: pw.PdfColors.black,
            ),
            buildTextWidget(
              text: getTranslation(locale: 'authorizedBy', language: language),
              fontSize: 10,
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildSummaryRow({
    required String label,
    required double value,
    String ccy = "",
    bool isBold = false,
    bool isTotal = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        buildTextWidget(
          text: label,
          fontSize: isTotal ? 14 : 11,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        buildTextWidget(
          text: "${value.toAmount()} $ccy",
          fontSize: isTotal ? 14 : 11,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isTotal ? pw.PdfColors.blue700 : null,
        ),
      ],
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
        buildTextWidget(
          text: label,
          fontSize: 10,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        buildTextWidget(
          text: "${value.toAmount()} $ccy",
          fontSize: 10,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isBold ? pw.PdfColors.blue700 : null,
        ),
      ],
    );
  }

  // FIXED: Proper calculation methods
  double _calculateOrderTotal(OrderByIdModel order, bool isPurchase) {
    if (order.records == null || order.records!.isEmpty) return 0.0;

    double total = 0.0;

    for (final record in order.records!) {
      total += _calculateItemTotal(record, isPurchase);
    }

    return total;
  }

  double _calculateItemTotal(OrderRecords record, bool isPurchase) {
    try {
      final quantity = double.tryParse(record.stkQuantity ?? "0") ?? 0.0;
      double price;

      if (isPurchase) {
        price = double.tryParse(record.stkPurPrice ?? "0") ?? 0.0;
      } else {
        price = double.tryParse(record.stkSalePrice ?? "0") ?? 0.0;
      }

      return quantity * price;
    } catch (e) {
      return 0.0;
    }
  }
  String _getTermsAndConditions(String language) {
    const terms = {
      'en': "1. Goods once sold will not be taken back.\n"
          "2. Payment should be made within 30 days.\n"
          "3. Interest @ 12% p.a. will be charged on overdue payments.\n"
          "4. All disputes subject to jurisdiction.",
      'fa': "1. کالاهای فروخته شده پس گرفته نمی شوند.\n"
          "2. پرداخت باید ظرف 30 روز انجام شود.\n"
          "3. بهره 12٪ در سال برای پرداخت های معوق دریافت می شود.\n"
          "4. کلیه اختلافات تابع صلاحیت.",
      'ar': "1. البضائع المباعة لن تؤخذ مرة أخرى.\n"
          "2. يجب أن يتم الدفع خلال 30 يومًا.\n"
          "3. سيتم فرض فائدة 12٪ سنويًا على المدفوعات المتأخرة.\n"
          "4. جميع النزاعات تخضع للولاية القضائية.",
    };
    return terms[language] ?? terms['en']!;
  }
}