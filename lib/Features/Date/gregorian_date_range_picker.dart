import 'package:flutter/material.dart';
import '../../Localizations/l10n/translations/app_localizations.dart';
import '../Widgets/button.dart';
import '../Widgets/outline_button.dart';

class ZGregorianRangePicker {
  final DateTime start;
  final DateTime end;

  ZGregorianRangePicker(this.start, this.end);

  bool contains(DateTime date) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
        date.isBefore(end.add(const Duration(days: 1)));
  }

  @override
  String toString() =>
      '${start.year}/${start.month}/${start.day} - ${end.year}/${end.month}/${end.day}';
}

class GregorianDateRangePicker extends StatefulWidget {
  final ValueChanged<ZGregorianRangePicker> onRangeSelected;
  final ZGregorianRangePicker? initialRange;
  final int minYear;
  final int maxYear;

  const GregorianDateRangePicker({
    super.key,
    required this.onRangeSelected,
    this.initialRange,
    this.minYear = 1900,
    this.maxYear = 2100,
  });

  @override
  _GregorianDateRangePickerState createState() =>
      _GregorianDateRangePickerState();
}

class _GregorianDateRangePickerState extends State<GregorianDateRangePicker> {
  late ZGregorianRangePicker _selectedRange;
  late DateTime _currentMonth;
  late DateTime _today;
  final List<String> _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  bool _showYearSelector = false;
  late int _selectedYear;
  DateTime? _startDate;
  DateTime? _endDate;
  late ScrollController _yearScrollController;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedRange =
        widget.initialRange ?? ZGregorianRangePicker(_today, _today);
    _currentMonth =
        DateTime(_selectedRange.start.year, _selectedRange.start.month, 1);
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

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2,'0')}/${date.day.toString().padLeft(2,'0')}';
  }

  String _formatRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return AppLocalizations.of(context)!.selectDate;
    if (start == null) return 'to ${_formatDate(end!)}';
    if (end == null) return 'from ${_formatDate(start)}';
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  void _onDateTapped(DateTime date) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = date;
        _endDate = null;
      } else if (_startDate != null && _endDate == null) {
        if (date.isBefore(_startDate!)) {
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
      _selectedRange = ZGregorianRangePicker(_startDate!, _endDate!);
    } else if (_startDate != null) {
      _selectedRange = ZGregorianRangePicker(_startDate!, _startDate!);
    } else {
      return;
    }

    _selectedYear = _selectedRange.start.year;
    widget.onRangeSelected(_selectedRange);
   // Navigator.of(context).pop();
  }

  void _selectToday() {
    setState(() {
      _startDate = _today;
      _endDate = _today;
      _currentMonth = DateTime(_today.year, _today.month, 1);
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

      _currentMonth = DateTime(newYear, newMonth, 1);
      _selectedYear = newYear;
    });
  }

  void _changeYear(int year) {
    setState(() {
      _selectedYear = year;
      _currentMonth = DateTime(year, _currentMonth.month, 1);
      _showYearSelector = false;
    });
  }

  void _scrollToSelectedYear() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = _selectedYear - widget.minYear;
      const rowHeight = 30.0;
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

  String _getMonthName(int month) {
    const months = [
      'January','February','March','April','May','June','July','August','September','October','November','December'
    ];
    return months[month-1];
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final monthLength = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekdayOfMonth = _currentMonth.weekday % 7;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: _showYearSelector ? 500 : 400,
        height: 500,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_showYearSelector)
                    SizedBox(
                      width: 130,
                      child: GridView.builder(
                        controller: _yearScrollController,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: widget.maxYear - widget.minYear + 1,
                        itemBuilder: (context,index){
                          final year = widget.minYear + index;
                          final selected = year == _selectedYear;
                          return InkWell(
                            onTap: ()=> _changeYear(year),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selected ? color.primary : color.surface,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Center(
                                child: Text(year.toString(),style: TextStyle(
                                  color: selected ? color.surface : color.primary,
                                  fontWeight: FontWeight.bold,
                                ),),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                   if(_showYearSelector) SizedBox(width: 8),
                   if(_showYearSelector)
                    VerticalDivider(width: 1, color: color.outlineVariant),
                   if(_showYearSelector) SizedBox(width: 10),
                  Expanded(
                    child: Column(

                      children: [
                        // Selected range
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(_formatRange(_startDate,_endDate),
                                style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: color.primary.withValues(alpha: .7)),
                              ),
                            ],
                          ),
                        ),

                        // Month Navigation
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: (){
                                  setState((){
                                    _showYearSelector = !_showYearSelector;
                                    if(_showYearSelector) _scrollToSelectedYear();
                                  });
                                },
                                child: Text('${_getMonthName(_currentMonth.month)} | ${_currentMonth.year}',
                                  style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: color.primary),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(onPressed: ()=>_navigateMonth(-1), icon: Icon(Icons.chevron_left)),
                                  IconButton(onPressed: ()=>_navigateMonth(1), icon: Icon(Icons.chevron_right)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _weekdays.map((d)=>Expanded(child: Center(child: Text(d,style: TextStyle(fontWeight: FontWeight.bold),)))).toList(),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1,
                            ),
                            itemCount: firstWeekdayOfMonth + monthLength -1,
                            itemBuilder: (context,index){
                              if(index < firstWeekdayOfMonth) return SizedBox.shrink();
                              final day = index - firstWeekdayOfMonth +1;
                              final date = DateTime(_currentMonth.year,_currentMonth.month,day);
                              final isStartDate = _startDate != null && date.isAtSameMomentAs(_startDate!);
                              final isEndDate = _endDate != null && date.isAtSameMomentAs(_endDate!);
                              final isInRange = _startDate != null &&
                                  _endDate != null &&
                                  date.isAfter(_startDate!) &&
                                  date.isBefore(_endDate!);

                              Color? bg;
                              BoxShape shape = BoxShape.rectangle;
                              Border? border;

                              if(isStartDate || isEndDate){ bg=color.primary; shape=BoxShape.circle;}
                              else if(isInRange) bg=color.primary.withAlpha(50);

                              final isToday = _today.year == date.year &&
                                  _today.month == date.month &&
                                  _today.day == date.day;
                              if (isStartDate || isEndDate) {
                                bg = color.primary;
                                shape = BoxShape.circle;
                              } else if (isInRange) {
                                bg = color.primary.withAlpha(50);
                              }

                              if (isToday && !(isStartDate || isEndDate)) {
                                border = Border.all(color: color.primary, width: 1);
                              }
                              return GestureDetector(
                                onTap: () => _onDateTapped(date),
                                child: Container(
                                  margin: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    shape: shape,
                                    border: border,
                                  ),
                                  child: Center(
                                    child: Text(
                                      day.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isStartDate || isEndDate
                                            ? Colors.white
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
            Row(
              children: [
                Expanded(child: ZOutlineButton(height:40,onPressed:_clearSelection,label:Text(AppLocalizations.of(context)!.clear))),
                SizedBox(width: 8),
                Expanded(child: ZOutlineButton(height:40,onPressed:_selectToday,label:Text(AppLocalizations.of(context)!.today))),
                SizedBox(width: 8),
                Expanded(child: ZButton(height:40,onPressed: (_startDate!=null)? _confirmSelection:null,label:Text(AppLocalizations.of(context)!.selectKeyword))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
