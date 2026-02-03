import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Reminder/features/due_drop.dart';

import '../../../../Features/Date/z_generic_date.dart';
import '../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../Features/Other/thousand_separator.dart';
import '../../../../Features/Other/zForm_dialog.dart';
import '../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../Auth/bloc/auth_bloc.dart';
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
  String? usrName;
  String? dueType;

  @override
  void initState() {
    final r = widget.reminder;

    if(r !=null){
      account.text = r.rmdAccount?.toString() ?? "";
      amount.text = r.rmdAmount ?? "";
      details.text = r.rmdDetails ?? "";
      dueDate = r.rmdAlertDate?.toFormattedDate() ??"";
      dueType = r.rmdName;
    }
    super.initState();
  }
  String dueDate = DateTime.now().toFormattedDate();

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final state = context.watch<AuthBloc>().state;
    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = state.loginData;
    usrName = login.usrName??"";
    final isLoading = context.watch<ReminderBloc>().state.loading;

    return ZFormDialog(
      width: 450,
      padding: EdgeInsets.all(12),
      icon: Icons.notifications,
      title: tr.reminders,
      actionLabel: isLoading
          ? SizedBox(
          width: 16,
          height: 16,
          child: const CircularProgressIndicator())
          : Text(widget.reminder == null ? tr.create : tr.update),
      onAction: onSubmit,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          /// DATE PICKER
          Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ZDatePicker(
                  disablePastDate: true,
                  label: tr.dueDate,
                  value: dueDate,
                  onDateChanged: (v) {
                    setState(() {
                      dueDate = v;
                    });
                  },
                ),
              ),
              Expanded(
                child: DueTypeDropdown(
                    onDueTypeSelected: (e){
                       setState(() {
                         dueType = e.name;
                       });
                }),
              ),
            ],
          ),
          /// Account
          GenericTextfield<StakeholdersAccountsModel, AccountsBloc, AccountsState>(
            showAllOnFocus: true,
            controller: account,
            title: tr.accounts,
            hintText: tr.accNameOrNumber,
            isRequired: true,
            bloc: context.read<AccountsBloc>(),
            fetchAllFunction: (bloc) => bloc.add(LoadStkAccountsEvent()),
            searchFunction: (bloc, query) => bloc.add(LoadStkAccountsEvent(search: query)),
            validator: (value) {
              if (value.isEmpty) {
                return tr.required(tr.accounts);
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
            noResultsText: tr.noDataFound,
            showClearButton: true,
          ),

          /// Amount
          ZTextFieldEntitled(
            controller: amount,
            title: tr.amount,
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
                return tr.required(tr.amount);
              }

              // Remove formatting (e.g. commas)
              final clean = value.replaceAll(
                RegExp(r'[^\d.]'),
                '',
              );
              final amount = double.tryParse(clean);

              if (amount == null || amount <= 0.0) {
                return tr.amountGreaterZero;
              }

              return null;
            },
          ),

          /// Details
          ZTextFieldEntitled(
            controller: details,
            title: tr.details,
            keyboardInputType: TextInputType.multiline,
            maxLength: 100,
          ),

          const SizedBox(height: 10),
          
        ],
      ),
    );
  }


  void onSubmit() {
    final model = ReminderModel(
      rmdId: widget.reminder?.rmdId,
      usrName: usrName,
      rmdName: dueType,
      rmdAccount: accNumber,
      rmdAmount: amount.text.cleanAmount,
      rmdDetails: details.text,
      rmdAlertDate: DateTime.tryParse(dueDate),
      rmdStatus: widget.reminder?.rmdStatus ?? 0,
    );

    if (widget.reminder == null) {
      context.read<ReminderBloc>().add(AddReminderEvent(model));
    } else {
      context.read<ReminderBloc>().add(UpdateReminderEvent(model));
    }
  }
}


