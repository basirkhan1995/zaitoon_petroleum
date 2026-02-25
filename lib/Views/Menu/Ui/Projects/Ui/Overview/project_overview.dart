import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/section_title.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../Features/Date/z_generic_date.dart';
import '../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../Features/Other/utils.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../../Auth/models/login_model.dart';
import '../../../Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import '../../../Stakeholders/Ui/Accounts/model/acc_model.dart';
import '../../../Stakeholders/Ui/Individuals/Ui/add_edit.dart';
import '../../../Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import '../../../Stakeholders/Ui/Individuals/model/individual_model.dart';
import '../AllProjects/bloc/projects_bloc.dart';
import '../AllProjects/model/pjr_model.dart';


class ProjectOverview extends StatelessWidget {
  final ProjectsModel? model;
  const ProjectOverview({super.key, this.model});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(model),
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
  final ProjectsModel? model;
  const _Desktop(this.model);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  final projectName = TextEditingController();
  final projectDetails = TextEditingController();
  final projectOwner = TextEditingController();
  final ownerAccount = TextEditingController();
  final projectLocation = TextEditingController();
  int? accNumber;
  int? ownerId;
  int? status;
  String deadline = DateTime.now().toFormattedDate();
  LoginData? loginData;
  final formKey = GlobalKey<FormState>();

  bool isPending = false;
  @override
  void initState() {
    final model = (context as dynamic).widget.model;
    if(model !=null){
      projectName.text = widget.model?.prjName ?? "";
      projectDetails.text = widget.model?.prjDetails ?? "";
      projectLocation.text = widget.model?.prjLocation ?? "";
      projectOwner.text = widget.model?.prjOwnerfullName ??"";
      accNumber = widget.model?.prjOwnerAccount;
      ownerAccount.text = widget.model?.prjOwnerAccount.toString() ?? "";
      ownerId = widget.model?.prjOwner;
      deadline = widget.model?.prjDateLine.toFormattedDate()??"";
      status = widget.model?.prjStatus ?? 0;
      isPending = widget.model?.prjStatus == 0;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final prjState = context.watch<ProjectsBloc>().state;
    final state = context.watch<AuthBloc>().state;
    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    loginData = state.loginData;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SectionTitle(title: tr.projectInformation),
                      SizedBox(height: 5),
                      ZTextFieldEntitled(
                        isEnabled: isPending,
                        controller: projectName,
                        isRequired: true,
                        title: tr.projectName,
                        validator: (e) {
                          if (e.isEmpty) {
                            return tr.required(tr.projectName);
                          }
                          return null;
                        },
                      ),
                  
                      SizedBox(height: 8),
                      ZTextFieldEntitled(
                        isEnabled: isPending,
                        isRequired: true,
                        controller: projectDetails,
                        keyboardInputType: TextInputType.multiline,
                        title: tr.details,
                        validator: (e) {
                          if (e.isEmpty) {
                            return tr.required(tr.details);
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ZTextFieldEntitled(
                              isEnabled: isPending,
                              controller: projectLocation,
                              title: tr.location,
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: ZDatePicker(
                              disablePastDate: true,
                              isActive: !isPending,
                              label: tr.deadline,
                              value: deadline,
                              onDateChanged: (v) {
                                setState(() {
                                  deadline = v;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      SectionTitle(title: tr.ownerInformation),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                        child:
                        GenericTextfield<IndividualsModel, IndividualsBloc, IndividualsState>(
                          isEnabled: isPending,
                          controller: projectOwner,
                          title: tr.individuals,
                          hintText: tr.individuals,
                          trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return IndividualAddEditView();
                                },
                              );
                            },
                            icon: Icon(Icons.add),
                          ),
                          isRequired: true,
                          bloc: context.read<IndividualsBloc>(),
                          fetchAllFunction: (bloc) => bloc.add(LoadIndividualsEvent()),
                          searchFunction: (bloc, query) => bloc.add(LoadIndividualsEvent(search: query)),
                          validator: (value) {
                            if (value.isEmpty) {
                              return tr.required(tr.individuals);
                            }
                            return null;
                          },
                          itemBuilder: (context, account) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${account.perName} ${account.perLastName}",
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          itemToString: (acc) => "${acc.perName} ${acc.perLastName}",
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
                              ownerId = value.perId!;
                              ownerAccount.clear();
                              accNumber = null;
                              context.read<AccountsBloc>().add(
                                LoadAccountsEvent(ownerId: ownerId),
                              );
                            });
                          },
                          noResultsText: tr.noDataFound,
                          showClearButton: true,
                        ),
                      ),
                      SizedBox(height: 8),
                  
                      // Account Information Card
                      SectionTitle(title: tr.ownerAccount),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                        child:
                        GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
                          isEnabled: isPending,
                          controller: ownerAccount,
                          title: tr.accounts,
                          hintText: tr.accNameOrNumber,
                          isRequired: true,
                          bloc: context.read<AccountsBloc>(),
                          fetchAllFunction: (bloc) =>
                              bloc.add(LoadAccountsEvent(ownerId: ownerId)),
                          searchFunction: (bloc, query) =>
                              bloc.add(LoadAccountsEvent(ownerId: ownerId)),
                          validator: (value) {
                            if (value.isEmpty) {
                              return tr.required(tr.accounts);
                            }
                            return null;
                          },
                          itemBuilder: (context, account) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${account.accNumber} | ${account.accName}",
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Utils.currencyColors(
                                          account.actCurrency ?? "",
                                        ).withValues(alpha: .1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "${account.actCurrency}",
                                        style: Theme.of(context).textTheme.titleSmall
                                            ?.copyWith(
                                          color: Utils.currencyColors(
                                            account.actCurrency ?? "",
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          itemToString: (acc) => "${acc.accNumber} | ${acc.accName}",
                          stateToLoading: (state) => state is AccountLoadingState,
                          loadingBuilder: (context) => const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          stateToItems: (state) {
                            if (state is AccountLoadedState) {
                              return state.accounts;
                            }
                            return [];
                          },
                          onSelected: (value) {
                            setState(() {
                              accNumber = value.accNumber ?? 1;
                            });
                          },
                          noResultsText: tr.noDataFound,
                          showClearButton: true,
                        ),
                      ),
                      const SizedBox(height: 5),
                  
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SectionTitle(title: tr.projectStatus),
                          Row(
                            children: [
                              SectionTitle(title: tr.deadline),
                              SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: Text(
                                  widget.model?.prjDateLine?.daysLeftText ?? 'No deadline',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Switch(
                            value: status == 1,
                            onChanged: (e) {
                              setState(() {
                                status = e ? 1 : 0;
                              });
                            },
                            activeTrackColor: Colors.green,
                            activeThumbColor: Theme.of(context).colorScheme.surface,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status == 0 ? tr.inProgress : tr.completed,
                            style: textTheme.bodyMedium?.copyWith(
                              color: status == 1 ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                        ],
                      ),
                  
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ZOutlineButton(
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                      label: Text(tr.cancel.toUpperCase())),
                  SizedBox(width: 5),
                  ZOutlineButton(
                      isActive: true,
                      onPressed: onSubmit,
                      label: prjState is ProjectsLoadingState? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator()) : Text(tr.update.toUpperCase())),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void onSubmit(){
    if (!formKey.currentState!.validate()) return;
    final bloc = context.read<ProjectsBloc>();

    final data = ProjectsModel(
      prjId: widget.model?.prjId,
      usrName: loginData?.usrName,
      prjName: projectName.text,
      prjDetails: projectDetails.text,
      prjLocation: projectLocation.text,
      prjDateLine: DateTime.tryParse(deadline),
      prjOwner: ownerId,
      prjOwnerAccount: accNumber,
      prjStatus: status
    );

    if(widget.model == null ){
      bloc.add(AddProjectEvent(data));
    }else{
      bloc.add(UpdateProjectEvent(data));
    }

  }
}
