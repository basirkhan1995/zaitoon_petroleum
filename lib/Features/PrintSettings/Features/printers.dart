import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../Localizations/l10n/translations/app_localizations.dart';
import '../../Generic/generic_drop.dart';

class PrinterDropdown extends StatefulWidget {
  final Function(Printer) onPrinterSelected;

  const PrinterDropdown({super.key, required this.onPrinterSelected});

  @override
  State<PrinterDropdown> createState() => _PrinterDropdownState();
}

class _PrinterDropdownState extends State<PrinterDropdown> {
  List<Printer> _printers = [];
  Printer? _selectedPrinter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPrinters();
  }

  Future<void> _fetchPrinters() async {
    final printers = await Printing.listPrinters();
    if (mounted) {
      setState(() {
        _printers = printers;
        _selectedPrinter = printers.isNotEmpty ? printers.first : null; // Default to first printer
        _isLoading = false;
      });

      if (_selectedPrinter != null) {
        widget.onPrinterSelected(_selectedPrinter!);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return CustomDropdown<Printer>(
      title: AppLocalizations.of(context)!.printers,
      isLoading: _isLoading,
      initialValue: _selectedPrinter?.name ?? "No printers available",
      items: _printers,
      itemLabel: (printer) => printer.name,
      onItemSelected: (printer) {
        setState(() {
          _selectedPrinter = printer;
        });
        widget.onPrinterSelected(printer);
      },
    );
  }
}