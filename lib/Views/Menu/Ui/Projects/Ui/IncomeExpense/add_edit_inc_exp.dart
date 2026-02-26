import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/AllProjects/model/pjr_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/IncomeExpense/bloc/project_inc_exp_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/IncomeExpense/model/prj_inc_exp_model.dart';
import '../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../Features/Other/alert_dialog.dart';
import '../../../../../../Features/Other/thousand_separator.dart';
import '../../../../../../Features/Other/zForm_dialog.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../../Auth/models/login_model.dart';
import '../../../Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import '../../../Stakeholders/Ui/Accounts/model/acc_model.dart';

class AddEditIncomeExpenseDialog extends StatefulWidget {
  final ProjectsModel project;
  final Payment? existingData; // Changed to Payment type

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
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData != null) {
      // Set type based on prpType
      _selectedType = widget.existingData!.prpType == 'Payment' ? 'Income' : 'Expense';

      // Set amount based on type
      if (_selectedType == 'Income') {
        _amountController.text = widget.existingData!.payments.toAmount();
      } else {
        _amountController.text = widget.existingData!.expenses.toAmount();
      }

      // For now, account number is not available in the Payment object
      // You might need to fetch it from another API or it might not be editable
      _accountController.text = widget.project.prjOwnerAccount.toString();

      // Remark might not be in the Payment object either
      _remarkController.text = '';
    } else if (widget.project.prjOwnerAccount != null) {
      // For new income, pre-fill with project owner account
      _accountController.text = widget.project.prjOwnerAccount!.toString();
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

    // Create data object for API
    final data = ProjectInOutModel(
      reference: widget.existingData?.prpTrnRef, // Use prpTrnRef as reference
      prpType: _selectedType == 'Income' ? 'Payment' : 'Expense',
      prjId: widget.project.prjId,
      account: _accountController.text,
      amount: _amountController.text.cleanAmount,
      currency: widget.project.actCurrency,
      ppRemark: _remarkController.text,
      usrName: loginData?.usrName ?? "",
    );

    if (widget.existingData != null) {
      // Update existing transaction
      context.read<ProjectIncExpBloc>().add(UpdateProjectIncExpEvent(data));
    } else {
      // Add new transaction
      context.read<ProjectIncExpBloc>().add(AddProjectIncExpEvent(data));
    }

    // Close dialog after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _deleteTransaction() {
    if (widget.existingData == null || loginData == null) return;

    showDialog(
      context: context,
      builder: (context) => ZAlertDialog(
        title: 'Confirm Delete',
        content: 'Are you sure you want to delete this transaction?',
        onYes: () {
          Navigator.of(context).pop(); // Close confirmation dialog
          setState(() => _isLoading = true);

          context.read<ProjectIncExpBloc>().add(
            DeleteProjectIncExpEvent(
              usrName: loginData!.usrName!,
              reference: widget.existingData!.prpTrnRef!, // Use prpTrnRef as reference
              projectId: widget.project.prjId,
            ),
          );

          // Close the main dialog
          Navigator.of(context).pop();
        },
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      onAction: _submitForm,
      isButtonEnabled: !_isLoading,
      actionLabel: _isLoading
          ? const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : Text(widget.existingData == null ? tr.create : tr.update),
      expandedAction: (widget.existingData != null)?
        ZOutlineButton(
          height: 43,
          onPressed: _isLoading ? null : _deleteTransaction,
          isActive: true,
          backgroundHover: Theme.of(context).colorScheme.error,
          label: Text(
            tr.delete,
          ),
        ) : null,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Type Selection
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
                          title: tr.payment,
                          isSelected: _selectedType == 'Income',
                          selectedColor: Colors.green,
                          icon: Icons.arrow_downward,
                          onTap: () {
                            setState(() {
                              _selectedType = 'Income';
                              if (widget.existingData == null && widget.project.prjOwnerAccount != null) {
                                _accountController.text = widget.project.prjOwnerAccount.toString();
                              } else if (widget.existingData != null) {
                                // Keep existing account if any
                              }
                              _amountController.clear();
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
                          icon: Icons.arrow_upward,
                          onTap: () {
                            setState(() {
                              _selectedType = 'Expense';
                              if (widget.existingData == null) {
                                _accountController.clear();
                              }
                              _amountController.clear();
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
              icon: Icons.money,
              inputFormat: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9.,]*'),
                ),
                SmartThousandsDecimalFormatter(),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return tr.required(tr.amount);
                }

                final clean = value.replaceAll(
                  RegExp(r'[^\d.]'),
                  '',
                );
                final amount = double.tryParse(clean);

                if (amount == null || amount <= 0.0) {
                  return tr.amountGreaterZero;
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
                isEnabled: false, // Disabled for income
                icon: Icons.account_balance,
                hint: 'Using project owner account',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number';
                  }
                  return null;
                },
              ),
            ],
            if(widget.existingData == null)
            if(_selectedType == "Expense")...[
              GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
                showAllOnFocus: true,
                controller: _accountController,
                title: tr.accounts,
                hintText: tr.accNameOrNumber,
                isRequired: true,
                bloc: context.read<AccountsBloc>(),
                fetchAllFunction: (bloc) => bloc.add(
                  LoadAccountsFilterEvent(include: "11,12", ccy: widget.project.actCurrency, exclude: ""),
                ),
                searchFunction: (bloc, query) => bloc.add(
                  LoadAccountsFilterEvent(
                      include: "11,12",
                      ccy: widget.project.actCurrency,
                      input: query,
                      exclude: ""
                  ),
                ),
                validator: widget.existingData != null ? (value) {
                  if (value.isEmpty) {
                    return tr.required(tr.accounts);
                  }
                  return null;
                } : null,
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
                  // Handle selection if needed
                },
                noResultsText: tr.noDataFound,
                showClearButton: true,
              ),
              const SizedBox(height: 16),
            ],


            // Remark Field
            ZTextFieldEntitled(
              controller: _remarkController,
              title: tr.remark,
              keyboardInputType: TextInputType.multiline,
            ),

            if (widget.existingData != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Reference:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      widget.existingData!.prpTrnRef ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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