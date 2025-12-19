import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../../Features/Generic/zaitoon_drop.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';

/// ─────────────────────────────────────────────────────────────
/// 1️⃣ DateTime extension
/// ─────────────────────────────────────────────────────────────
extension DateFormatX on DateTime {
  String toFormattedDate() {
    return DateFormat('yyyy-MM-dd').format(this);
  }
}

/// ─────────────────────────────────────────────────────────────
/// 2️⃣ Date range enum
/// ─────────────────────────────────────────────────────────────
enum DateRangeType {
  today,
  yesterday,
  lastWeek,
  last30Days,
  lastMonth,
}

/// ─────────────────────────────────────────────────────────────
/// 3️⃣ Date range model
/// ─────────────────────────────────────────────────────────────
class DateRangeItem {
  final DateRangeType type;
  final String label;

  DateRangeItem(this.type, this.label);
}

/// ─────────────────────────────────────────────────────────────
/// 4️⃣ Date range result
/// ─────────────────────────────────────────────────────────────
class DateRangeResult {
  final String fromDate;
  final String toDate;

  DateRangeResult(this.fromDate, this.toDate);
}

/// ─────────────────────────────────────────────────────────────
/// 5️⃣ Date range resolver (BUSINESS LOGIC)
/// ─────────────────────────────────────────────────────────────
DateRangeResult resolveDateRange(DateRangeType type) {
  final now = DateTime.now();

  late DateTime from;
  late DateTime to;

  switch (type) {
    case DateRangeType.today:
      from = DateTime(now.year, now.month, now.day);
      to = now;
      break;

    case DateRangeType.yesterday:
      final y = now.subtract(const Duration(days: 1));
      from = DateTime(y.year, y.month, y.day);
      to = DateTime(y.year, y.month, y.day, 23, 59, 59);
      break;

    case DateRangeType.lastWeek:
      from = now.subtract(const Duration(days: 7));
      to = now;
      break;

    case DateRangeType.last30Days:
      from = now.subtract(const Duration(days: 30));
      to = now;
      break;

    case DateRangeType.lastMonth:
      final firstThisMonth = DateTime(now.year, now.month, 1);
      final lastMonthEnd = firstThisMonth.subtract(const Duration(days: 1));
      from = DateTime(lastMonthEnd.year, lastMonthEnd.month, 1);
      to = DateTime(
        lastMonthEnd.year,
        lastMonthEnd.month,
        lastMonthEnd.day,
        23,
        59,
        59,
      );
      break;
  }

  return DateRangeResult(
    from.toFormattedDate(),
    to.toFormattedDate(),
  );
}

/// ─────────────────────────────────────────────────────────────
/// 6️⃣ DateRangeDropdown (USES YOUR ZDropdown)
/// ─────────────────────────────────────────────────────────────
class DateRangeDropdown extends StatefulWidget {
  final double height;
  final bool disableAction;
  final void Function(String fromDate, String toDate) onChanged;

  const DateRangeDropdown({
    super.key,
    required this.onChanged,
    this.height = 40,
    this.disableAction = false,
  });

  @override
  State<DateRangeDropdown> createState() => _DateRangeDropdownState();
}

class _DateRangeDropdownState extends State<DateRangeDropdown> {
  late List<DateRangeItem> items;
  DateRangeItem? selected;

  String fromDate = DateTime.now().toFormattedDate();
  String toDate = DateTime.now().toFormattedDate();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final loc = AppLocalizations.of(context)!;

    items = [
      DateRangeItem(DateRangeType.today, loc.today),
      DateRangeItem(DateRangeType.yesterday, loc.yesterday),
      DateRangeItem(DateRangeType.lastWeek, loc.lastWeek),
      DateRangeItem(DateRangeType.last30Days, loc.last30Days),
     // DateRangeItem(DateRangeType.lastMonth, loc.lastMonth),
    ];

    selected ??= items.first;
    _applyRange(selected!);
  }

  void _applyRange(DateRangeItem item) {
    final result = resolveDateRange(item.type);

    setState(() {
      selected = item;
      fromDate = result.fromDate;
      toDate = result.toDate;
    });

    widget.onChanged(fromDate, toDate);
  }

  @override
  Widget build(BuildContext context) {
    return ZDropdown<DateRangeItem>(
      title: AppLocalizations.of(context)!.dateRange,
      height: widget.height,
      disableAction: widget.disableAction,
      items: items,
      selectedItem: selected,
      itemLabel: (item) => item.label,
      initialValue: AppLocalizations.of(context)!.dateRange,
      onItemSelected: _applyRange,
    );
  }
}
