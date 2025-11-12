import 'package:flutter/material.dart';
import '../../../../../../../../Features/Other/responsive.dart';

class PasswordView extends StatelessWidget {
  const PasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
        tablet: _Tablet(),
        mobile: _Mobile(),
        desktop: _Desktop());
  }
}

class _Desktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Mobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Tablet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

