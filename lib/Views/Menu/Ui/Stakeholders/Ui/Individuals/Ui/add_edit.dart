import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/image_helper.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Other/zform_dialog.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import '../../../../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import 'package:flutter/services.dart';
import '../individual_model.dart';

class IndividualAddEditView extends StatelessWidget {
  final IndividualsModel? model;

  const IndividualAddEditView({super.key, this.model});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(model: model),
      tablet: _Tablet(model: model),
      desktop: _Desktop(model: model),
    );
  }
}

class _Mobile extends StatelessWidget {
  final IndividualsModel? model;

  const _Mobile({this.model});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Tablet extends StatelessWidget {
  final IndividualsModel? model;

  const _Tablet({this.model});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Desktop extends StatefulWidget {
  final IndividualsModel? model;

  const _Desktop({this.model});

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  // Controllers
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController province = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController nationalId = TextEditingController();
  final TextEditingController zipCode = TextEditingController();

  String gender = "Male";
  int mailingValue = 1;
  bool isMailingAddress = true;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Pre-fill for edit mode
    if (widget.model != null) {
      final m = widget.model!;
      firstName.text = m.perName ?? "";
      lastName.text = m.perLastName ?? "";
      phone.text = m.perPhone ?? "";
      nationalId.text = m.perEnidNo ?? "";
      city.text = m.addCity ?? "";
      province.text = m.addProvince ?? "";
      country.text = m.addCountry ?? "";
      zipCode.text = m.addZipCode?.toString() ?? "";
      address.text = m.addName ?? "";
      gender = m.perGender ?? "Male";
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
    firstName.dispose();
    lastName.dispose();
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
      (context.watch<IndividualsBloc>().state is IndividualLoadingState)
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ImageHelper.stakeholderProfile(
                        size: 100,
                        shapeStyle: ShapeStyle.roundedRectangle,
                        imageName: widget.model?.imageProfile),

                     IconButton(
                         onPressed: ()=> pickAndUploadImage(widget.model!.perId!),
                         icon: Icon(Icons.camera_alt)),
                  ],
                ),
                SizedBox(height: 10),
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
                        title: locale.lastName,
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

                ZTextFieldEntitled(
                  controller: email,
                  validator: (value)=> Utils.validateEmail(email: value,context: context),
                  title: locale.email,
                  onSubmit: (_) => onSubmit(),
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


                ZTextFieldEntitled(
                  controller: address,
                  title: locale.address,
                  onSubmit: (_) => onSubmit(),
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


                Row(
                  children: [
                    Checkbox(
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
              ],
            );
          },
        ),
      ),
    );
  }

  void pickAndUploadImage(int perId) async {
    // Pick image
    Uint8List? imageBytes = await Utils.pickImage();

    if (imageBytes != null && imageBytes.isNotEmpty) {

      // Trigger Bloc event
      context.read<IndividualsBloc>().add(
        UploadIndProfileImageEvent(
          perId: perId,
          image: imageBytes,
        ),
      );
    } else {
      // User cancelled or empty file
      print("No image selected or image is empty");
    }
  }



  void onSubmit() {
    if (!formKey.currentState!.validate()) return;

    final data = IndividualsModel(
      perId: widget.model?.perId,
      perName: firstName.text,
      perLastName: lastName.text,
      perPhone: phone.text,
      perEnidNo: nationalId.text,
      perGender: gender,
      perDoB: DateTime.now(),
      addName: address.text,
      addMailing: mailingValue,
      addZipCode: zipCode.text,
      addProvince: province.text,
      addCountry: country.text,
      addId: widget.model?.perAddress,
      addCity: city.text,
    );

    final bloc = context.read<IndividualsBloc>();

    if (widget.model == null) {
      bloc.add(AddIndividualEvent(data));
    } else {
      bloc.add(EditIndividualEvent(data));
    }
  }
}
