import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import '../../../../../../../../Features/PrintSettings/print_services.dart';
import '../../../../../../../../Features/PrintSettings/report_model.dart';
import '../model/bs_model.dart';

class BalanceSheetPrintSettings extends PrintServices {


  // =========================
  // PUBLIC METHODS
  // =========================

  Future<pw.Document> printPreview({
    required BalanceSheetModel data,
    required String language,
    required pw.PageOrientation orientation,
    required ReportModel company,
    required pw.PdfPageFormat pageFormat,
  }) {
    return _generate(
      data: data,
      company: company,
      language: language,
      orientation: orientation,
      pageFormat: pageFormat,
    );
  }

  Future<void> createDocument({
    required BalanceSheetModel data,
    required String language,
    required pw.PageOrientation orientation,
    required ReportModel company,
    required pw.PdfPageFormat pageFormat,
  }) async {
    final doc = await printPreview(
      data: data,
      language: language,
      orientation: orientation,
      company: company,
      pageFormat: pageFormat,
    );

    await saveDocument(
      suggestedName: "BalanceSheet_${DateTime.now().millisecondsSinceEpoch}.pdf",
      pdf: doc,
    );
  }

  Future<void> printDocument({
    required BalanceSheetModel data,
    required String language,
    required pw.PageOrientation orientation,
    required ReportModel company,
    required Printer selectedPrinter,
    required pw.PdfPageFormat pageFormat,
    required int copies,
    required String pages,
  }) async {
    final doc = await printPreview(
      data: data,
      language: language,
      orientation: orientation,
      company: company,
      pageFormat: pageFormat,
    );

    for (int i = 0; i < copies; i++) {
      await Printing.directPrintPdf(
        printer: selectedPrinter,
        onLayout: (_) async => doc.save(),
      );
    }
  }

  // =========================
  // DOCUMENT GENERATOR
  // =========================

  Future<pw.Document> _generate({
    required BalanceSheetModel data,
    required ReportModel company,
    required String language,
    required pw.PageOrientation orientation,
    required pw.PdfPageFormat pageFormat,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        orientation: orientation,
        margin: const pw.EdgeInsets.symmetric(horizontal: 30,vertical: 20),
        build: (_) => [
          _header(company),
          pw.SizedBox(height: 12), // Reduced from 15

          _mainTitle("ASSETS"),
          pw.SizedBox(height: 4), // Reduced spacing
          _yearHeader(),
          pw.SizedBox(height: 2), // Reduced spacing
          ..._assetSection(data.assets),

          pw.SizedBox(height: 10), // Reduced from 15
          _mainTitle("LIABILITIES AND EQUITY"),
          pw.SizedBox(height: 4), // Reduced spacing
          _yearHeader(),
          pw.SizedBox(height: 2), // Reduced spacing
          ..._liabilitySection(data.liability),
        ],
      ),
    );

    return doc;
  }

  // =========================
  // HEADER
  // =========================

  pw.Widget _header(ReportModel company) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          "Balance Sheet",
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold), // Reduced from 22
        ),
        pw.SizedBox(height: 3), // Reduced from 4
        pw.Text(company.comName ?? "", style: pw.TextStyle(fontSize: 10)), // Reduced from 12
        pw.Text(
          "${company.statementDate}",
          style: pw.TextStyle(fontSize: 8), // Reduced from 10
        ),
      ],
    );
  }

  // =========================
  // HEADERS
  // =========================

  pw.Widget _mainTitle(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4), // Reduced from 6
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold), // Reduced from 13
      ),
    );
  }

  pw.Widget _yearHeader() {
    return pw.Row(
      children: [
        pw.Expanded(flex: 4, child: pw.SizedBox()),
        pw.Expanded(
          flex: 3,
          child: text(text:"Current Year",
              fontSize: 8, // Reduced from 9
              fontWeight: pw.FontWeight.bold,
              textAlign: pw.TextAlign.right),
        ),
        pw.Expanded(
          flex: 3,
          child: text(text: "Prior Year",
              fontSize: 8, // Reduced from 9
              fontWeight: pw.FontWeight.bold,
              textAlign: pw.TextAlign.right),
        ),
      ],
    );
  }

  // =========================
  // ASSETS
  // =========================

  List<pw.Widget> _assetSection(Assets? assets) {
    if (assets == null) return [];

    return [
      ..._subSection("Current assets", assets.currentAsset),
      pw.SizedBox(height: 4), // Added spacing between sections
      ..._subSection("Fixed assets", assets.fixedAsset),
      pw.SizedBox(height: 4), // Added spacing between sections
      ..._subSection("Intangible assets", assets.intangibleAsset),
      pw.SizedBox(height: 6), // Reduced spacing before grand total
      _grandTotal("Total assets",
          _sumCurrent(assets), _sumLast(assets)),
    ];
  }

  // =========================
  // LIABILITIES
  // =========================

  List<pw.Widget> _liabilitySection(Liability? liab) {
    if (liab == null) return [];

    final cy = _sumLiabilityCurrent(liab);
    final ly = _sumLiabilityLast(liab);

    return [
      ..._subSection("Current liabilities", liab.currentLiability),
      pw.SizedBox(height: 4), // Added spacing between sections
      ..._subSection("Owner’s equity", liab.ownersEquity),
      pw.SizedBox(height: 4), // Added spacing between sections
      ..._subSection("Stakeholders", liab.stakeholders),
      pw.SizedBox(height: 4), // Added spacing between sections
      ..._subSection("Net profit", liab.netProfit),
      pw.SizedBox(height: 6), // Reduced spacing before grand total
      _grandTotal("Total liabilities and equity", cy, ly),
    ];
  }

  // =========================
  // SUB-SECTIONS
  // =========================

  List<pw.Widget> _subSection(String title, List<AssetItem>? items) {
    if (items == null || items.isEmpty) return [];

    double cy = 0, ly = 0;

    final rows = items.map((e) {
      final c = double.tryParse(e.currentYear ?? "0") ?? 0;
      final l = double.tryParse(e.lastYear ?? "0") ?? 0;
      cy += c;
      ly += l;
      return _row(e.accName ?? "", c, l);
    }).toList();

    return [
      text(text: title, fontSize: 9, fontWeight: pw.FontWeight.bold), // Changed to 9
      pw.SizedBox(height: 2), // Reduced spacing
      ...rows,
      _total("Total $title", cy, ly),
    ];
  }

  // =========================
  // ROWS
  // =========================

  pw.Widget _row(String name, double cy, double ly) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 1), // Reduced from 2
      child: pw.Row(
        children: [
          pw.Expanded(flex: 4, child: pw.Text(name, style: pw.TextStyle(fontSize: 8))), // Added font size 8
          pw.Expanded(flex: 3, child: pw.Text(cy.toAmount(), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8))), // Added font size 8
          pw.Expanded(flex: 3, child: pw.Text(ly.toAmount(), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8))), // Added font size 8
        ],
      ),
    );
  }

  pw.Widget _total(String label, double cy, double ly) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 4), // Reduced from 6
      padding: const pw.EdgeInsets.only(top: 4), // Reduced from 6
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(width: 1)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 4, child: pw.Text(label, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))), // Added font size 8
          pw.Expanded(flex: 3, child: pw.Text(cy.toAmount(), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))), // Added font size 8
          pw.Expanded(flex: 3, child: pw.Text(ly.toAmount(), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))), // Added font size 8
        ],
      ),
    );
  }

  pw.Widget _grandTotal(String label, double cy, double ly) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8), // Reduced from 12
      padding: const pw.EdgeInsets.only(top: 6), // Reduced from 8
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(width: 2)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 4,
            child: pw.Text(label,
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)), // Reduced from 12
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(cy.toAmount(),
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)), // Reduced from 12
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(ly.toAmount(),
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)), // Reduced from 12
          ),
        ],
      ),
    );
  }

  // =========================
  // TOTAL HELPERS
  // =========================

  double _sumCurrent(Assets a) =>
      [...?a.currentAsset, ...?a.fixedAsset, ...?a.intangibleAsset]
          .fold(0, (p, e) => p + (double.tryParse(e.currentYear ?? "0") ?? 0));

  double _sumLast(Assets a) =>
      [...?a.currentAsset, ...?a.fixedAsset, ...?a.intangibleAsset]
          .fold(0, (p, e) => p + (double.tryParse(e.lastYear ?? "0") ?? 0));

  double _sumLiabilityCurrent(Liability l) =>
      [...?l.currentLiability, ...?l.ownersEquity, ...?l.stakeholders, ...?l.netProfit]
          .fold(0, (p, e) => p + (double.tryParse(e.currentYear ?? "0") ?? 0));

  double _sumLiabilityLast(Liability l) =>
      [...?l.currentLiability, ...?l.ownersEquity, ...?l.stakeholders, ...?l.netProfit]
          .fold(0, (p, e) => p + (double.tryParse(e.lastYear ?? "0") ?? 0));
}