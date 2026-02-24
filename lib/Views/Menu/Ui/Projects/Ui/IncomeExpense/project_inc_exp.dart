import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';

class ProjectIncomeExpenseView extends StatelessWidget {
  final int? projectId;
  const ProjectIncomeExpenseView({super.key,this.projectId});
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(projectId), tablet: _Tablet(projectId), desktop: _Desktop(projectId));
  }
}

class _Mobile extends StatelessWidget {
  final int? projectId;
  const _Mobile(this.projectId);
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
class _Tablet extends StatelessWidget {
  final int? projectId;
  const _Tablet(this.projectId);
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
class _Desktop extends StatelessWidget {
  final int? projectId;
  const _Desktop(this.projectId);
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}



