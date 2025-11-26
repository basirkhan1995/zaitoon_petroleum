import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/zform_dialog.dart';
import 'package:flutter/services.dart';
import '../../../../../../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../bloc/branch_bloc.dart';
import '../model/branch_model.dart';

class BranchAddEditView extends StatelessWidget {
  final BranchModel? selectedBranch;

  const BranchAddEditView({super.key, this.selectedBranch});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(model: selectedBranch),
      tablet: _Tablet(model: selectedBranch),
      desktop: _Desktop(model: selectedBranch),
    );
  }
}

class _Mobile extends StatelessWidget {
  final BranchModel? model;

  const _Mobile({this.model});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Tablet extends StatelessWidget {
  final BranchModel? model;

  const _Tablet({this.model});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Desktop extends StatefulWidget {
  final BranchModel? model;

  const _Desktop({this.model});

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  // Controllers
  final TextEditingController branchName = TextEditingController();
  final TextEditingController branchCode = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController province = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController nationalId = TextEditingController();
  final TextEditingController zipCode = TextEditingController();

  int mailingValue = 1;
  bool isMailingAddress = true;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Pre-fill for edit mode
    if (widget.model != null) {
      final m = widget.model!;
      branchName.text = m.brcName ?? "";
      branchCode.text = m.brcId.toString();
      city.text = m.addCity ?? "";
      province.text = m.addProvince ?? "";
      country.text = m.addCountry ?? "";
      zipCode.text = m.addZipCode?.toString() ?? "";
      address.text = m.addName ?? "";
      mailingValue = m.addMailing ?? 1;
      isMailingAddress = mailingValue == 1;
    }
  }

  @override
  void dispose() {
    country.dispose();
    city.dispose();
    zipCode.dispose();
    address.dispose();
    nationalId.dispose();
    province.dispose();
    branchName.dispose();
    branchCode.dispose();
    phone.dispose();
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
      (context.watch<BranchBloc>().state is BranchLoadingState)
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
        child: BlocConsumer<BranchBloc, BranchState>(
          listener: (context, state) {
            if (state is BranchSuccessState) {
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ZTextFieldEntitled(
                  controller: branchName,
                  isRequired: true,
                  title: locale.branchName,
                  onSubmit: (_) => onSubmit(),
                  validator: (value) {
                    if (value.isEmpty) {
                      return locale.required(locale.branchName);
                    }
                    return null;
                  },
                ),

                Row(
                  spacing: 5,
                  children: [

                    Expanded(
                      flex: 3,
                      child: ZTextFieldEntitled(
                        controller: phone,
                        title: locale.mobile1,
                        inputFormat: [FilteringTextInputFormatter.digitsOnly],
                        onSubmit: (_) => onSubmit(),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ZTextFieldEntitled(
                        controller: zipCode,
                        title: locale.zipCode,
                        inputFormat: [FilteringTextInputFormatter.digitsOnly],
                        onSubmit: (_) => onSubmit(),
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    Expanded(
                      child: ZTextFieldEntitled(
                        controller: city,
                        title: locale.city,
                        onSubmit: (_) => onSubmit(),
                      ),
                    ),
                    Expanded(
                      child: ZTextFieldEntitled(
                        controller: province,
                        title: locale.province,
                        onSubmit: (_) => onSubmit(),
                      ),
                    ),
                    Expanded(
                      child: ZTextFieldEntitled(
                        controller: country,
                        title: locale.country,
                        onSubmit: (_) => onSubmit(),
                      ),
                    ),
                  ],
                ),

                ZTextFieldEntitled(
                  controller: address,
                  keyboardInputType: TextInputType.multiline,
                  maxLength: 100,
                  title: locale.address,
                  onSubmit: (_) => onSubmit(),
                ),

                Row(
                  spacing: 8,
                  children: [
                    Checkbox(
                      visualDensity: VisualDensity(horizontal: -4,vertical: -4),
                      value: isMailingAddress,
                      onChanged: (value) {
                        setState(() {
                          isMailingAddress = value ?? true;
                          mailingValue = isMailingAddress ? 1 : 0;
                        });
                      },
                    ),
                    Text(locale.isMilling),
                  ],
                ),
                SizedBox(height: 10)
              ],
            );
          },
        ),
      ),
    );
  }

  void onSubmit() {
    if (!formKey.currentState!.validate()) return;

    final data = BranchModel(
      brcId: widget.model?.brcId,
      brcName: branchName.text,
      addName: address.text,
      brcPhone: phone.text,
      addMailing: mailingValue,
      addZipCode: zipCode.text,
      addProvince: province.text,
      addCountry: country.text,
      addId: widget.model?.addId,
      addCity: city.text,
    );

    final bloc = context.read<BranchBloc>();

    if (widget.model == null) {
      bloc.add(AddBranchEvent(data));
    } else {
      bloc.add(EditBranchEvent(data));
    }
  }
}
