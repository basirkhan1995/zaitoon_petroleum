import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
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
import '../../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../../../../Settings/Ui/Stock/Ui/Products/bloc/products_bloc.dart';
import '../../../../Settings/Ui/Stock/Ui/Products/model/product_model.dart';
import '../../../../Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import '../../../../Stakeholders/Ui/Accounts/model/acc_model.dart';
import 'bloc/purchase_invoice_bloc.dart';
import 'model/purchase_invoice_items.dart';

class NewPurchaseOrderView extends StatelessWidget {
  const NewPurchaseOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const _Mobile(),
      desktop: const _Desktop(),
      tablet: const _Tablet(),
    );
  }
}

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _personController = TextEditingController();
  final TextEditingController _xRefController = TextEditingController();

  final List<List<FocusNode>> _rowFocusNodes = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _userName;
  String? baseCurrency;

  // Track controllers for each row
  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, TextEditingController> _qtyControllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PurchaseInvoiceBloc>().add(InitializePurchaseInvoiceEvent());
    });

    final companyState = context.read<CompanyProfileBloc>().state;
    if (companyState is CompanyProfileLoadedState) {
      baseCurrency = companyState.company.comLocalCcy ?? "";
    }
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

    // Dispose all price and qty controllers
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
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
      child: BlocListener<PurchaseInvoiceBloc, PurchaseInvoiceState>(
        listener: (context, state) {
          if (state is PurchaseInvoiceError) {
            Utils.showOverlayMessage(context, message: state.message, isError: true);
          }
          if (state is PurchaseInvoiceSaved) {
            if (state.success) {
              Utils.showOverlayMessage(
                context,
                title: tr.successTitle,
                message: tr.successPurchaseInvoiceMsg,
                isError: false,
              );
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
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Utils.zBackButton(context),
                      Text(tr.purchaseEntry, style: Theme.of(context).textTheme.titleLarge)
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Supplier and Account Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: GenericTextfield<IndividualsModel, IndividualsBloc, IndividualsState>(
                          key: const ValueKey('person_field'),
                          controller: _personController,
                          title: tr.supplier,
                          hintText: tr.supplier,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return tr.required(tr.supplier);
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
                            context.read<PurchaseInvoiceBloc>().add(SelectSupplierEvent(value));
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
                      Expanded(
                        child: BlocBuilder<PurchaseInvoiceBloc, PurchaseInvoiceState>(
                          builder: (context, state) {
                            if (state is PurchaseInvoiceLoaded) {
                              final current = state;
                              return GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
                                key: const ValueKey('account_field'),
                                controller: _accountController,
                                title: tr.accounts,
                                hintText: tr.selectAccount,
                                isRequired: current.paymentMode != PaymentMode.cash,
                                validator: (value) {
                                  if (current.paymentMode != PaymentMode.cash && (value == null || value.isEmpty)) {
                                    return tr.selectCreditAccountMsg;
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
                                  subtitle: Text('${account.accNumber} - ${tr.balance}: ${account.accAvailBalance?.toAmount() ?? "0.0"}'),
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
                                  context.read<PurchaseInvoiceBloc>().add(SelectSupplierAccountEvent(value));
                                },
                                showClearButton: true,
                              );
                            }
                            return GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
                              key: const ValueKey('account_field'),
                              controller: _accountController,
                              title: tr.accounts,
                              hintText: tr.selectAccount,
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
                                subtitle: Text('${account.accNumber} - ${tr.balance}: ${account.accAvailBalance?.toAmount() ?? "0.0"}'),
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
                                context.read<PurchaseInvoiceBloc>().add(SelectSupplierAccountEvent(value));
                              },
                              showClearButton: true,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ZTextFieldEntitled(
                            controller: _xRefController,
                            title: tr.invoiceNumber
                        ),
                      ),
                      const SizedBox(width: 8),
                      ZOutlineButton(
                        width: 120,
                        icon: Icons.refresh,
                        onPressed: () {
                          context.read<PurchaseInvoiceBloc>().add(ResetPurchaseInvoiceEvent());
                          _accountController.clear();
                          _personController.clear();
                          _xRefController.clear();
                        },
                        label: Text(tr.newKeyword),
                      ),
                      const SizedBox(width: 8),
                      BlocBuilder<PurchaseInvoiceBloc, PurchaseInvoiceState>(
                          builder: (context, state) {
                            if (state is PurchaseInvoiceLoaded || state is PurchaseInvoiceSaving) {
                              final current = state is PurchaseInvoiceSaving ?
                              state : (state as PurchaseInvoiceLoaded);
                              final isSaving = state is PurchaseInvoiceSaving;

                              return ZButton(
                                width: 120,
                                onPressed: (isSaving || !current.isFormValid) ? null : () => _saveInvoice(context, current),
                                label: isSaving
                                    ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).colorScheme.surface,
                                  ),
                                )
                                    : Text(tr.create),
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
                    child: BlocBuilder<PurchaseInvoiceBloc, PurchaseInvoiceState>(
                      builder: (context, state) {
                        if (state is PurchaseInvoiceLoaded || state is PurchaseInvoiceSaving) {
                          final current = state is PurchaseInvoiceSaving ?
                          state : (state as PurchaseInvoiceLoaded);
                          _synchronizeFocusNodes(current.items.length);
                          return ListView.builder(
                            itemCount: current.items.length,
                            itemBuilder: (context, index) {
                              final item = current.items[index];
                              final isLastRow = index == current.items.length - 1;
                              final nodes = _rowFocusNodes[index];

                              return _buildItemRow(
                                item: item,
                                nodes: nodes,
                                isLastRow: isLastRow,
                                context: context,
                              );
                            },
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),

                  // Summary Section
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
        color: color.primary,
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

  Widget _buildItemRow({required BuildContext context, required PurchaseInvoiceItem item, required List<FocusNode> nodes, required bool isLastRow,}) {
    final locale = AppLocalizations.of(context)!;

    // Get or create controllers for this row
    final productController = TextEditingController(text: item.productName);
    final qtyController = _qtyControllers.putIfAbsent(
      item.rowId,
          () => TextEditingController(text: item.qty > 0 ? item.qty.toString() : ''),
    );

    final priceController = _priceControllers.putIfAbsent(
      item.rowId,
          () => TextEditingController(text: item.purPrice != null && item.purPrice! > 0 ? item.purPrice!.toAmount() : ''),
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
                    context.read<PurchaseInvoiceBloc>().add(UpdatePurchaseItemEvent(
                      rowId: item.rowId,
                      productId: product.proId.toString(),
                      productName: product.proName ?? '',
                    ));
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    // Prevent leading zeros
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isEmpty) return newValue;
                      final parsed = int.tryParse(newValue.text);
                      if (parsed == null || parsed <= 0) {
                        return TextEditingValue.empty;
                      }
                      return newValue;
                    }),
                  ],
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.qty,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      context.read<PurchaseInvoiceBloc>().add(UpdatePurchaseItemEvent(
                        rowId: item.rowId,
                        qty: 0,
                      ));
                      return;
                    }
                    final qty = int.tryParse(value) ?? 0;
                    context.read<PurchaseInvoiceBloc>().add(UpdatePurchaseItemEvent(
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
                    // Prevent invalid prices
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isEmpty) return newValue;
                      final parsed = double.tryParse(newValue.text.replaceAll(',', ''));
                      if (parsed == null || parsed <= 0) {
                        return TextEditingValue.empty;
                      }
                      return newValue;
                    }),
                  ],
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.unitPrice,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      context.read<PurchaseInvoiceBloc>().add(UpdatePurchaseItemEvent(
                        rowId: item.rowId,
                        purPrice: 0,
                      ));
                      return;
                    }
                    final parsed = double.tryParse(value.replaceAll(',', ''));
                    if (parsed != null && parsed > 0) {
                      context.read<PurchaseInvoiceBloc>().add(
                        UpdatePurchaseItemEvent(
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
                  item.totalPurchase.toAmount(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              // Storage Selection
              SizedBox(
                width: 180,
                child: BlocBuilder<StorageBloc, StorageState>(
                  builder: (context, storageState) {
                    if (storageState is StorageLoadedState && storageState.storage.isNotEmpty) {
                      if (item.storageId == 0) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final firstStorage = storageState.storage.first;
                          context.read<PurchaseInvoiceBloc>().add(UpdatePurchaseItemEvent(
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
                        context.read<PurchaseInvoiceBloc>().add(UpdatePurchaseItemEvent(
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
                        // Clean up controllers before removing
                        _priceControllers.remove(item.rowId);
                        _qtyControllers.remove(item.rowId);
                        context.read<PurchaseInvoiceBloc>().add(RemovePurchaseItemEvent(item.rowId));
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
                  label: Text(AppLocalizations.of(context)!.addItem),
                  onPressed: () {
                    context.read<PurchaseInvoiceBloc>().add(AddNewPurchaseItemEvent());
                  },
                )
              ],
            ),
          )
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final tr = AppLocalizations.of(context)!;

    return BlocBuilder<PurchaseInvoiceBloc, PurchaseInvoiceState>(
      builder: (context, state) {
        if (state is PurchaseInvoiceLoaded || state is PurchaseInvoiceSaving) {
          final current = state is PurchaseInvoiceSaving ?
          state :
          (state as PurchaseInvoiceLoaded);

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
                    Text(tr.paymentMethod, style: TextStyle(fontWeight: FontWeight.bold)),
                    InkWell(
                      onTap: () => _showPaymentModeDialog(current),
                      child: Row(
                        children: [
                          Text(_getPaymentModeLabel(current.paymentMode),
                              style: TextStyle(color: color.primary)),
                          const SizedBox(width: 4),
                          Icon(Icons.edit, size: 16, color: color.primary),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(color: color.outline.withValues(alpha: .2)),

                // Grand Total
                _buildSummaryRow(
                  label: tr.grandTotal,
                  value: current.grandTotal,
                  isBold: true,
                ),
                Divider(color: color.outline.withValues(alpha: .2)),

                // Payment Breakdown
                if (current.paymentMode == PaymentMode.cash) ...[
                  _buildSummaryRow(
                    label: AppLocalizations.of(context)!.cashPayment,
                    value: current.cashPayment, // Use cashPayment getter
                    color: Colors.green,
                  ),
                ] else if (current.paymentMode == PaymentMode.credit) ...[
                  _buildSummaryRow(
                    label: AppLocalizations.of(context)!.accountPayment,
                    value: current.creditAmount, // Use creditAmount getter
                    color: Colors.orange,
                  ),
                ] else if (current.paymentMode == PaymentMode.mixed) ...[
                  _buildSummaryRow(
                    label: AppLocalizations.of(context)!.accountPayment,
                    value: current.creditAmount, // Use creditAmount getter
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 4),
                  _buildSummaryRow(
                    label: AppLocalizations.of(context)!.cashPayment,
                    value: current.cashPayment, // Use cashPayment getter
                    color: Colors.green,
                  ),
                ],

                // Account Information
                if (current.supplierAccount != null) ...[
                  Divider(color: color.outline.withValues(alpha: .2)),
                  _buildSummaryRow(
                    label: AppLocalizations.of(context)!.currentBalance,
                    value: current.currentBalance,
                    color: Colors.deepOrangeAccent,
                  ),
                  if (current.creditAmount > 0) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      label: AppLocalizations.of(context)!.newBalance,
                      value: current.newBalance,
                      isBold: true,
                      color: color.primary,
                    ),
                  ],
                ],
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSummaryRow({
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

  void _showPaymentModeDialog(PurchaseInvoiceLoaded current) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => ZFormDialog(
        isActionTrue: false,
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 5),
        title: tr.selectPaymentMethod,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: color.primary.withValues(alpha: .05),
                  child: Icon(Icons.money,
                      color: current.paymentMode == PaymentMode.cash ? color.primary : color.outline)),
              title: Text(tr.cashPayment),
              subtitle: Text(tr.cashPaymentSubtitle),
              trailing: current.paymentMode == PaymentMode.cash ? Icon(Icons.check, color: color.primary) : null,
              onTap: () {
                Navigator.pop(context);
                // Clear account and set full amount as cash
                _accountController.clear();
                // Use the new event to clear only account, not supplier
                context.read<PurchaseInvoiceBloc>().add(ClearSupplierAccountEvent());
              },
            ),
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: color.primary.withValues(alpha: .05),
                  child: Icon(Icons.credit_card,
                      color: current.paymentMode == PaymentMode.credit ? color.primary : color.outline)),
              title: Text(tr.accountCredit),
              subtitle: Text(tr.accountCreditSubtitle),
              trailing: current.paymentMode == PaymentMode.credit ? Icon(Icons.check, color: color.primary) : null,
              onTap: () {
                Navigator.pop(context);
                // Set payment to 0 (full credit)
                context.read<PurchaseInvoiceBloc>().add(UpdatePurchasePaymentEvent(0));
                // Show account field as required
                setState(() {
                  // This will trigger the validator to show account is required
                });
              },
            ),
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: color.primary.withValues(alpha: .05),
                  child: Icon(Icons.payments,
                      color: current.paymentMode == PaymentMode.mixed ? color.primary : color.outline)),
              title: Text(tr.combinedPayment),
              subtitle: Text(tr.combinedPaymentSubtitle),
              trailing: current.paymentMode == PaymentMode.mixed ? Icon(Icons.check, color: color.primary) : null,
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

  void _showMixedPaymentDialog(BuildContext context, PurchaseInvoiceLoaded current) {
    final controller = TextEditingController();
    final tr = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => ZFormDialog(
        title: tr.combinedPayment,
        actionLabel: Text(tr.submit),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ZTextFieldEntitled(
                title: "Account (Credit) Payment Amount",
                controller: controller,
                hint: "Enter amount to add to account as credit",
                inputFormat: [SmartThousandsDecimalFormatter()],
              ),
              const SizedBox(height: 16),
              Text(
                "${tr.grandTotal}: ${current.grandTotal.toAmount()}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (controller.text.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account (Credit) Payment: ${double.tryParse(controller.text.replaceAll(',', ''))?.toAmount() ?? '0.0'}",
                      style: const TextStyle(color: Colors.orange),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${tr.cashPayment}: ${(current.grandTotal - (double.tryParse(controller.text.replaceAll(',', '')) ?? 0)).toAmount()}",
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
            ],
          ),
        ),
        onAction: () {
          final cleaned = controller.text.replaceAll(',', '');
          final creditPayment = double.tryParse(cleaned) ?? 0;

          if (creditPayment <= 0) {
            Utils.showOverlayMessage(context, message: 'Account payment must be greater than 0', isError: true);
            return;
          }

          if (creditPayment >= current.grandTotal) {
            Utils.showOverlayMessage(context, message: 'Account payment must be less than total amount for mixed payment', isError: true);
            return;
          }

          // Pass credit amount to bloc with isCreditAmount flag
          context.read<PurchaseInvoiceBloc>().add(UpdatePurchasePaymentEvent(
            creditPayment,  // This is a POSITIONAL parameter
            isCreditAmount: true,  // This is a NAMED parameter
          ));
          Navigator.pop(context);
        },
      ),
    );
  }
  String _getPaymentModeLabel(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return AppLocalizations.of(context)!.cash;
      case PaymentMode.credit:
        return AppLocalizations.of(context)!.creditTitle;
      case PaymentMode.mixed:
        return AppLocalizations.of(context)!.combinedPayment;
    }
  }

  void _autoSelectFirstStorage(BuildContext context, String rowId) {
    final storageState = context.read<StorageBloc>().state;
    if (storageState is StorageLoadedState && storageState.storage.isNotEmpty) {
      final firstStorage = storageState.storage.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PurchaseInvoiceBloc>().add(UpdatePurchaseItemEvent(
          rowId: rowId,
          storageId: firstStorage.stgId!,
          storageName: firstStorage.stgName ?? '',
        ));
      });
    }
  }

  void _saveInvoice(BuildContext context, PurchaseInvoiceLoaded state) {
    // Additional validation
    if (!state.isFormValid) {
      Utils.showOverlayMessage(context, message: 'Please fill all required fields correctly', isError: true);
      return;
    }

    final completer = Completer<String>();

    context.read<PurchaseInvoiceBloc>().add(SavePurchaseInvoiceEvent(
      usrName: _userName ?? '',
      orderName: "Purchase",
      ordPersonal: state.supplier!.perId!,
      xRef: _xRefController.text.isNotEmpty ? _xRefController.text : null,
      items: state.items,
      completer: completer,
    ));
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