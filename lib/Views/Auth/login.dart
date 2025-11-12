import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/button.dart';
import 'package:zaitoon_petroleum/Views/Auth/ForgotPassword/forgot_password.dart';
import 'package:zaitoon_petroleum/Views/Menu/home.dart';
import '../../Features/Widgets/textfield_entitled.dart';
import '../../Localizations/l10n/translations/app_localizations.dart';
import '../../Localizations/locale_selector.dart';
import '../../Themes/Ui/theme_selector.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isPasswordSecure = true;
  bool isRememberMe = false;

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox.expand(
          child: Column(
            children: [
              /// Header Section (Logo + Language/Theme)
              _zaitoonTitle(context: context),

              /// Spacer pushes body to center
              Expanded(
                child: Center(
                  child: _body(),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _zaitoonTitle({required BuildContext context}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 8,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: Image.asset('assets/images/zaitoonLogo.png'),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                Text(
                  AppLocalizations.of(context)!.zPetroleum,
                  style: TextStyle(
                    fontFamily: "OpenSans",
                    fontWeight: FontWeight.bold,
                    fontSize: 40
                  )
                ),
                Text(
                  AppLocalizations.of(context)!.zaitoonSlogan,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
        // Header - Localization & Theme Selector
        Row(
          spacing: 5,
          children: [ThemeSelector(width: 150), LanguageSelector(width: 150)],
        ),
      ],
    );
  }

  Widget _body() {
    final locale = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: .5),
                blurRadius: 3,
                spreadRadius: .5
              )
            ]
          ),
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    locale.welcomeBoss,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                SizedBox(height: 10),
                ZTextFieldEntitled(
                  controller: _emailController,
                  title: locale.emailOrUsrname,
                  validator: (value) {
                    if (value.isEmpty) {
                      return locale.required(locale.emailOrUsrname);
                    }
                    return null;
                  },
                ),
                SizedBox(height: 5),

                ZTextFieldEntitled(
                  controller: _passwordController,
                  securePassword: isPasswordSecure,
                  title: locale.password,
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordSecure = !isPasswordSecure;
                      });
                    },
                    icon: Icon(
                      isPasswordSecure ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return locale.required(locale.password);
                    }
                    return null;
                  },
                ),

                Row(
                  spacing: 5,
                  children: [
                    Checkbox(
                      visualDensity: VisualDensity(horizontal: -4),
                      value: isRememberMe,
                      onChanged: (e) {
                        setState(() {
                          isRememberMe = !isRememberMe;
                        });
                      },
                    ),
                    Text(locale.rememberMe),
                  ],
                ),

                SizedBox(height: 10),

                ZButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Utils.gotoReplacement(context, HomeView());
                    }
                  },
                  label: Text(AppLocalizations.of(context)!.login),
                ),
                SizedBox(height: 15),
                TextButton(onPressed: () {
                  Utils.goto(context, ForgotPasswordView());
                }, child: Text(locale.forgotPassword)),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 450,
          child: Image.asset('assets/images/login.png'),
        ),
      ],
    );
  }
}
