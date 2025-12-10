import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../Localizations/l10n/translations/app_localizations.dart';
import '../Widgets/button.dart';
import '../Widgets/outline_button.dart';

class AfghanDatePicker extends StatefulWidget {
  final ValueChanged<Jalali> onDateSelected;
  final Jalali? initialDate;
  final int minYear;
  final int maxYear;

  const AfghanDatePicker({
    super.key,
    required this.onDateSelected,
    this.initialDate,
    this.minYear = 1300,
    this.maxYear = 1500,
  });

  @override
  _AfghanDatePickerState createState() => _AfghanDatePickerState();
}

class _AfghanDatePickerState extends State<AfghanDatePicker> {
  late Jalali _selectedDate;
  late Jalali _currentMonth;
  late Jalali _today;
  final List<String> _weekdays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
  bool _showYearSelector = false;
  late int _selectedYear;
  Jalali? _pendingSelection;

  late ScrollController _yearScrollController;

  @override
  void initState() {
    super.initState();
    _today = Jalali.now();
    _selectedDate = widget.initialDate ?? _today;
    _currentMonth = Jalali(_selectedDate.year, _selectedDate.month, 1);
    _selectedYear = _selectedDate.year;
    _yearScrollController = ScrollController();
  }

  @override
  void dispose() {
    _yearScrollController.dispose();
    super.dispose();
  }

  String _toPersianNumbers(String input) {
    const english = ['0','1','2','3','4','5','6','7','8','9'];
    const persian = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], persian[i]);
    }
    return input;
  }

  String _formatSelectedDate(Jalali date) {
    final weekday = _getFullWeekdayName(date.weekDay); // <-- add this
    final month = _getAfghanMonthName(date.month);
    final day = _toPersianNumbers(date.day.toString().padLeft(2,'0'));
    final year = _toPersianNumbers(date.year.toString());
    return '$weekday، $month $day/$year'; // include weekday at the start
  }


  bool _isSameDate(Jalali d1, Jalali d2) => d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

  void _onDateTapped(Jalali date) => setState(() => _pendingSelection = date);

  void _confirmSelection() {
    if (_pendingSelection != null) {
      setState(() {
        _selectedDate = _pendingSelection!;
        _selectedYear = _pendingSelection!.year;
      });
      widget.onDateSelected(_pendingSelection!);
      Navigator.of(context).pop();
    }
  }

  void _selectToday() {
    setState(() {
      _pendingSelection = _today;
      _selectedDate = _today;
      _currentMonth = Jalali(_today.year, _today.month, 1);
      _selectedYear = _today.year;
    });
  }

  void _navigateMonth(int offset) {
    setState(() {
      int newMonth = _currentMonth.month + offset;
      int newYear = _currentMonth.year;

      if (newMonth > 12) {
        newMonth = 1;
        newYear += 1;
      } else if (newMonth < 1) {
        newMonth = 12;
        newYear -= 1;
      }

      _currentMonth = Jalali(newYear, newMonth, 1);
      _selectedYear = newYear;
    });
  }


  void _changeYear(int year) {
    setState(() {
      _selectedYear = year;
      _currentMonth = Jalali(year, _currentMonth.month, 1);
      _showYearSelector = false;
    });
  }

  void _scrollToSelectedYear() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = _selectedYear - widget.minYear;
      final row = index ~/ 3; // 3 columns
      const rowHeight = 25.0;
      final offset = (row * rowHeight) - 60;
      if (_yearScrollController.hasClients) {
        _yearScrollController.animateTo(
          offset.clamp(0.0, _yearScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final monthLength = _currentMonth.monthLength;
    final firstWeekdayOfMonth = _currentMonth.weekDay;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: _showYearSelector ? 500 : 340,
        height: 450,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            // Year selector panel
            if (_showYearSelector)
              SizedBox(
                width: 180,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(locale.selectYear, style: TextStyle(fontWeight: FontWeight.bold, color: color.primary.withValues(alpha: .7))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        controller: _yearScrollController,
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemCount: widget.maxYear - widget.minYear + 1,
                        itemBuilder: (context, index) {
                          final year = widget.minYear + index;
                          final selected = year == _selectedYear;
                          return InkWell(
                            onTap: () => _changeYear(year),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selected ? color.primary : color.surface,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Center(
                                child: Text(
                                  _toPersianNumbers(year.toString()),
                                  style: TextStyle(color: selected ? color.surface : color.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(width: 5),
            if (_showYearSelector)
              VerticalDivider(width: 1, color: color.outlineVariant),
            if (_showYearSelector)
              SizedBox(width: 10),
            // Calendar panel
            Expanded(
              child: Column(
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      Icon(Icons.calendar_month_rounded,color: color.outline),
                      Text(_formatSelectedDate(_pendingSelection ?? _selectedDate),
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color.outline)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Month navigation
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() => _showYearSelector = !_showYearSelector);
                            if (_showYearSelector) _scrollToSelectedYear();
                          },
                          child: Text(
                            '${_getAfghanMonthName(_currentMonth.month)} | ${_toPersianNumbers(_selectedYear.toString())}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color.primary),
                          ),
                        ),
                      ),
                      IconButton(icon: Icon(Icons.chevron_left), onPressed: () => _navigateMonth(-1),iconSize: 20),
                      IconButton(icon: Icon(Icons.chevron_right), onPressed: () => _navigateMonth(1),iconSize: 20),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Weekdays row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _weekdays.map((d) => Expanded(child: Center(child: Text(d, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color.primary))))).toList(),
                  ),
                  const SizedBox(height: 6),

                  // Calendar grid
                  Expanded(
                    child: GridView.builder(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                      ),
                      itemCount: 42,
                      itemBuilder: (context, index) {
                        final dayOffset = index - ((firstWeekdayOfMonth - 1) % 7);
                        final isCurrentMonthDay = dayOffset >= 0 && dayOffset < monthLength;
                        final day = isCurrentMonthDay ? dayOffset + 1 : null;
                        final date = isCurrentMonthDay ? Jalali(_currentMonth.year, _currentMonth.month, day!) : null;
                        final isSelected = date != null && (_pendingSelection != null ? _isSameDate(date, _pendingSelection!) : _isSameDate(date, _selectedDate));
                        final isToday = date != null && _isSameDate(date, _today);

                        return InkWell(
                          onTap: date != null ? () => _onDateTapped(date) : null,
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isSelected ? color.primary : isToday ? color.primary.withValues(alpha: .2) : null,
                              shape: BoxShape.circle,
                              border: isToday ? Border.all(color: color.primary, width: 1) : null,
                            ),
                            child: Center(
                              child: Text(
                                day != null ? _toPersianNumbers(day.toString()) : '',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isSelected ? color.surface : isToday ? color.primary : color.secondary,
                                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 5),
                  // Footer buttons
                  Row(
                    children: [
                      ZOutlineButton(
                          width: 90,
                          height: 30, onPressed: _selectToday, label: Text(locale.today)),
                      const SizedBox(width: 8),
                      ZButton(
                          height: 30,
                          width: 90,
                          onPressed: _pendingSelection != null ? _confirmSelection : null, label: Text(locale.selectKeyword)),
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
  String _getFullWeekdayName(int weekday) {
    const weekdays = {
      1: 'شنبه',
      2: 'یکشنبه',
      3: 'دوشنبه',
      4: 'سه‌شنبه',
      5: 'چهارشنبه',
      6: 'پنجشنبه',
      7: 'جمعه',
    };
    return weekdays[weekday] ?? '';
  }

  String _getAfghanMonthName(int month) {
    const names = {1:'حمل',2:'ثور',3:'جوزا',4:'سرطان',5:'اسد',6:'سنبله',7:'میزان',8:'عقرب',9:'قوس',10:'جدی',11:'دلو',12:'حوت'};
    return names[month] ?? '';
  }
}
