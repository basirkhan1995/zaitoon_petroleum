import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/zform_dialog.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/Currencies/model/ccy_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/model/acc_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import '../../../../../../../../Features/Other/thousand_separator.dart';
import '../../../../../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../../Finance/Ui/Currency/features/currency_drop.dart';

class AccountsAddEditView extends StatelessWidget {
  final AccountsModel? model;
  final int? perId;
  const AccountsAddEditView({super.key, this.model,this.perId});
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(model: model),
      tablet: _Tablet(model: model),
      desktop: _Desktop(model: model,perId: perId),
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
  final int? perId;

  const _Desktop({this.model,this.perId});

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
      accountLimit.text = m.accCreditLimit?.toAmount() ?? "";
      defaultCcy = m.actCurrency ?? "";
      statusValue = m.accStatus ?? 0;
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
    final tr = AppLocalizations.of(context)!;
    final theme = Theme.of(context).colorScheme;
    final isEdit = widget.model != null;
    return ZFormDialog(
      icon: Icons.account_circle,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      width: 500,

      title: isEdit ? tr.update : tr.newKeyword,

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
          : Text(isEdit ? tr.update : tr.create),

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
              spacing: 8,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 5,
                  children: [
                    Expanded(
                      child: ZTextFieldEntitled(
                        controller: accName,
                        isRequired: true,
                        title: tr.accountName,
                        onSubmit: (_) => onSubmit(),
                        validator: (value) {
                          if (value.isEmpty) {
                            return tr.required(tr.accountName);
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: CurrencyDropdown(
                        height: 40,
                        disableAction: widget.model != null,
                        title: tr.currencyTitle,
                        isMulti: false,
                        initiallySelectedSingle: CurrenciesModel(ccyCode: defaultCcy),
                        onMultiChanged: (_) {},
                        onSingleChanged: (value) {
                          ccyCode = value;
                        },
                      ),
                    ),
                  ],
                ),

                ZTextFieldEntitled(
                  onSubmit: (_) => onSubmit(),
                  keyboardInputType:
                  TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormat: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9.,]*'),
                    ),
                    SmartThousandsDecimalFormatter(),
                  ],
                  title: tr.accountLimit,
                  controller: accountLimit,
                ),

                Row(
                  children: [
                    Checkbox(
                      visualDensity: VisualDensity(horizontal: -4),
                      value: status,
                      onChanged: (value) {
                        setState(() {
                          status = value ?? false;
                          statusValue = status ? 1 : 0;
                        });
                      },
                    ),
                    SizedBox(width: 5),
                    Text(status? tr.active : tr.blocked),
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
      actCurrency: ccyCode?.ccyCode ??"USD",
      accStatus: statusValue,
      accCreditLimit: accountLimit.text.cleanAmount,
      actSignatory: widget.perId,
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
