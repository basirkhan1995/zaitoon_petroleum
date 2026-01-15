import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/desktop_form_nav.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Other/zform_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/bloc/users_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/features/role_dropdown.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/model/user_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Branches/model/branch_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/model/individual_model.dart';
import '../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../features/branch_dropdown.dart';

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
  final TextEditingController usrOwner = TextEditingController();

  UserRole? _selectedRole;
  bool isPasswordSecure = true;
  bool fcpValue = true;
  bool fevValue = true;
  int usrOwnerId = 1;
  BranchModel? selectedBranch;

  final formKey = GlobalKey<FormState>();
  String? errorMessage;



  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final isLoading = context.watch<UsersBloc>().state is UsersLoadingState;

    return ZFormDialog(
      width: 650,
      icon: Icons.lock_clock_sharp,
      onAction: onSubmit,
      actionLabel: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: Theme.of(context).colorScheme.surface,
              ),
            )
          : Text(locale.create),
      title: locale.addUserTitle,
      child: BlocListener<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UsersErrorState) {
            setState(() {
              errorMessage = state.message; // store message locally
            });
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FormNavigation(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 5,
                      children: [
                        Expanded(
                          flex: 4,
                          child: ZTextFieldEntitled(
                            isRequired: true,
                            controller: usrName,
                            hint: "e.g zaitoon",
                            onSubmit: (_)=> onSubmit(),
                            validator: (e) {
                              if (e.isEmpty) {
                                return locale.required(locale.username);
                              }
                              if (e.isNotEmpty) {
                                return Utils.validateUsername(
                                  value: e,
                                  context: context,
                                );
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 8,
                      children: [
                        Expanded(
                          flex: 3,
                          child: GenericTextfield<IndividualsModel, IndividualsBloc, IndividualsState>(
                            showAllOnFocus: true,
                            controller: usrOwner,
                            title: locale.individuals,
                            hintText: locale.userOwner,
                            isRequired: true,
                            bloc: context.read<IndividualsBloc>(),
                            fetchAllFunction: (bloc) => bloc.add(LoadIndividualsEvent()),
                            searchFunction: (bloc, query) => bloc.add(SearchIndividualsEvent(query)),
                            validator: (value) {
                              if (value.isEmpty) {
                                return locale.required(locale.individuals);
                              }
                              return null;
                            },
                            itemBuilder: (context, account) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 5,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${account.perName} ${account.perLastName}",
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            itemToString: (ind) => "${ind.perName} ${ind.perLastName}",
                            stateToLoading: (state) => state is IndividualLoadingState,
                            loadingBuilder: (context) => const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
              
                            stateToItems: (state) {
                              if (state is IndividualLoadedState) {
                                return state.individuals;
                              }
                              return [];
                            },
                            onSelected: (value) {
                              setState(() {
                                usrOwnerId = value.perId!;
                              });
                            },
                            noResultsText: locale.noDataFound,
                            showClearButton: true,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: BranchDropdown(
                            title: locale.branch,
                            onBranchSelected: (branch) {
                              selectedBranch = branch;
                            },
                          ),
                        ),
              
              
                      ],
                    ),
              
                    ZTextFieldEntitled(
                      isRequired: true,
                      controller: usrEmail,
                      hint: 'example@zaitoonsoft.com',
                      onSubmit: (_)=> onSubmit(),
                      validator: (e) {
                        if (e.isEmpty) {
                          return locale.required(locale.email);
                        }
                        if (e.isNotEmpty) {
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
                            securePassword: isPasswordSecure,
                            controller: usrPas,
                            onSubmit: (_)=> onSubmit(),
                            validator: (e) {
                              if (e.isEmpty) {
                                return locale.required(locale.password);
                              }
                              if (e.isNotEmpty) {
                                return Utils.validatePassword(
                                  value: e,
                                  context: context,
                                );
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
                            securePassword: isPasswordSecure,
                            controller: passConfirm,
                            onSubmit: (_)=> onSubmit(),
                            validator: (e) {
                              if (e.isEmpty) {
                                return locale.required(locale.confirmPassword);
                              }
                              if (usrPas.text != passConfirm.text) {
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
                    Row(
                      spacing: 5,
                      children: [
                        Switch.adaptive(
                            value: fcpValue,
                            onChanged: (value){
                              setState(() {
                                fcpValue = value;
                              });
                            }),
                         Text(locale.forceChangePasswordTitle,style: Theme.of(context).textTheme.titleSmall),
                      ],
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Switch.adaptive(
              
                            value: fevValue,
                            onChanged: (value){
                              setState(() {
                                fevValue = value;
                              });
                            }),
                        Text(locale.forceEmailVerificationTitle,style: Theme.of(context).textTheme.titleSmall),
                      ],
                    ),
                    SizedBox(height: 10),
                    if (errorMessage != null && errorMessage!.isNotEmpty)
                      Row(
                        spacing: 5,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          Text(
                            errorMessage ?? "",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onSubmit() {
    if (formKey.currentState!.validate()) {
      context.read<UsersBloc>().add(
        AddUserEvent(
          UsersModel(
            usrName: usrName.text.trim(),
            usrPass: usrPas.text,
            usrBranch: selectedBranch?.brcId ?? 1000,
            usrRole: _selectedRole?.name,
            usrEmail: usrEmail.text,
            usrFcp: fcpValue,
            usrFev: fevValue,
            usrOwner: usrOwnerId,
          ),
        ),
      );
    }
  }
}
