import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/features/role_dropdown.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/features/individuals_dropdown.dart';

class AddUserView extends StatelessWidget {
  const AddUserView({super.key});

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
  final TextEditingController usrName = TextEditingController();
  final TextEditingController usrEmail = TextEditingController();
  final TextEditingController usrPas = TextEditingController();
  final TextEditingController passConfirm = TextEditingController();

  UserRole? _selectedRole;
  bool isPasswordSecure = true;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return ZFormDialog(
      width: 600,
      icon: Icons.lock_clock_sharp,
      onAction: () {
        if(formKey.currentState!.validate()){

        }
      },
      actionLabel: Text(locale.create),
      title: locale.addUserTitle,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                Row(
                  spacing: 5,
                  children: [
                    Expanded(
                      flex: 4,
                      child: ZTextFieldEntitled(
                        isRequired: true,
                        controller: usrName,
                        validator: (e) {
                          if (e.isEmpty) {
                            return locale.required(locale.username);
                          }if(e.isNotEmpty){
                            return Utils.validateUsername(value: e,context: context);
                          }
                          return null;
                        },
                        title: locale.username,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: UserRoleDropdown(
                        onRoleSelected: (UserRole role) {
                          setState(() {
                            _selectedRole = role;
                          });
                        },
                      ),
                    ),

                  ],
                ),
                StakeholdersDropdown(

                    isMulti: false,
                    title: locale.userOwner,
                    onSingleChanged: (e){},
                    onMultiChanged: (e){}),
                ZTextFieldEntitled(
                  isRequired: true,
                  controller: usrEmail,
                  validator: (e) {
                    if (e.isEmpty) {
                      return locale.required(locale.email);
                    }if(e.isNotEmpty){
                      return Utils.validateEmail(email: e, context: context);
                    }
                    return null;
                  },
                  title: locale.email,
                ),
                Row(
                  spacing: 3,
                 children: [
                   Expanded(
                     child: ZTextFieldEntitled(
                       isRequired: true,
                       controller: usrPas,
                       validator: (e){
                         if(e.isEmpty){
                           return locale.required(locale.password);
                         }if(e.isNotEmpty){
                          return Utils.validatePassword(value: e,context: context);
                         }
                         return null;
                       },
                       title: locale.password,
                       trailing: IconButton(
                         onPressed: () {
                           setState(() {
                             isPasswordSecure = !isPasswordSecure;
                           });
                         },
                         icon: Icon(
                           isPasswordSecure
                               ? Icons.visibility_off
                               : Icons.visibility,
                         ),
                       ),
                     ),
                   ),
                   Expanded(
                     child: ZTextFieldEntitled(
                       isRequired: true,
                       controller: passConfirm,
                       validator: (e) {
                         if (e.isEmpty) {
                           return locale.required(locale.confirmPassword);
                         }if(usrPas.text != passConfirm.text){
                           return locale.passwordNotMatch;
                         }
                         return null;
                       },
                       title: locale.confirmPassword,
                       trailing: IconButton(
                         onPressed: () {
                           setState(() {
                             isPasswordSecure = !isPasswordSecure;
                           });
                         },
                         icon: Icon(
                           isPasswordSecure
                               ? Icons.visibility_off
                               : Icons.visibility,
                         ),
                       ),
                     ),
                   ),
                 ],
               ),
                SizedBox(height: 5),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
