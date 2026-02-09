import 'package:flutter/material.dart';

import '../../Localizations/l10n/translations/app_localizations.dart';

enum AttendanceStatus {
  present,
  absent,
  late,
  leave,
}
AttendanceStatus attendanceStatusFromApi(String? value) {
  switch (value?.toLowerCase()) {
    case 'present':
      return AttendanceStatus.present;
    case 'absent':
      return AttendanceStatus.absent;
    case 'late':
      return AttendanceStatus.late;
    case 'leave':
      return AttendanceStatus.leave;
    default:
      return AttendanceStatus.present;
  }
}
class AttendanceStatusConfig {
  final Color bgColor;
  final Color textColor;
  final IconData icon;
  final String title;

  const AttendanceStatusConfig({
    required this.bgColor,
    required this.textColor,
    required this.icon,
    required this.title,
  });

  static AttendanceStatusConfig fromStatus(
      AttendanceStatus status,
      AppLocalizations tr,
      ) {
    switch (status) {
      case AttendanceStatus.present:
        return AttendanceStatusConfig(
          bgColor: const Color(0xFFE8F5E9),
          textColor: const Color(0xFF2E7D32),
          icon: Icons.check_circle_rounded,
          title: tr.presentTitle,
        );

      case AttendanceStatus.absent:
        return AttendanceStatusConfig(
          bgColor: const Color(0xFFFDECEA),
          textColor: const Color(0xFFD32F2F),
          icon: Icons.cancel_rounded,
          title: tr.absentTitle,
        );

      case AttendanceStatus.late:
        return AttendanceStatusConfig(
          bgColor: const Color(0xFFFFF8E1),
          textColor: const Color(0xFFF9A825),
          icon: Icons.schedule_rounded,
          title: tr.lateTitle,
        );

      case AttendanceStatus.leave:
        return AttendanceStatusConfig(
          bgColor: const Color(0xFFE3F2FD),
          textColor: const Color(0xFF1565C0),
          icon: Icons.event_available_rounded,
          title: tr.leaveTitle,
        );
    }
  }
}
class AttendanceStatusBadge extends StatelessWidget {
  /// API value: "Present", "Absent", "Late", "Leave"
  final String status;

  const AttendanceStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    final enumStatus = attendanceStatusFromApi(status);
    final config = AttendanceStatusConfig.fromStatus(enumStatus, tr);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: config.textColor.withValues(alpha: .4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: 14,
            color: config.textColor,
          ),
          const SizedBox(width: 6),
          Text(
            config.title,
            style: TextStyle(
              color: config.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
