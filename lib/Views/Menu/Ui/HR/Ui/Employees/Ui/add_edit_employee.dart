import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/bloc/employee_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/features/department_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/features/payment_method_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/features/salary_cal_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/model/emp_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/model/acc_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/model/individual_model.dart';
import '../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../../Features/Other/thousand_separator.dart';


class AddEditEmployeeView extends StatelessWidget {
  final EmployeeModel? model;
  final bool? isDriver;
  const AddEditEmployeeView({super.key, this.model,this.isDriver = false});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(model: model,isDriver: isDriver),
      tablet: _Tablet(),
    );
  }
}

class _Tablet extends StatelessWidget {

  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Desktop extends StatefulWidget {
  final EmployeeModel? model;
  final bool? isDriver;
  const _Desktop({this.model,this.isDriver = false});

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  final individualCtrl = TextEditingController();
  final indAccountCtrl = TextEditingController();
  final empSalary = TextEditingController();
  final empEmail = TextEditingController();
  final empTaxInfo = TextEditingController();
  final jobTitle = TextEditingController();

  int? perId;
  int? accNumber;
  String? salaryCalBase;
  String? paymentBase;
  String? department;
  DateTime? startDate;



  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if(widget.model != null){
      department = widget.model?.empDepartment ?? "";
      paymentBase = widget.model?.empPmntMethod ?? "";
      salaryCalBase = widget.model?.empSalCalcBase ?? "";
      accNumber = widget.model?.empSalAccount;
      empSalary.text = widget.model?.empSalary?.toAmount() ?? "";
      empEmail.text = widget.model?.empEmail ?? "";
      empTaxInfo.text = widget.model?.empTaxInfo ?? "";
      perId = widget.model!.perId!;
      jobTitle.text = widget.model?.empPosition??"";
    }
    if(widget.isDriver == true){
      jobTitle.text = "Driver";
    }else{
        jobTitle.text = '';
    }

    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final isLoading = context.watch<EmployeeBloc>().state is EmployeeLoadingState;

    return ZFormDialog(
      width: 550,
      actionLabel: isLoading? SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.surface,
            strokeWidth: 2,
          )) : widget.model == null ? Text(locale.create) : Text(locale.update),
      icon: Icons.perm_contact_calendar_rounded,
      onAction: onSubmit,
      title: widget.model == null ? locale.employeeRegistration : locale.update,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if(widget.model == null)
                GenericTextfield<IndividualsModel, IndividualsBloc, IndividualsState>(
                  showAllOnFocus: true,
                  controller: individualCtrl,
                  title: locale.individuals,
                  hintText: locale.individuals,
                  isRequired: true,
                  bloc: context.read<IndividualsBloc>(),
                  fetchAllFunction: (bloc) => bloc.add(LoadIndividualsEvent()),
                  searchFunction: (bloc, query) => bloc.add(LoadIndividualsEvent()),
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
                      perId = value.perId!;
                      indAccountCtrl.clear();
                      context.read<AccountsBloc>().add(LoadAccountsEvent(ownerId: perId));
                    });
                  },
                  noResultsText: locale.noDataFound,
                  showClearButton: true,
                ),
                if(widget.model == null)
                SizedBox(height: 10),
                if(widget.model == null)
                GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
                  showAllOnFocus: true,
                  controller: indAccountCtrl,
                  title: locale.accounts,
                  hintText: locale.accNameOrNumber,
                  isRequired: true,
                  bloc: context.read<AccountsBloc>(),
                  fetchAllFunction: (bloc) => bloc.add(LoadAccountsEvent(ownerId: perId)),
                  searchFunction: (bloc, query) => bloc.add(LoadAccountsEvent(ownerId: perId)),
                  validator: (value) {
                    if (value.isEmpty) {
                      return locale.required(locale.accounts);
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
                              "${account.accNumber} | ${account.accName}",
                              style: Theme.of(context).textTheme.bodyLarge,
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
                  noResultsText: locale.noDataFound,
                  showClearButton: true,
                ),
                SizedBox(height: 10),
                DepartmentDropdown(
                  onDepartmentSelected: (e) {
                    setState(() {
                      department = e.name;
                    });
                  },
                ),
                SizedBox(height: 10),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: SalaryCalcBaseDropdown(
                        onSelected: (e) {
                          salaryCalBase = e.name;
                        },
                      ),
                    ),
                    Expanded(
                      child: PaymentMethodDropdown(
                        onSelected: (e) {
                          paymentBase = e.name;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  spacing: 5,
                  children: [
                    Expanded(
                        child: ZTextFieldEntitled(
                          isEnabled: widget.isDriver == true,
                        controller: jobTitle, title: locale.jobTitle)),
                    Expanded(
                      child: ZTextFieldEntitled(
                        isRequired: true,
                        // onSubmit: (_)=> onSubmit(),
                        keyboardInputType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormat: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]*')),
                          SmartThousandsDecimalFormatter(),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return locale.required(locale.salary);
                          }

                          // Remove formatting (e.g. commas)
                          final clean = value.replaceAll(RegExp(r'[^\d.]'), '');
                          final amount = double.tryParse(clean);

                          if (amount == null || amount <= 0.0) {
                            return locale.amountGreaterZero;
                          }

                          return null;
                        },
                        controller: empSalary,
                        title: locale.salary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ZTextFieldEntitled(controller: empTaxInfo, title: locale.taxInfo),
                SizedBox(height: 10),
                ZTextFieldEntitled(
                  controller: empEmail,
                  validator: (value) =>
                      Utils.validateEmail(email: value, context: context),
                  title: locale.email,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onSubmit(){
    if (!formKey.currentState!.validate()) return;

    final data = EmployeeModel(
      empId: widget.model?.empId,
      empPersonal: perId,
      empSalAccount: accNumber,
      empEmail: empEmail.text,
      empHireDate: DateTime.now(),
      empDepartment: department,
      empPosition: jobTitle.text,
      empSalCalcBase: salaryCalBase,
      empPmntMethod: paymentBase,
      empStatus: 1,
      empFingerprint: "FP-23452",
      empEndDate: "12-2-2025",
      empSalary: empSalary.text.cleanAmount,
      empTaxInfo: empTaxInfo.text,
    );

    final bloc = context.read<EmployeeBloc>();
    if (widget.model == null) {
      bloc.add(AddEmployeeEvent(data));
    } else {
      bloc.add(UpdateEmployeeEvent(data));
    }

  }
}
