import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../Localizations/l10n/translations/app_localizations.dart';
import '../Widgets/button.dart';
import '../Widgets/outline_button.dart';

class JalaliRange {
  final Jalali start;
  final Jalali end;

  JalaliRange(this.start, this.end);

  bool contains(Jalali date) {
    return date.toGregorian().toDateTime().millisecondsSinceEpoch >=
        start.toGregorian().toDateTime().millisecondsSinceEpoch &&
        date.toGregorian().toDateTime().millisecondsSinceEpoch <=
            end.toGregorian().toDateTime().millisecondsSinceEpoch;
  }

  @override
  String toString() =>
      '${start.year}/${start.month}/${start.day} - ${end.year}/${end.month}/${end.day}';
}

class AfghanDateRangePicker extends StatefulWidget {
  final ValueChanged<JalaliRange> onRangeSelected;
  final JalaliRange? initialRange;
  final int minYear;
  final int maxYear;

  const AfghanDateRangePicker({
    super.key,
    required this.onRangeSelected,
    this.initialRange,
    this.minYear = 1300,
    this.maxYear = 1500,
  });

  @override
  _AfghanDateRangePickerState createState() => _AfghanDateRangePickerState();
}

class _AfghanDateRangePickerState extends State<AfghanDateRangePicker> {
  late JalaliRange _selectedRange;
  late Jalali _currentMonth;
  late Jalali _today;
  final List<String> _weekdays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  bool _showYearSelector = false;
  late int _selectedYear;
  Jalali? _startDate;
  Jalali? _endDate;
  late ScrollController _yearScrollController;

  @override
  void initState() {
    super.initState();
    _today = Jalali.now();
    _selectedRange = widget.initialRange ?? JalaliRange(_today, _today);
    _currentMonth = Jalali(_selectedRange.start.year, _selectedRange.start.month, 1);
    _selectedYear = _selectedRange.start.year;
    _startDate = _selectedRange.start;
    _endDate = _selectedRange.end;
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

  String _formatDate(Jalali date) {
    final day = _toPersianNumbers(date.day.toString().padLeft(2,'0'));
    final month = _toPersianNumbers(date.month.toString().padLeft(2,'0'));
    final year = _toPersianNumbers(date.year.toString());
    return '$year/$month/$day';
  }

  String _formatRange(Jalali? start, Jalali? end) {
    if (start == null && end == null) return AppLocalizations.of(context)!.selectKeyword;
    if (start == null) return ' تا ${_formatDate(end!)}';
    if (end == null) return ' از ${_formatDate(start)}';
    return '${_formatDate(start)} | ${_formatDate(end)}';
  }

  Widget _buildBorderedRangeText(Jalali? start, Jalali? end) {
    final text = _formatRange(start, end);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),

      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: "NotoNaskh",
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .7),
        ),
      ),
    );
  }

  bool _isSameDate(Jalali date1, Jalali date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _onDateTapped(Jalali date) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = date;
        _endDate = null;
      } else if (_startDate != null && _endDate == null) {
        if (date.toGregorian().toDateTime().millisecondsSinceEpoch <
            _startDate!.toGregorian().toDateTime().millisecondsSinceEpoch) {
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
      }
    });
  }

  void _confirmSelection() {
    if (_startDate != null && _endDate != null) {
      _selectedRange = JalaliRange(_startDate!, _endDate!);
    } else if (_startDate != null) {
      _selectedRange = JalaliRange(_startDate!, _startDate!);
    } else {
      return;
    }
    _selectedYear = _selectedRange.start.year;
    widget.onRangeSelected(_selectedRange);
    //Navigator.of(context).pop();
  }

  void _selectToday() {
    setState(() {
      _startDate = _today;
      _endDate = _today;
      _currentMonth = Jalali(_today.year, _today.month, 1);
      _selectedYear = _today.year;
    });
  }

  void _clearSelection() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  void _navigateMonth(int offset) {
    setState(() {
      int newMonth = _currentMonth.month + offset;
      int newYear = _currentMonth.year;

      if (newMonth > 12) {
        newMonth = 1;
        newYear++;
      } else if (newMonth < 1) {
        newMonth = 12;
        newYear--;
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
      const rowHeight = 35.0;
      final offset = (index ~/ 3) * rowHeight - 50;
      if (_yearScrollController.hasClients) {
        _yearScrollController.animateTo(
          offset.clamp(0.0, _yearScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getAfghanMonthName(int month) {
    const monthNames = {
      1: 'حمل',
      2: 'ثور',
      3: 'جوزا',
      4: 'سرطان',
      5: 'اسد',
      6: 'سنبله',
      7: 'میزان',
      8: 'عقرب',
      9: 'قوس',
      10: 'جدی',
      11: 'دلو',
      12: 'حوت',
    };
    return monthNames[month] ?? '';
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
        width: _showYearSelector? 500 : 400,
        height: 500,
        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Calendar + Year Selector Row
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Year selector panel on right
                  if (_showYearSelector)
                  SizedBox(
                      width: 130,
                      height: double.infinity,
                      child: GridView.builder(
                        controller: _yearScrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 1,
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
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: selected ? color.surface : color.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(width: 5),
                  if(_showYearSelector)
                    VerticalDivider(width: 1, color: color.outlineVariant),
                  if(_showYearSelector)
                    SizedBox(width: 10),
                  // Calendar Panel
                  Expanded(
                    child: Column(
                      children: [
                        // Selected Range display
                        Row(
                          children: [
                            _buildBorderedRangeText(_startDate, _endDate),
                          ],
                        ),

                        // Month navigation + weekday names
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _showYearSelector = !_showYearSelector;
                                  if (_showYearSelector) _scrollToSelectedYear();
                                });
                              },
                              child: Text(
                                '${_getAfghanMonthName(_currentMonth.month)} | ${_toPersianNumbers(_selectedYear.toString())}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: color.primary,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.chevron_left),
                                  onPressed: () => _navigateMonth(-1),
                                ),
                                IconButton(
                                  icon: Icon(Icons.chevron_right),
                                  onPressed: () => _navigateMonth(1),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Weekday headers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _weekdays
                              .map((d) => Expanded(
                            child: Center(
                              child: Text(
                                d,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: color.primary.withAlpha(180),
                                ),
                              ),
                            ),
                          ))
                              .toList(),
                        ),
                        const SizedBox(height: 6),
                        // Calendar Grid
                        Expanded(
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1,
                            ),
                            itemCount: firstWeekdayOfMonth + monthLength - 1,
                            itemBuilder: (context, index) {
                              if (index < firstWeekdayOfMonth - 1) return const SizedBox.shrink();
                              final day = index - firstWeekdayOfMonth + 2;
                              final date = Jalali(_currentMonth.year, _currentMonth.month, day);

                              final isStartDate = _startDate != null && _isSameDate(date, _startDate!);
                              final isEndDate = _endDate != null && _isSameDate(date, _endDate!);
                              final isInRange = _startDate != null && _endDate != null &&
                                  date.toGregorian().toDateTime().isAfter(_startDate!.toGregorian().toDateTime().subtract(const Duration(days: 1))) &&
                                  date.toGregorian().toDateTime().isBefore(_endDate!.toGregorian().toDateTime().add(const Duration(days: 1)));

                              Color? background;
                              BoxShape shape = BoxShape.rectangle;
                              if (isStartDate || isEndDate) { background = color.primary; shape = BoxShape.circle; }
                              else if (isInRange) background = color.primary.withAlpha(50);

                              final isToday = _isSameDate(date, _today);

                              return GestureDetector(
                                onTap: () => _onDateTapped(date),
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: background,
                                    shape: shape,
                                    border: isToday ? Border.all(color: color.primary, width: 1) : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _toPersianNumbers(day.toString()),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isStartDate || isEndDate
                                            ? color.surface
                                            : isToday
                                            ? color.primary
                                            : color.secondary,
                                      ),
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
                ],
              ),
            ),

            const SizedBox(height: 10),
            // Footer buttons
            Row(
              children: [
                Expanded(
                  child: ZOutlineButton(
                    height: 40,
                    onPressed: _clearSelection,
                    label: Text(locale.clear),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ZOutlineButton(
                    height: 40,
                    onPressed: _selectToday,
                    label: Text(locale.today),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ZButton(
                    height: 40,
                    onPressed: (_startDate != null) ? _confirmSelection : null,
                    label: Text(locale.selectKeyword),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
