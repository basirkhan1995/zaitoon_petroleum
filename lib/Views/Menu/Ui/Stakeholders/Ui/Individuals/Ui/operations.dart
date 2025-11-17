import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import '../../../../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import 'package:flutter/services.dart';

import '../individual_model.dart';


class IndividualAddEditView extends StatelessWidget {
  const IndividualAddEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(),
    );
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
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController province = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController nationalId = TextEditingController();
  final TextEditingController zipCode = TextEditingController();


  String gender = "Male";
  bool isMailingAddress = true;

  int mailingValue = 1;
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    country.dispose();
    city.dispose();
    zipCode.dispose();
    address.dispose();
    nationalId.dispose();
    province.dispose();
    firstName.dispose();
    lastName.dispose();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context).colorScheme;

    return ZFormDialog(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      width: 550,
      actionLabel: (context.watch<IndividualsBloc>().state is IndividualLoadingState)
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: theme.surface,
        ),
      )
          : Text(locale.create),

      onAction: onSubmit,
      title: locale.newKeyword,
      child: Form(
        key: formKey,
        child: BlocConsumer<IndividualsBloc, IndividualsState>(
          listener: (context, state) {
            if(state is IndividualSuccessState){
             Navigator.of(context).pop();
            }
          },
          builder: (context, state) {

            return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        child: ZTextFieldEntitled(
                          controller: firstName,
                          isRequired: true,
                          title: locale.firstName,
                          onSubmit: (_) => onSubmit(),
                          validator: (value) {
                            if (value.isEmpty) {
                              return locale.required(locale.firstName);
                            }
                            return null;
                          },
                        ),
                      ),

                      Expanded(
                        child: ZTextFieldEntitled(
                          controller: lastName,
                          isRequired: true,
                          title: AppLocalizations.of(context)!.lastName,
                          onSubmit: (_) => onSubmit(),
                          validator: (value) {
                            if (value.isEmpty) {
                              return locale.required(locale.lastName);
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        child: ZTextFieldEntitled(
                          controller: phone,
                          inputFormat: [FilteringTextInputFormatter.digitsOnly],
                          title: locale.cellNumber,
                          onSubmit: (_) => onSubmit(),
                        ),
                      ),

                      Expanded(
                        child: ZTextFieldEntitled(
                          controller: nationalId,
                          inputFormat: [FilteringTextInputFormatter.digitsOnly],
                          title: locale.nationalId,
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
                    ],
                  ),

                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        flex: 5,
                        child: ZTextFieldEntitled(
                          controller: country,
                          title: locale.country,
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
                  ZTextFieldEntitled(
                    controller: address,
                    keyboardInputType: TextInputType.multiline,
                    maxLength: 100,
                    title: locale.address,
                    onSubmit: (_) => onSubmit(),
                  ),


                  Row(
                    children: [
                      Checkbox(
                        value: isMailingAddress,
                        onChanged: (value) {
                          setState(() {
                            isMailingAddress = !isMailingAddress;
                            isMailingAddress ? mailingValue = 1 : 0;
                          });
                        },
                      ),
                      Text(locale.isMilling),
                    ],
                  ),
                ]

            );
          },
        ),
      ),
    );
  }

  void onSubmit() {
    context.read<IndividualsBloc>().add(AddIndividualEvent(IndividualsModel(
      perName: firstName.text,
      perLastName: lastName.text,
      perPhone: phone.text,
      perEnidNo: nationalId.text,
      perGender: gender,
      perDoB: "1995/01/01",
      address: address.text,
      isMailing: mailingValue,
      zipCode: int.tryParse(zipCode.text),
      province: province.text,
      country: country.text,
      city: city.text,
    )));
  }
}
