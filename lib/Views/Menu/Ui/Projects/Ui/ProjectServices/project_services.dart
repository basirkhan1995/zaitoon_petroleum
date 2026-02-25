import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/Bloc/localizations_bloc.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/ProjectServices/bloc/project_services_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/ProjectServices/model/project_services_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Services/Ui/add_edit_services.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Services/bloc/services_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Services/model/services_model.dart';

import '../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../../Auth/models/login_model.dart';

class ProjectServicesView extends StatelessWidget {
  final int? projectId;
  const ProjectServicesView({super.key, this.projectId});
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(projectId),
      tablet: _Tablet(projectId),
      desktop: _Desktop(projectId),
    );
  }
}

class _Mobile extends StatelessWidget {
  final int? projectId;
  const _Mobile(this.projectId);
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Tablet extends StatelessWidget {
  final int? projectId;
  const _Tablet(this.projectId);
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Desktop extends StatefulWidget {
  final int? projectId;
  const _Desktop(this.projectId);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  final formKey = GlobalKey<FormState>();
  final servicesController = TextEditingController();
  final qty = TextEditingController(text: "1");
  final amount = TextEditingController();
  final remark = TextEditingController();
  int? serviceId;
  int? editingPjdId; // Track if we're editing an existing service
  String? myLocale;

  @override
  void initState() {
    myLocale = context.read<LocalizationBloc>().state.languageCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.projectId != null) {
        context.read<ProjectServicesBloc>().add(LoadProjectServiceEvent(widget.projectId!));
      }
    });
    super.initState();
  }

  LoginData? loginData;

  @override
  void dispose() {
    remark.dispose();
    servicesController.dispose();
    amount.dispose();
    qty.dispose();
    super.dispose();
  }

  // Method to clear the form
  void clearForm() {
    servicesController.clear();
    qty.text = "1";
    amount.clear();
    remark.clear();
    setState(() {
      serviceId = null;
      editingPjdId = null;
    });
  }

  // Method to load a project service into the form for editing
  void loadServiceForEditing(ProjectServicesModel service) {
    setState(() {
      servicesController.text = service.srvName ?? '';
      qty.text = service.pjdQuantity?.toString() ?? '1';
      amount.text = service.pjdPricePerQty?.toString() ?? '';
      remark.text = service.pjdRemark ?? '';
      serviceId = service.srvId;
      editingPjdId = service.pjdId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    TextStyle? titleStyle = Theme.of(context).textTheme.titleSmall;
    TextStyle? subtitleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: color.outline.withValues(alpha: .8),
    );

    final state = context.watch<AuthBloc>().state;
    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    loginData = state.loginData;

    return Scaffold(
      body: Column(
        children: [
          ZCover(
            padding: const EdgeInsets.all(8.0),
            color: color.surface,
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        flex: 3,
                        child: GenericTextfield<ServicesModel, ServicesBloc, ServicesState>(
                          controller: servicesController,
                          title: tr.services,
                          hintText: tr.services,
                          trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AddEditServiceView();
                                },
                              );
                            },
                            icon: const Icon(Icons.add),
                          ),
                          isRequired: true,
                          bloc: context.read<ServicesBloc>(),
                          fetchAllFunction: (bloc) => bloc.add(LoadServicesEvent()),
                          searchFunction: (bloc, query) => bloc.add(LoadServicesEvent(search: query)),
                          validator: (value) {
                            if (value.isEmpty) {
                              return tr.required(tr.services);
                            }
                            return null;
                          },
                          itemBuilder: (context, ser) => Padding(
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
                                        "${ser.srvName}",
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          itemToString: (ser) => "${ser.srvName}",
                          stateToLoading: (state) => state is ServicesLoadingState,
                          loadingBuilder: (context) => const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          stateToItems: (state) {
                            if (state is ServicesLoadedState) {
                              return state.services;
                            }
                            return [];
                          },
                          onSelected: (value) {
                            setState(() {
                              serviceId = value.srvId;
                            });
                          },
                          noResultsText: tr.noDataFound,
                          showClearButton: true,
                        ),
                      ),
                      Expanded(
                        child: ZTextFieldEntitled(
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return tr.required(tr.qty);
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          controller: qty,
                          title: tr.qty,
                        ),
                      ),
                      Expanded(
                        child: ZTextFieldEntitled(
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return tr.required(tr.amount);
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                          controller: amount,
                          title: tr.amount,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ZTextFieldEntitled(
                    keyboardInputType: TextInputType.multiline,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr.required(tr.remark);
                      }
                      return null;
                    },
                    controller: remark,
                    title: tr.remark,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ZOutlineButton(
                        onPressed: clearForm,
                        label: Text(tr.clear.toUpperCase()),
                      ),
                      const SizedBox(width: 8),
                      ZOutlineButton(
                        onPressed: editingPjdId != null ? onUpdateSubmit : onAddSubmit,
                        isActive: true,
                        label: Text(
                            editingPjdId != null
                                ? tr.update.toUpperCase()
                                : tr.create.toUpperCase()
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (editingPjdId != null)
                        ZOutlineButton(
                          onPressed: onDeleteSubmit,
                          label: Text(tr.delete.toUpperCase()),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: .05),
            ),
            child: Row(
              children: [
                Expanded(child: Text("Project Services", style: titleStyle)),
                SizedBox(
                  width: 50,
                  child: Text(tr.qty, style: titleStyle),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    textAlign: myLocale == "en" ? TextAlign.right : TextAlign.left,
                    tr.amount,
                    style: titleStyle,
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    textAlign: myLocale == "en" ? TextAlign.right : TextAlign.left,
                    tr.totalTitle,
                    style: titleStyle,
                  ),
                ),
                const SizedBox(width: 40), // Space for delete button
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<ProjectServicesBloc, ProjectServicesState>(
              listener: (context, state) {
                if (state is ProjectServicesSuccessState) {
                  clearForm();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Operation completed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                if (state is ProjectServicesErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ProjectServicesLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ProjectServicesErrorState) {
                  return NoDataWidget(
                    title: tr.errorTitle,
                    message: state.message,
                    onRefresh: () {
                      if (widget.projectId != null) {
                        context.read<ProjectServicesBloc>().add(
                          LoadProjectServiceEvent(widget.projectId!),
                        );
                      }
                    },
                  );
                }
                if (state is ProjectServicesLoadedState) {
                  if (state.projectServices.isEmpty) {
                    return NoDataWidget(
                      title: "No Services",
                      message: "Click Add Services to add a new",
                      enableAction: false,
                    );
                  }
                  return ListView.builder(
                    itemCount: state.projectServices.length,
                    itemBuilder: (context, index) {
                      final prjServices = state.projectServices[index];
                      return GestureDetector(
                        onTap: () => loadServiceForEditing(prjServices),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: index.isOdd
                                ? color.primary.withValues(alpha: .05)
                                : Colors.transparent,
                            border: editingPjdId == prjServices.pjdId
                                ? Border.all(color: color.primary, width: 2)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(prjServices.srvName ?? "", style: titleStyle),
                                    Text(prjServices.prpTrnRef ?? "", style: subtitleStyle),
                                    if (prjServices.pjdRemark != null)
                                      Text(prjServices.pjdRemark ?? "", style: subtitleStyle),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                child: Text(prjServices.pjdQuantity?.toString() ?? '0'),
                              ),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  (prjServices.pjdPricePerQty ?? 0).toAmount(),
                                  textAlign: myLocale == "en" ? TextAlign.right : TextAlign.left,
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  (prjServices.total ?? 0).toAmount(),
                                  textAlign: myLocale == "en" ? TextAlign.right : TextAlign.left,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => showDeleteConfirmation(prjServices),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  void onAddSubmit() {
    if (!formKey.currentState!.validate()) return;
    if (serviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final bloc = context.read<ProjectServicesBloc>();

    final data = ProjectServicesModel(
      prjId: widget.projectId,
      srvId: serviceId,
      pjdQuantity: double.tryParse(qty.text),
      pjdPricePerQty: double.tryParse(amount.text),
      usrName: loginData?.usrName,
    );

    bloc.add(AddProjectServiceEvent(data));
  }

  void onUpdateSubmit() {
    if (!formKey.currentState!.validate()) return;
    if (serviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final bloc = context.read<ProjectServicesBloc>();

    final data = ProjectServicesModel(
      pjdId: editingPjdId,
      prjId: widget.projectId,
      srvId: serviceId,
      srvName: servicesController.text,
      pjdQuantity: double.tryParse(qty.text),
      pjdPricePerQty: double.tryParse(amount.text),
      usrName: loginData?.usrName,
    );

    bloc.add(UpdateProjectServiceEvent(data));
  }

  void onDeleteSubmit() {
    if (editingPjdId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final bloc = context.read<ProjectServicesBloc>();
              bloc.add(
                DeleteProjectServiceEvent(
                 editingPjdId!,
                  loginData?.usrName ?? '',
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmation(ProjectServicesModel service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${service.srvName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final bloc = context.read<ProjectServicesBloc>();
              bloc.add(
                DeleteProjectServiceEvent(
                  service.pjdId!,
                  loginData?.usrName ?? '',
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
