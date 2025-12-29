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
  final TextEditingController _paymentController = TextEditingController();
  final TextEditingController _narrationController = TextEditingController();

  final List<List<FocusNode>> _rowFocusNodes = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int? _userId;
  int? perId;
  double? totalAmount;
  int? accNumber;
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
    _paymentController.dispose();
    _narrationController.dispose();
    _personController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

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
              Utils.showOverlayMessage(context, message: "Success invoice",isError: false);
              // Reset form
              _paymentController.clear();
              _narrationController.clear();
            } else {
              Utils.showOverlayMessage(context, message: "Failed invoice", isError: true);
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(locale.purchaseInvoice),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<PurchaseBloc>().add(ResetPurchaseEvent());
                  _accountController.clear();
                  _paymentController.clear();
                  _narrationController.clear();
                  _personController.dispose();
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
                          controller: _personController,
                          title: locale.customer,
                          hintText: locale.customer,
                          isRequired: true,
                          bloc: context.read<IndividualsBloc>(),
                          fetchAllFunction: (bloc) => bloc.add(LoadIndividualsEvent(),),
                          searchFunction: (bloc, query) => bloc.add(LoadIndividualsEvent()),
                          itemBuilder: (context, ind) => ListTile(
                            title: Text(ind.perName ?? ''),
                            subtitle: Text(ind.perId.toString()),
                          ),
                          itemToString: (account) => "${account.perName} ${account.perLastName}",
                          stateToLoading: (state) => state is AccountLoadingState,
                          stateToItems: (state) {
                            if (state is IndividualLoadedState) return state.individuals;
                            return [];
                          },
                          onSelected: (value) {
                            context.read<PurchaseBloc>().add(SelectSupplierEvent(value));
                            perId = value.perId;
                          },
                          showClearButton: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
                          controller: _accountController,
                          title: locale.customer,
                          hintText: locale.customer,
                          isRequired: true,
                          bloc: context.read<AccountsBloc>(),
                          fetchAllFunction: (bloc) => bloc.add(LoadAccountsFilterEvent(start: 5, end: 5, exclude: ''),),
                          searchFunction: (bloc, query) => bloc.add(LoadAccountsFilterEvent(input: query,start: 5, end: 5, exclude: '')),
                          itemBuilder: (context, account) => ListTile(
                            title: Text(account.accName ?? ''),
                            subtitle: Text(account.accNumber.toString()),
                            trailing: Text(account.actCurrency??""),
                          ),
                          itemToString: (account) => account.accName ?? '',
                          stateToLoading: (state) => state is AccountLoadingState,
                          stateToItems: (state) {
                            if (state is AccountLoadedState) return state.accounts;
                            return [];
                          },
                          onSelected: (value) {
                            context.read<PurchaseBloc>().add(SelectSupplierAccountEvent(value));
                            accNumber = value.accNumber;
                          },
                          showClearButton: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ZOutlineButton(
                        icon: Icons.payments_rounded,
                        onPressed: () => _showPaymentDialog(context),
                        label: Text(locale.payment),
                      ),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text('#', style: TextStyle(color: Colors.white))),
          Expanded( child: Text(locale.products, style: TextStyle(color: Colors.white))),
          SizedBox(width: 100, child: Text("qty", style: TextStyle(color: Colors.white))),
          SizedBox(width: 100, child: Text("unit price", style: TextStyle(color: Colors.white))),
          SizedBox(width: 150, child: Text(locale.storage, style: TextStyle(color: Colors.white))),
          SizedBox(width: 100, child: Text("total", style: TextStyle(color: Colors.white))),
          SizedBox(width: 60, child: Text("action", style: TextStyle(color: Colors.white))),
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
    final priceController = TextEditingController(text: item.purPrice.toAmount());
    final storageController = TextEditingController(text: item.storageName);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
                width: 100,
                child: TextField(
                  controller: priceController,
                  focusNode: nodes[2],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Price',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    final price = double.tryParse(value) ?? 0;
                    context.read<PurchaseBloc>().add(UpdateItemEvent(
                      rowId: item.rowId,
                      purPrice: price,
                    ));
                  },
                  onSubmitted: (_) => nodes[3].requestFocus(),
                ),
              ),

              // Storage Selection
              SizedBox(
                width: 150,
                child: GenericUnderlineTextfield<StorageModel, StorageBloc, StorageState>(
                  title: "",
                  focusNode: nodes[3],
                  controller: storageController,
                  hintText: locale.storage,
                  bloc: context.read<StorageBloc>(),
                  fetchAllFunction: (bloc) => bloc.add(LoadStorageEvent()),
                  searchFunction: (bloc, query) => bloc.add(LoadStorageEvent()),
                  itemBuilder: (context, stg) => ListTile(
                    title: Text(stg.stgName ?? ''),
                    subtitle: Text('Code: ${stg.stgId ?? ''}'),
                  ),
                  itemToString: (stg) => stg.stgName ?? '',
                  stateToLoading: (state) => state is StorageLoadingState,
                  stateToItems: (state) {
                    if (state is StorageLoadedState) return state.storage;
                    return [];
                  },
                  onSelected: (product) {
                    context.read<PurchaseBloc>().add(UpdateItemEvent(
                      rowId: item.rowId,
                      storageId: product.stgId,
                      storageName: product.stgName ?? '',
                    ));
                    nodes[4].requestFocus();
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
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
        Row(
          children: [
            if (isLastRow)...[

              ZOutlineButton(
                icon: Icons.add,
                label: Text("Add Item"),
                onPressed: (){
                  context.read<PurchaseBloc>().add(AddNewItemEvent());
                },
              )
            ]
          ],
        )
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    return BlocBuilder<PurchaseBloc, PurchaseState>(
      builder: (context, state) {
        if (state is PurchaseLoaded || state is PurchaseSaving) {
          final current = state as PurchaseLoaded;
          final isSaving = state is PurchaseSaving;
          final locale = AppLocalizations.of(context)!;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Grand Total
                _buildSummaryRow(
                  context,
                  label: "grand total",
                  value: current.grandTotal,
                  isBold: true,
                ),
                const SizedBox(height: 8),

                // Payment
                _buildSummaryRow(
                  context,
                  label: locale.payment,
                  value: current.payment,
                ),
                const SizedBox(height: 8),

                // Balance
                if (current.supplier != null)
                  _buildSummaryRow(
                    context,
                    label: locale.balance,
                    value: current.netBalance,
                    isBold: true,
                    color: current.netBalance > 0 ? Colors.green : Colors.red,
                  ),

                const SizedBox(height: 16),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ZButton(
                    onPressed: isSaving ? null : () => _saveInvoice(context, current),
                    label: isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text(locale.create),
                  ),
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
          value.toAmount(),
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

  void _showPaymentDialog(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => ZFormDialog(
        title: locale.payment,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ZTextFieldEntitled(
              title: locale.amount,
              controller: controller,
              inputFormat: [SmartThousandsDecimalFormatter()],
            ),
          ],
        ),
        onAction: () {
          final cleaned = controller.text.replaceAll(',', '');
          final payment = double.tryParse(cleaned) ?? 0;
          context.read<PurchaseBloc>().add(UpdatePaymentEvent(payment));
          Navigator.pop(context);
        },
      ),
    );
  }



  void _saveInvoice(BuildContext context, PurchaseLoaded state) {
    if (!_formKey.currentState!.validate()) {
      Utils.showOverlayMessage(context, message: 'Please fill all required fields', isError: true);
      return;
    }

    if (state.items.isEmpty) {
      Utils.showOverlayMessage(context, message: 'Please add at least one item', isError: true);
      return;
    }


    final completer = Completer<String>();
    context.read<PurchaseBloc>().add(SavePurchaseInvoiceEvent(
      usrName: _userName ?? 'radveen',
      perID: state.supplier!.perId!,
      accNumber: state.accountNumber,
      xRef: "541",
      totalAmount: state.grandTotal,
      items: state.items,
      completer: completer,
    ));

    completer.future.then((invoiceNumber) {
      if (invoiceNumber.isNotEmpty) {
        Utils.showOverlayMessage(context, message: 'Invoice saved: $invoiceNumber', isError: false);
      }
    });
  }
}