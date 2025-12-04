import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class PrintPreviewDialog<T> extends StatefulWidget {
  final T data;
  final ReportModel company;

  final Future<pw.Document> Function({
  required T data,
  required String language,
  required pw.PageOrientation orientation,
  required PdfPageFormat pageFormat,
  }) buildPreview;

  final Future<void> Function({
  required T data,
  required String language,
  required pw.PageOrientation orientation,
  required PdfPageFormat pageFormat,
  required Printer selectedPrinter,
  required int copies,
  required String pages, // Added pages parameter
  }) onPrint;

  final Future<void> Function({
  required T data,
  required String language,
  required pw.PageOrientation orientation,
  required PdfPageFormat pageFormat,
  }) onSave;

  const PrintPreviewDialog({
    super.key,
    required this.company,
    required this.data,
    required this.buildPreview,
    required this.onPrint,
    required this.onSave,
  });

  @override
  State<PrintPreviewDialog<T>> createState() => _PrintPreviewDialogState<T>();
}

class _PrintPreviewDialogState<T> extends State<PrintPreviewDialog<T>> {
  late TextEditingController _copiesController;
  late TextEditingController _pagesController;
  int copies = 1;
  String pages = "all"; // Added pages state

  @override
  void initState() {
    super.initState();
    _copiesController = TextEditingController(text: "1");
    _pagesController = TextEditingController(text: ""); // Initialize pages controller
  }

  @override
  void dispose() {
    _copiesController.dispose();
    _pagesController.dispose(); // Dispose pages controller
    super.dispose();
  }

  void updateCopies(int value, {bool fromTyping = false}) {
    if (value < 1) value = 1;
    if (value > 200) value = 200;

    setState(() {
      copies = value;

      // Only update controller text if NOT typing manually
      if (!fromTyping) {
        _copiesController.text = value.toString();
        _copiesController.selection = TextSelection.collapsed(
          offset: _copiesController.text.length,
        );
      }
    });
  }

  void updatePages(String value) {
    setState(() {
      pages = value.trim().isEmpty ? "all" : value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.zero,
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

  // ---------------------------------------------------------------------------
  // PAGES FIELD
  // ---------------------------------------------------------------------------
  Widget _buildPagesField(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.pages,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: .5),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextFormField(
              controller: _pagesController,
              decoration: const InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: InputBorder.none,
                hintText: '',
              ),
              onChanged: (value) {
                updatePages(value);
              },
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '1,3,5 or 1-3 or 1,3-5,7',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .6),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SIDEBAR
  // ---------------------------------------------------------------------------
  Widget _buildSidebar(BuildContext context, AppLocalizations locale) {
    final currentLocale = context.watch<LocalizationBloc>();
    String sysLanguage = currentLocale.toString();

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ],
      ),
      child: Column(
        spacing: 5,
        children: [
          Row(
            spacing: 5,
            children: [
              Icon(Icons.print_rounded,color: Theme.of(context).colorScheme.outline,),
              Text(locale.print,style: Theme.of(context).textTheme.titleMedium,)
            ],
          ),
          SizedBox(height: 5), // Add some spacing
          Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _buildCopiesField(context)),
              Expanded(
                child: ZOutlineButton(
                  isActive: true,
                  width: double.infinity,
                  backgroundHover: Theme.of(context).colorScheme.primary,
                  height: 40,
                  icon: Icons.print,
                  label: Text(locale.print),
                  onPressed: () {
                    final printer = context.read<PrinterCubit>().state!;
                    final language =
                        context.read<PrintLanguageCubit>().state ?? sysLanguage;
                    final size = context.read<PaperSizeCubit>().state;
                    final orientation = context.read<PageOrientationCubit>().state;

                    widget.onPrint(
                      data: widget.data,
                      language: language,
                      pageFormat: size,
                      orientation: orientation,
                      selectedPrinter: printer,
                      copies: copies,
                      pages: pages, // Added pages parameter
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          PrinterDropdown(
            onPrinterSelected: (value) => context.read<PrinterCubit>().setPrinter(value),
          ),
          const SizedBox(height: 1),
          PageFormatDropdown(
            onFormatSelected: (format) => context.read<PaperSizeCubit>().setPaperSize(format),
          ),
          const SizedBox(height: 1),

          PageOrientationDropdown(
            onOrientationSelected: (orientation) =>
                context.read<PageOrientationCubit>().setOrientation(orientation),
          ),
          const SizedBox(height: 1),

          LanguageDropdown(
            onLanguageSelected: (value) =>
                context.read<PrintLanguageCubit>().setLanguage(value.code),
          ),
          const Spacer(),
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
                  icon: FontAwesomeIcons.solidFilePdf,
                  label: Text("PDF"),
                  onPressed: () {
                    final language =
                        context.read<PrintLanguageCubit>().state ?? sysLanguage;
                    final size = context.read<PaperSizeCubit>().state;
                    final orientation =
                        context.read<PageOrientationCubit>().state;

                    widget.onSave(
                      data: widget.data,
                      language: language,
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

  // ---------------------------------------------------------------------------
  // COPIES FIELD
  // ---------------------------------------------------------------------------
  Widget _buildCopiesField(BuildContext context) {
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.copies,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),

        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: .5),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                  child: TextFormField(
                    controller: _copiesController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(3),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      constraints: BoxConstraints(),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) return;

                      int val = int.tryParse(value) ?? 1;

                      // Enforce max 200
                      if (val > 200) {
                        val = 200;
                        _copiesController.text = "200";
                        _copiesController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _copiesController.text.length),
                        );
                      }

                      updateCopies(val, fromTyping: true);
                    },
                  )
              ),

              Container(
                  width: 30,
                  decoration: BoxDecoration(
                    border: Border(
                      // Handle both LTR and RTL directions
                      left: isRTL ? BorderSide.none : BorderSide(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: .5),
                      ),
                      right: isRTL ? BorderSide(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: .5),
                      ) : BorderSide.none,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Material(
                          child: InkWell(
                            onTap: () => updateCopies(copies + 1),
                            hoverColor: Theme.of(context).colorScheme.outline.withValues(alpha: .1),
                            child: Center(
                              child: Icon(Icons.arrow_drop_up, size: 16),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Material(
                          child: InkWell(
                            onTap: () => updateCopies(copies - 1),
                            hoverColor: Theme.of(context).colorScheme.outline.withValues(alpha: .1),
                            child: Center(
                              child: Icon(Icons.arrow_drop_down, size: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PREVIEW PANEL
  // ---------------------------------------------------------------------------
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
            BoxShadow(
              blurRadius: 1,
              color: Colors.grey.withValues(alpha: .3),
            ),
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
          pdfPreviewPageDecoration: const BoxDecoration(color: Colors.white),
          build: (context) => widget.buildPreview(
            data: widget.data,
            language: language,
            orientation: orientation,
            pageFormat: pageFormat,
          )
              .then((doc) => doc.save()),
        ),
      ),
    );
  }
}