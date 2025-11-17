import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/IndividualDetails/profile.dart';
import '../../../Individuals/individual_model.dart';


class IndividualProfileView extends StatelessWidget {
  final IndividualsModel ind;
  const IndividualProfileView({super.key, required this.ind});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(ind),
    );
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Desktop extends StatelessWidget {
  final IndividualsModel ind;
  const _Desktop(this.ind);

  @override
  Widget build(BuildContext context) {

    final color = Theme.of(context).colorScheme;
    final locale = AppLocalizations.of(context)!;
    String fullName = "${ind.perName} ${ind.perLastName}";

    return Scaffold(
      appBar: AppBar(titleSpacing: 0, title: Text(ind.perName ?? "")),
      body: Column(
        children: [
          Cover(
            margin: EdgeInsets.symmetric(horizontal: 8),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            color: color.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color.primary.withValues(alpha: .8),
                      radius: 28,
                      child: Text(
                        fullName.getFirstLetter,
                        style: TextStyle(color: color.surface, fontSize: 17),
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(ind.perPhone ?? ""),
                        ],
                      ),
                    ),

                    Row(
                      spacing: 8,
                      children: [
                        ZOutlineButton(
                            icon: Icons.refresh,
                            width: 100, label: Text(locale.edit)),
                        ZOutlineButton(
                            isActive: true,
                            icon: Icons.delete,
                            width: 100, label: Text(locale.delete)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IndividualsDetailsTabView(ind: ind),
          ))
        ],
      ),
    );
  }
}
