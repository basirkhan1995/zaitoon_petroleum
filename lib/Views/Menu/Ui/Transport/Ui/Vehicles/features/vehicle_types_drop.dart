import 'package:flutter/material.dart';
import '../../../../../../../Features/Generic/custom_filter_drop.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';

/// =======================
///   VehicleType ENUM
/// =======================

enum VehicleType {
  truck,
  tanker,
  trailer,
  pickup,
  van,
  bus,
  minivan,
  sedan,
  suv,
  motorcycle,
  threeWheeler,
  ambulance,
  fireTruck,
  tractor,
  refrigeratedTruck;

  String toDatabaseValue() {
    switch (this) {
      case VehicleType.truck: return "Truck";
      case VehicleType.tanker: return "Tanker";
      case VehicleType.trailer: return "Trailer";
      case VehicleType.pickup: return "Pickup";
      case VehicleType.van: return "Van";
      case VehicleType.bus: return "Bus";
      case VehicleType.minivan: return "Minivan";
      case VehicleType.sedan: return "Sedan";
      case VehicleType.suv: return "SUV";
      case VehicleType.motorcycle: return "Motorcycle";
      case VehicleType.threeWheeler: return "Three-Wheeler";
      case VehicleType.ambulance: return "Ambulance";
      case VehicleType.fireTruck: return "Fire Truck";
      case VehicleType.tractor: return "Tractor";
      case VehicleType.refrigeratedTruck: return "Refrigerated Truck";
    }
  }

  static VehicleType fromDatabaseValue(String value) {
    switch (value) {
      case "Truck": return VehicleType.truck;
      case "Tanker": return VehicleType.tanker;
      case "Trailer": return VehicleType.trailer;
      case "Pickup": return VehicleType.pickup;
      case "Van": return VehicleType.van;
      case "Bus": return VehicleType.bus;
      case "Minivan": return VehicleType.minivan;
      case "Sedan": return VehicleType.sedan;
      case "SUV": return VehicleType.suv;
      case "Motorcycle": return VehicleType.motorcycle;
      case "Three-Wheeler": return VehicleType.threeWheeler;
      case "Ambulance": return VehicleType.ambulance;
      case "Fire Truck": return VehicleType.fireTruck;
      case "Tractor": return VehicleType.tractor;
      case "Refrigerated Truck": return VehicleType.refrigeratedTruck;
      default: return VehicleType.truck;
    }
  }
}

/// =======================
/// Vehicle Translator
/// =======================

class VehicleTranslator {
  static String getTranslatedVehicle(BuildContext context, VehicleType type) {
    final t = AppLocalizations.of(context)!;

    switch (type) {
      case VehicleType.truck: return t.truck;
      case VehicleType.tanker: return t.tanker;
      case VehicleType.trailer: return t.trailer;
      case VehicleType.pickup: return t.pickup;
      case VehicleType.van: return t.van;
      case VehicleType.bus: return t.bus;
      case VehicleType.minivan: return t.miniVan;
      case VehicleType.sedan: return t.sedan;
      case VehicleType.suv: return t.suv;
      case VehicleType.motorcycle: return t.motorcycle;
      case VehicleType.threeWheeler: return t.rickshaw;
      case VehicleType.ambulance: return t.ambulance;
      case VehicleType.fireTruck: return t.fireTruck;
      case VehicleType.tractor: return t.tractor;
      case VehicleType.refrigeratedTruck: return t.refrigeratedTruck;
    }
  }

  static String getTranslatedVehicleFromDb(BuildContext context, String dbValue) {
    final type = VehicleType.fromDatabaseValue(dbValue);
    return getTranslatedVehicle(context, type);
  }

  static List<Map<String, dynamic>> getTranslatedVehicleList(BuildContext context) {
    return VehicleType.values.map((type) {
      return {
        "vehicle": type,
        "translatedName": getTranslatedVehicle(context, type),
        "databaseValue": type.toDatabaseValue(),
      };
    }).toList();
  }
}

/// =======================
/// Vehicle Dropdown UI
/// =======================

class VehicleDropdown extends StatefulWidget {
  final VehicleType? selectedVehicle;
  final Function(VehicleType) onVehicleSelected;

  const VehicleDropdown({
    super.key,
    this.selectedVehicle,
    required this.onVehicleSelected,
  });

  @override
  State<VehicleDropdown> createState() => _VehicleDropdownState();
}

class _VehicleDropdownState extends State<VehicleDropdown> {
  late VehicleType _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.selectedVehicle ?? VehicleType.values.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onVehicleSelected(_selectedVehicle);
    });
  }

  @override
  void didUpdateWidget(covariant VehicleDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedVehicle != null && widget.selectedVehicle != _selectedVehicle) {
      setState(() {
        _selectedVehicle = widget.selectedVehicle!;
      });
    }
  }

  void _handleSelected(VehicleType type) {
    setState(() => _selectedVehicle = type);
    widget.onVehicleSelected(type);
  }

  @override
  Widget build(BuildContext context) {
    return ZDropdown<VehicleType>(
      title: AppLocalizations.of(context)!.vehicleType,
      items: VehicleType.values.toList(),
      itemLabel: (type) => VehicleTranslator.getTranslatedVehicle(context, type),
      selectedItem: _selectedVehicle,
      onItemSelected: _handleSelected,
      leadingBuilder: (type) => _getVehicleIcon(type),
    );
  }

  Widget _getVehicleIcon(VehicleType type) {
    final icon = switch (type) {
      VehicleType.truck => Icons.local_shipping_rounded,
      VehicleType.tanker => Icons.oil_barrel_rounded,
      VehicleType.trailer => Icons.train_rounded,
      VehicleType.pickup => Icons.car_rental_rounded,
      VehicleType.van => Icons.directions_bus_filled_rounded,
      VehicleType.bus => Icons.directions_bus_rounded,
      VehicleType.minivan => Icons.airport_shuttle_rounded,
      VehicleType.sedan => Icons.directions_car_rounded,
      VehicleType.suv => Icons.sports_motorsports_rounded,
      VehicleType.motorcycle => Icons.motorcycle_rounded,
      VehicleType.threeWheeler => Icons.electric_rickshaw_rounded,
      VehicleType.ambulance => Icons.local_hospital_rounded,
      VehicleType.fireTruck => Icons.fire_truck_rounded,
      VehicleType.tractor => Icons.agriculture_rounded,
      VehicleType.refrigeratedTruck => Icons.ac_unit_rounded,
    };

    return Icon(icon, size: 20);
  }
}