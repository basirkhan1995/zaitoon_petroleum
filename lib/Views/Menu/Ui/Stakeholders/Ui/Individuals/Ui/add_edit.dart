import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/image_helper.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Other/zform_dialog.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import '../../../../../../../Features/Other/crop.dart';
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
  Uint8List? selectedImageBytes;

  String gender = "Male";
  int mailingValue = 1;
  bool isMailingAddress = true;
  String? imageName;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Pre-fill for edit mode
    if (widget.model != null) {
      final m = widget.model!;
      firstName.text = m.perName ?? "";
      imageName = m.imageProfile??"";
      lastName.text = m.perLastName ?? "";
      phone.text = m.perPhone ?? "";
      nationalId.text = m.perEnidNo ?? "";
      city.text = m.addCity ?? "";
      province.text = m.addProvince ?? "";
      country.text = m.addCountry ?? "";
      zipCode.text = m.addZipCode?.toString() ?? "";
      address.text = m.addName ?? "";
      gender = m.perGender ?? "Male";
      email.text = m.perEmail ?? "";
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
    email.dispose();
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
                if (isEdit)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // GestureDetector(
                    //   onTap: ()=> pickAndShowImage(widget.model!.perId!,context),
                    //   child: ImageHelper.stakeholderProfile(
                    //     imageName: imageName,
                    //     localImageBytes: selectedImageBytes,
                    //     size: 110,
                    //     border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: .3)),
                    //     shapeStyle: ShapeStyle.roundedRectangle,
                    //     showCameraIcon: true,
                    //   ),
                    // )

                    GestureDetector(
                      onTap: () => pickAndCropImage(widget.model!.perId!),
                      child: ImageHelper.stakeholderProfile(
                        imageName: imageName,
                        localImageBytes: selectedImageBytes,
                        size: 110,
                        border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: .3)
                        ),
                        shapeStyle: ShapeStyle.roundedRectangle,
                        showCameraIcon: true,
                      ),
                    )

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

  void pickAndCropImage(int perId) async {
    // Capture bloc and navigator BEFORE any async gap
    final bloc = context.read<IndividualsBloc>();

    // Pick image
    final imageBytes = await Utils.pickImage();
    if (imageBytes == null || imageBytes.isEmpty) return;

    try {
      // Show cropper in a safe way
      Uint8List? croppedBytes;
      if (mounted) {
        croppedBytes = await showImageCropper(
          context: context, // OK because mounted check
          imageBytes: imageBytes,
        );
      }

      if (!mounted || croppedBytes == null || croppedBytes.isEmpty) return;

      // Update UI immediately
      setState(() => selectedImageBytes = croppedBytes);

      // Upload to bloc
      bloc.add(UploadIndProfileImageEvent(perId: perId, image: croppedBytes));
    } catch (e) {
      debugPrint("Image crop failed: $e");
    }
  }



  // void pickAndShowImage(int perId, BuildContext context) async {
  //   final bloc = context.read<IndividualsBloc>();
  //   final imageBytes = await Utils.pickImage();
  //
  //   if (imageBytes != null && imageBytes.isNotEmpty) {
  //     setState(() {
  //       selectedImageBytes = imageBytes; // Show immediately
  //     });
  //
  //     bloc.add(
  //       UploadIndProfileImageEvent(perId: perId, image: imageBytes),
  //     );
  //   }
  // }



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
      perEmail: email.text,
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
