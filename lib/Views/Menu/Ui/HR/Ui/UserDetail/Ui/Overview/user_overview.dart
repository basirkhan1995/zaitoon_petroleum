import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/model/user_model.dart';

class UserOverviewView extends StatelessWidget {
  final UsersModel user;
  const UserOverviewView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(user),
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
  final UsersModel user;
  const _Desktop(this.user);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.primary),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Row(
              children: [
                Text(
                  locale.userInformation,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),

            Row(
              spacing: 5,
              children: [
                Icon(Icons.email, size: 20),
                Text(user.usrEmail ?? ""),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    locale.userOwner,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color.secondary,
                    ),
                  ),
                ),
                Text(user.usrFullName ?? ""),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    locale.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color.secondary,
                    ),
                  ),
                ),
                Text(user.usrName ?? ""),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    locale.usrRole,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color.secondary,
                    ),
                  ),
                ),
                Text(user.usrRole ?? ""),
              ],
            ),

            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    locale.branch,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color.secondary,
                    ),
                  ),
                ),
                Text(user.usrBranch.toString()),
              ],
            ),

            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    locale.createdAt,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color.secondary,
                    ),
                  ),
                ),
                Text(user.usrEntryDate!.toDateString),
              ],
            ),

            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    locale.status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color.secondary,
                    ),
                  ),
                ),
                Switch(value: user.usrStatus == 1, onChanged: (e) {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
