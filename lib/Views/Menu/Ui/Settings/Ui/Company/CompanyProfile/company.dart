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

  bool isUpdateMode = false;
  Uint8List _companyLogo = Uint8List(0);
  int? comId;

  // Future<void> _pickLogoImage() async {
  //   final imageBytes = await Utils.pickImage();
  //   if (imageBytes != null && imageBytes.isNotEmpty) {
  //     setState(() {
  //       _companyLogo = imageBytes;
  //     });
  //   }
  // }

  Future<void> _pickLogoImage() async {
    final imageBytes = await Utils.pickImage();
    if (imageBytes == null || imageBytes.isEmpty) return;

    final croppedBytes = await showImageCropper(
      context: context,
      imageBytes: imageBytes,
    );

    if (croppedBytes != null) {
      setState(() {
        _companyLogo = croppedBytes;
      });
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
    // Reset to original values
    final state = context.read<CompanyProfileBloc>().state;
    if (state is CompanyProfileLoadedState) {
      _updateControllers(state);
    }
    setState(() {
      isUpdateMode = false;
    });
  }

  void _updateCompanyProfile() {
    final logoBase64 = _companyLogo.isNotEmpty ? base64Encode(_companyLogo) : null;

    context.read<CompanyProfileBloc>().add(UpdateCompanyProfileEvent(
      CompanySettingsModel(
        comName: businessName.text,
        comWebsite: website.text,
        comEmail: email.text,
        comDetails: comDetails.text,
        comId: comId,
        comLogo: logoBase64,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocConsumer<CompanyProfileBloc, CompanyProfileState>(
          listener: (context, state) {
            if (state is CompanyProfileErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: ${state.message}"),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state is CompanyProfileLoadedState) {
              // Update form fields with new data
              _updateControllers(state);

              // Exit update mode after successful update
              if (isUpdateMode) {
                setState(() {
                  isUpdateMode = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Profile updated successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          },
        builder: (context, state) {
          // Show loading indicator
          if (state is CompanyProfileLoadingState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error state
          if (state is CompanyProfileErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    "Something went wrong",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(state.message),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // context.read<AuthBloc>().add(CheckAuthStatusEvent());
                    },
                    child: Text("Retry"),
                  ),
                ],
              ),
            );
          }

          // Show the main form when authenticated
          if (state is CompanyProfileLoadedState) {
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
                        children: [
                          if (!isUpdateMode)
                            ZOutlineButton(
                              width: 110,
                              label: Text(AppLocalizations.of(context)!.edit),
                              onPressed: () {
                                setState(() {
                                  isUpdateMode = true;
                                });
                              },
                            ),
                          if (isUpdateMode)
                            ZOutlineButton(
                              width: 110,
                              backgroundHover: Theme.of(context).colorScheme.error,
                              label: Text(AppLocalizations.of(context)!.cancel),
                              onPressed: _cancelUpdate,
                            ),
                          if (isUpdateMode)
                            ZButton(
                              width: 110,
                              label: Text(AppLocalizations.of(context)!.update),
                              onPressed: _updateCompanyProfile,
                            ),
                        ],
                      )
                    ],
                  ),

                  SizedBox(height: 5),
                  Divider(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                  ),
                  SizedBox(height: 5),

                  // Company Info Form
                  SectionFormLayout(
                    title: AppLocalizations.of(context)!.profile,
                    subtitle: AppLocalizations.of(context)!.profileHint,
                    trailing: SizedBox(),
                    formFields: [
                      Row(
                        children: [
                          Expanded(
                            child: ZTextFieldEntitled(
                              readOnly: !isUpdateMode,
                              controller: website,
                              title: AppLocalizations.of(context)!.website,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ZTextFieldEntitled(
                              readOnly: !isUpdateMode,
                              controller: email,
                              title: AppLocalizations.of(context)!.email,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SectionFormLayout(
                    title: AppLocalizations.of(context)!.address,
                    subtitle: AppLocalizations.of(context)!.addressHint,
                    trailing: SizedBox(),
                    formFields: [
                      Row(
                        children: [
                          Expanded(
                            child: ZTextFieldEntitled(
                              readOnly: !isUpdateMode,
                              controller: city,
                              title: AppLocalizations.of(context)!.city,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ZTextFieldEntitled(
                              readOnly: !isUpdateMode,
                              controller: province,
                              title: AppLocalizations.of(context)!.province,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ZTextFieldEntitled(
                              readOnly: !isUpdateMode,
                              controller: phone,
                              title: AppLocalizations.of(context)!.mobile1,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ZTextFieldEntitled(
                              readOnly: !isUpdateMode,
                              controller: phone2,
                              title: AppLocalizations.of(context)!.mobile1,
                            ),
                          ),
                        ],
                      ),
                      ZTextFieldEntitled(
                        readOnly: !isUpdateMode,
                        controller: address,
                        keyboardInputType: TextInputType.multiline,
                        title: AppLocalizations.of(context)!.address,
                      ),
                    ],
                  ),
                  SectionFormLayout(
                    title: AppLocalizations.of(context)!.comDetails,
                    subtitle: AppLocalizations.of(context)!.addressHint,
                    trailing: SizedBox(),
                    formFields: [
                      ZTextFieldEntitled(
                        readOnly: !isUpdateMode,
                        controller: comDetails,
                        keyboardInputType: TextInputType.multiline,
                        title: AppLocalizations.of(context)!.comDetails,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          // Fallback - should not reach here normally
          return Center(
            child: Text("Unexpected state"),
          );
        },
      ),
    );
  }
}

