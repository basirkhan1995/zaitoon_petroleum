import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:zaitoon_petroleum/Features/PrintSettings/report_model.dart';


abstract class PrintServices {

  // Font management
  static late pw.Font _englishFont;
  static late pw.Font _persianFont;

  // Initialize fonts
  static Future<void> initializeFonts() async {
    await _loadEnglishFont();
    await _loadPersianFont();
  }

  // Add these methods to your InvoicePrintService class

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

  static Future<void> _loadEnglishFont() async {
    final ByteData englishFontData = await rootBundle.load(
      'assets/fonts/OpenSans/OpenSans-regular.ttf',
    );
    final Uint8List englishBytes = englishFontData.buffer.asUint8List();
    _englishFont = pw.Font.ttf(englishBytes.buffer.asByteData());
  }

  static Future<void> _loadPersianFont() async {
    final ByteData persianFontData = await rootBundle.load(
      'assets/fonts/NotoNaskh/NotoNaskhArabic-regular.ttf',
    );
    final Uint8List persianBytes = persianFontData.buffer.asUint8List();
    _persianFont = pw.Font.ttf(persianBytes.buffer.asByteData());
  }

  Future<File?> saveDocument({required String suggestedName, required pw.Document pdf}) async {
    try {
      final FileSaveLocation? fileSaveLocation = await getSaveLocation(
        suggestedName: suggestedName, // Default file name
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'PDF Files', // Label for file types
            extensions: ['pdf'], // Limit to .pdf files
          ),
        ],
      );

      if (fileSaveLocation == null) {
        return null;
      }

      // Ensure the file path has a .pdf extension
      String filePath = fileSaveLocation.path;
      if (!filePath.toLowerCase().endsWith('.pdf')) {
        filePath += '.pdf'; // Append .pdf extension if missing
      }

      // Save the PDF document to the selected path
      final bytes = await pdf.save();

      // Write the bytes to the file
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return file; // Return the saved file
    } catch (e) {
      return null;
    }
  }

  // Common widgets
  pw.Widget buildTextWidget({
    required String text,
    double? fontSize,
    pw.FontWeight? fontWeight,
    bool? tightBounds,
    PdfColor? color,
    pw.TextAlign? textAlign,
    pw.FontStyle? font,
  }) {
    return pw.Text(
      tightBounds: tightBounds ?? false,
      text,
      textAlign: textAlign,
      style: _textStyle(text: text,color: color, fontSize: fontSize, fontWeight: fontWeight,font: font),
      textDirection: _textDirection(text: text),
    );
  }


  Future<pw.ImageProvider?> getImage() async {
    const url = 'https://picsum.photos/500/300.jpg';
    if (url.isEmpty) return null;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return pw.MemoryImage(response.bodyBytes);
    } else {
      return null;
    }
  }

  pw.Widget buildPage(int currentPage, int totalPages, String language) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 1),
      child: buildTextWidget(
        text: '${getTranslation(locale: 'page', language: language)} $currentPage ${getTranslation(locale: 'of', language: language)} $totalPages',
        fontSize: 8,
      ),
    );
  }

  Future<pw.ImageProvider?> loadNetworkImage(String? url) async {
    if (url == null || url.isEmpty) return null;
    final response = await http.get(Uri.parse('https://www.zaitoonsoft.com/rapi/uploads/$url'));
    if (response.statusCode == 200) {
      return pw.MemoryImage(response.bodyBytes);
    } else {
      return null;
    }
  }

  static pw.TextStyle _textStyle({
    required String text,
    double? fontSize,
    PdfColor? color,
    pw.FontWeight? fontWeight,
    pw.FontStyle? font,
  }) {
    return pw.TextStyle(
        color: color,
        font: _isPersian(text) ? _persianFont : _englishFont,
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontStyle: font
    );
  }

  static bool _isPersian(String text) {
    final persianRegex = RegExp(r'[\u0600-\u06FF]');
    return persianRegex.hasMatch(text);
  }

  static pw.TextDirection _textDirection({required String text}) {
    return _isPersian(text) ? pw.TextDirection.rtl : pw.TextDirection.ltr;
  }

  pw.Widget verticalDivider({
    required double height,
    required double width,
  }) {
    return pw.Container(
      height: height,
      width: width,
      color: PdfColors.grey300,
      margin: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 8),
    );
  }

  pw.Widget horizontalDivider({double? width}) {
    return pw.Container(
      height: 0.5,
      width: width ?? double.infinity,
      color: PdfColors.grey300,
      margin: const pw.EdgeInsets.symmetric(vertical: 1, horizontal: 0),
    );
  }

  pw.Widget buildSummary({
    required String label,
    required String value,
    double? fontSize,
    PdfColor? color,
    double distance = 100,
    bool isEmphasized = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.SizedBox(
            width: distance,
            child: buildTextWidget(
                color: color,
                text: label,
                fontWeight: pw.FontWeight.normal,
                fontSize: fontSize ?? 8
            ),
          ),
          buildTextWidget(
            text:value,
            fontSize: fontSize ?? 8,
            fontWeight: pw.FontWeight.normal,
            textAlign: pw.TextAlign.right,
          ),
        ],
      ),
    );
  }

  PdfColor hexToPdfColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    hexColor = '425e91';
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Add full opacity if missing
    } else if (hexColor.length == 8) {
      // Reorder from RGBA to ARGB
      hexColor = '${hexColor.substring(6,8)}${hexColor.substring(0,6)}';
    }

    return PdfColor.fromInt(int.parse(hexColor, radix: 16));
  }

  pw.Widget buildTotalSummary({
    required String label,
    required String value,
    double? width,
    double? space,
    PdfColor? color,
    String? ccySymbol,
    pw.TextAlign? align,
    bool isEmphasized = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.SizedBox(
            width: width ?? 100,
            child: buildTextWidget(
                color: color,
                text: label,
                fontWeight: pw.FontWeight.normal,
                fontSize: 9
            ),
          ),
          pw.SizedBox(width: space ?? 30),
          pw.Row(
            children: [
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: isEmphasized ? pw.FontWeight.bold : pw.FontWeight.normal,
                ),
                textAlign: align ?? pw.TextAlign.center,
              ),
              if(ccySymbol !=null)
              pw.SizedBox(width: 3),
              buildTextWidget(text: ccySymbol??"",tightBounds: true,fontSize: 8)
            ]
          )
        ],
      ),
    );
  }

  pw.TextDirection documentLanguage({required String language}) {
    return language == 'en' ? pw.TextDirection.ltr : pw.TextDirection.rtl;
  }

  String getTranslation({required String locale, required String language}) {
    const translation = {
      'moneyReceipt' : {
        'en':"Money Receipt",
        'fa':"رسید پول",
        "ar":"پول رسید"
      },
      'totalDebits' : {
        'en':"Total Debit",
        'fa':"مجموعه دبت",
        "ar":"مجموعه دبت"
      },
      'totalCredits' : {
        'en':"Total Credit",
        'fa':"مجموعه دبت",
        "ar":"مجموعه دبت"
      },
      'statementAccount' : {
        'en':"Statement of Account",
        'fa':"صورت حساب",
        "ar":"صورت حساب"
      },
      'address' : {
        'en':"Address",
        'fa':"آدرس",
        "ar":"پته"
      },
      'accountSummary': {
        'en': 'Account Summary',
        'fa': 'خلاصه صورت حساب',
        'ar': 'حساب لنډیز',
      },
      'signatory' : {
        'en':"Signatory",
        'fa':"دارنده حساب",
        "ar":"دارنده حساب"
      },
      'currentBalance' : {
        'en':"Current Balance",
        'fa':"مانده فعلی",
        "ar":"فعلی مانده"
      },
      'email' : {
        'en':"Email",
        'fa':"ایمیل آدرس",
        "ar":"ایمیل آدرس"
      },
      'availableBalance' : {
        'en':"Available Balance",
        'fa':"مانده قابل برداشت",
        "ar":"قابل برداشت مانده"
      },
      'incomeStatement' : {
        'en':"Profit & Loss",
        'fa':"سود و زیان",
        "ar":"سود و زیان"
      },
      'grossProfit' : {
        'en':"Gross Profit",
        'fa':"سود ناخالص",
        "ar":"ناخالصه ګټه"
      },
      'cogs' : {
        'en':"Cost of Goods Sold",
        'fa':"هزینه کالا فروخته شده",
        "ar":"د پلورل شویو توکو لګښت"
      },
      'totalExpense' : {
        'en':"Total Expenses",
        'fa':"مصارف",
        "ar":"مصرفونه"
      },
      'totalRevenue' : {
        'en':"Total Revenue",
        'fa':"عواید",
        "ar":"عواید"
      },
      'balanceSheet' : {
        'en':"Balance sheet",
        'fa':"بیلانس شیت",
        "ar":"بیلانس شیت"
      },
      'equityFormula' : {
        'en':"Equity = Asset - Liability",
        'fa':"سهام = دارایی - بدهی",
        "ar":"سهام = دارایی - بدهی"
      },
      'assetFormula' : {
        'en':"Asset = Liability + Equity",
        'fa':"دارایی = بدهی + سهام",
        "ar":"دارایی = بدهی + سهام"
      },
      'accounts' : {
        'en':"Accounts",
        'fa':"حساب ها",
        "ar":"حسابونه"
      },
      'equity' : {
        'en':"Equity",
        'fa':"سهام",
        "ar":"سهام"
      },
      'netProfit' : {
        'en':"Net Profit",
        'fa':"سود خالص",
        "ar":"خالص سود"
      },
      'drawings' : {
        'en':"Drawings",
        'fa':"برداشت ها",
        "ar":"برداشتونه"
      },
      'opb' : {
        'en':"Opening Balance",
        'fa':"بیلانس اولیه",
        "ar":"لومری بیلانس"
      },
      'retainedEarnings' : {
        'en':"Retained Earnings",
        'fa':"سود انباشته",
        "ar":"انباشته سود"
      },
      'capital' : {
        'en':"Capital",
        'fa':"دارایی",
        "ar":"دارایی"
      },
      'liability' : {
        'en':"Liability",
        'fa':"بدهی ها",
        "ar":"دیون"
      },
      'totalAsset' : {
        'en':"Total Asset",
        'fa':"سرمایه",
        "ar":"سرمایه"
      },
      'accountReceivable' : {
        'en':"Receivables",
        'fa':"پول دریافتنی",
        "ar":"دریافتی پیسی"
      },
      'cashVault' : {
        'en':"Cash Vault",
        'fa':"پول نقد",
        "ar":"نقدی پیسی"
      },
      'bank' : {
        'en':"Bank",
        'fa':"بانک",
        "ar":"بانک"
      },
      'saraf' : {
        'en':"Saraf",
        'fa':"صراف",
        "ar":"صراف"
      },
      'products' : {
        'en':"Products",
        'fa':"محصولات",
        "ar":"محصولات"
      },
      'stock' : {
        'en':"Stock",
        'fa':"انبار",
        "ar":"انبار"
      },
      'returnInvoice' : {
        'en':"Return Invoice",
        'fa':"بل برگشتی",
        "ar":"بل برگشتی"
      },
      'RTPU' : {
        'en':"Buy Return",
        'fa':"برگشت خرید",
        "ar":"برگشت خرید"
      },
      'RTSL' : {
        'en':"Sell Return",
        'fa':"برگشت فروش",
        "ar":"برگشت فروش"
      },
      'inventoryMovement' : {
        'en':"Product CardX",
        'fa':"گردش کالا",
        "ar":"کالا گردش"
      },
      'qtyIn' : {
        'en':"IN",
        'fa':"ورود",
        "ar":"ورود"
      },
      'qtyOut' : {
        'en':"OUT",
        'fa':"خروج",
        "ar":"خروج"
      },
      'unitBasePrice' : {
        'en':"Price",
        'fa':"قیمت",
        "ar":"قیمت"
      },
      'deal' : {
        'en':"Deal",
        'fa':"معامله",
        "ar":"معامله"
      },
      'id' : {
        'en':"ID",
        'fa':"شناسه",
        "ar":"شناسه"
      },
      'noAccount' : {
        'en':"Settled",
        'fa':"تسویه",
        "ar":"تسویه"
      },
      'details' : {
        'en':"Details",
        'fa':"جزئیات",
        "ar":"جزئیات"
      },
      'productName' : {
        'en':"Product name",
        'fa':"نام کالا",
        "ar":"کالا نوم"
      },
      'inventoryTitle' : {
        'en':"Inventory Report",
        'fa':"گزارش کالا ها",
        "ar":"کالا گزارش"
      },
      'category' : {
        'en':"Category",
        'fa':"کتگوری",
        "ar":"کتگوری"
      },
      'inventory' : {
        'en':"QTY",
        'fa':"موجودی",
        "ar":"موجودی"
      },
      'unit' : {
        'en':"Unit",
        'fa':"واحد",
        "ar":"واحد"
      },
      'amountInWords' : {
        'en':"Amount in words",
        'fa':"مبلغ به حروف",
        "ar":"مبلغ کلمو کې"
      },
      'statementPeriod': {
        'en': 'Statement Period',
        'fa': 'مدت صورت حساب',
        'ar': 'صورت حساب مدت',
      },
      'statementDate': {
        'en': 'Statement Date',
        'fa': 'تاریخ صورت حساب',
        'ar': 'صورت حساب نیټه',
      },

      'total': {
        'en': 'Total',
        'fa': 'جمع کل',
        'ar': 'ټول قیمت',
      },

      'debitAccount':{
        'en':'Debit Account',
        'fa':'حساب دبت',
        'ar':'دبت حساب'
      },
      'creditAccount':{
        'en':'Credit Account',
        'fa':'حساب کریدت',
        'ar':'کریدت حساب'
      },

      'debitAmount':{
        'en':'Debit Amount',
        'fa':'مبلغ دبت',
        'ar':'مبلغ حساب'
      },
      'ACCT':{
        'en':'ACCT Transfer',
        'fa':'حساب به حساب',
        'ar':'حساب به حساب'
      },
      'creditAmount':{
        'en':'Credit Amount',
        'fa':'مبلغ کریدت',
        'ar':'کریدت مبلغ'
      },

      'OBAL':{
        'en':'OBAL',
        'fa':'بیلانس افتتاحیه',
        'ar':'افتتاحیه بیلانس'
      },
      'openingBalance': {
        'en': 'Opening Balance',
        'fa': 'مانده اولیه',
        'ar': 'د پرانیستې بیلانس',
      },

      'closingBalance': {
        'en': 'Closing Balance',
        'fa': 'بیلانس نهایی',
        'ar': 'تړلو بیلانس',
      },

      'totalCredit': {
        'en': 'Credits',
        'fa': 'بستانکار',
        'ar': 'بستانکار',
      },

      'totalDebit': {
        'en': 'Debits',
        'fa': 'بدهکار',
        'ar': 'بدهکار',
      },

      'page': {
        'en': 'Page',
        'fa': 'صفحه',
        'ar': 'پاڼه',
      },

      'of': {
        'en': 'of',
        'fa': 'از ',
        'ar': 'له',
      },

      'accountStatement': {
        'en': 'Account Statement',
        'fa': 'صورت حساب اشخاص',
        'ar': 'صورت حساب اشخاص',
      },
      'trnType': {
        'en': 'Transaction Code',
        'fa': 'کد معامله',
        'ar': 'معامله کد',
      },
      'checker': {
        'en': 'Checker',
        'fa': 'تایید کننده',
        'ar': 'تایید کونکی',
      },
      'maker': {
        'en': 'Maker',
        'fa': 'اجراء کننده',
        'ar': 'اجراء کونکی',
      },
      'CHDP': {
        'en': 'Cash Deposit',
        'fa': 'دریافت نقدی',
        'ar': 'نقدی دریافت',
      },
      'CHWL': {
        'en': 'Cash Withdraw',
        'fa': 'پرداخت نقدی',
        'ar': 'نقدی پرداخت',
      },
      'GLDR': {
        'en': 'General Ledger Debit',
        'fa': 'پرداخت دفتر کل',
        'ar': 'پرداخت دفتر کل',
      },

      'GLCR': {
        'en': 'General Ledger Credit',
        'fa': 'دریافت دفتر کل',
        'ar': 'دریافت دفتر کل',
      },

      'XPNS': {
        'en': 'Expense',
        'fa': 'مصارف',
        'ar': 'لګښت',
      },

      'INCM': {
        'en': 'Income (Profit)',
        'fa': 'عواید',
        'ar': 'عواید',
      },

      'EXCH': {
        'en': 'Cross Currency',
        'fa': 'ارز متقابل',
        'ar': 'متقابل ارز',
      },

      'debit': {
        'en': 'Debit',
        'fa': 'بدهکار',
        'ar': 'بدهکار',
      },

      'credit': {
        'en': 'Credit',
        'fa': 'بستانکار',
        'ar': 'بسټانکار',
      },

      'branch':{
        'en':'Branch',
        'fa':'شعبه',
        'ar':'څانګه',
      },

      'authorizedBy':{
        'en':'Authorized by: ',
        'fa':'تایید کننده',
        'ar':'تایید کونکی',
      },

      'producedBy':{
        'en':"Powered by Zaitoon Inc",
        'fa':"ساخته شده زیتون سافت",
        'ar':'زیتون سافت لخوا وړاندې شوی',
      },

      'createdBy':{
        'en':'Issued by: ',
        'fa':'تهیه شده توسط: ',
        'ar':'چمتو شوی لخوا: ',
      },
      'reference':{
        'en':'Reference',
        'fa':'شماره مرجع',
        'ar':'حوالې شمیره',
      },
      'amount':{
        'en':'Amount',
        'fa':'مبلغ',
        'ar':'مبلغ',
      },
      'accountName':{
        'en':'Account ',
        'fa':'نام حساب',
        'ar':'حساب نوم',
      },
      'status':{
        'en':'Status ',
        'fa':'وضعیت',
        'ar':'وضعیت',
      },
      'debtor':{
        'en':'Debtor ',
        'fa':'بدهکار',
        'ar':'بدهکار',
      },
      'creditor':{
        'en':'Creditor ',
        'fa':'طلبکار',
        'ar':'طلبکار',
      },


      'accountNumber':{
        'en':'Account No',
        'fa':'شماره حساب',
        'ar':'حساب شمیره',
      },
      'currency': {
        'en':'Currency',
        'fa':'ارز حساب',
        'ar':'حساب ارز',
      },
      'narration':{
        'en':'Narration',
        'fa':'شرح',
        'ar':'شرح',
      },
      'withdrawal':{
        'en':'Withdrawal',
        'fa':'دریافت',
        'ar':'دریافت',
      },
      'deposit':{
        'en':'Deposit',
        'fa':'پرداخت',
        'ar':'پرداخت',
      },
      'balance':{
        'en':'Balance',
        'fa':'بیلانس',
        'ar':'بیلانس',
      },
      'date':{
        'en':'Date',
        'fa':'تاریخ',
        'ar':'نیته',
      },

      'accOwner':{
        'en':'Account holder',
        'fa':'دارنده حساب',
        'ar':'دارنده حساب',
      },
      'mobile':{
        'en':'Mobile',
        'fa':'تماس',
        'ar':'تماس',
      },
      'qty':{
        'en':'Qty',
        'fa':'مقدار',
        'ar':'مقدار',
      },
      'unitPrice':{
        'en':'Unit Price',
        'fa':'قیمت واحد',
        'ar':'واحد قیمت',
      },
      'totalInvoice':{
        'en':'Total',
        'fa':'جمع کل',
        'ar':'ټول قیمت',
      },
      'subTotal':{
        'en':'Total',
        'fa':'جمع جزء',
        'ar':'فرعي مجموعه',
      },
      'number':{
        'en':'No',
        'fa':'شماره',
        'ar':'شمېره',
      },
      'invoiceType':{
        'en':'Invoice',
        'fa':'نوع بل',
        'ar':'بل نوع',
      },
      'PUR':{
        'en':'Purchase',
        'fa':'خرید',
        'ar':'خرید',
      },
      'SEL':{
        'en':'Sell',
        'fa':'فروش',
        'ar':'فروش',
      },
      'invoiceNumber':{
        'en':'Invoice#',
        'fa':'نمبر بل',
        'ar':'بل نمبر',
      },
      'items':{
        'en':'Items',
        'fa':'نام کالا',
        'ar':'توکي نوم',
      },
      'grandTotal':{
        'en':'Grand Total',
        'fa':'جمع کل نهایی',
        'ar':'ټولیز مجموعه',
      },
      'previousBalance':{
        'en':'Balance',
        'fa':'مانده حساب',
        'ar':'پاتې حساب',
      },
      'payment':{
        'en':'Payment',
        'fa':'مبلغ رسید',
        'ar':'رسید مبلغ',
      },

      'vehicleDetails': {
        'en': 'Vehicle Details',
        'fa': 'جزئیات وسیله نقلیه',
        'ar': 'د موټرو معلومات',
      },
      'vehicleID': {
        'en': 'Vehicle ID',
        'fa': 'شناسه وسیله نقلیه',
        'ar': 'د موټر آی ډی',
      },
      'model': {
        'en': 'model',
        'fa': 'مدل',
        'ar': 'مودل',
      },
      'year': {
        'en': 'Year',
        'fa': 'سال',
        'ar': 'کال',
      },
      'vinNumber': {
        'en': 'VIN Number',
        'fa': 'شماره VIN',
        'ar': 'وی آی اېن نمبر',
      },
      'fuelType': {
        'en': 'Fuel Type',
        'fa': 'نوع سوخت',
        'ar': 'د سون توکي ډول',
      },
      'enginePower': {
        'en': 'Engine Power',
        'fa': 'قدرت موتور',
        'ar': 'د انجن قوت',
      },
      'bodyType': {
        'en': 'Body Type',
        'fa': 'نوع بدنه',
        'ar': 'د بدن ډول',
      },
      'plateNumber': {
        'en': 'Plate Number',
        'fa': 'شماره پلاک',
        'ar': 'د پلیټ نمبر',
      },
      'registrationNumber': {
        'en': 'Registration Number',
        'fa': 'شماره ثبت',
        'ar': 'د ثبت نمبر',
      },
      'expiryDate': {
        'en': 'Expiry Date',
        'fa': 'تاریخ انقضا',
        'ar': 'د پای نیټه',
      },
      'odometer': {
        'en': 'Odometer',
        'fa': 'کیلومتر شمار',
        'ar': 'د ګزاریچې شمار',
      },
      'purchaseAmount': {
        'en': 'Orders Amount',
        'fa': 'مبلغ خرید',
        'ar': 'د پیرود مقدار',
      },
      'driver': {
        'en': 'Driver',
        'fa': 'راننده',
        'ar': 'چلوونکی',
      },

      'transactionDetails': {
        'en': 'Transaction Details',
        'fa': 'جزئیات تراکنش',
        'ar': 'د معاملې معلومات',
      },

      'transactionStatus': {
        'en': 'Transaction Status',
        'fa': 'وضعیت تراکنش',
        'ar': 'د معاملې حالت',
      },
      'inactive': {
        'en': 'Inactive',
        'fa': 'غیرفعال',
        'ar': 'غیر فعال',
      },
      'active': {
        'en': 'Active',
        'fa': 'فعال',
        'ar': 'فعال',
      },
      'pending': {
        'en': 'Pending',
        'fa': 'در انتظار',
        'ar': 'په تمه کې',
      },
      'approved': {
        'en': 'Approved',
        'fa': 'تایید شده',
        'ar': 'تصویب شوی',
      },
      'rejected': {
        'en': 'Rejected',
        'fa': 'رد شده',
        'ar': 'رد شوی',
      },
      'unknown': {
        'en': 'Unknown',
        'fa': 'ناشناخته',
        'ar': 'نامعلوم',
      },

      // Add these to your translation map
      'allShipping': {
        'en': 'All Shipping Records',
        'fa': 'همه سوابق حمل و نقل',
        'ar': 'جميع سجلات الشحن',
      },
      'shippingSummary': {
        'en': 'Shipping Summary',
        'fa': 'خلاصه حمل و نقل',
        'ar': 'ملخص الشحن',
      },
      'totalShipments': {
        'en': 'Total Shipments',
        'fa': 'کل حمل و نقل',
        'ar': 'إجمالي الشحنات',
      },
      'completed': {
        'en': 'Completed',
        'fa': 'تکمیل شده',
        'ar': 'مكتمل',
      },
      'totalRent': {
        'en': 'Total Rent',
        'fa': 'کرایه کل',
        'ar': 'الإيجار الكلي',
      },
      'avgUnLoadSize': {
        'en': 'Avg Unload',
        'fa': 'میانگین بارگیری',
        'ar': 'میانگین بارگیری',
      },
      'avgLoadSize': {
        'en': 'Avg Load',
        'fa': 'میانگین تلخیه',
        'ar': 'میانگین تخلیه',
      },
      'vehicles': {
        'en': 'Vehicle',
        'fa': 'وسیله نقلیه',
        'ar': 'مركبة',
      },
      'customer': {
        'en': 'Customer',
        'fa': 'مشتری',
        'ar': 'عميل',
      },
      'shippingRent': {
        'en': 'Rent',
        'fa': 'کرایه',
        'ar': 'إيجار',
      },
      'loadingSize': {
        'en': 'LD Weight',
        'fa': 'اندازه بارگیری',
        'ar': 'حجم التحميل',
      },
      'unloadingSize': {
        'en': 'ULD Weight',
        'fa': 'اندازه تخلیه',
        'ar': 'حجم التفريغ',
      },
      'completedTitle': {
        'en': 'Completed',
        'fa': 'تکمیل',
        'ar': 'مكتمل',
      },
      'pendingTitle': {
        'en': 'Pending',
        'fa': 'در انتظار',
        'ar': 'قيد الانتظار',
      },
      'termsAndConditions': {
        'en': 'Terms & Conditions',
        'fa': 'شرایط و ضوابط',
        'ar': 'شرایط و ضوابط',
      },
      'customerSignature': {
        'en': 'Customer Signature',
        'fa': 'امضای مشتری',
        'ar': 'امضاء العميل',
      },
      'totalPayment': {
        'en': 'Total Payment',
        'fa': 'مجموع پرداخت',
        'ar': 'المبلغ الإجمالي',
      },
      'cashPayment': {
        'en': 'Cash Payment',
        'fa': 'پرداخت نقدی',
        'ar': 'دفع نقدي',
      },
      'accountPayment': {
        'en': 'Account Payment',
        'fa': 'پرداخت حساب',
        'ar': 'دفع الحساب',
      },
      'supplier': {
        'en': 'Supplier',
        'fa': 'تامین کننده',
        'ar': 'المورد',
      },
      'referenceNumber': {
        'en': 'Reference No',
        'fa': 'شماره مرجع',
        'ar': 'رقم المرجع',
      },
      'orderDate': {
        'en': 'Order Date',
        'fa': 'تاریخ سفارش',
        'ar': 'تاريخ الطلب',
      },
      'quantity': {
        'en': 'Qty',
        'fa': 'تعداد',
        'ar': 'الكمية',
      },
      'storage': {
        'en': 'Storage',
        'fa': 'انبار',
        'ar': 'المستودع',
      },
      'description': {
        'en': 'Description',
        'fa': 'توضیحات',
        'ar': 'الوصف',
      },

    };

    // Default to English if language not found
    final languageMap = translation[locale] ?? {'en': '', 'fa': '', 'ar': ''};
    return languageMap[language] ?? languageMap['en']!;
  }
}



