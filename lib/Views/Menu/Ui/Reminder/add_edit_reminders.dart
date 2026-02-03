import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';

import '../../../../Features/Other/zForm_dialog.dart';
import '../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import 'bloc/reminder_bloc.dart';
import 'model/reminder_model.dart';

class AddEditReminderView extends StatelessWidget {
  final ReminderModel? r;
  const AddEditReminderView({super.key, this.r});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), desktop: _Desktop(r), tablet: _Tablet(),);
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
class _Desktop extends StatefulWidget {
  final ReminderModel? reminder;

  const _Desktop(this.reminder);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {

  final TextEditingController account = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final TextEditingController details = TextEditingController();

  DateTime? alertDate;

  @override
  void initState() {
    final r = widget.reminder;

    account.text = r?.rmdAccount?.toString() ?? "";
    amount.text = r?.rmdAmount ?? "";
    details.text = r?.rmdDetails ?? "";
    alertDate = r?.rmdAlertDate;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    final isLoading =
        context.watch<ReminderBloc>().state.loading;

    return ZFormDialog(
      width: 450,
      padding: EdgeInsets.all(10),
      icon: Icons.notifications,
      title: locale.reminders,
      actionLabel: isLoading
          ? const CircularProgressIndicator()
          : Text(locale.create),
      onAction: onSubmit,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [

          /// Account
          ZTextFieldEntitled(
            controller: account,
            title: AppLocalizations.of(context)!.accounts,
            keyboardInputType: TextInputType.number,
            isRequired: true,
          ),

          /// Amount
          ZTextFieldEntitled(
            controller: amount,
            title: locale.amount,
            keyboardInputType:
            const TextInputType.numberWithOptions(decimal: true),
            isRequired: true,
          ),

          /// Details
          ZTextFieldEntitled(
            controller: details,
            title: locale.details,
            keyboardInputType: TextInputType.multiline,
            maxLength: 100,
          ),

          const SizedBox(height: 10),

          /// DATE PICKER

        ],
      ),
    );
  }

  void pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: alertDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() => alertDate = picked);
    }
  }

  void onSubmit() {

    final model = ReminderModel(
      rmdId: widget.reminder?.rmdId,
      usrName: "basir.h",
      rmdAccount: int.tryParse(account.text),
      rmdAmount: amount.text,
      rmdDetails: details.text,
      rmdAlertDate: alertDate,
      rmdStatus: widget.reminder?.rmdStatus ?? 0,
    );

    if (widget.reminder == null) {
      context.read<ReminderBloc>().add(AddReminderEvent(model));
    } else {
      context.read<ReminderBloc>().add(UpdateReminderEvent(model));
    }
  }
}


