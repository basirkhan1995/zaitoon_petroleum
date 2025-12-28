import 'package:flutter/material.dart';
import '../../../../../../../Features/Generic/zaitoon_drop.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';

/// =======================
///   VehicleOwnership ENUM
/// =======================

enum VehicleOwnership {
  owned,
  rental,
  lease;

  /// Exact DB values
  String toDatabaseValue() {
    switch (this) {
      case VehicleOwnership.owned: return "Owned";
      case VehicleOwnership.rental: return "Rental";
      case VehicleOwnership.lease: return "Lease";
    }
  }

  /// Parse from DB string back to Enum
  static VehicleOwnership fromDatabaseValue(String value) {
    switch (value) {
      case "Owned": return VehicleOwnership.owned;
      case "Rental": return VehicleOwnership.rental;
      case "Lease": return VehicleOwnership.lease;
      default: return VehicleOwnership.owned;
    }
  }
}

/// =======================
/// Ownership Translator
/// =======================

class OwnershipTranslator {
  static String getTranslatedOwnership(BuildContext context, VehicleOwnership own) {
    final t = AppLocalizations.of(context)!;

    switch (own) {
      case VehicleOwnership.owned: return t.owned;
      case VehicleOwnership.rental: return t.rental;
      case VehicleOwnership.lease: return t.lease;
    }
  }

  static String getTranslatedOwnershipFromDb(BuildContext context, String dbValue) {
    final own = VehicleOwnership.fromDatabaseValue(dbValue);
    return getTranslatedOwnership(context, own);
  }

  static List<Map<String, dynamic>> getTranslatedOwnershipList(BuildContext context) {
    return VehicleOwnership.values.map((own) {
      return {
        "ownership": own,
        "translatedName": getTranslatedOwnership(context, own),
        "databaseValue": own.toDatabaseValue(),
      };
    }).toList();
  }
}

/// =======================
/// Ownership Dropdown UI
/// =======================

class OwnershipDropdown extends StatefulWidget {
  final String? selectedOwnership; // Changed from VehicleOwnership? to String?
  final Function(VehicleOwnership) onOwnershipSelected;

  const OwnershipDropdown({
    super.key,
    this.selectedOwnership,
    required this.onOwnershipSelected,
  });

  @override
  State<OwnershipDropdown> createState() => _OwnershipDropdownState();
}

class _OwnershipDropdownState extends State<OwnershipDropdown> {
  late VehicleOwnership _selectedOwnership;

  @override
  void initState() {
    super.initState();
    // Convert string to enum
    _selectedOwnership = widget.selectedOwnership != null
        ? VehicleOwnership.fromDatabaseValue(widget.selectedOwnership!)
        : VehicleOwnership.values.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onOwnershipSelected(_selectedOwnership);
    });
  }

  @override
  void didUpdateWidget(covariant OwnershipDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedOwnership != null &&
        VehicleOwnership.fromDatabaseValue(widget.selectedOwnership!) != _selectedOwnership) {
      setState(() {
        _selectedOwnership = VehicleOwnership.fromDatabaseValue(widget.selectedOwnership!);
      });
    }
  }

  void _handleSelected(VehicleOwnership own) {
    setState(() => _selectedOwnership = own);
    widget.onOwnershipSelected(own);
  }

  @override
  Widget build(BuildContext context) {
    return ZDropdown<VehicleOwnership>(
      title: AppLocalizations.of(context)!.ownership,
      items: VehicleOwnership.values.toList(),
      itemLabel: (own) => OwnershipTranslator.getTranslatedOwnership(context, own),
      selectedItem: _selectedOwnership,
      onItemSelected: _handleSelected,
      leadingBuilder: (own) => _getOwnershipIcon(own),
    );
  }

  Widget _getOwnershipIcon(VehicleOwnership own) {
    final icon = switch (own) {
      VehicleOwnership.owned => Icons.verified_rounded,
      VehicleOwnership.rental => Icons.car_rental_rounded,
      VehicleOwnership.lease => Icons.assignment_rounded,
    };

    return Icon(icon, size: 20);
  }
}