import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/individual_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/OrderScreen/NewSale/bloc/sale_invoice_bloc.dart';
import '../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../../Features/Generic/underline_searchable_textfield.dart';
import '../../../../../../../Features/Other/thousand_separator.dart';
import '../../../../../../../Features/Other/utils.dart';
import '../../../../../../../Features/Other/zForm_dialog.dart';
import '../../../../../../../Features/PrintSettings/print_preview.dart';
import '../../../../../../../Features/PrintSettings/report_model.dart';
import '../../../../../../../Features/Widgets/button.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../../../../Settings/Ui/Stock/Ui/Products/bloc/products_bloc.dart';
import '../../../../Settings/Ui/Stock/Ui/Products/model/product_stock_model.dart';
import '../../../../Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import '../../../../Stakeholders/Ui/Accounts/model/acc_model.dart';
import '../Print/print.dart';
import 'model/sale_invoice_items.dart';

class NewSaleView extends StatelessWidget {
  const NewSaleView({super.key});

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
      context.read<SaleInvoiceBloc>().add(InitializeSaleInvoiceEvent());
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
      child: BlocListener<SaleInvoiceBloc, SaleInvoiceState>(
        listener: (context, state) {
          if (state is SaleInvoiceError) {
            Utils.showOverlayMessage(context, message: state.message, isError: true);
          }
          if (state is SaleInvoiceSaved) {
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
                      Text(tr.saleEntry, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold,fontSize: 20))
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Customer and Account Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: GenericTextfield<IndividualsModel, IndividualsBloc, IndividualsState>(
                          key: const ValueKey('person_field'),
                          controller: _personController,
                          title: tr.customer,
                          hintText: tr.customer,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return tr.required(tr.customer);
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
                            context.read<SaleInvoiceBloc>().add(SelectCustomerEvent(value));
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
                        child: BlocBuilder<SaleInvoiceBloc, SaleInvoiceState>(
                          builder: (context, state) {
                            if (state is SaleInvoiceLoaded) {
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
                                  context.read<SaleInvoiceBloc>().add(SelectCustomerAccountEvent(value));
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
                                context.read<SaleInvoiceBloc>().add(SelectCustomerAccountEvent(value));
                              },
                              showClearButton: true,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ZOutlineButton(
                        width: 100,
                        icon: Icons.print,
                        onPressed: () => _printSaleInvoice(),
                        label: Text(tr.print),
                      ),
                      const SizedBox(width: 8),
                      ZOutlineButton(
                        width: 100,
                        icon: Icons.refresh,
                        onPressed: () {
                          context.read<SaleInvoiceBloc>().add(ResetSaleInvoiceEvent());
                          _accountController.clear();
                          _personController.clear();
                          _xRefController.clear();
                        },
                        label: Text(tr.newKeyword),
                      ),
                      const SizedBox(width: 8),
                      BlocBuilder<SaleInvoiceBloc, SaleInvoiceState>(
                          builder: (context, state) {
                            if (state is SaleInvoiceLoaded || state is SaleInvoiceSaving) {
                              final current = state is SaleInvoiceSaving ?
                              state : (state as SaleInvoiceLoaded);
                              final isSaving = state is SaleInvoiceSaving;

                              return ZButton(
                                width: 100,
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
                  const SizedBox(height: 10),

                  // Items Header
                  _buildItemsHeader(context),
                  const SizedBox(height: 8),

                  // Items List
                  Expanded(
                    child: BlocBuilder<SaleInvoiceBloc, SaleInvoiceState>(
                      builder: (context, state) {
                        if (state is SaleInvoiceLoaded || state is SaleInvoiceSaving) {
                          final current = state is SaleInvoiceSaving ?
                          state : (state as SaleInvoiceLoaded);
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 8,
                    children: [
                      Expanded(child: _buildSummarySection(context)),
                      Expanded(child: _buildProfitSummarySection(context)),
                    ],
                  ),
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
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: BoxDecoration(
        color: color.primary,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          SizedBox(width: 25, child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Text('#', style: title),
          )),
          Expanded(child: Text(locale.products, style: title)),
          SizedBox(width: 80, child: Text(locale.qty, style: title)),
         // SizedBox(width: 120, child: Text(locale.costPrice, style: title)),
          SizedBox(width: 120, child: Text(locale.unitPrice, style: title)),
          SizedBox(width: 120, child: Text(locale.totalTitle, style: title)),
          SizedBox(width: 150, child: Text(locale.storage, style: title)),
          SizedBox(width: 60, child: Text(locale.actions, style: title)),
        ],
      ),
    );
  }

  Widget _buildItemRow({
    required BuildContext context,
    required SaleInvoiceItem item,
    required List<FocusNode> nodes,
    required bool isLastRow,
  }) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    TextStyle? title = textTheme.titleSmall?.copyWith(color: color.primary);

    final productController = TextEditingController(text: item.productName);
    final qtyController = _qtyControllers.putIfAbsent(
      item.rowId, () => TextEditingController(text: item.qty > 0 ? item.qty.toString() : ''),
    );

    final purchasePriceController = _priceControllers.putIfAbsent(
      "purchase_${item.rowId}", () => TextEditingController(text: item.purPrice != null && item.purPrice! > 0 ? item.purPrice!.toAmount() : ''),
    );

    // FIX: Use putIfAbsent to properly manage the sale price controller
    final salePriceController = _priceControllers.putIfAbsent(
      "sale_${item.rowId}", () => TextEditingController(text: item.salePrice != null && item.salePrice! > 0 ? item.salePrice!.toAmount() : ''),
    );

    final storageController = TextEditingController(text: item.storageName);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  (_rowFocusNodes.indexOf(nodes) + 1).toString(),
                  textAlign: TextAlign.center,
                ),
              ),

              // Product Selection
              Expanded(
                child: GenericUnderlineTextfield<ProductsStockModel, ProductsBloc, ProductsState>(
                  title: "",
                  controller: productController,
                  hintText: tr.products,
                  bloc: context.read<ProductsBloc>(),
                  fetchAllFunction: (bloc) => bloc.add(LoadProductsStockEvent()),
                  searchFunction: (bloc, query) => bloc.add(LoadProductsStockEvent()),
                  itemBuilder: (context, product) => ListTile(
                    title: Text(product.proName ?? ''),
                    subtitle: Row(
                      spacing: 5,
                      children: [
                       Wrap(
                         children: [
                           Cover(radius: 0,child: Text(tr.purchasePrice,style: title),),
                           Cover(radius: 0,child: Text(product.purchasePrice?.toAmount()??"")),
                         ],
                       ),
                        Wrap(
                          children: [
                            Cover(radius: 0,child: Text(tr.salePriceBrief,style: title)),
                            Cover(radius: 0,child: Text(product.sellPrice?.toAmount()??"")),
                          ],
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(product.available?.toAmount()??"",style: TextStyle(fontSize: 18),),
                        Text(product.stgName??"",style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),),
                      ],
                    ),
                  ),
                  itemToString: (product) => product.proName ?? '',
                  stateToLoading: (state) => state is ProductsLoadingState,
                  stateToItems: (state) {
                    if (state is ProductsStockLoadedState) return state.products;
                    return [];
                  },
                  onSelected: (product) {
                    final purchasePrice = double.tryParse(product.purchasePrice?.toAmount() ?? "0.0") ?? 0.0;
                    final salePrice = double.tryParse(product.sellPrice?.toAmount() ?? "0.0") ?? 0.0;

                    // Get storage ID and name from product
                    final storageId = product.stkStorage;
                    final storageName = product.stgName ?? '';

                    context.read<SaleInvoiceBloc>().add(UpdateSaleItemEvent(
                      rowId: item.rowId,
                      productId: product.proId.toString(),
                      productName: product.proName ?? '',
                      storageId: storageId,
                      storageName: storageName,
                      purPrice: purchasePrice,
                      salePrice: salePrice,
                    ));

                    // Update controllers
                    purchasePriceController.text = purchasePrice.toAmount();
                    salePriceController.text = salePrice.toAmount();
                    storageController.text = storageName;

                    nodes[1].requestFocus(); // Focus on quantity field
                  },
                ),
              ),

              // Quantity
              SizedBox(
                width: 80,
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
                    hintText: tr.qty,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      context.read<SaleInvoiceBloc>().add(UpdateSaleItemEvent(
                        rowId: item.rowId,
                        qty: 0,
                      ));
                      return;
                    }
                    final qty = int.tryParse(value) ?? 0;
                    context.read<SaleInvoiceBloc>().add(UpdateSaleItemEvent(
                      rowId: item.rowId,
                      qty: qty,
                    ));
                  },
                  onSubmitted: (_) => nodes[2].requestFocus(),
                ),
              ),

              // Purchase Price (Read-only/Disabled)
              // SizedBox(
              //   width: 120,
              //   child: TextField(
              //     controller: purchasePriceController,
              //     focusNode: nodes[2],
              //     readOnly: true, // Make purchase price read-only
              //     keyboardType: const TextInputType.numberWithOptions(decimal: true),
              //     inputFormatters: [
              //       FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              //       SmartThousandsDecimalFormatter(),
              //       // Prevent invalid prices
              //       TextInputFormatter.withFunction((oldValue, newValue) {
              //         if (newValue.text.isEmpty) return newValue;
              //         final parsed = double.tryParse(newValue.text.replaceAll(',', ''));
              //         if (parsed == null || parsed <= 0) {
              //           return TextEditingValue.empty;
              //         }
              //         return newValue;
              //       }),
              //     ],
              //     decoration: InputDecoration(
              //       hintText: tr.costPrice,
              //       border: InputBorder.none,
              //       isDense: true,
              //     ),
              //     onSubmitted: (_) => nodes[3].requestFocus(),
              //   ),
              // ),

              // Sale Price (Editable) - ULTRA SIMPLE FIX
              SizedBox(
                width: 120,
                child: TextField(
                  controller: salePriceController,
                  focusNode: nodes[3],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    // Only allow numbers and decimal point
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                  decoration: InputDecoration(
                    hintText: tr.salePrice,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      context.read<SaleInvoiceBloc>().add(UpdateSaleItemEvent(
                        rowId: item.rowId,
                        salePrice: 0,
                      ));
                      return;
                    }
                    final parsed = double.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      context.read<SaleInvoiceBloc>().add(
                        UpdateSaleItemEvent(
                          rowId: item.rowId,
                          salePrice: parsed,
                        ),
                      );
                    }
                  },
                ),
              ),

              // Total Sale (Selling total)
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.totalSale.toAmount(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (item.purPrice != null && item.purPrice! > 0 && item.salePrice != null && item.salePrice! > 0)
                      Text(
                        '${tr.profit}: ${(item.totalSale - item.totalPurchase).toAmount()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: (item.totalSale - item.totalPurchase) >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                  ],
                ),
              ),

              // Storage Display (Read-only)
              SizedBox(
                width: 150,
                child: TextField(
                  controller: storageController,
                  focusNode: nodes[4],
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: tr.storage,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),

              // Actions
              SizedBox(
                width: 65,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      isSelected: true,
                      hoverColor: color.primary.withValues(alpha: .05),
                      onPressed: () {
                        // Clean up controllers before removing
                        _priceControllers.remove("purchase_${item.rowId}");
                        _priceControllers.remove("sale_${item.rowId}");
                        _qtyControllers.remove(item.rowId);
                        context.read<SaleInvoiceBloc>().add(RemoveSaleItemEvent(item.rowId));
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
                  height: 35,
                  backgroundColor: color.primary.withValues(alpha: .08),
                  icon: Icons.add,
                  label: Text(AppLocalizations.of(context)!.addItem),
                  onPressed: () {
                    context.read<SaleInvoiceBloc>().add(AddNewSaleItemEvent());
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

    return BlocBuilder<SaleInvoiceBloc, SaleInvoiceState>(
      builder: (context, state) {
        if (state is SaleInvoiceLoaded || state is SaleInvoiceSaving) {
          final current = state is SaleInvoiceSaving ?
          state :
          (state as SaleInvoiceLoaded);

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

                SizedBox(height: 5),


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
                    value: current.cashPayment,
                    color: Colors.green,
                  ),
                ] else if (current.paymentMode == PaymentMode.credit) ...[
                  _buildSummaryRow(
                    label: AppLocalizations.of(context)!.accountPayment,
                    value: current.creditAmount,
                    color: Colors.orange,
                  ),
                ] else if (current.paymentMode == PaymentMode.mixed) ...[
                  _buildSummaryRow(
                    label: AppLocalizations.of(context)!.accountPayment,
                    value: current.creditAmount,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 4),
                  _buildSummaryRow(
                    label: AppLocalizations.of(context)!.cashPayment,
                    value: current.cashPayment,
                    color: Colors.green,
                  ),
                ],

                // Account Information
                if (current.customerAccount != null) ...[
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
  Widget _buildProfitSummarySection(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final tr = AppLocalizations.of(context)!;

    return BlocBuilder<SaleInvoiceBloc, SaleInvoiceState>(
      builder: (context, state) {
        if (state is SaleInvoiceLoaded || state is SaleInvoiceSaving) {
          final current = state is SaleInvoiceSaving ?
          state :
          (state as SaleInvoiceLoaded);

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
                // Profit Summary
                _buildSummaryRow(
                  label: tr.totalCost,
                  value: current.totalPurchaseCost,
                  color: color.primary.withValues(alpha: .9),
                ),
                SizedBox(height: 5),
                _buildSummaryRow(
                  label: tr.profit,
                  value: current.totalProfit,
                  color: current.totalProfit >= 0 ? Colors.green : Colors.red,
                  isBold: true,
                ),
                if (current.totalPurchaseCost > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${tr.profit} %', style: TextStyle(fontSize: 16)),
                      Text(
                        '${current.profitPercentage.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 16,
                          color: current.totalProfit >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
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
        FocusNode(), // Product
        FocusNode(), // Quantity
        FocusNode(), // Purchase Price (read-only)
        FocusNode(), // Sale Price
        FocusNode(), // Storage
      ]);
    }
    while (_rowFocusNodes.length > itemCount) {
      final removed = _rowFocusNodes.removeLast();
      for (final node in removed) {
        node.dispose();
      }
    }
  }
  void _showPaymentModeDialog(SaleInvoiceLoaded current) {
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
                context.read<SaleInvoiceBloc>().add(ClearCustomerAccountEvent());
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
                context.read<SaleInvoiceBloc>().add(UpdateSaleReceivePaymentEvent(0));
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

  void _showMixedPaymentDialog(BuildContext context, SaleInvoiceLoaded current) {
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
          context.read<SaleInvoiceBloc>().add(UpdateSaleReceivePaymentEvent(
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

  void _saveInvoice(BuildContext context, SaleInvoiceLoaded state) {
    // Additional validation
    if (!state.isFormValid) {
      Utils.showOverlayMessage(context, message: 'Please fill all required fields correctly', isError: true);
      return;
    }

    final completer = Completer<String>();

    context.read<SaleInvoiceBloc>().add(SaveSaleInvoiceEvent(
      usrName: _userName ?? '',
      orderName: "Sale",
      ordPersonal: state.customer!.perId!,
      xRef: _xRefController.text.isNotEmpty ? _xRefController.text : null,
      items: state.items,
      completer: completer,
    ));
  }

  void _printSaleInvoice() {
    final state = context.read<SaleInvoiceBloc>().state;

    if (state is! SaleInvoiceLoaded) {
      Utils.showOverlayMessage(context, message: 'Cannot print: No invoice data loaded', isError: true);
      return;
    }

    final current = state;

    // Get company info
    final companyState = context.read<CompanyProfileBloc>().state;
    if (companyState is! CompanyProfileLoadedState) {
      Utils.showOverlayMessage(context, message: 'Company information not available', isError: true);
      return;
    }

    final company = ReportModel(
      comName: companyState.company.comName ?? "",
      comAddress: companyState.company.addName ?? "",
      compPhone: companyState.company.comPhone ?? "",
      comEmail: companyState.company.comEmail ?? "",
      statementDate: DateTime.now().toFullDateTime,
    );

    // Get company logo
    final base64Logo = companyState.company.comLogo;
    if (base64Logo != null && base64Logo.isNotEmpty) {
      try {
        company.comLogo = base64Decode(base64Logo);
      } catch (e) {
       "";
      }
    }


    // Prepare invoice items for print
    final List<InvoiceItem> invoiceItems = current.items.map((item) {
      return SaleInvoiceItemForPrint(
        productName: item.productName,
        quantity: item.qty.toDouble(),
        unitPrice: item.salePrice ?? 0.0,
        total: item.totalSale,
        storageName: item.storageName,
        purchasePrice: item.purPrice ?? 0.0,
        profit: (item.salePrice ?? 0.0) - (item.purPrice ?? 0.0),
      );
    }).toList();

    showDialog(
      context: context,
      builder: (_) => PrintPreviewDialog<dynamic>(
        data: null, // You can pass current state here if needed
        company: company,
        buildPreview: ({
          required data,
          required language,
          required orientation,
          required pageFormat,
        }) {
          return InvoicePrintService().printInvoicePreview(
            invoiceType: "Sale",
            invoiceNumber: 0, // Use 0 for new invoices, or get from saved invoice
            reference: _xRefController.text,
            invoiceDate: DateTime.now(),
            customerSupplierName: current.customer?.perName ?? "",
            items: invoiceItems,
            grandTotal: current.grandTotal,
            cashPayment: current.cashPayment,
            creditAmount: current.creditAmount,
            account: current.customerAccount,
            language: language,
            orientation: orientation,
            company: company,
            pageFormat: pageFormat,
            currency: baseCurrency,
          );
        },
        onPrint: ({
          required data,
          required language,
          required orientation,
          required pageFormat,
          required selectedPrinter,
          required copies,
          required pages,
        }) {
          return InvoicePrintService().printInvoiceDocument(
            invoiceType: "Sale",
            invoiceNumber: 0,
            reference: _xRefController.text,
            invoiceDate: DateTime.now(),
            customerSupplierName: current.customer?.perName ?? "",
            items: invoiceItems,
            grandTotal: current.grandTotal,
            cashPayment: current.cashPayment,
            creditAmount: current.creditAmount,
            account: current.customerAccount,
            language: language,
            orientation: orientation,
            company: company,
            selectedPrinter: selectedPrinter,
            pageFormat: pageFormat,
            copies: copies,
            currency: baseCurrency,
          );
        },
        onSave: ({
          required data,
          required language,
          required orientation,
          required pageFormat,
        }) {
          return InvoicePrintService().createInvoiceDocument(
            invoiceType: "Sale",
            invoiceNumber: 0,
            reference: _xRefController.text,
            invoiceDate: DateTime.now(),
            customerSupplierName: current.customer?.perName ?? "",
            items: invoiceItems,
            grandTotal: current.grandTotal,
            cashPayment: current.cashPayment,
            creditAmount: current.creditAmount,
            account: current.customerAccount,
            language: language,
            orientation: orientation,
            company: company,
            pageFormat: pageFormat,
            currency: baseCurrency,
          );
        },
      ),
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