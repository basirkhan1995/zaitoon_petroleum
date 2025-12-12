import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zaitoon_petroleum/Features/PrintSettings/print_services.dart';
import '../../../../../../../Features/PrintSettings/report_model.dart';
import 'package:flutter/services.dart';

 class GlatPrintServices extends PrintServices{

   Future<pw.Widget> header({required ReportModel report}) async {
     final image = (report.comLogo != null && report.comLogo is Uint8List && report.comLogo!.isNotEmpty)
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
                   buildTextWidget(text: report.comName ?? "", fontSize: 20,tightBounds: true),
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