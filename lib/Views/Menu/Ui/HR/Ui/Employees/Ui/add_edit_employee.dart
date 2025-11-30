import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';

import '../../../../../../../Features/Other/thousand_separator.dart';

class AddEditEmployeeView extends StatelessWidget {
  const AddEditEmployeeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), desktop: _Desktop(),tablet: _Tablet(),);
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



class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  final empSalary = TextEditingController();
  final empEmail = TextEditingController();
  final empTaxInfo = TextEditingController();

  String? department;
  String? jobTitle;
  DateTime? startDate;

  @override
  void dispose() {

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return ZFormDialog(
        width: 550,
        actionLabel: Text(locale.create),
        icon: Icons.perm_contact_calendar_rounded,
        onAction: (){},
        title: "Add Employee",
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 0,
              children: [
                ZTextFieldEntitled(
                    controller: empTaxInfo,
                    title: "Tax Info"),
                ZTextFieldEntitled(
                    controller: empEmail,
                    validator: (value)=> Utils.validateEmail(email: value,context: context),
                    title: locale.email),
                ZTextFieldEntitled(
                  isRequired: true,
                  // onSubmit: (_)=> onSubmit(),
                  keyboardInputType: TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormat: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9.,]*'),
                    ),
                    SmartThousandsDecimalFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return locale.required(locale.exchangeRate);
                    }

                    // Remove formatting (e.g. commas)
                    final clean = value.replaceAll(
                      RegExp(r'[^\d.]'),
                      '',
                    );
                    final amount = double.tryParse(clean);

                    if (amount == null || amount <= 0.0) {
                      return locale.amountGreaterZero;
                    }

                    return null;
                  },
                  controller: empSalary,
                  title: locale.amount,
                ),
              ],
            ),
          ),
        ),
    );
  }
}

