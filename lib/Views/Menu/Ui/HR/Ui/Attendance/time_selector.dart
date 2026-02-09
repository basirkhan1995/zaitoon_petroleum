import 'package:flutter/material.dart';

/// ===============================
/// 1️⃣ TIME PICKER FIELD (UI)
/// ===============================
class TimePickerField extends StatefulWidget {
  final String label;
  final String initialTime; // "08:00:00"
  final bool withSeconds;
  final ValueChanged<String> onChanged;

  const TimePickerField({
    super.key,
    required this.label,
    required this.initialTime,
    required this.onChanged,
    this.withSeconds = true,
  });

  @override
  State<TimePickerField> createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<TimePickerField> {
  late String _time;

  @override
  void initState() {
    _time = widget.initialTime;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () async {
            final picked = await selectTime(
              context,
              initialTime: _toTimeOfDay(_time),
              withSeconds: widget.withSeconds,
            );

            if (picked != null) {
              setState(() => _time = picked);
              widget.onChanged(picked);
            }
          },
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: color.outline.withValues(alpha: .4),
              ),
              borderRadius: BorderRadius.circular(3),
              color: color.surface,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _time,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: color.outline,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TimeOfDay _toTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

/// ===============================
/// 2️⃣ TIME PICKER METHOD (FIX)
/// ===============================
Future<String?> selectTime(
    BuildContext context, {
      TimeOfDay? initialTime,
      bool withSeconds = false,
    }) async {
  final picked = await showTimePicker(
    context: context,
    initialTime: initialTime ?? TimeOfDay.now(),
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          alwaysUse24HourFormat: true,
        ),
        child: child!,
      );
    },
  );

  if (picked == null) return null;

  final now = DateTime.now();
  final dateTime = DateTime(
    now.year,
    now.month,
    now.day,
    picked.hour,
    picked.minute,
  );

  return _formatTime(dateTime, withSeconds: withSeconds);
}

/// ===============================
/// 3️⃣ FORMATTER
/// ===============================
String _formatTime(DateTime dt, {bool withSeconds = false}) {
  String two(int n) => n.toString().padLeft(2, '0');

  return withSeconds
      ? '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}'
      : '${two(dt.hour)}:${two(dt.minute)}';
}
