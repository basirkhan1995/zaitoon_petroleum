import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/bloc/storage_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/model/storage_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/individual_model.dart';
import '../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../../Features/Generic/underline_searchable_textfield.dart';
import '../../../../../../../Features/Other/thousand_separator.dart';
import '../../../../../../../Features/Other/utils.dart';
import '../../../../../../../Features/Other/zForm_dialog.dart';
import '../../../../../../../Features/Widgets/button.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../Settings/Ui/Stock/Ui/Products/bloc/products_bloc.dart';
import '../../../../Settings/Ui/Stock/Ui/Products/model/product_model.dart';
import '../../../../Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import '../../../../Stakeholders/Ui/Accounts/model/acc_model.dart';
import 'bloc/purchase_bloc.dart';
import 'model/pur_invoice_items.dart';

class NewPurchaseView extends StatefulWidget {
  const NewPurchaseView({super.key});

  @override
  State<NewPurchaseView> createState() => _NewPurchaseViewState();
}

class _NewPurchaseViewState extends State<NewPurchaseView> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _personController = TextEditingController();
  final TextEditingController _xRefController = TextEditingController();



  final List<List<FocusNode>> _rowFocusNodes = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _userName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PurchaseBloc>().add(InitializePurchaseEvent());
    });
  }

  @override
  void dispose() {
    for (final row in _rowFocusNodes) {
      for (final node in row) {
        node.dispose();
      }
    }
    _accountController.dispose();
    _personController.dispose();
    _xRefController.dispose();

    for (final controller in _priceControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }
  final Map<String, TextEditingController> _priceControllers = {};


  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = state.loginData;
    _userName = login.usrName??"";
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          _userName = state.loginData.usrName ?? '';
        }
      },
      child: BlocListener<PurchaseBloc, PurchaseState>(
        listener: (context, state) {
          if (state is PurchaseError) {
            Utils.showOverlayMessage(context, message: state.message, isError: true);
          }
          if (state is PurchaseSaved) {
            if (state.success) {
              Utils.showOverlayMessage(
                context,
                title: "Success",
                message: "Invoice created successfully",
                isError: false,
              );
              // Reset form
              _accountController.clear();
              _personController.clear();
              _xRefController.clear();
            } else {
              Utils.showOverlayMessage(context, message: "Failed to create invoice", isError: true);
            }
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            titleSpacing: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(locale.purchaseEntry),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<PurchaseBloc>().add(ResetPurchaseEvent());
                  _accountController.clear();
                  _personController.clear();
                  _xRefController.clear();
                },
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Supplier Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: GenericTextfield<IndividualsModel, IndividualsBloc, IndividualsState>(
                          key: ValueKey('person_field'),
                          controller: _personController,
                          title: locale.supplier,
                          hintText: "Select Supplier",
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a supplier';
                            }
                            return null;
                          },
                          bloc: context.read<IndividualsBloc>(),
                          fetchAllFunction: (bloc) => bloc.add(LoadIndividualsEvent()),
                          searchFunction: (bloc, query) => bloc.add(LoadIndividualsEvent()),
                          itemBuilder: (context, ind) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("${ind.perName ?? ''} ${ind.perLastName ?? ''}"),
                          ),
                          itemToString: (individual) => "${individual.perName} ${individual.perLastName}",
                          stateToLoading: (state) => state is IndividualLoadingState,
                          stateToItems: (state) {
                            if (state is IndividualLoadedState) return state.individuals;
                            return [];
                          },
                          onSelected: (value) {
                            _personController.text = "${value.perName} ${value.perLastName}";
                            context.read<PurchaseBloc>().add(SelectSupplierEvent(value));
                            // Load accounts for this supplier
                            context.read<AccountsBloc>().add(LoadAccountsFilterEvent(
                                input: value.perId.toString(),
                                start: 5,
                                end: 5,
                                exclude: ''
                            ));
                          },
                          showClearButton: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: ZTextFieldEntitled(
                          controller: _xRefController,
                          title: locale.invoiceNumber)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: BlocBuilder<PurchaseBloc, PurchaseState>(
                          builder: (context, state) {
                            if (state is PurchaseLoaded) {
                              final current = state;

                              return GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
                                key: ValueKey('account_field'),
                                controller: _accountController,
                                title: locale.accounts,
                                hintText: locale.selectAccount,
                                isRequired: current.paymentMode != PaymentMode.cash,
                                validator: (value) {
                                  if (current.paymentMode != PaymentMode.cash && (value == null || value.isEmpty)) {
                                    return 'Please select an account for credit payment';
                                  }
                                  return null;
                                },
                                bloc: context.read<AccountsBloc>(),
                                fetchAllFunction: (bloc) => bloc.add(LoadAccountsFilterEvent(start: 5, end: 5, exclude: '')),
                                searchFunction: (bloc, query) => bloc.add(LoadAccountsFilterEvent(
                                    input: query,
                                    start: 5,
                                    end: 5,
                                    exclude: ''
                                )),
                                itemBuilder: (context, account) => ListTile(
                                  title: Text(account.accName ?? ''),
                                  subtitle: Text('${account.accNumber} - Balance: ${account.accAvailBalance?.toAmount() ?? "0.0"}'),
                                  trailing: Text(account.actCurrency ?? ""),
                                ),
                                itemToString: (account) => '${account.accName} (${account.accNumber})',
                                stateToLoading: (state) => state is AccountLoadingState,
                                stateToItems: (state) {
                                  if (state is AccountLoadedState) return state.accounts;
                                  return [];
                                },
                                onSelected: (value) {
                                  _accountController.text = '${value.accName} (${value.accNumber})';
                                  context.read<PurchaseBloc>().add(SelectSupplierAccountEvent(value));
                                },
                                showClearButton: true,

                              );
                            }
                            return GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
                              key: ValueKey('account_field'),
                              controller: _accountController,
                              title: locale.accounts,
                              hintText: locale.selectAccount,
                              isRequired: false,
                              bloc: context.read<AccountsBloc>(),
                              fetchAllFunction: (bloc) => bloc.add(LoadAccountsFilterEvent(start: 5, end: 5, exclude: '')),
                              searchFunction: (bloc, query) => bloc.add(LoadAccountsFilterEvent(
                                  input: query,
                                  start: 5,
                                  end: 5,
                                  exclude: ''
                              )),
                              itemBuilder: (context, account) => ListTile(
                                title: Text(account.accName ?? ''),
                                subtitle: Text('${account.accNumber} - Balance: ${account.accAvailBalance?.toAmount() ?? "0.0"}'),
                                trailing: Text(account.actCurrency ?? ""),
                              ),
                              itemToString: (account) => '${account.accName} (${account.accNumber})',
                              stateToLoading: (state) => state is AccountLoadingState,
                              stateToItems: (state) {
                                if (state is AccountLoadedState) return state.accounts;
                                return [];
                              },
                              onSelected: (value) {
                                _accountController.text = '${value.accName} (${value.accNumber})';
                                context.read<PurchaseBloc>().add(SelectSupplierAccountEvent(value));
                              },
                              showClearButton: true,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      BlocBuilder<PurchaseBloc, PurchaseState>(
                        builder: (context, state) {
                          if (state is PurchaseLoaded) {
                            final current = state;
                            return ZOutlineButton(
                              icon: current.paymentMode == PaymentMode.cash
                                  ? Icons.money
                                  : current.paymentMode == PaymentMode.credit
                                  ? Icons.credit_card
                                  : Icons.payments,
                              onPressed: () => _showPaymentModeDialog(context, current),
                              label: Text(_getPaymentModeLabel(current.paymentMode)),
                            );
                          }
                          return ZOutlineButton(
                            icon: Icons.payments_rounded,
                            onPressed: () {},
                            label: Text(locale.payment),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      BlocBuilder<PurchaseBloc,PurchaseState>(
                        builder: (context,state) {
                          if (state is PurchaseLoaded || state is PurchaseSaving) {
                            final current = state as PurchaseLoaded;
                            final isSaving = state is PurchaseSaving;
                            final locale = AppLocalizations.of(context)!;
                            // Save Button
                            return ZButton(
                              width: 120,
                              onPressed: isSaving ? null : () => _saveInvoice(context, current),
                              label: isSaving
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2,color: Theme.of(context).colorScheme.surface,),
                              )
                                  : Text(locale.create),
                            );
                          }
                          return const SizedBox();
                        }
                      )
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Items Header
                  _buildItemsHeader(context),
                  const SizedBox(height: 8),

                  // Items List
                  Expanded(
                    child: BlocBuilder<PurchaseBloc, PurchaseState>(
                      builder: (context, state) {
                        if (state is PurchaseLoaded || state is PurchaseSaving) {
                          final current = state as PurchaseLoaded;

                          // Ensure focus nodes match items count
                          _synchronizeFocusNodes(current.items.length);

                          return ListView.builder(
                            itemCount: current.items.length,
                            itemBuilder: (context, index) {
                              final item = current.items[index];
                              final isLastRow = index == current.items.length - 1;
                              final nodes = _rowFocusNodes[index];

                              return _buildItemRow(
                                context,
                                item: item,
                                nodes: nodes,
                                isLastRow: isLastRow,
                              );
                            },
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),

                  // Summary and Save Button
                  _buildSummarySection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemsHeader(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    TextStyle? title = Theme.of(context).textTheme.titleSmall?.copyWith(color: color.surface);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('#', style: title),
          )),
          Expanded(child: Text(locale.products, style: title)),
          SizedBox(width: 100, child: Text(locale.qty, style: title)),
          SizedBox(width: 150, child: Text(locale.unitPrice, style: title)),
          SizedBox(width: 100, child: Text(locale.totalTitle, style: title)),
          SizedBox(width: 180, child: Text(locale.storage, style: title)),
          SizedBox(width: 60, child: Text(locale.actions, style: title)),
        ],
      ),
    );
  }

  Widget _buildItemRow(
      BuildContext context, {
        required PurInvoiceItem item,
        required List<FocusNode> nodes,
        required bool isLastRow,
      }) {
    final locale = AppLocalizations.of(context)!;
    final productController = TextEditingController(text: item.productName);
    final qtyController = TextEditingController(text: item.qty.toString());
    final priceController = _priceControllers.putIfAbsent(
      item.rowId,
          () => TextEditingController(text: item.purPrice.toAmount()),
    );

    final storageController = TextEditingController(text: item.storageName);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  (_rowFocusNodes.indexOf(nodes) + 1).toString(),
                  textAlign: TextAlign.center,
                ),
              ),

              // Product Selection
              Expanded(
                child: GenericUnderlineTextfield<ProductsModel, ProductsBloc, ProductsState>(
                  title: "",
                  controller: productController,
                  hintText: locale.products,
                  bloc: context.read<ProductsBloc>(),
                  fetchAllFunction: (bloc) => bloc.add(LoadProductsEvent()),
                  searchFunction: (bloc, query) => bloc.add(LoadProductsEvent()),
                  itemBuilder: (context, product) => ListTile(
                    title: Text(product.proName ?? ''),
                    subtitle: Text('Code: ${product.proCode ?? ''}'),
                  ),
                  itemToString: (product) => product.proName ?? '',
                  stateToLoading: (state) => state is ProductsLoadingState,
                  stateToItems: (state) {
                    if (state is ProductsLoadedState) return state.products;
                    return [];
                  },
                  onSelected: (product) {
                    context.read<PurchaseBloc>().add(UpdateItemEvent(
                      rowId: item.rowId,
                      productId: product.proId.toString(),
                      productName: product.proName ?? '',
                    ));

                    // Auto-select first storage if available
                    _autoSelectFirstStorage(context, item.rowId);

                    nodes[1].requestFocus();
                  },
                ),
              ),

              // Quantity
              SizedBox(
                width: 100,
                child: TextField(
                  controller: qtyController,
                  focusNode: nodes[1],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Qty',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    final qty = int.tryParse(value) ?? 1;
                    context.read<PurchaseBloc>().add(UpdateItemEvent(
                      rowId: item.rowId,
                      qty: qty,
                    ));
                  },
                  onSubmitted: (_) => nodes[2].requestFocus(),
                ),
              ),

              // Unit Price
             SizedBox(
            width: 150,
            child: TextField(
              controller: priceController,
              focusNode: nodes[2],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                SmartThousandsDecimalFormatter(),
              ],
              decoration: const InputDecoration(
                hintText: 'Price',
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) {
                final parsed = double.tryParse(value.replaceAll(',', ''));
                if (parsed != null) {
                  context.read<PurchaseBloc>().add(
                    UpdateItemEvent(
                      rowId: item.rowId,
                      purPrice: parsed,
                    ),
                  );
                }
              },
            ),
          ),

              // Total
              SizedBox(
                width: 100,
                child: Text(
                  item.total.toAmount(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

           // Storage Selection with default first storage
              SizedBox(
                width: 180,
                child: BlocBuilder<StorageBloc, StorageState>(
                  builder: (context, storageState) {
                    if (storageState is StorageLoadedState && storageState.storage.isNotEmpty) {
                      // Auto-select first storage if not already selected
                      if (item.storageId == 0) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final firstStorage = storageState.storage.first;
                          context.read<PurchaseBloc>().add(UpdateItemEvent(
                            rowId: item.rowId,
                            storageId: firstStorage.stgId!,
                            storageName: firstStorage.stgName ?? '',
                          ));
                          storageController.text = firstStorage.stgName ?? '';
                        });
                      }
                    }

                    return GenericUnderlineTextfield<StorageModel, StorageBloc, StorageState>(
                      title: "",
                      focusNode: nodes[3],
                      controller: storageController,
                      hintText: locale.storage,
                      bloc: context.read<StorageBloc>(),
                      fetchAllFunction: (bloc) => bloc.add(LoadStorageEvent()),
                      searchFunction: (bloc, query) => bloc.add(LoadStorageEvent()),
                      itemBuilder: (context, stg) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(stg.stgName ?? ''),
                      ),
                      itemToString: (stg) => stg.stgName ?? '',
                      stateToLoading: (state) => state is StorageLoadingState,
                      stateToItems: (state) {
                        if (state is StorageLoadedState) return state.storage;
                        return [];
                      },
                      onSelected: (storage) {
                        context.read<PurchaseBloc>().add(UpdateItemEvent(
                          rowId: item.rowId,
                          storageId: storage.stgId!,
                          storageName: storage.stgName ?? '',
                        ));
                      },
                    );
                  },
                ),
              ),



              // Actions
              SizedBox(
                width: 60,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: () {
                        context.read<PurchaseBloc>().add(RemoveItemEvent(item.rowId));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isLastRow)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                ZOutlineButton(
                  width: 120,
                  icon: Icons.add,
                  label: Text(locale.addItem),
                  onPressed: () {
                    context.read<PurchaseBloc>().add(AddNewItemEvent());
                  },
                )
              ],
            ),
          )
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    return BlocBuilder<PurchaseBloc, PurchaseState>(
      builder: (context, state) {
        if (state is PurchaseLoaded || state is PurchaseSaving) {
          final current = state as PurchaseLoaded;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Payment Mode
                _buildSummaryRow(
                  context,
                  label: AppLocalizations.of(context)!.paymentMethod,
                  value: _getPaymentModeLabel(current.paymentMode),
                  isBold: false,
                  isText: true,
                ),
                const SizedBox(height: 8),

                // Grand Total
                _buildSummaryRow(
                  context,
                  label: AppLocalizations.of(context)!.grandTotal,
                  value: current.grandTotal,
                  isBold: true,
                ),
                const SizedBox(height: 8),

                // Cash Payment (if applicable)
                if (current.paymentMode != PaymentMode.credit)
                  _buildSummaryRow(
                    context,
                    label: current.paymentMode == PaymentMode.cash ? AppLocalizations.of(context)!.cashPayment : AppLocalizations.of(context)!.accountPayment,
                    value: current.cashPayment,
                    isBold: false,
                    color: Colors.green,
                  ),

                // Credit Amount (if applicable)
                if (current.paymentMode != PaymentMode.cash)
                  _buildSummaryRow(
                    context,
                    label: "Credit Amount",
                    value: current.creditAmount,
                    isBold: false,
                    color: Colors.blue,
                  ),

                // Current Balance (if account selected)
                if (current.supplierAccount != null)
                  _buildSummaryRow(
                    context,
                    label: "Current Balance",
                    value: current.currentBalance,
                    isBold: false,
                    color: Colors.grey[700],
                  ),

                // New Balance (if credit)
                if (current.supplierAccount != null && current.creditAmount > 0)
                  _buildSummaryRow(
                    context,
                    label: "New Balance",
                    value: current.newBalance,
                    isBold: true,
                    color: Colors.orange,
                  ),

              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSummaryRow(
      BuildContext context, {
        required String label,
        dynamic value,
        bool isBold = false,
        bool isText = false,
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
        isText
            ? Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        )
            : Text(
          (value as double).toAmount(),
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  void _synchronizeFocusNodes(int itemCount) {
    while (_rowFocusNodes.length < itemCount) {
      _rowFocusNodes.add([
        FocusNode(),
        FocusNode(),
        FocusNode(),
        FocusNode(),
      ]);
    }
    while (_rowFocusNodes.length > itemCount) {
      final removed = _rowFocusNodes.removeLast();
      for (final node in removed) {
        node.dispose();
      }
    }
  }

  void _showPaymentModeDialog(BuildContext context, PurchaseLoaded current) {
    showDialog(
      context: context,
      builder: (context) => ZFormDialog(
        isActionTrue: false,
        title: AppLocalizations.of(context)!.selectPaymentMethod,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.money, color: current.paymentMode == PaymentMode.cash ? Colors.green : Colors.grey),
              title: Text(AppLocalizations.of(context)!.cashPayment),
              subtitle: Text("Pay full amount in cash"),
              trailing: current.paymentMode == PaymentMode.cash ? Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                Navigator.pop(context);
                context.read<PurchaseBloc>().add(UpdatePaymentEvent(current.grandTotal));
              },
            ),
            ListTile(
              leading: Icon(Icons.credit_card, color: current.paymentMode == PaymentMode.credit ? Colors.blue : Colors.grey),
              title: Text(AppLocalizations.of(context)!.accountPayment),
              subtitle: Text("Add full amount to supplier account"),
              trailing: current.paymentMode == PaymentMode.credit ? Icon(Icons.check, color: Colors.blue) : null,
              onTap: () {
                Navigator.pop(context);
                context.read<PurchaseBloc>().add(UpdatePaymentEvent(0));
              },
            ),
            ListTile(
              leading: Icon(Icons.payments, color: current.paymentMode == PaymentMode.mixed ? Colors.orange : Colors.grey),
              title: Text("Mixed Payment"),
              subtitle: Text("Part cash, part credit"),
              trailing: current.paymentMode == PaymentMode.mixed ? Icon(Icons.check, color: Colors.orange) : null,
              onTap: () {
                Navigator.pop(context);
                _showMixedPaymentDialog(context, current);
              },
            ),
          ],
        ),
        onAction: () => Navigator.pop(context),
      ),
    );
  }

  void _showMixedPaymentDialog(BuildContext context, PurchaseLoaded current) {
    final controller = TextEditingController(text: current.payment.toString());

    showDialog(
      context: context,
      builder: (context) => ZFormDialog(
        title: "Mixed Payment Details",
        actionLabel: Text("Submit"),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ZTextFieldEntitled(
                title: "Cash Payment Amount",
                controller: controller,
                hint: "Enter cash payment amount",
                inputFormat: [SmartThousandsDecimalFormatter()],
              ),
              const SizedBox(height: 16),
              Text(
                "${AppLocalizations.of(context)!.grandTotal}: ${current.grandTotal.toAmount()}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                "Remaining ${(current.grandTotal - (double.tryParse(controller.text.replaceAll(',', '')) ?? 0)).toAmount()} will be added to supplier's account as credit",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        onAction: () {
          final cleaned = controller.text.replaceAll(',', '');
          final payment = double.tryParse(cleaned) ?? 0;

          // Validate payment
          if (payment > current.grandTotal) {
            Utils.showOverlayMessage(
              context,
              message: 'Cash payment cannot exceed grand total',
              isError: true,
            );
            return;
          }

          if (payment < 0) {
            Utils.showOverlayMessage(
              context,
              message: 'Payment cannot be negative',
              isError: true,
            );
            return;
          }

          // Update payment
          context.read<PurchaseBloc>().add(UpdatePaymentEvent(payment));
          Navigator.pop(context);
        },
      ),
    );
  }

  String _getPaymentModeLabel(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return "Cash";
      case PaymentMode.credit:
        return "Credit";
      case PaymentMode.mixed:
        return "Mixed";
    }
  }

  void _autoSelectFirstStorage(BuildContext context, String rowId) {
    final storageState = context.read<StorageBloc>().state;
    if (storageState is StorageLoadedState && storageState.storage.isNotEmpty) {
      final firstStorage = storageState.storage.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PurchaseBloc>().add(UpdateItemEvent(
          rowId: rowId,
          storageId: firstStorage.stgId!,
          storageName: firstStorage.stgName ?? '',
        ));
      });
    }
  }

  void _saveInvoice(BuildContext context, PurchaseLoaded state) {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      Utils.showOverlayMessage(
        context,
        message: 'Please fill all required fields',
        isError: true,
      );
      return;
    }

    // Validate supplier selection
    if (state.supplier == null) {
      Utils.showOverlayMessage(
        context,
        message: 'Please select a supplier',
        isError: true,
      );
      return;
    }

    // Validate account for credit payment
    if (state.paymentMode != PaymentMode.cash && state.supplierAccount == null) {
      Utils.showOverlayMessage(
        context,
        message: 'Please select a supplier account for credit payment',
        isError: true,
      );
      return;
    }

    // Validate items
    if (state.items.isEmpty) {
      Utils.showOverlayMessage(
        context,
        message: 'Please add at least one item',
        isError: true,
      );
      return;
    }

    // Validate each item
    for (var item in state.items) {
      if (item.productId.isEmpty || item.storageId == 0) {
        Utils.showOverlayMessage(
          context,
          message: 'Please fill all item details (product, quantity, price, storage)',
          isError: true,
        );
        return;
      }
    }

    final completer = Completer<String>();
    context.read<PurchaseBloc>().add(SavePurchaseInvoiceEvent(
      usrName: _userName ?? '',
      perID: state.supplier!.perId!,
      xRef: _xRefController.text,
      cashPayment: state.cashPayment,
      items: state.items,
      completer: completer,
    ));
  }
}