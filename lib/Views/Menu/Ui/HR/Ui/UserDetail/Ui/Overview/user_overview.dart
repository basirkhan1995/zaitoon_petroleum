import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/features/branch_dropdown.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/features/role_dropdown.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/model/user_model.dart';

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

  void editOrOverview(){
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  final email = TextEditingController();
  final usrName = TextEditingController();

  @override
  void initState() {
    email.text = widget.user.usrEmail ?? "";
    usrName.text = widget.user.usrName??"";
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeCtrl = Theme.of(context);
    TextStyle? myStyle = textTheme.titleSmall?.copyWith(color: color.outline.withValues(alpha: .8));
    TextStyle? myStyleBody = textTheme.bodyMedium?.copyWith(color: color.onSurface.withValues(alpha: .9));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: AnimatedCrossFade(
        duration: Duration(milliseconds: 500),
        crossFadeState: isEditMode ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: _editView(locale: locale),
        secondChild: _overView(
            locale: locale,
            textTheme: themeCtrl,
            myStyle: myStyle,
            myStyleBody: myStyleBody,
            color: themeCtrl
        ),
      ),
    );
  }

  Widget _overView({required AppLocalizations locale,required ThemeData textTheme, TextStyle? myStyle, TextStyle? myStyleBody, required ThemeData color}){
    return Container(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.colorScheme.primary.withValues(alpha: .4)),
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
                locale.userInformation,
                style: Theme.of(context).textTheme.titleMedium,
              ),

              Material(
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                      highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                      onTap: editOrOverview,
                      child: Icon(Icons.edit)),
                ),
              )
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
                    child: Text(
                        locale.userOwner,
                        style: myStyle
                    ),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 120,
                    child: Text(
                        locale.username,
                        style: myStyle
                    ),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 120,
                    child: Text(
                        locale.usrRole,
                        style: myStyle
                    ),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 120,
                    child: Text(
                        locale.branch,
                        style: myStyle
                    ),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 120,
                    child: Text(
                        locale.createdAt,
                        style: myStyle
                    ),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 120,
                    child: Text(
                        locale.status,
                        style: myStyle
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.user.usrFullName ?? "",style: myStyleBody),
                  SizedBox(height: 5),
                  Text(widget.user.usrName ?? "",style: myStyleBody),
                  SizedBox(height: 5),
                  Text(widget.user.usrRole ?? "",style: myStyleBody),
                  SizedBox(height: 5),
                  Text(widget.user.usrBranch.toString(),style: myStyleBody),
                  SizedBox(height: 5),
                  Text(widget.user.usrEntryDate!.toFullDateTime,style: myStyleBody),
                  SizedBox(height: 5),
                  Switch(value: widget.user.usrStatus == 1, onChanged: (e) {}),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _editView({required AppLocalizations locale}){
    return Container(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale.userInformation,
                style: Theme.of(context).textTheme.titleMedium,
              ),

              Material(
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                      highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                      onTap: editOrOverview,
                      child: Icon(Icons.save)),
                ),
              )
            ],
          ),
          SizedBox(height: 5),
          Row(
            spacing: 8,
            children: [
              Expanded(child: BranchDropdown(onBranchSelected: (e){})),
              Expanded(child: UserRoleDropdown(onRoleSelected: (e){})),
            ],
          ),
          SizedBox(height: 5),
          ZTextFieldEntitled(
            title: locale.username,
            controller: usrName,
            isRequired: true,
            readOnly: true,
          ),
          Row(
            spacing: 5,
            children: [
              Expanded(
                child: ZTextFieldEntitled(
                  title: locale.newPasswordTitle,
                  isRequired: true,
                ),
              ),

              Expanded(
                child: ZTextFieldEntitled(
                  title: locale.confirmPassword,
                  isRequired: true,
                ),
              ),
            ],
          ),

          ZTextFieldEntitled(
            title: locale.email,
            controller: email,
            isRequired: true,
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Switch(value: widget.user.usrStatus == 1, onChanged: (e) {}),
              SizedBox(width: 8),
              Text(locale.status),
            ],
          ),
        ],
      ),
    );
  }
}