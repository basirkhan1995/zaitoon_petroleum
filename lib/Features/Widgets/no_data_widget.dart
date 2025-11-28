import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';

import 'outline_button.dart';

class NoDataWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRefresh;
  final bool enableAction;
  const NoDataWidget({super.key,this.title, this.message,this.onRefresh,this.enableAction = true});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 300,
                child:Image.asset("assets/images/noData.png")
            ),
            if(title !=null && title!.isNotEmpty)
            Text(title??"", style: Theme.of(context).textTheme.titleMedium),
            message == null? SizedBox() : Text(message??AppLocalizations.of(context)!.noDataFound,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary.withValues(alpha: .7))),
            SizedBox(height: 15),
            if(enableAction)
            ZOutlineButton(
              width: 100,
              icon: Icons.refresh,
              label: Text(AppLocalizations.of(context)!.refresh),
              onPressed: onRefresh,
            ),
          ],
        ));
  }
}
