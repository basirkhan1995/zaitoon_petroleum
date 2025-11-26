import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:flutter/services.dart';
import '../../../../../../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../Branches/bloc/branch_bloc.dart';
import '../../../Branches/model/branch_model.dart';


class BranchOverviewView extends StatelessWidget {
  final BranchModel? selectedBranch;

  const BranchOverviewView({super.key, this.selectedBranch});

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

  final TextEditingController branchName = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController province = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController nationalId = TextEditingController();
  final TextEditingController zipCode = TextEditingController();

  int mailingValue = 1;
  int? addId;
  bool isMailingAddress = true;
  int? branchCode;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Pre-fill for edit mode
    if (widget.model != null) {
      final m = widget.model!;
      branchName.text = m.brcName ?? "";
      branchCode = m.brcId;
      city.text = m.addCity ?? "";
      phone.text = m.brcPhone ??"";
      province.text = m.addProvince ?? "";
      country.text = m.addCountry ?? "";
      zipCode.text = m.addZipCode?.toString() ?? "";
      address.text = m.addName ?? "";
      mailingValue = m.addMailing ?? 0;
      addId = m.addId;
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
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Form(
      key: formKey,
      child: BlocConsumer<BranchBloc, BranchState>(
        listener: (context, state) {
          if (state is BranchSuccessState) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
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
                    
                          SizedBox(height: 20),
                    
                          Spacer(),
                          Row(
                            spacing: 8,
                            children: [
                              ZOutlineButton(
                                  width: 100,
                                  backgroundHover: Theme.of(context).colorScheme.error,
                                  onPressed: ()=> Navigator.of(context).pop(),
                                  icon: Icons.close,
                                  label: Text(locale.cancel)),
                              ZOutlineButton(
                                  width: 110,
                                  isActive: true,
                                  icon: (context.watch<BranchBloc>().state is BranchLoadingState)
                                      ? null : Icons.refresh,
                                  label: (context.watch<BranchBloc>().state is BranchLoadingState)
                                      ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  )
                                      : Text(locale.update),
                                  onPressed: onSubmit
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          );
        },
      ),
    );
  }

  void onSubmit() {
    if (!formKey.currentState!.validate()) return;

    final data = BranchModel(
        brcId: branchCode,
        addCity: city.text,
        addId: addId,
        addCountry: country.text,
        brcName: branchName.text,
        addName: address.text,
        brcPhone: phone.text,
        addMailing: mailingValue,
        addProvince: province.text,
        addZipCode: zipCode.text
    );

    final bloc = context.read<BranchBloc>();
    bloc.add(EditBranchEvent(data));
  }
}
