import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Generic/rounded_searchable_textfield.dart';
import 'package:zaitoon_petroleum/Features/Generic/underline_searchable_textfield.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../Features/Other/cover.dart';
import '../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';
import '../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../../../Settings/Ui/Stock/Ui/Products/bloc/products_bloc.dart';
import '../../../Settings/Ui/Stock/Ui/Products/model/product_stock_model.dart';
import '../../../Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import '../../../Stakeholders/Ui/Accounts/model/acc_model.dart';
import 'bloc/adjustment_bloc.dart';
import 'model/adj_items.dart';

class AdjustmentFormView extends StatefulWidget {
  const AdjustmentFormView({super.key});

  @override
  State<AdjustmentFormView> createState() => _AdjustmentFormViewState();
}

class _AdjustmentFormViewState extends State<AdjustmentFormView> {
  final TextEditingController _expenseAccountController = TextEditingController();
  final TextEditingController _xRefController = TextEditingController();
  final List<List<FocusNode>> _rowFocusNodes = [];
  final Map<String, TextEditingController> _qtyControllers = {};
  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, TextEditingController> _productControllers = {};
  final Map<String, TextEditingController> _storageControllers = {};

  int? _selectedExpenseAccount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdjustmentBloc>().add(InitializeAdjustmentEvent());
    });
  }

  @override
  void dispose() {
    for (final row in _rowFocusNodes) {
      for (final node in row) {
        node.dispose();
      }
    }
    _expenseAccountController.dispose();
    _xRefController.dispose();
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    for (final controller in _productControllers.values) {
      controller.dispose();
    }
    for (final controller in _storageControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final authState = context.watch<AuthBloc>().state;
    final userName = (authState is AuthenticatedState) ? authState.loginData.usrName ?? "" : "";

    return BlocListener<AdjustmentBloc, AdjustmentState>(
      listener: (context, state) {
        if (state is AdjustmentError) {
          Utils.showOverlayMessage(context, message: state.message, isError: true);
        }
        if (state is AdjustmentSaved) {
          if (state.success) {
            Utils.showOverlayMessage(
              context,
              title: tr.successTitle,
              message: 'Adjustment ${state.adjustmentNumber} created successfully',
              isError: false,
            );
            Navigator.pop(context);
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('New Adjustment', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Expense Account and Reference
          Row(
            children: [
              Expanded(
                flex: 5,
                child: GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
                  showAllOnFocus: true,
                  controller: _expenseAccountController,
                  title: tr.accounts,
                  hintText: tr.accNameOrNumber,
                  isRequired: true,
                  bloc: context.read<AccountsBloc>(),
                  fetchAllFunction: (bloc) => bloc.add(
                    LoadAccountsFilterEvent(include: "11,12", ccy: "USD", exclude: ""),
                  ),
                  searchFunction: (bloc, query) => bloc.add(
                    LoadAccountsFilterEvent(
                        include: "11,12",
                        ccy: "USD",
                        input: query,
                        exclude: ""
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return tr.required(tr.accounts);
                    }
                    return null;
                  },
                  itemBuilder: (context, account) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                            Text(
                              "${account.accAvailBalance?.toAmount() ?? "0.0"} ${account.actCurrency}",
                              style: Theme.of(context).textTheme.bodyMedium,
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
                    if (state is AccountLoadedState) return state.accounts;
                    return [];
                  },
                  onSelected: (value) {
                    _selectedExpenseAccount = value.accNumber;
                    context.read<AdjustmentBloc>().add(SelectExpenseAccountEvent(value.accNumber ?? 0));
                  },
                  noResultsText: tr.noDataFound,
                  showClearButton: true,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 200,
                child: ZTextFieldEntitled(
                  title: tr.invoiceNumber,
                  controller: _xRefController,
                  hint: 'Optional reference',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Items Header
          _buildItemsHeader(context),

          // Items List
          Expanded(
            child: BlocBuilder<AdjustmentBloc, AdjustmentState>(
              builder: (context, state) {
                if (state is AdjustmentFormLoaded || state is AdjustmentSaving) {
                  final current = state is AdjustmentSaving
                      ? state
                      : (state as AdjustmentFormLoaded);
                  _synchronizeFocusNodes(current.items.length);

                  return ListView.builder(
                    shrinkWrap: true,
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
                return const SizedBox();
              },
            ),
          ),

          // Summary and Actions
          BlocBuilder<AdjustmentBloc, AdjustmentState>(
            builder: (context, state) {
              if (state is AdjustmentFormLoaded || state is AdjustmentSaving) {
                final current = state is AdjustmentSaving
                    ? state
                    : (state as AdjustmentFormLoaded);
                final isSaving = state is AdjustmentSaving;
                final companyState = context.read<CompanyProfileBloc>().state;
                final baseCurrency = (companyState is CompanyProfileLoadedState)
                    ? companyState.company.comLocalCcy ?? ""
                    : "";

                return Column(
                  children: [
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Adjustment: ${current.totalAmount.toAmount()} $baseCurrency',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            ZOutlineButton(
                              width: 120,
                              onPressed: () => Navigator.pop(context),
                              label: Text(tr.cancel),
                            ),
                            const SizedBox(width: 8),
                            ZButton(
                              width: 120,
                              onPressed: (isSaving || !current.isFormValid || _selectedExpenseAccount == null)
                                  ? null
                                  : () => _saveAdjustment(context, current, userName),
                              label: isSaving
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              )
                                  : Text(tr.submit),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
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
          SizedBox(width: 25, child: Text('#', style: title)),
          Expanded(child: Text(locale.products, style: title)),
          SizedBox(width: 100, child: Text(locale.qty, style: title)),
          SizedBox(width: 120, child: Text("Unit Cost", style: title)),
          SizedBox(width: 120, child: Text("Total Cost", style: title)),
          SizedBox(width: 150, child: Text(locale.storage, style: title)),
          SizedBox(width: 60, child: Text(locale.actions, style: title)),
        ],
      ),
    );
  }

  Widget _buildItemRow({
    required BuildContext context,
    required AdjustmentItem item,
    required List<FocusNode> nodes,
    required bool isLastRow,
  }) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    TextStyle? title = textTheme.titleSmall?.copyWith(color: color.primary);

    final productController = _productControllers.putIfAbsent(
      item.rowId,
          () => TextEditingController(text: item.productName),
    );
    final qtyController = _qtyControllers.putIfAbsent(
      item.rowId,
          () => TextEditingController(
        text: item.quantity > 0 ? item.quantity.toString() : '',
      ),
    );
    final priceController = _priceControllers.putIfAbsent(
      item.rowId,
          () => TextEditingController(
        text: item.purPrice != null && item.purPrice! > 0
            ? item.purPrice!.toAmount()
            : '',
      ),
    );
    final storageController = _storageControllers.putIfAbsent(
      item.rowId,
          () => TextEditingController(text: item.storageName),
    );

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            color: _rowFocusNodes.indexOf(nodes).isEven
                ? Colors.transparent
                : Colors.grey.shade50,
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
                  fetchAllFunction: (bloc) => bloc.add(LoadProductsStockEvent(noStock: 1)),
                  searchFunction: (bloc, query) => bloc.add(LoadProductsStockEvent()),
                  itemBuilder: (context, product) => ListTile(
                    tileColor: Colors.transparent,
                    title: Text(product.proName ?? ''),
                    subtitle: Row(
                      spacing: 5,
                      children: [
                        Wrap(
                          children: [
                            ZCover(radius: 0,child: Text(tr.purchasePrice,style: title),),
                            ZCover(radius: 0,child: Text(product.purchasePrice?.toAmount()??"")),
                          ],
                        ),
                        Wrap(
                          children: [
                            ZCover(radius: 0,child: Text(tr.salePriceBrief,style: title)),
                            ZCover(radius: 0,child: Text(product.sellPrice?.toAmount()??"")),
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
                    final storageId = product.stkStorage;
                    final storageName = product.stgName ?? '';

                    context.read<AdjustmentBloc>().add(
                      UpdateAdjustmentItemEvent(
                        rowId: item.rowId,
                        productId: product.proId.toString(),
                        productName: product.proName ?? '',
                        storageId: storageId,
                        storageName: storageName,
                        purPrice: purchasePrice,
                      ),
                    );

                    priceController.text = purchasePrice.toAmount();
                    storageController.text = storageName;

                    // Auto-focus on quantity field after product selection
                    if (nodes.length > 1) {
                      nodes[1].requestFocus();
                    }
                  },
                ),
              ),

              // Quantity
              SizedBox(
                width: 100,
                child: TextField(
                  controller: qtyController,
                  focusNode: nodes.length > 1 ? nodes[1] : FocusNode(),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: tr.qty,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                  onChanged: (value) {
                    final qty = double.tryParse(value) ?? 0;
                    context.read<AdjustmentBloc>().add(
                      UpdateAdjustmentItemEvent(
                        rowId: item.rowId,
                        quantity: qty,
                      ),
                    );
                  },
                ),
              ),

              // Purchase Price
              SizedBox(
                width: 120,
                child: TextField(
                  controller: priceController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Cost Price",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                ),
              ),

              // Total Cost
              SizedBox(
                width: 120,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Text(
                    item.totalCost.toAmount(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

              // Storage
              SizedBox(
                width: 150,
                child: TextField(
                  controller: storageController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: tr.storage,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                ),
              ),

              // Actions
              SizedBox(
                width: 60,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () {
                    _priceControllers.remove(item.rowId);
                    _qtyControllers.remove(item.rowId);
                    _productControllers.remove(item.rowId);
                    _storageControllers.remove(item.rowId);
                    context.read<AdjustmentBloc>().add(
                      RemoveAdjustmentItemEvent(item.rowId),
                    );
                  },
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
                  icon: Icons.add,
                  label: Text(tr.addItem),
                  onPressed: () {
                    context.read<AdjustmentBloc>().add(AddNewAdjustmentItemEvent());
                  },
                ),
              ],
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
        FocusNode(), // Price
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

  void _saveAdjustment(
      BuildContext context,
      AdjustmentFormLoaded state,
      String userName,
      ) {
    if (_selectedExpenseAccount == null) {
      Utils.showOverlayMessage(
        context,
        message: 'Please select an expense account',
        isError: true,
      );
      return;
    }

    final completer = Completer<String>();

    context.read<AdjustmentBloc>().add(
      SaveAdjustmentEvent(
        usrName: userName,
        xRef: _xRefController.text.isNotEmpty ? _xRefController.text : "ADJ-${DateTime.now().millisecondsSinceEpoch}",
        expenseAccount: _selectedExpenseAccount!,
        items: state.items,
        completer: completer,
      ),
    );
  }
}