import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';

import '../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../Features/Other/thousand_separator.dart';
import '../../../../Features/Other/zForm_dialog.dart';
import '../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import '../Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import '../Stakeholders/Ui/Accounts/model/stk_acc_model.dart';
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
  int? accNumber;
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
          GenericTextfield<StakeholdersAccountsModel, AccountsBloc, AccountsState>(
            showAllOnFocus: true,
            controller: account,
            title: locale.accounts,
            hintText: locale.accNameOrNumber,
            isRequired: true,
            bloc: context.read<AccountsBloc>(),
            fetchAllFunction: (bloc) => bloc.add(LoadStkAccountsEvent()),
            searchFunction: (bloc, query) => bloc.add(LoadStkAccountsEvent(search: query)),
            validator: (value) {
              if (value.isEmpty) {
                return locale.required(locale.accounts);
              }
              return null;
            },
            itemBuilder: (context, account) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${account.accnumber} | ${account.accName}",
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            itemToString: (acc) =>
            "${acc.accnumber} | ${acc.accName}",
            stateToLoading: (state) =>
            state is AccountLoadingState,
            loadingBuilder: (context) => const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
            stateToItems: (state) {
              if (state is StkAccountLoadedState) {
                return state.accounts;
              }
              return [];
            },
            onSelected: (value) {
              setState(() {
                accNumber = value.accnumber;
              });
            },
            noResultsText: locale.noDataFound,
            showClearButton: true,
          ),

          /// Amount
          ZTextFieldEntitled(
            controller: amount,
            title: locale.amount,
            keyboardInputType:
            const TextInputType.numberWithOptions(decimal: true),
            isRequired: true,

            inputFormat: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[0-9.,]*'),
              ),
              SmartThousandsDecimalFormatter(),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return locale.required(locale.amount);
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


  void onSubmit() {
    final model = ReminderModel(
      rmdId: widget.reminder?.rmdId,
      usrName: "basir.h",
      rmdAccount: accNumber,
      rmdAmount: amount.text.cleanAmount,
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


