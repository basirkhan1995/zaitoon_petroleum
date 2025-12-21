import 'package:flutter/material.dart';
import '../../../../../../../Features/Generic/zaitoon_drop.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';

/// =======================
///   UNIT ENUM
/// =======================

enum UnitType {
  tn,
  kg,
  m3,
  lb,
  f3;

  String toDatabaseValue() {
    switch (this) {
      case UnitType.tn: return "TN";
      case UnitType.kg: return "KG";
      case UnitType.m3: return "M3";
      case UnitType.lb: return "LB";
      case UnitType.f3: return "F3";
    }
  }

  static UnitType fromDatabaseValue(String value) {
    switch (value) {
      case "TN": return UnitType.tn;
      case "KG": return UnitType.kg;
      case "M3": return UnitType.m3;
      case "LB": return UnitType.lb;
      case "F3": return UnitType.f3;
      default: return UnitType.kg;
    }
  }
}

/// =======================
///   UNIT TRANSLATOR
/// =======================

class UnitTranslator {
  static String getTranslatedUnit(BuildContext context, UnitType unit) {

    switch (unit) {
      case UnitType.tn: return "TN";
      case UnitType.kg: return "KG";
      case UnitType.m3: return "M3";
      case UnitType.lb: return "LB";
      case UnitType.f3: return "F3";
    }
  }

  static String getTranslatedUnitFromDb(BuildContext context, String dbValue) {
    final unit = UnitType.fromDatabaseValue(dbValue);
    return getTranslatedUnit(context, unit);
  }

  static List<Map<String, dynamic>> getTranslatedUnitList(BuildContext context) {
    return UnitType.values.map((unit) {
      return {
        "unit": unit,
        "translatedName": getTranslatedUnit(context, unit),
        "databaseValue": unit.toDatabaseValue(),
      };
    }).toList();
  }
}

/// =======================
///   UNIT DROPDOWN UI
/// =======================

class UnitDropdown extends StatefulWidget {
  final UnitType? selectedUnit;
  final bool? isActive;
  final Function(UnitType) onUnitSelected;

  const UnitDropdown({
    super.key,
    this.isActive,
    this.selectedUnit,
    required this.onUnitSelected,
  });

  @override
  State<UnitDropdown> createState() => _UnitDropdownState();
}

class _UnitDropdownState extends State<UnitDropdown> {
  late UnitType _selectedUnit;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.selectedUnit ?? UnitType.kg;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onUnitSelected(_selectedUnit);
    });
  }

  @override
  void didUpdateWidget(covariant UnitDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedUnit != null &&
        widget.selectedUnit != _selectedUnit) {
      setState(() => _selectedUnit = widget.selectedUnit!);
    }
  }

  void _handleSelected(UnitType unit) {
    setState(() => _selectedUnit = unit);
    widget.onUnitSelected(unit);
  }

  @override
  Widget build(BuildContext context) {
    return ZDropdown<UnitType>(
      disableAction: widget.isActive ?? false,
      title: AppLocalizations.of(context)!.unit,
      items: UnitType.values.toList(),
      itemLabel: (unit) => UnitTranslator.getTranslatedUnit(context, unit),
      selectedItem: _selectedUnit,
      onItemSelected: _handleSelected,
      leadingBuilder: (unit) => Icon(Icons.straighten_rounded, size: 20),
    );
  }
}
