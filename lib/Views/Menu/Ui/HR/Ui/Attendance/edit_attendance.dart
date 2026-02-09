// edit_attendance_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Attendance/bloc/attendance_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Attendance/model/attendance_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Attendance/time_selector.dart';

class EditAttendanceDialog extends StatefulWidget {
  final AttendanceRecord record;
  final String currentDate;

  const EditAttendanceDialog({
    super.key,
    required this.record,
    required this.currentDate,
  });

  @override
  State<EditAttendanceDialog> createState() => _EditAttendanceDialogState();
}

class _EditAttendanceDialogState extends State<EditAttendanceDialog> {
  late String checkIn;
  late String checkOut;
  late String status;

  // Status options
  final List<String> statusOptions = [
    'Present',
    'Late',
    'Absent',
  ];

  @override
  void initState() {
    super.initState();
    checkIn = widget.record.emaCheckedIn ?? "08:00:00";
    checkOut = widget.record.emaCheckedOut ?? "16:00:00";
    status = widget.record.emaStatus ?? "Present";
  }

  void _updateAttendance() {
    final updatedRecord = AttendanceRecord(
      usrName: widget.record.usrName,
      emaId: widget.record.emaId,
      emaEmployee: widget.record.emaEmployee,
      fullName: widget.record.fullName,
      emaCheckedIn: checkIn,
      emaCheckedOut: checkOut,
      emaStatus: status,
      emaDate: widget.record.emaDate ?? widget.currentDate,
      empPosition: widget.record.empPosition,
    );

    // Create AttendanceModel with updated record
    final attendanceModel = AttendanceModel(
      usrName: widget.record.usrName,
      records: [updatedRecord],
    );

    // Dispatch update event
    context.read<AttendanceBloc>().add(
      UpdateAttendanceEvent(attendanceModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceErrorState) {
          // Show error message
          Utils.showOverlayMessage(context, message: state.message, isError: true);
        } else if (state is AttendanceLoadedState) {
          // Close dialog on success
          Navigator.of(context).pop();
        }
      },
      child: ZFormDialog(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        icon: Icons.edit,
        title: "${tr.edit} - ${widget.record.fullName}",

        onAction: _updateAttendance,

        actionLabel: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            final isLoading = state is AttendanceSilentLoadingState;

            if (isLoading) {
              return const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }

            return Text(tr.update);
          },
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Employee Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: .2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.record.fullName ?? "",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  if (widget.record.empPosition != null)
                    Text(
                      widget.record.empPosition!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    widget.record.emaDate?.compact ?? widget.currentDate.compact,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Check-in Time
            TimePickerField(
              label: tr.checkIn,
              initialTime: checkIn,
              onChanged: (time) {
                if (time.isNotEmpty) {
                  setState(() => checkIn = time);
                }
              },
            ),

            const SizedBox(height: 12),

            // Check-out Time
            TimePickerField(
              label: tr.checkOut,
              initialTime: checkOut,
              onChanged: (time) {
                if (time.isNotEmpty) {
                  setState(() => checkOut = time);
                }
              },
            ),

            const SizedBox(height: 15),

            // Status Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: tr.status,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              initialValue: status,
              items: statusOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => status = newValue);
                }
              },
            ),

            const SizedBox(height: 16),

            // Current Values Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: .2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr.currentValues,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${tr.checkIn}: ${widget.record.emaCheckedIn ?? '--:--:--'}"),
                      Text("${tr.checkOut}: ${widget.record.emaCheckedOut ?? '--:--:--'}"),
                      Text("${tr.status}: ${widget.record.emaStatus ?? '--'}"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}