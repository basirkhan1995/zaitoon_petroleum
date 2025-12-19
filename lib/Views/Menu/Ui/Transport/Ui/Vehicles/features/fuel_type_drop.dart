import 'package:flutter/material.dart';
import '../../../../../../../Features/Generic/zaitoon_drop.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';

/// =======================
///   FuelType ENUM
/// =======================

enum FuelType {
  petrol,
  diesel,
  cng,
  lpg,
  electric,
  hydrogen;

  String toDatabaseValue() {
    switch (this) {
      case FuelType.petrol: return "Petrol";
      case FuelType.diesel: return "Diesel";
      case FuelType.cng: return "CNG";
      case FuelType.lpg: return "LPG";
      case FuelType.electric: return "Electric";
      case FuelType.hydrogen: return "Hydrogen";
    }
  }

  static FuelType fromDatabaseValue(String value) {
    switch (value) {
      case "Petrol": return FuelType.petrol;
      case "Diesel": return FuelType.diesel;
      case "CNG": return FuelType.cng;
      case "LPG": return FuelType.lpg;
      case "Electric": return FuelType.electric;
      case "Hydrogen": return FuelType.hydrogen;
      default: return FuelType.petrol;
    }
  }
}

/// =======================
/// Fuel Translator
/// =======================

class FuelTranslator {
  static String getTranslatedFuel(BuildContext context, FuelType type) {
    final t = AppLocalizations.of(context)!;

    switch (type) {
      case FuelType.petrol: return t.petrol;
      case FuelType.diesel: return t.diesel;
      case FuelType.cng: return t.cngGas;
      case FuelType.lpg: return t.lpgGass;
      case FuelType.electric: return t.electric;
      case FuelType.hydrogen: return t.hydrogen;
    }
  }

  static String getTranslatedFuelFromDb(BuildContext context, String dbValue) {
    final type = FuelType.fromDatabaseValue(dbValue);
    return getTranslatedFuel(context, type);
  }

  static List<Map<String, dynamic>> getTranslatedFuelList(BuildContext context) {
    return FuelType.values.map((type) {
      return {
        "fuel": type,
        "translatedName": getTranslatedFuel(context, type),
        "databaseValue": type.toDatabaseValue(),
      };
    }).toList();
  }
}

/// =======================
/// Fuel Dropdown UI
/// =======================

class FuelDropdown extends StatefulWidget {
  final FuelType? selectedFuel;
  final Function(FuelType) onFuelSelected;

  const FuelDropdown({
    super.key,
    this.selectedFuel,
    required this.onFuelSelected,
  });

  @override
  State<FuelDropdown> createState() => _FuelDropdownState();
}

class _FuelDropdownState extends State<FuelDropdown> {
  late FuelType _selectedFuel;

  @override
  void initState() {
    super.initState();
    _selectedFuel = widget.selectedFuel ?? FuelType.values.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFuelSelected(_selectedFuel);
    });
  }

  @override
  void didUpdateWidget(covariant FuelDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedFuel != null && widget.selectedFuel != _selectedFuel) {
      setState(() {
        _selectedFuel = widget.selectedFuel!;
      });
    }
  }

  void _handleSelected(FuelType type) {
    setState(() => _selectedFuel = type);
    widget.onFuelSelected(type);
  }

  @override
  Widget build(BuildContext context) {
    return ZDropdown<FuelType>(
      title: AppLocalizations.of(context)!.fuelType,
      items: FuelType.values.toList(),
      itemLabel: (type) => FuelTranslator.getTranslatedFuel(context, type),
      selectedItem: _selectedFuel,
      onItemSelected: _handleSelected,
      leadingBuilder: (type) => _getFuelIcon(type),
    );
  }

  Widget _getFuelIcon(FuelType type) {
    final icon = switch (type) {
      FuelType.petrol => Icons.local_gas_station_rounded,
      FuelType.diesel => Icons.local_gas_station,
      FuelType.cng => Icons.propane_tank_rounded,
      FuelType.lpg => Icons.propane_rounded,
      FuelType.electric => Icons.battery_charging_full_rounded,
      FuelType.hydrogen => Icons.science_rounded,
    };

    return Icon(icon, size: 20);
  }
}