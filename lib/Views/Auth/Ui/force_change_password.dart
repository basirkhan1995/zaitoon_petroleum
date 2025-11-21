import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Auth/bloc/auth_bloc.dart';
import '../../../Features/Other/responsive.dart';
import '../../../Features/Other/utils.dart';
import '../../../Features/Widgets/button.dart';
import '../../../Features/Widgets/textfield_entitled.dart';
import '../../../Localizations/l10n/translations/app_localizations.dart';
import '../../PasswordSettings/bloc/password_bloc.dart';

class ForceChangePasswordView extends StatelessWidget {
  final String credential;
  const ForceChangePasswordView({super.key,required this.credential});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
        mobile: _Mobile(credential: credential),
        tablet: _Tablet(credential: credential),
        desktop: _Desktop(credential: credential));
  }
}

class _Desktop extends StatefulWidget {
  final String credential;
  const _Desktop({required this.credential});

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {

  final formKey = GlobalKey<FormState>();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();
  bool isSecure = true;
  bool isError = false;
  bool isLoading = false;
  bool isVisible1 = true, isVisible2 = true, isVisible3 = true;
  String error = "";

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: Text(locale.backTitle),
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<AuthBloc>().add(OnResetAuthState());
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
      ),
      body: BlocConsumer<PasswordBloc, PasswordState>(
        listener: (context, state) {
          if(state is PasswordLoadingState){
            isLoading = true;
            error = "";
          }if(state is PasswordErrorState){
            isLoading = false;
            error = state.message;
          }if(state is PasswordResetSuccessState){
            isLoading = false;
            error = "";
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return Center(
            child: Container(
              width: 450,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8)
              ),
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                locale.changePasswordTitle,
                                style: TextStyle(
                                  fontSize: 25,
                                  color:
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Text(
                                locale.forceChangePasswordHint,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ZTextFieldEntitled(
                      controller: newPassword,
                      title: AppLocalizations.of(context)!.newPasswordTitle,
                      isRequired: true,
                      securePassword: isVisible2,
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            isVisible2 = !isVisible2;
                          });
                        },
                        icon: Icon(
                          !isVisible2
                              ? Icons.visibility
                              : Icons.visibility_off_rounded,
                          size: 18,
                        ),
                      ),
                      validator: (value) {
                        if(value.isEmpty){
                          return locale.required(locale.password);
                        }if(value.isNotEmpty){
                          Utils.validatePassword(
                            value: value,
                            context: context,
                          );
                        }return null;
                      },
                    ),
                    ZTextFieldEntitled(
                      controller: confirmPassword,
                      title: AppLocalizations.of(context)!.confirmPassword,
                      isRequired: true,
                      securePassword: isVisible3,
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            isVisible3 = !isVisible3;
                          });
                        },
                        icon: Icon(
                          !isVisible3
                              ? Icons.visibility
                              : Icons.visibility_off_rounded,
                          size: 18,
                        ),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context)!.required(
                            locale.confirmPassword,
                          );
                        } else if (newPassword.text != confirmPassword.text) {
                          return locale.passwordNotMatch;
                        }
                        return null;
                      },
                    ),

                    error.isEmpty
                        ? const SizedBox()
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          error,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ZButton(
                      height: 40,
                      width: MediaQuery.sizeOf(context).width,
                      label: isLoading? CircularProgressIndicator(color: Theme.of(context).colorScheme.surface) : Text(
                        AppLocalizations.of(context)!.changePasswordTitle,
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          // context.read<PasswordCubit>().resetPasswordEvent(
                          //   usrName: widget.credential,
                          //   newPassword: newPassword.text,
                          //   usrEmail: widget.credential,
                          // );
                        }
                      },
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


class _Mobile extends StatelessWidget {
  final String credential;
  const _Mobile({required this.credential});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


class _Tablet extends StatelessWidget {
  final String credential;
  const _Tablet({required this.credential});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

