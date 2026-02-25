import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/AllProjects/model/pjr_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/IncomeExpense/bloc/project_inc_exp_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/IncomeExpense/model/prj_inc_exp_model.dart';
import '../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../Features/Other/zForm_dialog.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../../Auth/models/login_model.dart';
import '../../../Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import '../../../Stakeholders/Ui/Accounts/model/acc_model.dart';

class AddEditIncomeExpenseDialog extends StatefulWidget {
  final ProjectsModel project;
  final ProjectInOutModel? existingData;

  const AddEditIncomeExpenseDialog({
    super.key,
    required this.project,
    this.existingData,
  });

  @override
  State<AddEditIncomeExpenseDialog> createState() => _AddEditIncomeExpenseDialogState();
}

class _AddEditIncomeExpenseDialogState extends State<AddEditIncomeExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();
  final _remarkController = TextEditingController();

  String _selectedType = 'Income';
  bool _isLoading = false;
  LoginData? loginData;

  @override
  void initState() {
    super.initState();
    if (widget.project.prjOwnerAccount != null) {
      _accountController.text = widget.project.prjOwnerAccount!.toString();
    }

    if (widget.existingData != null) {
      _selectedType = widget.existingData!.prpType == 'Payment' ? 'Income' : 'Expense';
      _amountController.text = widget.existingData!.amount ?? '';
      _accountController.text = widget.existingData!.account ?? '';
      _remarkController.text = widget.existingData!.ppRemark ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (loginData == null) return;

    setState(() => _isLoading = true);

    final newData = ProjectInOutModel(
      prpType: _selectedType == 'Income' ? 'Payment' : 'Expense',
      prjId: widget.project.prjId,
      account: _accountController.text,
      amount: _amountController.text,
      currency: widget.project.actCurrency,
      ppRemark: _remarkController.text,
      usrName: loginData?.usrName??""
    );

    context.read<ProjectIncExpBloc>().add(AddProjectIncExpEvent(newData));

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      loginData = authState.loginData;
    }

    return ZFormDialog(
      title: widget.existingData == null ? 'Add Transaction' : 'Edit Transaction',
      icon: widget.existingData == null ? Icons.add_circle_outline : Icons.edit,
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      onAction: _submitForm,
      isButtonEnabled: !_isLoading,
      actionLabel: _isLoading
          ? const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : Text(widget.existingData == null ? tr.create : tr.update),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Type Selection - Improved UI
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Transaction Type',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeCard(
                          title: tr.income,
                          isSelected: _selectedType == 'Income',
                          selectedColor: Colors.green,
                          icon: Icons.arrow_upward,
                          onTap: () {
                            setState(() {
                              _selectedType = 'Income';
                              if (widget.project.prjOwnerAccount != null) {
                                _accountController.text = widget.project.prjOwnerAccount.toString();
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTypeCard(
                          title: tr.expense,
                          isSelected: _selectedType == 'Expense',
                          selectedColor: color.error,
                          icon: Icons.arrow_downward,
                          onTap: () {
                            setState(() {
                              _selectedType = 'Expense';
                              _accountController.clear();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Amount Field
            ZTextFieldEntitled(
              controller: _amountController,
              title: '${tr.amount} (${widget.project.actCurrency})',
              isRequired: true,
              keyboardInputType: const TextInputType.numberWithOptions(decimal: true),
              icon: Icons.money,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Account Field
            if(_selectedType == "Income")...[
              ZTextFieldEntitled(
                controller: _accountController,
                title: 'Account Number',
                isRequired: true,
                isEnabled: _selectedType != 'Income',
                icon: Icons.account_balance,
                hint: _selectedType == 'Income'
                    ? 'Using project owner account'
                    : 'Enter expense account number',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number';
                  }
                  return null;
                },
              ),
            ],
            if(_selectedType == "Expense")...[
              GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
                showAllOnFocus: true,
                controller: _accountController,
                title: tr.accounts,
                hintText: tr.accNameOrNumber,
                isRequired: true,
                bloc: context.read<AccountsBloc>(),
                fetchAllFunction: (bloc) => bloc.add(
                  LoadAccountsFilterEvent(include: "11,12",ccy: widget.project.actCurrency,exclude: ""),
                ),
                searchFunction: (bloc, query) => bloc.add(
                  LoadAccountsFilterEvent(
                      include: "11,12",
                      ccy: widget.project.actCurrency,
                      input: query, exclude: ""
                  ),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return tr.required(tr.accounts);
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
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                stateToItems: (state) {
                  if (state is AccountLoadedState) {
                    return state.accounts;
                  }
                  return [];
                },
                onSelected: (value) {
                  setState(() {
                   // accNumber = value.accNumber;
                  });
                },
                noResultsText: tr.noDataFound,
                showClearButton: true,
              ),
            ],

            const SizedBox(height: 16),

            // Remark Field
            ZTextFieldEntitled(
              controller: _remarkController,
              title: tr.remark,
              keyboardInputType: TextInputType.multiline,

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required bool isSelected,
    required Color selectedColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: isSelected ? selectedColor : Theme.of(context).colorScheme.outline.withValues(alpha: .5),
            width: isSelected ? 1 : 0.5,
          ),
          color: isSelected ? selectedColor.withValues(alpha: .1) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? selectedColor : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? selectedColor : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}