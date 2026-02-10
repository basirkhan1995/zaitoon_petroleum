import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/bloc/users_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/features/branch_dropdown.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/features/role_dropdown.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/model/user_model.dart';

import '../../../../../../../Auth/bloc/auth_bloc.dart';

class UserOverviewView extends StatelessWidget {
  final UsersModel user;
  const UserOverviewView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(user),
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
  final UsersModel user;
  const _Desktop(this.user);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  bool isEditMode = false;
  bool usrFcp = true;
  int? usrStatus;
  int? branchCode;
  String? usrRole;

  final formKey = GlobalKey<FormState>();

  final email = TextEditingController();
  final usrName = TextEditingController();
  final usrPass = TextEditingController();
  final confirmPass = TextEditingController();
  @override
  void initState() {
    email.text = widget.user.usrEmail ?? "";
    usrName.text = widget.user.usrName ?? "";
    usrRole = widget.user.usrRole;
    branchCode = widget.user.usrBranch;
    usrFcp = widget.user.usrFcp == 1;
    usrStatus = widget.user.usrStatus;
    super.initState();
  }

  void toggleEdit() {
    setState(() {
      isEditMode = !isEditMode;
    });
  }
  String? currentUser() {
    try {
      final companyState = context.read<AuthBloc>().state;
      if (companyState is AuthenticatedState) {
        return companyState.loginData.usrName;
      }
      return ""; // Fallback currency
    } catch (e) {
      return ""; // Fallback if provider not available
    }
  }
  void saveChanges() {
    final updatedUser = UsersModel(
      usrName: usrName.text,
      usrEmail: email.text,
      usrPass: usrPass.text,
      usrRole: usrRole,
      usrBranch: branchCode,
      usrFcp: usrFcp ? 1 : 0,
      loggedInUser: currentUser(),
      usrStatus: usrStatus ?? widget.user.usrStatus,
    );

    if(formKey.currentState!.validate()){
      context.read<UsersBloc>().add(UpdateUserEvent(updatedUser));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeCtrl = Theme.of(context);
    TextStyle? myStyle = textTheme.titleSmall?.copyWith(
      color: color.outline.withValues(alpha: .8),
    );
    TextStyle? myStyleBody = textTheme.bodyMedium?.copyWith(
      color: color.onSurface.withValues(alpha: .9),
    );

    final isLoading = context.watch<UsersBloc>().state is UsersLoadingState;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocListener<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UserSuccessState) {
            setState(() {
              isEditMode = false;
            });
          }
        },
        child: AnimatedCrossFade(
          duration: Duration(milliseconds: 500),
          crossFadeState: isEditMode
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _editView(locale: tr, isLoading: isLoading),
          secondChild: _overView(
            tr: tr,
            textTheme: themeCtrl,
            myStyle: myStyle,
            myStyleBody: myStyleBody,
            color: themeCtrl,
          ),
        ),
      ),
    );
  }

  Widget _overView({
    required AppLocalizations tr,
    required ThemeData textTheme,
    TextStyle? myStyle,
    TextStyle? myStyleBody,
    required ThemeData color,
  }) {
    return BlocListener<UsersBloc, UsersState>(
  listener: (context, state) {
    if(state is UsersErrorState){
       Utils.showOverlayMessage(context,title: tr.accessDenied, message: state.message, isError: true);
    }
  },
  child: Container(
      padding: const EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        color: color.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.colorScheme.outline.withValues(alpha: .4),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr.userInformation,
                style: Theme.of(context).textTheme.titleMedium,
              ),

              Material(
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    hoverColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: .08),
                    highlightColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: .08),
                    onTap: toggleEdit,
                    child: Icon(Icons.edit),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.email, size: 20),
              SizedBox(width: 5),
              Text(widget.user.usrEmail ?? ""),
            ],
          ),
          SizedBox(height: 8),
          Divider(),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(tr.userOwner, style: myStyle),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 120,
                    child: Text(tr.username, style: myStyle),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 120,
                    child: Text(tr.usrRole, style: myStyle),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 120,
                    child: Text(tr.branch, style: myStyle),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 120,
                    child: Text(tr.createdAt, style: myStyle),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 120,
                    child: Text(tr.status, style: myStyle),
                  ),
                ],
              ),
              SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.user.usrFullName ?? "", style: myStyleBody),
                  SizedBox(height: 5),
                  Text(widget.user.usrName ?? "", style: myStyleBody),
                  SizedBox(height: 5),
                  Text(widget.user.usrRole ?? "", style: myStyleBody),
                  SizedBox(height: 5),
                  Text(widget.user.usrBranch.toString(), style: myStyleBody),
                  SizedBox(height: 5),
                  Text(
                    widget.user.usrEntryDate!.toFullDateTime,
                    style: myStyleBody,
                  ),
                  SizedBox(height: 5),
                  Text(widget.user.usrStatus == 1? tr.active : tr.blocked)
                ],
              ),
            ],
          ),
        ],
      ),
    ),
);
  }

  Widget _editView({required AppLocalizations locale, required bool isLoading,}) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),

      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  locale.userInformation,
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                Material(
                  child: Row(
                    spacing: 5,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(5),
                        hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                        highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                        onTap: toggleEdit,
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Icon(Icons.clear),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: 30,
                        child: Tooltip(
                          message: locale.saveChanges,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5),
                            hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                            highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                            onTap: isLoading ? null : saveChanges,
                            child: isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(Icons.check),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 5),
            ZTextFieldEntitled(
              title: locale.username,
              controller: usrName,
              isEnabled: false,
              readOnly: true,
            ),
            SizedBox(height: 5),
            ZTextFieldEntitled(
              isEnabled: false,
              title: locale.email,
              controller: email,
              readOnly: true,
            ),
            SizedBox(height: 5),
            Row(
              spacing: 8,
              children: [
                Expanded(
                    child: BranchDropdown(
                      selectedId: branchCode,

                    onBranchSelected: (e) {
                  setState(() {
                    branchCode = e?.brcId;
                  });
                })),
                Expanded(child: UserRoleDropdown(
                  selectedDatabaseValue: widget.user.usrRole,
                    onRoleSelected: (e) {
                  setState(() {
                    usrRole = e?.name;
                  });
                })),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text("RESET PASSWORD")
              ],
            ),
            Row(
              spacing: 5,
              children: [
                Expanded(
                  child: ZTextFieldEntitled(
                    controller: usrPass,
                    isRequired: false,
                    title: locale.newPasswordTitle,
                  ),
                ),

                Expanded(
                  child: ZTextFieldEntitled(
                    controller: confirmPass,
                    title: locale.confirmPassword,
                    validator: (value){
                      if (usrPass.text.isNotEmpty) {
                        if (value == null || value.isEmpty) {
                          return locale.required(locale.confirmPassword);
                        }
                        if (usrPass.text != confirmPass.text) {
                          return locale.passwordNotMatch;
                        }
                      }
                      return null;
                    },

                  ),
                ),
              ],
            ),

            SizedBox(height: 5),
            Row(
              children: [
                Switch(
                  value: usrStatus == 1,
                  onChanged: (e) {
                    setState(() {
                      usrStatus = e == true ? 1 : 0;
                    });
                  },
                ),
                SizedBox(width: 8),
                Text(usrStatus == 1 ? locale.active : locale.blocked),
              ],
            ),

            SizedBox(height: 5),
            Row(
              children: [
                Switch(
                  value: usrFcp,
                  onChanged: (e) {
                    setState(() {
                      usrFcp = e;
                    });
                  },
                ),
                SizedBox(width: 8),
                Text(locale.forceChangePasswordTitle),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}
