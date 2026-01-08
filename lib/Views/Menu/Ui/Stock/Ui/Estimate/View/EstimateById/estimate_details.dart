import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/button.dart';
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
  double _totalCost = 0.0;
  double _totalProfit = 0.0;
  bool _isCashPayment = true;
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

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
          title: Text('${widget.estimateId}'),
          actionsPadding: EdgeInsets.all(8),
          actions: [
            BlocBuilder<EstimateBloc, EstimateState>(
              builder: (context, state) {
                if (state is EstimateDetailLoaded) {
                  return Row(
                    spacing: 8,
                    children: [
                      // Delete button
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .05),
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteEstimate(state.estimate),
                          tooltip: 'Delete',
                        ),
                      ),
                      // Convert to Sale button
                      ZButton(
                        width: 130,
                        height: 35,
                        label: const Text('Convert to Sale'),
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

              // Calculate totals
              _calculateTotals(estimate);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header info
                    _buildHeaderInfo(estimate),
                    const SizedBox(height: 16),

                    // Items header
                    _buildItemsHeader(),

                    // Items list
                    _buildItemsList(estimate),

                    const SizedBox(height: 16),

                    // Summary section
                    _buildSummarySection(estimate),
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
                  Text("${estimate.total?.toAmount()} $baseCurrency"),
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
          SizedBox(width: 100, child: Text(tr.qty, style: TextStyle(color: color.surface))),
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
        final qty = double.tryParse(record.tstQuantity ?? "0") ?? 0;
        final price = double.tryParse(record.tstSalePrice ?? "0") ?? 0;
        final total = qty * price;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              SizedBox(width: 40, child: Text((index + 1).toString())),
              const Expanded(child: Text('Product Name')), // You'll need to fetch product names
              SizedBox(width: 100, child: Text(record.tstQuantity ?? '')),
              SizedBox(width: 120, child: Text(record.tstSalePrice?.toAmount() ?? '')),
              SizedBox(width: 120, child: Text(total.toAmount())),
              SizedBox(width: 150, child: Text('Storage Name')), // You'll need to fetch storage names
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummarySection(EstimateModel estimate) {
    final total = double.tryParse(estimate.total ?? "0") ?? 0.0;

    return ZCard(
      radius: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Total Cost', _totalCost),
            _buildSummaryRow('Profit', _totalProfit, color: _totalProfit >= 0 ? Colors.green : Colors.red),
             Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: .3)),
            _buildSummaryRow('Grand Total', total, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          )),
          Text("${value.toAmount()} $baseCurrency", style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Theme.of(context).colorScheme.primary,
          )),
        ],
      ),
    );
  }

  void _calculateTotals(EstimateModel estimate) {
    _totalCost = 0.0;
    _totalProfit = 0.0;

    for (final record in estimate.records ?? []) {
      final qty = double.tryParse(record.tstQuantity ?? "0") ?? 0;
      final purPrice = double.tryParse(record.tstPurPrice ?? "0") ?? 0;
      final salePrice = double.tryParse(record.tstSalePrice ?? "0") ?? 0;
      _totalCost += qty * purPrice;
      _totalProfit += qty * (salePrice - purPrice);
    }
  }

  void _showConvertToSaleDialog(EstimateModel estimate) {
    final tr = AppLocalizations.of(context)!;

    // Reset controllers
    _accountController.clear();
    _amountController.text = estimate.total ?? "0";
    _isCashPayment = true;

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
                  // Payment Type Selection
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('Cash Payment'),
                          leading: Radio<bool>(
                            value: true,
                            groupValue: _isCashPayment,
                            onChanged: (value) {
                              setState(() {
                                _isCashPayment = value!;
                                if (_isCashPayment) {
                                  _accountController.clear();
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('Credit Payment'),
                          leading: Radio<bool>(
                            value: false,
                            groupValue: _isCashPayment,
                            onChanged: (value) {
                              setState(() {
                                _isCashPayment = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Account Selection (only for credit)
                  if (!_isCashPayment) ...[
                    GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
                      controller: _accountController,
                      title: 'Customer Account',
                      hintText: 'Select account',
                      isRequired: !_isCashPayment,
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
                        _accountController.text = '${value.accName} (${value.accNumber})';
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Payment Amount (only for credit)
                  if (!_isCashPayment)
                    ZTextFieldEntitled(
                      title: 'Payment Amount',
                      controller: _amountController,
                      isRequired: !_isCashPayment,
                    ),

                  // For cash payment, show info
                  if (_isCashPayment)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Full cash payment will be processed. No account needed.',
                        style: TextStyle(color: Colors.green),
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
                onPressed: () {
                  if (!_isCashPayment && _accountController.text.isEmpty) {
                    Utils.showOverlayMessage(context, message: 'Please select an account', isError: true);
                    return;
                  }

                  if (!_isCashPayment && (_amountController.text.isEmpty || double.tryParse(_amountController.text) == 0)) {
                    Utils.showOverlayMessage(context, message: 'Please enter payment amount', isError: true);
                    return;
                  }

                  if (_userName == null) return;

                  int accountNumber = 0;
                  String amount = "0";

                  if (!_isCashPayment) {
                    // Extract account number from controller text
                    final accountText = _accountController.text;
                    final accountNumberMatch = RegExp(r'\((\d+)\)').firstMatch(accountText);
                    accountNumber = accountNumberMatch != null
                        ? int.tryParse(accountNumberMatch.group(1)!) ?? 0
                        : 0;

                    amount = _amountController.text;

                    if (accountNumber == 0) {
                      Utils.showOverlayMessage(context, message: 'Invalid account number', isError: true);
                      return;
                    }
                  }

                  context.read<EstimateBloc>().add(ConvertEstimateToSaleEvent(
                    usrName: _userName!,
                    orderId: estimate.ordId!,
                    perID: estimate.ordPersonal!,
                    account: accountNumber,
                    amount: amount,
                    isCash: _isCashPayment,
                  ));

                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
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