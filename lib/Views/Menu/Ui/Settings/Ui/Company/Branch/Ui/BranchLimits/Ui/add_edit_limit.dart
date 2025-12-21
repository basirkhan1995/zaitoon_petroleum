import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/zform_dialog.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/Currencies/model/ccy_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/features/currency_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Branch/Ui/BranchLimits/bloc/branch_limit_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Branch/Ui/BranchLimits/model/limit_model.dart';
import '../../../../../../../../../../Features/Other/thousand_separator.dart';
import '../../../../../../../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../../../../../../../Localizations/l10n/translations/app_localizations.dart';

class BranchLimitAddEditView extends StatelessWidget {
  final BranchLimitModel? branchLimit;
  final int? branchCode;

  const BranchLimitAddEditView({super.key, this.branchLimit,this.branchCode});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(model: branchLimit),
      tablet: _Tablet(model: branchLimit),
      desktop: _Desktop(model: branchLimit,branchCode: branchCode),
    );
  }
}

class _Mobile extends StatelessWidget {
  final BranchLimitModel? model;

  const _Mobile({this.model});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
class _Tablet extends StatelessWidget {
  final BranchLimitModel? model;

  const _Tablet({this.model});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Desktop extends StatefulWidget {
  final BranchLimitModel? model;
  final int? branchCode;

  const _Desktop({this.model,required this.branchCode});

  @override
  State<_Desktop> createState() => _DesktopState();
}
class _DesktopState extends State<_Desktop> {
  // Controllers
  final TextEditingController amountLimit = TextEditingController();
  String currencyCode = "USD";
  bool isUnlimited = false;
  String unlimitedAmount = "9999999999999";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Pre-fill for edit mode
    if (widget.model != null) {
      final m = widget.model!;
      amountLimit.text = m.balLimitAmount!.toAmount();
      currencyCode = m.balCurrency??"";
    }
  }

  @override
  void dispose() {
    amountLimit.dispose();
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
      (context.watch<BranchLimitBloc>().state is BranchLimitLoadingState)
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 4,
          color: theme.surface,
        ),
      )
          : Text(isEdit ? locale.update : locale.create),

      onAction: onSubmit,

      child: Form(
        key: formKey,
        child: BlocConsumer<BranchLimitBloc, BranchLimitState>(
          listener: (context, state) {},
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  spacing: 5,
                  children: [
                    Expanded(
                      child:  ZTextFieldEntitled(
                        isRequired: true,
                         onSubmit: (_)=> onSubmit(),
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
                            return locale.required(locale.amount);
                          }
                          return null;
                        },
                        controller: amountLimit,
                        title: locale.amount,
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: CurrencyDropdown(
                           height: 40,
                          initiallySelected: [],
                          isMulti: false,
                          onMultiChanged: (_){},
                          onSingleChanged: (value){
                             setState(() {
                               currencyCode = value?.ccyCode??"USD";
                             });
                          },
                          title: locale.currencyTitle,
                         initiallySelectedSingle: CurrenciesModel(ccyCode: currencyCode),
                      ),
                    )
                  ],
                ),

                Row(
                  children: [
                    CheckboxMenuButton(
                        value: isUnlimited,
                        onChanged: (_){
                         setState(() {
                           isUnlimited =! isUnlimited;
                           amountLimit.text = isUnlimited? unlimitedAmount : "";
                         });
                        },
                        style: ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 5)),
                          backgroundColor: WidgetStatePropertyAll(theme.surface),
                          overlayColor: WidgetStatePropertyAll(theme.primary.withValues(alpha: .05))
                        ),
                        child: Text("Unlimit"))
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  void onSubmit() {
    if (!formKey.currentState!.validate()) return;

    // Clean formatted number
    final raw = amountLimit.text.replaceAll(RegExp(r'[^\d.]'), '');
    final parsedAmount = double.tryParse(raw) ?? 0;

    final data = BranchLimitModel(
      balBranch: widget.branchCode ?? widget.model?.balBranch,
      balCurrency: currencyCode,
      balLimitAmount: parsedAmount.toString(),
    );

    final bloc = context.read<BranchLimitBloc>();

    if (widget.model == null) {
      bloc.add(AddBranchLimitEvent(data));
    } else {
      bloc.add(EditBranchLimitEvent(data));
    }
  }

}
