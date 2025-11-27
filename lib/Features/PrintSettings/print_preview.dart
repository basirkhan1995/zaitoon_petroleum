import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zaitoon_petroleum/Features/PrintSettings/report_model.dart';
import '../../Localizations/Bloc/localizations_bloc.dart';
import '../../Localizations/l10n/translations/app_localizations.dart';
import '../Widgets/button.dart';
import '../Widgets/outline_button.dart';
import 'Features/document_locale.dart';
import 'Features/printers.dart';
import 'PageOrientation/paper_orientation.dart';
import 'PaperSize/paper_size.dart';
import 'bloc/Language/print_language_cubit.dart';
import 'bloc/PageOrientation/page_orientation_cubit.dart';
import 'bloc/PageSize/paper_size_cubit.dart';
import 'bloc/Printer/printer_cubit.dart';

class PrintPreviewDialog<T> extends StatelessWidget {
  final T data;
  final ReportModel company;
  final Future<pw.Document> Function({
  required T data,
  required String language,
  required pw.PageOrientation orientation,
  required PdfPageFormat pageFormat,
  })buildPreview;

  final Future<void> Function({
  required T data,
  required String language,
  required pw.PageOrientation orientation,
  required PdfPageFormat pageFormat,
  required Printer selectedPrinter,
  })onPrint;

  final Future<void> Function({
  required T data,
  required String language,
  required pw.PageOrientation orientation,
  required PdfPageFormat pageFormat,
  })onSave;

  const PrintPreviewDialog({
    super.key,
    required this.company,
    required this.data,
    required this.buildPreview,
    required this.onPrint,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      content: Container(
        height: MediaQuery.sizeOf(context).height * .95,
        width: MediaQuery.sizeOf(context).width * .9,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // _buildTitleBar(locale, context),
            Expanded(
              child: Row(
                children: [
                  _buildSidebar(context, locale),
                  _buildPreview(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AppLocalizations locale) {
    final currentLocale = context.watch<LocalizationBloc>();
    String sysLanguage = currentLocale.toString();
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      width: 230,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(blurRadius: 1, color: Theme.of(context).colorScheme.surfaceContainer),
        ],
      ),
      child: Column(
        spacing: 5,
        children: [
          PrinterDropdown(
            onPrinterSelected: (value) => context.read<PrinterCubit>().setPrinter(value),
          ),
          const SizedBox(height: 5),
          LanguageDropdown(
            onLanguageSelected:
                (value) =>
                context.read<PrintLanguageCubit>().setLanguage(value.code),
          ),
          const SizedBox(height: 5),
          PageFormatDropdown(
            onFormatSelected: (format) => context.read<PaperSizeCubit>().setPaperSize(format),
          ),
          const SizedBox(height: 5),
          PageOrientationDropdown(
            onOrientationSelected:
                (orientation) => context
                .read<PageOrientationCubit>()
                .setOrientation(orientation),
          ),
          const Spacer(),
          ZOutlineButton(
            width: double.infinity,
            height: 45,
            icon: Icons.print,
            label: Text(locale.print),
            onPressed: () {
              final printer = context.read<PrinterCubit>().state!;
              final language =
                  context.read<PrintLanguageCubit>().state ?? sysLanguage;
              final size = context.read<PaperSizeCubit>().state;
              final orientation = context.read<PageOrientationCubit>().state;
              onPrint(
                data: data,
                language: language,
                pageFormat: size,
                orientation: orientation,
                selectedPrinter: printer,
              );
            },
          ),
          const SizedBox(height: 2),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: ZButton(
                  width: double.infinity,
                  height: 45,
                  label: Text(locale.cancel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Expanded(
                child: ZOutlineButton(
                  width: double.infinity,
                  height: 45,
                  label: Text("PDF"),
                  onPressed: () {
                    final language = context.read<PrintLanguageCubit>().state;
                    final size = context.read<PaperSizeCubit>().state;
                    final orientation = context.read<PageOrientationCubit>().state;
                    onSave(
                      data: data,
                      language: language ?? sysLanguage,
                      pageFormat: size,
                      orientation: orientation,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    final currentLocale = context.watch<LocalizationBloc>();
    String sysLanguage = currentLocale.toString();
    final language = context.watch<PrintLanguageCubit>().state ?? sysLanguage;
    final pageFormat = context.watch<PaperSizeCubit>().state;
    final orientation = context.watch<PageOrientationCubit>().state;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(blurRadius: 1, color: Colors.grey.withValues(alpha: .3)),
          ],
        ),
        child: PdfPreview(
          padding: EdgeInsets.zero,
          useActions: false,
          previewPageMargin: EdgeInsets.zero,
          maxPageWidth: double.infinity,
          dynamicLayout: true,
          shouldRepaint: true,
          canChangeOrientation: true,
          canChangePageFormat: true,
          pdfPreviewPageDecoration: BoxDecoration(color: Colors.white),
          build:
              (context) => buildPreview(
            data: data,
            language: language,
            orientation: orientation,
            pageFormat: pageFormat,
          ).then((doc) => doc.save()),
        ),
      ),
    );
  }
}
