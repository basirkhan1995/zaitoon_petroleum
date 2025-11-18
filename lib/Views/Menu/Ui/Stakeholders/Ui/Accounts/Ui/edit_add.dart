import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/Currencies/model/ccy_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/model/acc_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import '../../../../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../Finance/Ui/Currency/features/currency_drop.dart';

class AccountsAddEditView extends StatelessWidget {
  final AccountsModel? model;
  final int? signatory;

  const AccountsAddEditView({super.key, this.model, this.signatory});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(model: model),
      tablet: _Tablet(model: model),
      desktop: _Desktop(model: model,signatory: signatory),
    );
  }
}

class _Mobile extends StatelessWidget {
  final AccountsModel? model;

  const _Mobile({this.model});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Tablet extends StatelessWidget {
  final AccountsModel? model;

  const _Tablet({this.model});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Desktop extends StatefulWidget {
  final AccountsModel? model;
  final int? signatory;

  const _Desktop({this.model,this.signatory});

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  // Controllers
  final TextEditingController accName = TextEditingController();
  final TextEditingController accountLimit = TextEditingController();

  bool status = true;
  int statusValue = 0;
  String defaultCcy = "USD";
  CurrenciesModel? ccyCode;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill for edit mode
    if (widget.model != null) {
      final m = widget.model!;
      accName.text = m.accName ?? "";
      accountLimit.text = m.actCreditLimit ?? "";
      defaultCcy = m.actCurrency ?? "";
      statusValue = m.actStatus ?? 0;
      status = statusValue == 1;
    }
  }

  @override
  void dispose() {
    accName.dispose();
    accountLimit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context).colorScheme;
    final isEdit = widget.model != null;
    return ZFormDialog(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      width: 550,

      title: isEdit ? locale.update : locale.newKeyword,

      actionLabel:
          (context.watch<AccountsBloc>().state is AccountLoadingState)
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: theme.surface,
              ),
            )
          : Text(isEdit ? locale.update : locale.create),

      onAction: onSubmit,

      child: Form(
        key: formKey,
        child: BlocConsumer<IndividualsBloc, IndividualsState>(
          listener: (context, state) {
            if (state is IndividualSuccessState) {
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ZTextFieldEntitled(
                  controller: accName,
                  isRequired: true,
                  title: locale.accountName,
                  onSubmit: (_) => onSubmit(),
                  validator: (value) {
                    if (value.isEmpty) {
                      return locale.required(locale.accountName);
                    }
                    return null;
                  },
                ),
                ZTextFieldEntitled(
                  controller: accountLimit,
                  title: locale.accountLimit,
                  onSubmit: (_) => onSubmit(),
                ),

                SizedBox(height: 5),

                CurrencyDropdown(
                  isMulti: false,
                  initiallySelectedSingle: CurrenciesModel(ccyCode: defaultCcy),
                  onMultiChanged: (_) {},
                  onSingleChanged: (value) {
                    ccyCode = value;
                  },
                ),

                Row(
                  children: [
                    Checkbox(
                      value: status,
                      onChanged: (value) {
                        setState(() {
                          status = value ?? false;
                          statusValue = status ? 1 : 0;
                        });
                      },
                    ),
                    Text(locale.status),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void onSubmit() {
    if (!formKey.currentState!.validate()) return;

    final data = AccountsModel(
      accName: accName.text,
      actCurrency: defaultCcy,
      actStatus: statusValue,
      actCreditLimit: accountLimit.text,
      actSignatory: widget.signatory ?? widget.model?.actSignatory,
      accNumber: widget.model?.accNumber,
    );

    final bloc = context.read<AccountsBloc>();

    if (widget.model == null) {
      bloc.add(AddAccountEvent(data));
    } else {
      bloc.add(UpdateAccountEvent(data));
    }
  }
}
