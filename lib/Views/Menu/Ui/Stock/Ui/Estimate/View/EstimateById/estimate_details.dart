import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/model/acc_model.dart';
import '../../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../../bloc/estimate_bloc.dart';
import '../../model/estimate_model.dart';

class EstimateDetailView extends StatefulWidget {
  final int estimateId;
  const EstimateDetailView({super.key, required this.estimateId});

  @override
  State<EstimateDetailView> createState() => _EstimateDetailViewState();
}

class _EstimateDetailViewState extends State<EstimateDetailView> {
  String? _userName;
  String? baseCurrency;
  double _totalAmount = 0.0;

  // Payment variables
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  AccountsModel? _selectedAccount;
  final TextEditingController _creditAmountController = TextEditingController();
  double _remainingAmount = 0.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EstimateBloc>().add(LoadEstimateByIdEvent(widget.estimateId));
    });

    final companyState = context.read<CompanyProfileBloc>().state;
    if (companyState is CompanyProfileLoadedState) {
      baseCurrency = companyState.company.comLocalCcy ?? "";
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      _userName = authState.loginData.usrName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EstimateBloc, EstimateState>(
      listener: (context, state) {
        if (state is EstimateError) {
          Utils.showOverlayMessage(context, message: state.message, isError: true);
        }
        if (state is EstimateConverted) {
          Utils.showOverlayMessage(
            context,
            message: state.message,
            isError: false,
          );
          Navigator.pop(context);
        }
        if (state is EstimateDeleted) {
          Utils.showOverlayMessage(
            context,
            message: state.message,
            isError: false,
          );
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          titleSpacing: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Estimate #${widget.estimateId}'),
        ),
        body: BlocBuilder<EstimateBloc, EstimateState>(
          builder: (context, state) {
            if (state is EstimateDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is EstimateError) {
              return Center(child: Text(state.message));
            }

            if (state is EstimateDetailLoaded) {
              final estimate = state.estimate;

              // Update total amount
              _totalAmount = estimate.grandTotal;

              // Update remaining amount based on credit payment
              _updateRemainingAmount();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildHeaderInfo(estimate),
                        BlocBuilder<EstimateBloc, EstimateState>(
                          builder: (context, state) {
                            if (state is EstimateDetailLoaded) {
                              return Row(
                                spacing: 8,
                                children: [
                                  ZOutlineButton(
                                      width: 110,
                                      icon: Icons.delete_outline,
                                      backgroundHover: Theme.of(context).colorScheme.error,
                                      onPressed: () => _deleteEstimate(state.estimate),
                                      label: Text(AppLocalizations.of(context)!.delete)),

                                  ZOutlineButton(
                                    width: 110,
                                    icon: Icons.published_with_changes_rounded,
                                    label: const Text('Convert'),
                                    onPressed: () => _showConvertToSaleDialog(state.estimate),
                                  ),
                                ],
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Items header
                    _buildItemsHeader(),

                    // Items list
                    _buildItemsList(estimate),

                    const SizedBox(height: 16),

                    // Profit Summary Section (Added like sale invoice)
                    _buildProfitSummarySection(estimate)
                  ],
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(EstimateModel estimate) {
    return SizedBox(
      width: 500,
      child: ZCard(
        radius: 5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.customer, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(estimate.ordPersonalName ?? ''),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.referenceNumber, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(estimate.ordxRef ?? ''),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.totalInvoice, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("${_totalAmount.toAmount()} $baseCurrency"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsHeader() {
    final color = Theme.of(context).colorScheme;
    final tr = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text('#', style: TextStyle(color: color.surface))),
          Expanded(child: Text(tr.products, style: TextStyle(color: color.surface))),
          SizedBox(width: 80, child: Text(tr.qty, style: TextStyle(color: color.surface))),
          SizedBox(width: 120, child: Text(tr.unitPrice, style: TextStyle(color: color.surface))),
          SizedBox(width: 120, child: Text(tr.totalTitle, style: TextStyle(color: color.surface))),
          SizedBox(width: 150, child: Text(tr.storage, style: TextStyle(color: color.surface))),
        ],
      ),
    );
  }

  Widget _buildItemsList(EstimateModel estimate) {
    final records = estimate.records ?? [];

    if (records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No items found')),
      );
    }

    return Column(
      children: records.asMap().entries.map((entry) {
        final index = entry.key;
        final record = entry.value;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              SizedBox(width: 40, child: Text((index + 1).toString())),
              Expanded(child: Text(record.productName ?? 'Product ${record.tstProduct}')),
              SizedBox(width: 80, child: Text(record.quantity.toStringAsFixed(2))),
              SizedBox(width: 120, child: Text(record.salePrice.toAmount())),
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.total.toAmount(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (record.purchasePrice > 0 && record.salePrice > 0)
                      Text(
                        '${AppLocalizations.of(context)!.profit}: ${record.profit.toAmount()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: record.profit >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 150, child: Text(record.storageName ?? '')),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProfitSummarySection(EstimateModel estimate) {
    final color = Theme.of(context).colorScheme;
    final tr = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surface,
        border: Border.all(color: color.outline.withValues(alpha: .3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr.profitSummary, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Icon(Icons.ssid_chart, size: 22, color: color.primary),
            ],
          ),
          Divider(color: color.outline.withValues(alpha: .2)),
          // Profit Summary - Similar to Sale Invoice
          _buildProfitRow(
            label: tr.totalCost,
            value: estimate.totalPurchaseCost,
            color: color.primary.withValues(alpha: .9),
          ),
          const SizedBox(height: 5),
          _buildProfitRow(
            label: tr.profit,
            value: estimate.totalProfit,
            color: estimate.totalProfit >= 0 ? Colors.green : Colors.red,
            isBold: true,
          ),
          if (estimate.totalPurchaseCost > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${tr.profit} %', style: const TextStyle(fontSize: 16)),
                Text(
                  '${estimate.profitPercentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 16,
                    color: estimate.totalProfit >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          Divider(color: color.outline.withValues(alpha: .2)),

          // Grand Total
          _buildProfitRow(
            label: tr.grandTotal,
            value: estimate.grandTotal,
            isBold: true,
          ),
        ],
      ),
    );
  }


  Widget _buildProfitRow({
    required String label,
    required double value,
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          "${value.toAmount()} $baseCurrency",
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  void _showConvertToSaleDialog(EstimateModel estimate) {
    final tr = AppLocalizations.of(context)!;

    // Reset payment variables
    _selectedPaymentMethod = PaymentMethod.cash;
    _selectedAccount = null;
    _creditAmountController.clear();
    _remainingAmount = _totalAmount;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Convert to Sale'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Payment Method Selection
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // Cash Option
                        _buildPaymentOption(
                          title: 'Cash Payment',
                          subtitle: 'Full payment in cash',
                          isSelected: _selectedPaymentMethod == PaymentMethod.cash,
                          onTap: () {
                            setState(() {
                              _selectedPaymentMethod = PaymentMethod.cash;
                              _selectedAccount = null;
                              _creditAmountController.clear();
                              _remainingAmount = _totalAmount;
                            });
                          },
                        ),

                        // Credit Option
                        _buildPaymentOption(
                          title: 'Credit Payment',
                          subtitle: 'Full payment via account',
                          isSelected: _selectedPaymentMethod == PaymentMethod.credit,
                          onTap: () {
                            setState(() {
                              _selectedPaymentMethod = PaymentMethod.credit;
                              _remainingAmount = 0.0;
                              _creditAmountController.text = _totalAmount.toStringAsFixed(2);
                            });
                          },
                        ),

                        // Mixed Option
                        _buildPaymentOption(
                          title: 'Mixed Payment',
                          subtitle: 'Part credit, rest cash',
                          isSelected: _selectedPaymentMethod == PaymentMethod.mixed,
                          onTap: () {
                            setState(() {
                              _selectedPaymentMethod = PaymentMethod.mixed;
                              _remainingAmount = _totalAmount;
                              _creditAmountController.text = '0';
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Account Selection (for credit and mixed)
                  if (_selectedPaymentMethod != PaymentMethod.cash)
                    GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
                      title: 'Customer Account',
                      hintText: 'Select account for credit payment',
                      isRequired: _selectedPaymentMethod != PaymentMethod.cash,
                      bloc: context.read<AccountsBloc>(),
                      fetchAllFunction: (bloc) => bloc.add(LoadAccountsFilterEvent(start: 5, end: 5, exclude: '')),
                      searchFunction: (bloc, query) => bloc.add(LoadAccountsFilterEvent(
                        input: query,
                        start: 5,
                        end: 5,
                        exclude: '',
                      )),
                      itemBuilder: (context, account) => ListTile(
                        title: Text(account.accName ?? ''),
                        subtitle: Text('${account.accNumber} - Balance: ${account.accAvailBalance?.toAmount()}'),
                      ),
                      itemToString: (account) => '${account.accName} (${account.accNumber})',
                      stateToLoading: (state) => state is AccountLoadingState,
                      stateToItems: (state) => state is AccountLoadedState ? state.accounts : [],
                      onSelected: (value) {
                        setState(() {
                          _selectedAccount = value;
                        });
                      },
                      controller: null,
                    ),

                  // Credit Amount (for credit and mixed)
                  if (_selectedPaymentMethod != PaymentMethod.cash)
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        ZTextFieldEntitled(
                          title: 'Credit Amount',
                          controller: _creditAmountController,
                          isRequired: _selectedPaymentMethod != PaymentMethod.cash,
                          onChanged: (value) {
                            final creditAmount = double.tryParse(value) ?? 0.0;
                            setState(() {
                              if (creditAmount > _totalAmount) {
                                _creditAmountController.text = _totalAmount.toStringAsFixed(2);
                                _remainingAmount = 0.0;
                              } else {
                                _remainingAmount = _totalAmount - creditAmount;
                              }
                            });
                          },
                        ),
                      ],
                    ),

                  // Payment Summary
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Invoice:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("${_totalAmount.toAmount()} $baseCurrency"),
                          ],
                        ),
                        if (_selectedPaymentMethod == PaymentMethod.credit) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Credit Payment:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("${_totalAmount.toAmount()} $baseCurrency"),
                            ],
                          ),
                        ],
                        if (_selectedPaymentMethod == PaymentMethod.mixed) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Credit Payment:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("${(_totalAmount - _remainingAmount).toAmount()} $baseCurrency"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Cash Payment:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              Text("${_remainingAmount.toAmount()} $baseCurrency", style: TextStyle(color: Colors.green)),
                            ],
                          ),
                        ],
                        if (_selectedPaymentMethod == PaymentMethod.cash) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Cash Payment:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              Text("${_totalAmount.toAmount()} $baseCurrency", style: TextStyle(color: Colors.green)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(tr.cancel),
              ),
              ZButton(
                label: const Text('Convert'),
                onPressed: () => _convertEstimateToSale(estimate),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue : Colors.black,
                  )),
                  Text(subtitle, style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.blue : Colors.grey,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _convertEstimateToSale(EstimateModel estimate) {
    if (_userName == null) {
      Utils.showOverlayMessage(context, message: 'User not authenticated', isError: true);
      return;
    }

    // Validation
    if (_selectedPaymentMethod != PaymentMethod.cash && _selectedAccount == null) {
      Utils.showOverlayMessage(context, message: 'Please select an account for credit payment', isError: true);
      return;
    }

    if (_selectedPaymentMethod != PaymentMethod.cash) {
      final creditAmount = double.tryParse(_creditAmountController.text) ?? 0.0;
      if (creditAmount <= 0) {
        Utils.showOverlayMessage(context, message: 'Please enter credit amount', isError: true);
        return;
      }

      if (creditAmount > _totalAmount) {
        Utils.showOverlayMessage(context, message: 'Credit amount cannot exceed total invoice', isError: true);
        return;
      }
    }

    // Prepare API parameters based on payment method
    int account = 0;
    String amount = "0";

    switch (_selectedPaymentMethod) {
      case PaymentMethod.cash:
      // API expects account = 0, amount = 0 for cash
        account = 0;
        amount = "0";
        break;

      case PaymentMethod.credit:
      // Full amount via credit
        account = _selectedAccount?.accNumber ?? 0;
        amount = _totalAmount.toStringAsFixed(2);
        break;

      case PaymentMethod.mixed:
      // Part credit, rest auto cash
        account = _selectedAccount?.accNumber ?? 0;
        final creditAmount = double.tryParse(_creditAmountController.text) ?? 0.0;
        amount = creditAmount.toStringAsFixed(2);
        break;
    }

    // Send conversion request
    context.read<EstimateBloc>().add(ConvertEstimateToSaleEvent(
      usrName: _userName!,
      orderId: estimate.ordId!,
      perID: estimate.ordPersonal!,
      account: account,
      amount: amount,
      isCash: _selectedPaymentMethod == PaymentMethod.cash,
    ));

    Navigator.pop(context); // Close dialog
  }

  void _updateRemainingAmount() {
    if (_selectedPaymentMethod == PaymentMethod.cash) {
      _remainingAmount = _totalAmount;
    } else if (_selectedPaymentMethod == PaymentMethod.credit) {
      _remainingAmount = 0.0;
    } else if (_selectedPaymentMethod == PaymentMethod.mixed) {
      final creditAmount = double.tryParse(_creditAmountController.text) ?? 0.0;
      _remainingAmount = _totalAmount - creditAmount;
      if (_remainingAmount < 0) _remainingAmount = 0.0;
    }
  }

  void _deleteEstimate(EstimateModel estimate) {
    if (_userName == null) {
      Utils.showOverlayMessage(context, message: 'User not authenticated', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Estimate'),
        content: const Text('Are you sure you want to delete this estimate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<EstimateBloc>().add(DeleteEstimateEvent(
                orderId: estimate.ordId!,
                usrName: _userName!,
              ));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Payment Method Enum
enum PaymentMethod {
  cash,
  credit,
  mixed,
}