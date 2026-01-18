import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import '../../../../../Features/Other/cover.dart';
import 'package:intl/intl.dart';

import '../../../../../Localizations/l10n/translations/app_localizations.dart';

class DigitalClock extends StatefulWidget {
  const DigitalClock({super.key});

  @override
  State<DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  late DateTime _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: .3)
          )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              Flexible(
                flex: 3,
                child: Text(
                  DateFormat('HH:mm:ss').format(_currentTime),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Digital',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              Flexible(
                flex: 1,
                child: Text(
                  getLocalizedPeriod(DateFormat('a').format(_currentTime)),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),

          // Date (Tue, July 05, 2025)
          Text(
            DateFormat('EEE, MMMM dd, yyyy').format(_currentTime),
            style: TextStyle(
              fontSize: 15,
              fontFamily: "Roboto",
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),

          SizedBox(height: 5),

          ZCover(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.symmetric(horizontal: 3,vertical: 2),
            color: Theme.of(context).colorScheme.surface,
            child: Wrap(
              spacing: 5,
              children: [
                Text(
                  DateTime.now().shamsiDateFormatted,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),

                Text(
                  DateTime.now().shamsiWeekdayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Roboto",
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                Text(
                  DateTime.now().shamsiMonthName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Roboto",
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  String getLocalizedPeriod(String period) {
    if(period == "AM") return AppLocalizations.of(context)!.am;
    if(period == "PM") return AppLocalizations.of(context)!.pm;
    return period; // Default to English if not specified
  }
}