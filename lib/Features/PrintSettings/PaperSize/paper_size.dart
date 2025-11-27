import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart' as pw;
import '../../../Localizations/l10n/translations/app_localizations.dart';
import '../../Generic/generic_drop.dart';


class PdfFormatHelper {

  static const List<pw.PdfPageFormat> availableFormats = [
    pw.PdfPageFormat.a4,
    pw.PdfPageFormat.a5,
    pw.PdfPageFormat.letter,
    pw.PdfPageFormat.roll80,
  ];

  static String getDisplayName(pw.PdfPageFormat format) {
    if (format == pw.PdfPageFormat.a4) return 'A4 (210 × 297 mm)';
    if (format == pw.PdfPageFormat.a5) return 'A5 (148 × 210 mm)';
    if (format == pw.PdfPageFormat.letter) return 'Letter (216 × 279 mm)';
    //if (format == pw.PdfPageFormat.roll80) return 'Roll (80 mm)';
    return 'Custom Size';
  }
}

class PageFormatDropdown extends StatefulWidget {
  final Function(pw.PdfPageFormat) onFormatSelected;
  final pw.PdfPageFormat? initialFormat;

  const PageFormatDropdown({
    super.key,
    required this.onFormatSelected,
    this.initialFormat,
  });

  @override
  State<PageFormatDropdown> createState() => _PageFormatDropdownState();
}

class _PageFormatDropdownState extends State<PageFormatDropdown> {
  late pw.PdfPageFormat _selectedFormat;

  @override
  void initState() {
    super.initState();
    _selectedFormat = widget.initialFormat ?? pw.PdfPageFormat.a4;
  }

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<pw.PdfPageFormat>(
      title: AppLocalizations.of(context)!.paper,
      items: PdfFormatHelper.availableFormats,
      initialValue: PdfFormatHelper.getDisplayName(_selectedFormat),
      itemLabel: (format) => PdfFormatHelper.getDisplayName(format),
      onItemSelected: (selected) {
        setState(() {
          _selectedFormat = selected;
        });
        widget.onFormatSelected(selected);
      },
    );
  }
}