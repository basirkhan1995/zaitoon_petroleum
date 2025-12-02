import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/model/com_model.dart';
import 'dart:typed_data';
import '../../../../../../../Features/Other/crop.dart';
import '../../../../../../../Features/Other/sections.dart';
import '../../../../../../../Features/Other/utils.dart';
import '../../../../../../../Features/Widgets/button.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';

class CompanySettingsView extends StatelessWidget {
  const CompanySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
        mobile: _Mobile(), tablet: _Tablet(), desktop: _Desktop());
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
  final TextEditingController businessName = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController comDetails = TextEditingController();
  final TextEditingController website = TextEditingController();
  final TextEditingController phone2 = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController province = TextEditingController();
  final TextEditingController baseCurrency = TextEditingController();
  final TextEditingController comFb = TextEditingController();
  final TextEditingController comInsta = TextEditingController();
  final TextEditingController comWhatsApp = TextEditingController();
  final TextEditingController comZipCode = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController comLicense = TextEditingController();

  CompanySettingsModel? loadedCompany;

  bool isUpdateMode = false;
  Uint8List _companyLogo = Uint8List(0);
  int? comId;

  Future<void> _pickLogoImage() async {
    final bloc = context.read<CompanyProfileBloc>();  // SAFELY STORE BEFORE AWAIT

    final imageBytes = await Utils.pickImage();
    if (imageBytes == null || imageBytes.isEmpty) return;

    try {
      if (!mounted) return;
      final croppedBytes = await showImageCropper(
        context: context,
        imageBytes: imageBytes,
      );

      if (!mounted || croppedBytes == null || croppedBytes.isEmpty) return;

      setState(() => _companyLogo = croppedBytes);
      bloc.add(UploadCompanyLogoEvent(croppedBytes));
    } catch (e) {
      debugPrint('Image crop failed: $e');
    }

  }

  @override
  void initState() {
    _initializeData();
    super.initState();
  }

  void _initializeData() {
    final state = context.read<CompanyProfileBloc>().state;
    if (state is CompanyProfileLoadedState) {
      _updateControllers(state);
    }
  }

  void _updateControllers(CompanyProfileLoadedState state) {
    businessName.text = state.company.comName ?? "";
    address.text = state.company.addName ?? "";
    email.text = state.company.comEmail ?? "";
    phone.text = state.company.comPhone ?? "";
    website.text = state.company.comWebsite ?? "";
    comDetails.text = state.company.comDetails ?? "";
    comWhatsApp.text = state.company.comWhatsapp ??"";
    comInsta.text = state.company.comInsta ?? "";
    comFb.text = state.company.comFb ?? "";
    comLicense.text = state.company.comLicenseNo??"";
    comDetails.text = state.company.comSlogan??"";
    comZipCode.text = state.company.addZipCode??"";
    city.text = state.company.addCity??"";
    province.text = state.company.addProvince??"";
    country.text = state.company.addCountry??"";
    loadedCompany = state.company;
    final base64Logo = state.company.comLogo;
    if (base64Logo != null && base64Logo.isNotEmpty) {
      try {
        _companyLogo = base64Decode(base64Logo);
      } catch (e) {
        _companyLogo = Uint8List(0);
      }
    }
  }

  void _cancelUpdate() {
    final state = context.read<CompanyProfileBloc>().state;
    if (state is CompanyProfileLoadedState) {
      _updateControllers(state);
    }
    setState(() {
      isUpdateMode = false;
    });
  }

  void _updateCompanyProfile() {
    context.read<CompanyProfileBloc>().add(UpdateCompanyProfileEvent(
      CompanySettingsModel(
        comName: businessName.text,
        comWebsite: website.text,
        comEmail: email.text,
        comDetails: comDetails.text,
        comId: 1,
        addCity: city.text,
        addName: address.text,
        addProvince: province.text,
        comFb: comFb.text,
        comInsta: comInsta.text,
        comPhone: phone.text,
        comSlogan: comDetails.text,
        comWhatsapp: comWhatsApp.text,
        addCountry: country.text,
        addZipCode: comZipCode.text,
        comLicenseNo: comLicense.text,
        comAddress: loadedCompany?.comAddress,
      ),
    ));
  }

  void changeImage(){

  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocConsumer<CompanyProfileBloc, CompanyProfileState>(
          listener: (context, state) {
            if (state is CompanyProfileErrorState) {
              Utils.showOverlayMessage(context, message: state.message, isError: true);
            }

            if (state is CompanyProfileLoadedState) {
              // Update form fields with new data
              _updateControllers(state);

              // Exit update mode after successful update
              if (isUpdateMode) {
                setState(() {
                  isUpdateMode = false;
                });
                Utils.showOverlayMessage(context, message: "Successfully updated", isError: false);
              }
            }
          },
        builder: (context, state) {
          if (state is CompanyProfileLoadingState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is CompanyProfileErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 8),
                  Text(state.message),
                ],
              ),
            );
          }

          if (state is CompanyProfileLoadedState) {
            loadedCompany = state.company;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header & Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: .09),
                                  ),
                                ),
                                child: (_companyLogo.isEmpty)
                                    ? Image.asset("assets/images/zaitoonLogo.png")
                                    : Image.memory(_companyLogo),
                              ),
                              if (isUpdateMode)
                                Positioned(
                                  top: 82,
                                  left: 82,
                                  child: IconButton(
                                    onPressed: _pickLogoImage,
                                    icon: Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.surface,
                                          borderRadius: BorderRadius.circular(3),
                                          border: Border.all(
                                              color: Theme.of(context).colorScheme.primary
                                          )
                                      ),
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.company.comName ?? "",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (state.company.comEmail != null && state.company.comEmail!.isNotEmpty)
                                Text(state.company.comEmail ?? ""),
                              if (state.company.comPhone != null && state.company.comPhone!.isNotEmpty)
                                Text(state.company.comPhone ?? ""),
                            ],
                          )
                        ],
                      ),
                      Row(
                        spacing: 8,
                        children: [
                          if (!isUpdateMode)
                            ZOutlineButton(
                              width: 110,
                              icon: Icons.edit,
                              label: Text(locale.edit),
                              onPressed: () {
                                setState(() {
                                  isUpdateMode = true;
                                });
                              },
                            ),
                          if (isUpdateMode)
                            ZOutlineButton(
                              width: 110,
                              icon: Icons.clear,
                              backgroundHover: Theme.of(context).colorScheme.error,
                              label: Text(locale.cancel),
                              onPressed: _cancelUpdate,
                            ),
                          if (isUpdateMode)
                            ZButton(
                              width: 120,
                              label: Text(locale.saveChanges),
                              onPressed: _updateCompanyProfile,
                            ),
                        ],
                      )
                    ],
                  ),

                  SizedBox(height: 5),
                  Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: .3)),
                  SizedBox(height: 5),

                  SectionFormLayout(
                    title: AppLocalizations.of(context)!.address,
                    subtitle: locale.addressHint,
                    trailing: SizedBox(),
                    formFields: [
                      ZTextFieldEntitled(
                        readOnly: !isUpdateMode,
                        controller: address,
                        title: locale.address,
                        validator: (value){
                          if(value.isEmpty){
                            return locale.required(locale.address);
                          }
                          return null;
                        },
                      ),
                      Row(
                        spacing: 5,
                        children: [
                          Expanded(
                            child: ZTextFieldEntitled(
                              readOnly: !isUpdateMode,
                              controller: city,
                              title: locale.city,
                            ),
                          ),

                          Expanded(
                            child: ZTextFieldEntitled(
                              readOnly: !isUpdateMode,
                              controller: province,
                              title: locale.province,
                            ),
                          ),
                          Expanded(
                            child: ZTextFieldEntitled(
                              readOnly: !isUpdateMode,
                              controller: country,
                              title: locale.country,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 5,
                        children: [
                          Expanded(
                            child: ZTextFieldEntitled(
                              readOnly: !isUpdateMode,
                              controller: phone,
                              title: locale.mobile1,
                            ),
                          ),
                          Expanded(
                            child: ZTextFieldEntitled(
                              readOnly: !isUpdateMode,
                              controller: comWhatsApp,
                              title: locale.whatsApp,
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                  SizedBox(height: 5),
                  Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: .3)),
                  SizedBox(height: 5),
                  SectionFormLayout(
                    title: AppLocalizations.of(context)!.socialMedia,
                    subtitle: AppLocalizations.of(context)!.profileHint,
                    trailing: SizedBox(),
                    formFields: [
                      Row(
                        spacing: 5,
                        children: [
                          Expanded(
                            child: ZTextFieldEntitled(
                              readOnly: !isUpdateMode,
                              controller: website,
                              title: AppLocalizations.of(context)!.website,
                            ),
                          ),

                          Expanded(
                            child: ZTextFieldEntitled(
                              readOnly: !isUpdateMode,
                              controller: email,
                              title: AppLocalizations.of(context)!.email,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 5,
                        children: [
                          Expanded(
                            child: ZTextFieldEntitled(
                              readOnly: !isUpdateMode,
                              controller: comFb,
                              title: AppLocalizations.of(context)!.facebook,
                            ),
                          ),

                          Expanded(
                            child: ZTextFieldEntitled(
                              readOnly: !isUpdateMode,
                              controller: comInsta,
                              title: AppLocalizations.of(context)!.instagram,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: .3)),
                  SizedBox(height: 5),
                  SectionFormLayout(
                    title: AppLocalizations.of(context)!.comDetails,
                    subtitle: locale.addressHint,
                    trailing: SizedBox(),
                    formFields: [
                      Row(
                        spacing: 5,
                        children: [
                          Expanded(
                            child: ZTextFieldEntitled(
                              controller: comLicense,
                              title: locale.comLicense,
                            ),
                          ),
                          Expanded(
                            child: ZTextFieldEntitled(
                              controller: comZipCode,
                              title: locale.zipCode,
                            ),
                          ),
                        ],
                      ),
                      ZTextFieldEntitled(
                        readOnly: !isUpdateMode,
                        controller: comDetails,
                        keyboardInputType: TextInputType.multiline,
                        title: locale.comDetails,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

