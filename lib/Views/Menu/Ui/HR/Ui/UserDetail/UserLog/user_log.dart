import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';

class UserLogView extends StatelessWidget {
  final String? usrName;
  const UserLogView({super.key,this.usrName});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), desktop: _Desktop(usrName), tablet: _Tablet());
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
class _Desktop extends StatelessWidget {
  final String? usrName;
  const _Desktop(this.usrName);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

