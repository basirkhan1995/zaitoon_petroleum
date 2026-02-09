import 'package:flutter/material.dart';

import '../../../../../../../Features/Generic/zaitoon_drop.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';

enum AttendanceStatusEnum {
  present,
  absent,
  late,
  leave;

  String toDatabaseValue() {
    switch (this) {
      case AttendanceStatusEnum.present:
        return "Present";
      case AttendanceStatusEnum.absent:
        return "Absent";
      case AttendanceStatusEnum.late:
        return "Late";
      case AttendanceStatusEnum.leave:
        return "Leave";
    }
  }

  static AttendanceStatusEnum fromDatabaseValue(String value) {
    switch (value) {
      case "Present":
        return AttendanceStatusEnum.present;
      case "Absent":
        return AttendanceStatusEnum.absent;
      case "Late":
        return AttendanceStatusEnum.late;
      case "Leave":
        return AttendanceStatusEnum.leave;
      default:
        return AttendanceStatusEnum.present;
    }
  }
}

class AttendanceTranslator {
  static String getTranslatedStatus(
      BuildContext context,
      AttendanceStatusEnum status,
      ) {
    final t = AppLocalizations.of(context)!;

    switch (status) {
      case AttendanceStatusEnum.present:
        return t.presentTitle;
      case AttendanceStatusEnum.absent:
        return t.absentTitle;
      case AttendanceStatusEnum.late:
        return t.lateTitle;
      case AttendanceStatusEnum.leave:
        return t.leaveTitle;
    }
  }

  static String getTranslatedFromDb(
      BuildContext context,
      String dbValue,
      ) {
    final status = AttendanceStatusEnum.fromDatabaseValue(dbValue);
    return getTranslatedStatus(context, status);
  }

  static List<Map<String, dynamic>> getStatusList(BuildContext context) {
    return AttendanceStatusEnum.values.map((status) {
      return {
        "status": status,
        "translatedName": getTranslatedStatus(context, status),
        "databaseValue": status.toDatabaseValue(),
      };
    }).toList();
  }
}
class AttendanceDropdown extends StatefulWidget {
  final AttendanceStatusEnum? selectedStatus;
  final Function(AttendanceStatusEnum) onStatusSelected;

  const AttendanceDropdown({
    super.key,
    this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  State<AttendanceDropdown> createState() => _AttendanceDropdownState();
}
class _AttendanceDropdownState extends State<AttendanceDropdown> {
  late AttendanceStatusEnum _selectedStatus;

  @override
  void initState() {
    super.initState();

    _selectedStatus =
        widget.selectedStatus ?? AttendanceStatusEnum.present;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStatusSelected(_selectedStatus);
    });
  }

  @override
  void didUpdateWidget(covariant AttendanceDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedStatus != null &&
        widget.selectedStatus != _selectedStatus) {
      setState(() {
        _selectedStatus = widget.selectedStatus!;
      });
    }
  }

  void _handleSelected(AttendanceStatusEnum status) {
    setState(() => _selectedStatus = status);
    widget.onStatusSelected(status);
  }

  @override
  Widget build(BuildContext context) {
    return ZDropdown<AttendanceStatusEnum>(
      title: AppLocalizations.of(context)!.status,
      items: AttendanceStatusEnum.values.toList(),
      itemLabel: (status) =>
          AttendanceTranslator.getTranslatedStatus(context, status),
      selectedItem: _selectedStatus,
      onItemSelected: _handleSelected,
      leadingBuilder: (status) => _getStatusIcon(status),
    );
  }
  Widget _getStatusIcon(AttendanceStatusEnum status) {
    final icon = switch (status) {
      AttendanceStatusEnum.present => Icons.check_circle_rounded,
      AttendanceStatusEnum.absent => Icons.cancel_rounded,
      AttendanceStatusEnum.late => Icons.access_time_rounded,
      AttendanceStatusEnum.leave => Icons.event_busy_rounded,
    };

    return Icon(icon, size: 20);
  }

}
