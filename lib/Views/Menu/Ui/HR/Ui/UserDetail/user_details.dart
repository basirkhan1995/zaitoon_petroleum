import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/UserDetail/details_tab.dart';
import '../Users/model/user_model.dart';

class UserDetailsView extends StatelessWidget {
  final UsersModel usr;
  const UserDetailsView({super.key, required this.usr});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(usr: usr),
      tablet: _Tablet(),
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
  final UsersModel usr;
  const _Desktop({required this.usr});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        content: Container(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          width: MediaQuery.sizeOf(context).width * .5,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8)
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 0),
                    horizontalTitleGap: 7,
                    title: Text(usr.usrFullName??""),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(usr.usrName??""),
                        Text(usr.usrEmail??""),
                      ],
                    ),
                    leading: CircleAvatar(
                      radius: 30,
                      child: Text(usr.usrFullName!.getFirstLetter, style: theme.titleMedium),
                    ),
                  ),
                  Expanded(child: UserDetailsTabView(user: usr))
                ]
            ),
          ),
        ),
      ),
    );
  }
}
