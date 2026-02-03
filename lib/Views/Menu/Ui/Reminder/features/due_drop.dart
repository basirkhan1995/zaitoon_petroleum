import 'package:flutter/material.dart';

import '../../../../../Features/Generic/zaitoon_drop.dart';
import '../../../../../Localizations/l10n/translations/app_localizations.dart';

enum DueType {
  payable,
  receivable;

  /// Value stored in database
  String toDatabaseValue() {
    switch (this) {
      case DueType.payable:
        return "Payable";
      case DueType.receivable:
        return "Receivable";
    }
  }

  /// Convert database value back to enum
  static DueType fromDatabaseValue(String value) {
    switch (value) {
      case "Payable":
        return DueType.payable;
      case "Receivable":
        return DueType.receivable;
      default:
        return DueType.payable;
    }
  }
}

class DueTypeTranslator {
  /// UI Translation only
  static String getTranslatedDueType(
      BuildContext context, DueType type) {
    final t = AppLocalizations.of(context)!;

    switch (type) {
      case DueType.payable:
        return t.payableDue;
      case DueType.receivable:
        return t.receivableDue;
    }
  }

  static String getTranslatedDueTypeFromDb(
      BuildContext context, String dbValue) {
    final type = DueType.fromDatabaseValue(dbValue);
    return getTranslatedDueType(context, type);
  }

  static List<Map<String, dynamic>> getTranslatedDueTypeList(
      BuildContext context) {
    return DueType.values.map((type) {
      return {
        "dueType": type,
        "translatedName": getTranslatedDueType(context, type),
        "databaseValue": type.toDatabaseValue(),
      };
    }).toList();
  }
}

class DueTypeDropdown extends StatefulWidget {
  final DueType? selectedDueType;
  final Function(DueType) onDueTypeSelected;

  const DueTypeDropdown({
    super.key,
    this.selectedDueType,
    required this.onDueTypeSelected,
  });

  @override
  State<DueTypeDropdown> createState() => _DueTypeDropdownState();
}

class _DueTypeDropdownState extends State<DueTypeDropdown> {
  late DueType _selectedDueType;

  @override
  void initState() {
    super.initState();
    _selectedDueType = widget.selectedDueType ?? DueType.values.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDueTypeSelected(_selectedDueType);
    });
  }

  @override
  void didUpdateWidget(covariant DueTypeDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedDueType != null &&
        widget.selectedDueType != _selectedDueType) {
      setState(() {
        _selectedDueType = widget.selectedDueType!;
      });
    }
  }

  void _handleSelected(DueType type) {
    setState(() => _selectedDueType = type);
    widget.onDueTypeSelected(type);
  }

  @override
  Widget build(BuildContext context) {
    return ZDropdown<DueType>(
      title: AppLocalizations.of(context)!.dueType,
      items: DueType.values.toList(),
      itemLabel: (type) =>
          DueTypeTranslator.getTranslatedDueType(context, type),
      selectedItem: _selectedDueType,
      onItemSelected: _handleSelected,
      leadingBuilder: (type) => _getDueTypeIcon(type),
    );
  }

  Widget _getDueTypeIcon(DueType type) {
    final icon = switch (type) {
      DueType.payable => Icons.arrow_upward_rounded,
      DueType.receivable => Icons.arrow_downward_rounded,
    };

    return Icon(
      icon,
      size: 20,
      color: type == DueType.payable ? Colors.red : Colors.green,
    );
  }
}
