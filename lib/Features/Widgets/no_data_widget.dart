import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';

import 'outline_button.dart';

class NoDataWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRefresh;
  const NoDataWidget({super.key,this.message,this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 100,
                child:Image.asset("assets/images/noData.png")
            ),
            message == null? SizedBox() : Text(message??AppLocalizations.of(context)!.noDataFound,style: Theme.of(context).textTheme.bodyMedium),
           SizedBox(height: 10),
            ZOutlineButton(
              width: 120,
              icon: Icons.refresh,
              label: Text(AppLocalizations.of(context)!.refresh),
              onPressed: onRefresh,
            ),
          ],
        ));
  }
}
