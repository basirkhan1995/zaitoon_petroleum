import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Generic/rounded_searchable_textfield.dart';
import 'package:zaitoon_petroleum/Features/Generic/underline_searchable_textfield.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/thousand_separator.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/bloc/storage_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/model/storage_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/Products/bloc/products_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/Products/model/product_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/Products/model/product_stock_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/model/acc_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/individual_model.dart';
import '../../../../../../Auth/bloc/auth_bloc.dart';
import 'bloc/order_by_id_bloc.dart';
import 'model/ord_by_Id_model.dart';

class OrderByIdView extends StatefulWidget {
  final int orderId;

  const OrderByIdView({super.key, required this.orderId});

  @override
  State<OrderByIdView> createState() => _OrderByIdViewState();
}

class _OrderByIdViewState extends State<OrderByIdView> {
  final List<List<FocusNode>> _rowFocusNodes = [];
  final Map<int, TextEditingController> _qtyControllers = {};
  final Map<int, TextEditingController> _priceControllers = {};
  final TextEditingController _personController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  String? _userName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderByIdBloc>().add(LoadOrderByIdEvent(widget.orderId));
      // Load storages and products
      context.read<StorageBloc>().add(LoadStorageEvent());
      context.read<ProductsBloc>().add(LoadProductsEvent());
    });
  }

  @override
  void dispose() {
    for (final row in _rowFocusNodes) {
      for (final node in row) {
        node.dispose();
      }
    }
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    _personController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState is AuthenticatedState) {
      _userName = authState.loginData.usrName;
    }

    return BlocListener<OrderByIdBloc, OrderByIdState>(
      listener: (context, state) {
        if (state is OrderByIdError) {
          Utils.showOverlayMessage(context, message: state.message, isError: true);
        }
        if (state is OrderByIdSaved) {
          Utils.showOverlayMessage(
            context,
            message: state.message,
            isError: !state.success,
          );

          if (state.success) {
            Navigator.of(context).pop();
          }
        }

        if (state is OrderByIdDeleted) {
          Utils.showOverlayMessage(
            context,
            message: state.message,
            isError: !state.success,
          );

          if (state.success) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          actionsPadding: EdgeInsets.symmetric(horizontal: 12),
          title: Text('#${widget.orderId}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<OrderByIdBloc>().add(LoadOrderByIdEvent(widget.orderId));
              },
            ),
            BlocBuilder<OrderByIdBloc, OrderByIdState>(
              builder: (context, state) {
                if (state is OrderByIdLoaded && state.order.trnStateText?.toLowerCase() == 'pending') {
                  return Row(
                    children: [
                      IconButton(
                        icon: Icon(state.isEditing ? Icons.visibility : Icons.edit),
                        onPressed: () => _toggleEditMode(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _showDeleteDialog(context, state.order),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
        body: BlocBuilder<OrderByIdBloc, OrderByIdState>(
          builder: (context, state) {
            if (state is OrderByIdLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is OrderByIdError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ZButton(
                      label: Text("Retry"),
                      onPressed: () => context.read<OrderByIdBloc>().add(LoadOrderByIdEvent(widget.orderId)),
                    ),
                  ],
                ),
              );
            }

            if (state is OrderByIdSaving) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Saving changes...'),
                  ],
                ),
              );
            }

            if (state is OrderByIdDeleting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Deleting order...'),
                  ],
                ),
              );
            }

            if (state is OrderByIdLoaded) {
              final order = state.order;
              final isEditing = state.isEditing;

              _initializeControllers(order);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Order Header
                    _buildOrderHeader(context, state),
                    const SizedBox(height: 24),

                    // Items Header
                    _buildItemsHeader(context, isEditing),
                    const SizedBox(height: 8),

                    // Items List
                    _buildItemsList(context, order, state, isEditing),

                    const SizedBox(height: 24),

                    // Order Summary
                    _buildOrderSummary(context, state),

                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(context, order, state),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context, OrderByIdLoaded state) {
    final order = state.order;
    final statusColor = _getStatusColor(order.trnStateText);
    final color = Theme.of(context).colorScheme;
    final tr = AppLocalizations.of(context)!;

    return Cover(
      radius: 5,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.ordName}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.trnStateText?.toUpperCase() ?? 'UNKNOWN',
                    style: TextStyle(
                      color: color.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Supplier/Customer Selection
            Row(
              children: [
                Expanded(
                  child: state.isEditing
                      ? GenericTextfield<IndividualsModel, IndividualsBloc, IndividualsState>(
                    controller: TextEditingController(
                        text: state.selectedSupplier != null
                            ? "${state.selectedSupplier!.perName} ${state.selectedSupplier!.perLastName}"
                            : order.personal ?? ''
                    ),
                    title: order.ordName?.toLowerCase().contains('purchase') ?? true
                        ? tr.supplier
                        : tr.customer,
                    hintText: order.ordName?.toLowerCase().contains('purchase') ?? true
                        ? tr.supplier
                        : tr.customer,
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
                      context.read<OrderByIdBloc>().add(SelectOrderSupplierEvent(value));
                      // Load accounts for this individual
                      context.read<AccountsBloc>().add(LoadAccountsFilterEvent(
                          input: value.perId.toString(),
                          start: 5,
                          end: 5,
                          exclude: ''
                      ));
                    },
                    showClearButton: true,
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.ordName?.toLowerCase().contains('purchase') ?? true
                            ? tr.supplier
                            : tr.customer,
                        style: TextStyle(color: color.outline),
                      ),
                      Text(
                        order.personal ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr.billNo, style: TextStyle(color: color.outline)),
                      Text(order.ordxRef ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Account Selection (Editable when editing and credit payment)
            if (state.isEditing && state.creditAmount > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
                    controller: TextEditingController(
                        text: state.selectedAccount != null
                            ? '${state.selectedAccount!.accName} (${state.selectedAccount!.accNumber})'
                            : ''
                    ),
                    title: tr.accounts,
                    hintText: tr.selectAccount,
                    isRequired: state.creditAmount > 0,
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
                      context.read<OrderByIdBloc>().add(SelectOrderAccountEvent(value));
                    },
                    showClearButton: true,
                  ),
                  const SizedBox(height: 8),
                ],
              ),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr.referenceNumber, style: TextStyle(color: color.outline)),
                      Text(order.ordTrnRef ?? '-', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr.date, style: TextStyle(color: color.outline)),
                      Text(
                        order.ordEntryDate?.toString().substring(0, 19) ?? '-',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Payment Details
            if (state.isEditing)
              _buildEditablePaymentSection(context, state)
            else
              _buildReadOnlyPaymentSection(context, order, state),
          ],
        ),
      ),
    );
  }

  Widget _buildEditablePaymentSection(BuildContext context, OrderByIdLoaded state) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr.paymentDetails, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),

        // Payment Mode Selection
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(tr.cash),
                    selected: state.paymentMode == PaymentMode.cash,
                    onSelected: (selected) {
                      if (selected) {
                        context.read<OrderByIdBloc>().add(UpdateOrderPaymentEvent(
                          cashPayment: state.grandTotal,
                          creditAmount: 0.0,
                        ));
                      }
                    },
                  ),
                  ChoiceChip(
                    label: Text(tr.creditTitle),
                    selected: state.paymentMode == PaymentMode.credit,
                    onSelected: (selected) {
                      if (selected) {
                        context.read<OrderByIdBloc>().add(UpdateOrderPaymentEvent(
                          cashPayment: 0.0,
                          creditAmount: state.grandTotal,
                        ));
                      }
                    },
                  ),
                  ChoiceChip(
                    label: Text(tr.combinedPayment),
                    selected: state.paymentMode == PaymentMode.mixed,
                    onSelected: (selected) {
                      if (selected && state.grandTotal > 0) {
                        // Default to 50/50 split for mixed
                        final half = state.grandTotal / 2;
                        context.read<OrderByIdBloc>().add(UpdateOrderPaymentEvent(
                          cashPayment: half,
                          creditAmount: state.grandTotal - half,
                        ));
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Cash Payment Input
        if (state.paymentMode != PaymentMode.credit)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr.cashPayment, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: color.outline.withValues(alpha: .3)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: TextEditingController(
                      text: state.cashPayment.toStringAsFixed(2)
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    suffixText: tr.currencyTitle,
                  ),
                  onChanged: (value) {
                    final cash = double.tryParse(value) ?? 0.0;
                    final credit = state.grandTotal - cash;
                    context.read<OrderByIdBloc>().add(UpdateOrderPaymentEvent(
                      cashPayment: cash,
                      creditAmount: credit,
                    ));
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),

        // Credit Amount Input
        if (state.paymentMode != PaymentMode.cash)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr.accountPayment, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: color.outline.withValues(alpha: .3)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: TextEditingController(
                      text: state.creditAmount.toStringAsFixed(2)
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    suffixText: tr.currencyTitle,
                  ),
                  onChanged: (value) {
                    final credit = double.tryParse(value) ?? 0.0;
                    final cash = state.grandTotal - credit;
                    context.read<OrderByIdBloc>().add(UpdateOrderPaymentEvent(
                      cashPayment: cash,
                      creditAmount: credit,
                    ));
                  },
                ),
              ),
            ],
          ),

        // Payment Validation
        if (!state.isPaymentValid)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'payment must match total invoice ${state.totalPayment.toAmount()} ≠ ${state.grandTotal.toAmount()}',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        if (state.selectedAccount != null && state.creditAmount > 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Divider(color: color.outline.withValues(alpha: .3)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr.currentBalance, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    (double.tryParse(state.selectedAccount!.accAvailBalance ?? "0.0") ?? 0.0).toAmount(),
                    style: TextStyle(color: Colors.deepOrangeAccent),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr.newBalance, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    ((double.tryParse(state.selectedAccount!.accAvailBalance ?? "0.0") ?? 0.0) + state.creditAmount).toAmount(),
                    style: TextStyle(color: color.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildReadOnlyPaymentSection(BuildContext context, OrderByIdModel order, OrderByIdLoaded state) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;

    double total = double.tryParse(order.amount ?? "0.0") ?? 0.0;
    bool hasAccount = order.acc != null && order.acc! > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr.paymentDetails, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (hasAccount)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.credit_card, size: 16, color: color.outline),
                  const SizedBox(width: 8),
                  Text(
                    tr.accountNumber,
                    style: TextStyle(
                      color: color.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                order.acc.toString(),
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
            ],
          ),

        Row(
          children: [
            Icon(Icons.money, size: 16, color: color.outline),
            const SizedBox(width: 8),
            Text(
              tr.payment,
              style: TextStyle(
                color: color.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          hasAccount
              ? '${tr.creditTitle}: ${total.toAmount()}'
              : '${tr.cash}: ${total.toAmount()}',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildItemsHeader(BuildContext context, bool isEditing) {
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
          SizedBox(width: 40, child: Text('#', style: title)),
          Expanded(child: Text(locale.products, style: title)),
          SizedBox(width: 100, child: Text(locale.qty, style: title)),
          SizedBox(width: 150, child: Text(locale.unitPrice, style: title)),
          SizedBox(width: 100, child: Text(locale.totalTitle, style: title)),
          SizedBox(width: 180, child: Text(locale.storage, style: title)),
          if (isEditing) SizedBox(width: 60, child: Text(locale.actions, style: title)),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, OrderByIdModel order, OrderByIdLoaded state, bool isEditing) {
    if (order.records == null || order.records!.isEmpty) {
      return Cover(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                SizedBox(height: 16),
                Text(
                  'No Items Found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: order.records!.length,
          itemBuilder: (context, index) {
            final record = order.records![index];
            final nodes = _rowFocusNodes.length > index ? _rowFocusNodes[index] : [FocusNode(), FocusNode()];
            return _buildItemRow(
              context,
              record: record,
              index: index,
              state: state,
              nodes: nodes,
              isEditing: isEditing,
            );
          },
        ),
        if (isEditing)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                ZOutlineButton(
                  icon: Icons.add,
                  label: Text(AppLocalizations.of(context)!.addItem),
                  onPressed: () => context.read<OrderByIdBloc>().add(AddOrderItemEvent()),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildItemRow(
      BuildContext context, {
        required OrderRecords record,
        required int index,
        required OrderByIdLoaded state,
        required List<FocusNode> nodes,
        required bool isEditing,
      }) {
    final locale = AppLocalizations.of(context)!;
    final productName = state.productNames[record.stkProduct] ?? 'Unknown';
    final storageName = state.storageNames[record.stkStorage] ?? 'Unknown';

    final productController = TextEditingController(text: productName);
    final qtyController = _qtyControllers[index] ?? TextEditingController(text: record.stkQuantity);

    // Determine which price to show based on order type
    final isPurchase = state.order.ordName?.toLowerCase().contains('purchase') ?? true;
    final priceText = isPurchase
        ? record.stkPurPrice?.toAmount()
        : record.stkSalePrice?.toAmount();

    final priceController = _priceControllers[index] ?? TextEditingController(text: priceText);
    final storageController = TextEditingController(text: storageName);

    final qty = double.tryParse(record.stkQuantity ?? "0") ?? 0;
    double price;

    if (isPurchase) {
      price = double.tryParse(record.stkPurPrice ?? "0") ?? 0;
    } else {
      price = double.tryParse(record.stkSalePrice ?? "0") ?? 0;
    }

    final total = qty * price;

    final color = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: color.outline)),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text((index + 1).toString())),

          // Product
          Expanded(
            child: isEditing
                ? GenericUnderlineTextfield<dynamic, ProductsBloc, ProductsState>(
              controller: productController,
              hintText: locale.products,
              bloc: context.read<ProductsBloc>(),
              fetchAllFunction: (bloc) => isPurchase
                  ? bloc.add(LoadProductsEvent())
                  : bloc.add(LoadProductsStockEvent()),
              searchFunction: (bloc, query) => isPurchase
                  ? bloc.add(LoadProductsEvent())
                  : bloc.add(LoadProductsStockEvent()),
              itemBuilder: (context, product) {
                if (isPurchase) {
                  final prod = product as ProductsModel;
                  return ListTile(
                    title: Text(prod.proName ?? ''),
                    subtitle: Text(prod.proCode ?? ''),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("T"),
                      ],
                    ),
                  );
                } else {
                  final prod = product as ProductsStockModel;
                  return ListTile(
                    title: Text(prod.proName ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${locale.purchasePrice}: ${prod.purchasePrice?.toAmount() ?? "0.0"}'),
                        Text('${locale.salePrice}: ${prod.sellPrice?.toAmount() ?? "0.0"}'),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(prod.available?.toAmount() ?? "0.0"),
                        Text(prod.stgName ?? '', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  );
                }
              },
              itemToString: (product) {
                if (isPurchase) {
                  return (product as ProductsModel).proName ?? '';
                } else {
                  return (product as ProductsStockModel).proName ?? '';
                }
              },
              stateToLoading: (state) => state is ProductsLoadingState,
              stateToItems: (state) {
                if (isPurchase) {
                  if (state is ProductsLoadedState) return state.products;
                } else {
                  if (state is ProductsStockLoadedState) return state.products;
                }
                return [];
              },
              onSelected: (product) {
                int productId;
                String productName;

                if (isPurchase) {
                  productId = (product as ProductsModel).proId!;
                  productName = (product).proName ?? '';
                } else {
                  productId = (product as ProductsStockModel).proId!;
                  productName = (product).proName ?? '';

                  // For sale orders, also set storage from product
                  final storageId = (product).stkStorage;
                  if (storageId != null && storageId > 0) {
                    context.read<OrderByIdBloc>().add(UpdateOrderItemEvent(
                      index: index,
                      productId: productId,
                      storageId: storageId,
                    ));

                    // Update storage controller
                    final storageName = (product).stgName ?? '';
                    storageController.text = storageName;
                  }
                }

                context.read<OrderByIdBloc>().add(UpdateOrderItemEvent(
                  index: index,
                  productId: productId,
                ));

                // Update price if available
                if (!isPurchase) {
                  final salePrice = (product as ProductsStockModel).sellPrice;
                  if (salePrice != null) {
                    final priceValue = double.tryParse(salePrice) ?? 0.0;
                    context.read<OrderByIdBloc>().add(UpdateOrderItemEvent(
                      index: index,
                      price: priceValue,
                    ));
                    priceController.text = priceValue.toAmount();
                  }
                }
              },
              title: '',
            )
                : TextField(
              controller: productController,
              readOnly: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          // Quantity
          SizedBox(
            width: 100,
            child: TextField(
              controller: qtyController,
              focusNode: isEditing ? nodes[0] : null,
              readOnly: !isEditing,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: isEditing ? (value) {
                final qty = double.tryParse(value) ?? 0.0;
                context.read<OrderByIdBloc>().add(UpdateOrderItemEvent(
                  index: index,
                  quantity: qty,
                ));
              } : null,
            ),
          ),

          // Price
          SizedBox(
            width: 150,
            child: TextField(
              controller: priceController,
              focusNode: isEditing ? nodes[1] : null,
              readOnly: !isEditing,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                SmartThousandsDecimalFormatter(),
              ],
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: isEditing ? (value) {
                final price = double.tryParse(value.replaceAll(',', '')) ?? 0.0;
                context.read<OrderByIdBloc>().add(UpdateOrderItemEvent(
                  index: index,
                  price: price,
                ));
              } : null,
            ),
          ),

          // Total
          SizedBox(
            width: 100,
            child: Text(
              total.toAmount(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          // Storage
          SizedBox(
            width: 180,
            child: isEditing
                ? GenericUnderlineTextfield<StorageModel, StorageBloc, StorageState>(
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
                context.read<OrderByIdBloc>().add(UpdateOrderItemEvent(
                  index: index,
                  storageId: storage.stgId,
                ));
              },
              title: '',
            )
                : TextField(
              controller: storageController,
              readOnly: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          // Actions
          if (isEditing)
            SizedBox(
              width: 60,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: () => _removeItemDialog(context, index),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, OrderByIdLoaded state) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: color.outline),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            context,
            label: tr.grandTotal,
            value: state.grandTotal,
            isBold: true,
          ),
          if (state.cashPayment > 0)
            _buildSummaryRow(
              context,
              label: tr.cashPayment,
              value: state.cashPayment,
              color: Colors.green,
            ),
          if (state.creditAmount > 0)
            _buildSummaryRow(
              context,
              label: tr.accountPayment,
              value: state.creditAmount,
              color: Colors.orange,
            ),
          if (state.selectedAccount != null && state.creditAmount > 0)
            Column(
              children: [
                Divider(color: color.outline.withValues(alpha: 0.3)),
                _buildSummaryRow(
                  context,
                  label: tr.currentBalance,
                  value: double.tryParse(state.selectedAccount!.accAvailBalance ?? "0.0") ?? 0.0,
                  color: Colors.deepOrangeAccent,
                ),
                const SizedBox(height: 4),
                _buildSummaryRow(
                  context,
                  label: tr.newBalance,
                  value: (double.tryParse(state.selectedAccount!.accAvailBalance ?? "0.0") ?? 0.0) + state.creditAmount,
                  isBold: true,
                  color: color.primary,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderByIdModel order, OrderByIdLoaded state) {
    final tr = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (order.trnStateText?.toLowerCase() == 'pending')
          ZOutlineButton(
            width: 120,
            label: Text(state.isEditing ? tr.cancel : tr.edit),
            onPressed: () => _toggleEditMode(context),
          ),
        if (state.isEditing) const SizedBox(width: 16),
        if (state.isEditing)
          ZButton(
            width: 120,
            onPressed: !state.isPaymentValid || state.selectedSupplier == null ? null : () => _saveChanges(context),
            label: Text(tr.saveChanges),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(
      BuildContext context, {
        required String label,
        required double value,
        bool isBold = false,
        Color? color,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
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
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _initializeControllers(OrderByIdModel order) {
    if (order.records == null) return;

    // Initialize focus nodes
    while (_rowFocusNodes.length < order.records!.length) {
      _rowFocusNodes.add([FocusNode(), FocusNode()]);
    }
    while (_rowFocusNodes.length > order.records!.length) {
      final removed = _rowFocusNodes.removeLast();
      for (final node in removed) {
        node.dispose();
      }
    }

    // Initialize controllers
    for (var i = 0; i < order.records!.length; i++) {
      final record = order.records![i];
      _qtyControllers[i] = TextEditingController(text: record.stkQuantity);

      // Determine which price to show based on order type
      final isPurchase = order.ordName?.toLowerCase().contains('purchase') ?? true;
      final priceText = isPurchase
          ? record.stkPurPrice?.toAmount()
          : record.stkSalePrice?.toAmount();

      _priceControllers[i] = TextEditingController(text: priceText);
    }
  }

  void _toggleEditMode(BuildContext context) {
    final state = context.read<OrderByIdBloc>().state;
    if (state is OrderByIdLoaded) {
      context.read<OrderByIdBloc>().add(ToggleEditModeEvent());
    }
  }

  void _removeItemDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text('Are you sure you want to remove this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<OrderByIdBloc>().add(RemoveOrderItemEvent(index));
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _saveChanges(BuildContext context) {
    if (_userName == null) {
      Utils.showOverlayMessage(context, message: 'User not authenticated', isError: true);
      return;
    }

    final completer = Completer<bool>();
    context.read<OrderByIdBloc>().add(SaveOrderChangesEvent(
      usrName: _userName!,
      completer: completer,
    ));
  }

  void _showDeleteDialog(BuildContext context, OrderByIdModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this order?'),
            SizedBox(height: 8),
            Text('Order: ${order.ordName ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Reference: ${order.ordTrnRef ?? 'N/A'}'),
            SizedBox(height: 12),
            Text(
              'Note: Only pending orders can be deleted. Verified transactions cannot be deleted.',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteOrder(context, order);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteOrder(BuildContext context, OrderByIdModel order) {
    if (_userName == null) {
      Utils.showOverlayMessage(context, message: 'User not authenticated', isError: true);
      return;
    }

    context.read<OrderByIdBloc>().add(DeleteOrderEvent(
      orderId: order.ordId!,
      ref: order.ordTrnRef ?? '',
      orderName: order.ordName ?? '',
      usrName: _userName!,
    ));
  }
}