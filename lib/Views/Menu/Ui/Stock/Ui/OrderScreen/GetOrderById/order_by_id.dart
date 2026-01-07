import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Generic/rounded_searchable_textfield.dart';
import 'package:zaitoon_petroleum/Features/Generic/underline_searchable_textfield.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/thousand_separator.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
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
import '../../../../../../../Features/PrintSettings/print_preview.dart';
import '../../../../../../../Features/PrintSettings/report_model.dart';
import '../../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../Print/print.dart';
import 'bloc/order_by_id_bloc.dart';
import 'model/ord_by_Id_model.dart';

class OrderByIdView extends StatefulWidget {
  final int orderId;
  final String? ordName;

  const OrderByIdView({super.key,this.ordName, required this.orderId});

  @override
  State<OrderByIdView> createState() => _OrderByIdViewState();
}

class _OrderByIdViewState extends State<OrderByIdView> {
  final List<List<FocusNode>> _rowFocusNodes = [];
  final Map<int, TextEditingController> _qtyControllers = {};
  final Map<int, TextEditingController> _priceControllers = {};
  final TextEditingController _personController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  late final TextEditingController cashController;
  late final TextEditingController creditController;

  String? _userName;
  String? ccy;
  @override
  void initState() {
    super.initState();
    cashController = TextEditingController();
    creditController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderByIdBloc>().add(LoadOrderByIdEvent(widget.orderId));
      context.read<StorageBloc>().add(LoadStorageEvent());
      context.read<ProductsBloc>().add(LoadProductsEvent());
    });

    final companyState = context.read<CompanyProfileBloc>().state;
    if (companyState is CompanyProfileLoadedState) {
      ccy = companyState.company.comLocalCcy ?? "";
    }
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

  OrderByIdModel? xOrder;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      _userName = authState.loginData.usrName;
    }

    return BlocListener<OrderByIdBloc, OrderByIdState>(
      listener: (context, state) {
        if (state is OrderByIdLoaded) {
          cashController.text = state.cashPayment.toAmount();
          creditController.text = state.creditAmount.toAmount();
        }
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          titleSpacing: 0,
          actionsPadding: EdgeInsets.symmetric(horizontal: 15),
          title: Text('${widget.ordName??""} #${widget.orderId}'),
          actions: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .09),
              child: IconButton(
                icon: const Icon(Icons.refresh),
                hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                tooltip: AppLocalizations.of(context)!.refresh,
                onPressed: () {
                  context.read<OrderByIdBloc>().add(LoadOrderByIdEvent(widget.orderId));
                },
              ),
            ),
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .09),
              child: IconButton(
                icon: Icon(Icons.print),
                onPressed: () => _printInvoice(),
                hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                tooltip: AppLocalizations.of(context)!.print,
              ),
            ),
            SizedBox(width: 8),
            BlocBuilder<OrderByIdBloc, OrderByIdState>(
              builder: (context, state) {
                if(state is OrderByIdLoaded){
                  xOrder = state.order;
                }
                if (state is OrderByIdLoaded && state.order.trnStateText?.toLowerCase() == 'pending') {
                  return Row(
                    spacing: 8,
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .09),
                        child: IconButton(
                          icon: Icon(state.isEditing ? Icons.visibility : Icons.edit),
                          onPressed: () => _toggleEditMode(),
                          hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                          tooltip: state.isEditing? AppLocalizations.of(context)!.cancel : AppLocalizations.of(context)!.edit,
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .09),
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _showDeleteDialog(state.order),
                          isSelected: true,
                          hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                          tooltip: AppLocalizations.of(context)!.delete,
                        ),
                      ),
                      if (state.isEditing)...[
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .09),
                          child: IconButton(
                              hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                              onPressed: !state.isPaymentValid || state.selectedSupplier == null ? null : () => _saveChanges(),
                              tooltip: AppLocalizations.of(context)!.saveChanges,
                              icon: Icon(Icons.check)),
                        )
                      ],

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
                      width: 120,
                      label: Text(AppLocalizations.of(context)!.retry),
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
                    Text(AppLocalizations.of(context)!.savingChanges),
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
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    // Order Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Expanded(
                            flex: 3,
                            child: _buildOrderHeader(state)),
                        Expanded(
                            flex: 2,
                            child: _buildOrderHeaderDetails(state)),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Items Header
                    _buildItemsHeader(isEditing),
                    const SizedBox(height: 1),

                    // Items List
                    _buildItemsList(order, state, isEditing),

                    const SizedBox(height: 10),

                    // Order Summary
                    Row(
                      children: [
                        _buildOrderSummary(state),
                      ],
                    ),

                    const SizedBox(height: 10),
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

  Widget _buildOrderHeader(OrderByIdLoaded state) {
    final order = state.order;
    final statusColor = _getStatusColor(order.trnStateText);
    final color = Theme.of(context).colorScheme;
    final tr = AppLocalizations.of(context)!;
    final String paymentTitle = order.ordName == "Sale"? tr.customerAndPaymentDetails : tr.supplierAndPaymentDetails;
    return Cover(
      radius: 8,
      color: color.outline.withValues(alpha: .03),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  paymentTitle,
                  style: Theme.of(context).textTheme.titleLarge
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.trnStateText?.toUpperCase() ?? '',
                    style: TextStyle(
                      color: color.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            const SizedBox(height: 5),

            // Supplier/Customer Selection
            Row(
              children: [
                Expanded(
                  child: state.isEditing
                      ? GenericTextfield<IndividualsModel, IndividualsBloc, IndividualsState>(
                    controller: TextEditingController(
                        text: state.selectedSupplier != null
                            ? "${state.selectedSupplier?.perName ?? ""} ${state.selectedSupplier?.perLastName ??""}"
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
                        order.personal ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Payment Details
            if (state.isEditing)
              _buildEditablePaymentSection(state)
            else
              _buildReadOnlyPaymentSection(order, state),
          ],
        ),
      ),
    );
  }
  Widget _buildOrderHeaderDetails(OrderByIdLoaded state) {
    final order = state.order;
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final String invoiceType = order.ordName == "Sale"? tr.saleTitle : order.ordName == "Purchase"? tr.purchaseTitle : "";
    return Cover(
      radius: 10,
      color: color.outline.withValues(alpha: .03),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr.invoiceDetails,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text("${tr.orderId} #${order.ordId}")
            ],
          ),
          Divider(),
          rowHeader(title: tr.invoiceType,value: invoiceType),
          SizedBox(height: 5),
          rowHeader(title: tr.referenceNumber,value: order.ordTrnRef),
          SizedBox(height: 5),
          rowHeader(title: tr.totalInvoice,value: "${state.grandTotal.toAmount()} $ccy"),
          SizedBox(height: 5),
          rowHeader(title: tr.orderDate,value: order.ordEntryDate?.toDateTime),
          SizedBox(height: 10),

        ],
      ),
    );
  }
  Widget _buildEditablePaymentSection(OrderByIdLoaded state) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr.paymentDetails, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Divider(),
        SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [

                  // Cash Only
                  ChoiceChip(
                    selectedColor: color.primary.withValues(alpha: .1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    label: Text(tr.cash),
                    selected: state.isCashOnly,
                    onSelected: (selected) {
                      if (selected) {
                        context.read<OrderByIdBloc>().add(UpdateOrderPaymentEvent(
                          cashPayment: state.grandTotal,
                          creditAmount: 0.0,
                        ));
                      }
                    },
                  ),

                  // Credit Only
                  ChoiceChip(
                    selectedColor: color.primary.withValues(alpha: .1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    label: Text(tr.creditTitle),
                    selected: state.isCreditOnly,
                    onSelected: (selected) {
                      if (selected) {
                        context.read<OrderByIdBloc>().add(UpdateOrderPaymentEvent(
                          cashPayment: 0.0,
                          creditAmount: state.grandTotal,
                        ));
                      }
                    },
                  ),

                  // Mixed Payment
                  ChoiceChip(
                    selectedColor: color.primary.withValues(alpha: .1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    label: Text(tr.combinedPayment),
                    selected: state.isMixed,
                    onSelected: (selected) {
                      if (selected && state.grandTotal > 0) {
                        // Default to 50/50 split for mixed
                        final credit = state.grandTotal / 2;
                        final cash = state.grandTotal - credit;
                        context.read<OrderByIdBloc>().add(UpdateOrderPaymentEvent(
                          cashPayment: cash,
                          creditAmount: credit,
                        ));
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        // Account Selection (Editable when editing and credit payment)
        if (state.isEditing && state.creditAmount > 0)...[
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

        // Cash Payment Input
        if (state.paymentMode != PaymentMode.credit)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ZTextFieldEntitled(
                  title: tr.cashPayment,
                  controller: cashController,
                  inputFormat: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (value) {
                    final cash = double.tryParse(value) ?? 0.0;
                    final credit = state.grandTotal - cash;

                    context.read<OrderByIdBloc>().add(
                      UpdateOrderPaymentEvent(
                        cashPayment: cash,
                        creditAmount: credit,
                      ),
                    );
                  },
                  end: Text(ccy ?? ""),
                )

              ),
              if (state.paymentMode != PaymentMode.cash)...[
                SizedBox(width: 5),
                Expanded(
                  child: ZTextFieldEntitled(
                    title: tr.accountPayment,
                    controller: creditController,
                    inputFormat: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: (value) {
                      final credit = double.tryParse(value) ?? 0.0;
                      final cash = state.grandTotal - credit;

                      context.read<OrderByIdBloc>().add(
                        UpdateOrderPaymentEvent(
                          cashPayment: cash,
                          creditAmount: credit,
                        ),
                      );
                    },
                    end: Text(ccy ?? ""),
                  )

                ),
              ]

            ],
          ),

        // Payment Validation
        if (!state.isPaymentValid)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '${tr.paymentMismatchTotalInvoice} (${state.totalPayment.toAmount()} ≠ ${state.grandTotal.toAmount()})',
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
              Divider(color: color.outline.withValues(alpha: .3)),
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
  Widget _buildReadOnlyPaymentSection(OrderByIdModel order, OrderByIdLoaded state) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;

    double creditAmount = double.tryParse(order.amount ?? "0.0") ?? 0.0;

    bool hasAccount = order.acc != null && order.acc! > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr.paymentDetails, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Divider(),
        if (hasAccount)...[
          Row(
            children: [
              Icon(Icons.add_card_rounded, size: 20, color: color.outline),
              const SizedBox(width: 8),
              Text(
                tr.accountPayment,
                style: TextStyle(
                  color: color.outline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text("${state.order.acc.toString()} | ${state.order.personal}"),
          Text("${creditAmount.toAmount()} $ccy",
            style: TextStyle(fontSize: 14,color: color.primary,fontWeight: FontWeight.bold),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.money, size: 20, color: color.outline),
            const SizedBox(width: 8),
            Text(
              tr.cashAmount,
              style: TextStyle(
                color: color.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text("10101010 | ${tr.cash}"),
        Text("${state.cashPayment.toAmount()} $ccy",
          style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: color.primary),
        ),
      ],
    );
  }
  Widget _buildItemsHeader(bool isEditing) {
    final locale = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    TextStyle? title = Theme.of(context).textTheme.titleSmall?.copyWith(color: color.surface);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.primary,
        borderRadius: BorderRadius.circular(1),
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
  Widget _buildItemsList(OrderByIdModel order, OrderByIdLoaded state, bool isEditing) {
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
  Widget _buildItemRow({required OrderRecords record, required int index, required OrderByIdLoaded state, required List<FocusNode> nodes, required bool isEditing,}) {
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

    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    TextStyle? title = textTheme.titleSmall?.copyWith(color: color.primary);

    return Container(
      padding: EdgeInsets.symmetric(vertical: isEditing? 0 : 8, horizontal: 10),
      decoration: BoxDecoration(
        color: index.isEven? Theme.of(context).colorScheme.outline.withValues(alpha: .05) : Colors.transparent,
        border: Border(bottom: BorderSide(color: color.outline.withValues(alpha: .1))),
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

                  return ListTile(
                    title: Text(product.proName ?? ''),
                    subtitle: Row(
                      spacing: 5,
                      children: [
                        Wrap(
                          children: [
                            Cover(child: Text(tr.purchasePrice,style: title),),
                            Cover(child: Text(product.purchasePrice)),
                          ],
                        ),
                        Wrap(
                          children: [
                            Cover(radius: 0,child: Text(tr.salePriceBrief,style: title)),
                            Cover(radius: 0,child: Text(product.sellPrice)),
                          ],
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(product.available,style: TextStyle(fontSize: 18),),
                        Text(product.stgName??"",style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),),
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

                  // For sale orders, auto-set storage from product
                  final storageId = (product).stkStorage;
                  if (storageId != null && storageId > 0) {
                    context.read<OrderByIdBloc>().add(UpdateOrderItemEvent(
                      index: index,
                      productId: productId,
                      productName: productName,
                      storageId: storageId,
                    ));

                    storageController.text = (product).stgName ?? '';
                  }
                }

                context.read<OrderByIdBloc>().add(UpdateOrderItemEvent(
                  index: index,
                  productId: productId,
                  productName: productName,
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
                fontSize: 15,
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
                onPressed: () => _removeItemDialog(index),
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildOrderSummary(OrderByIdLoaded state) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;

    return Container(
      width: 600,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.outline.withValues(alpha: .03),
        border: Border.all(color: color.outline.withValues(alpha: .4)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            label: tr.grandTotal,
            value: state.grandTotal,
            isBold: true,
          ),

          // Always show cash payment if it exists
          if (state.cashPayment > 0)
            _buildSummaryRow(
              label: tr.cashPayment,
              value: state.cashPayment,
              color: Colors.green,
            ),

          // Always show credit amount if it exists
          if (state.creditAmount > 0)
            _buildSummaryRow(
              label: tr.accountPayment,
              value: state.creditAmount,
              color: Colors.orange,
            ),

          // Show account balance info if there's credit
          if (state.selectedAccount != null && state.creditAmount > 0)
            Column(
              children: [
                Divider(color: color.outline.withValues(alpha: 0.3)),
                _buildSummaryRow(
                  label: tr.currentBalance,
                  value: double.tryParse(state.selectedAccount!.accAvailBalance ?? "0.0") ?? 0.0,
                  color: Colors.deepOrangeAccent,
                ),
                _buildSummaryRow(
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
  Widget _buildSummaryRow({required String label, required double value, bool isBold = false, Color? color}) {
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
            "${value.toAmount()} $ccy",
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
      case 'authorized':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
  Widget rowHeader({required String title, dynamic value}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 150,
            child: Text(title,style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.outline))),
        Text(value)
      ],
    );
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
  void _toggleEditMode() {
    final state = context.read<OrderByIdBloc>().state;
    if (state is OrderByIdLoaded) {
      context.read<OrderByIdBloc>().add(ToggleEditModeEvent());
    }
  }
  void _removeItemDialog(int index) {
    final tr = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text(tr.removeItem),
        content:  Text(tr.removeItemMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<OrderByIdBloc>().add(RemoveOrderItemEvent(index));
              Navigator.pop(context);
            },
            child: Text(tr.remove),
          ),
        ],
      ),
    );
  }
  void _saveChanges() {
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
  void _showDeleteDialog(OrderByIdModel order) {
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
              _deleteOrder(order);
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
  void _deleteOrder(OrderByIdModel order) {
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
  void _printInvoice() {
    final state = context.read<OrderByIdBloc>().state;

    if (state is! OrderByIdLoaded) {
      Utils.showOverlayMessage(context, message: 'Cannot print: No order loaded', isError: true);
      return;
    }

    final current = state;
    final order = current.order;

    // Get company info from CompanyProfileBloc
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
      startDate: order.ordEntryDate?.toFormattedDate() ?? DateTime.now().toFormattedDate(),
      endDate: DateTime.now().toFormattedDate(),
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

    showDialog(
      context: context,
      builder: (_) => PrintPreviewDialog<OrderByIdModel>(
        data: order,
        company: company,
        buildPreview: ({
          required data,
          required language,
          required orientation,
          required pageFormat,
        }) {
          return OrderPrintService().printPreview(
            order: order,
            company: company,
            language: language,
            orientation: orientation,
            pageFormat: pageFormat,
            storages: current.storages,
            productNames: current.productNames,
            storageNames: current.storageNames,
            cashPayment: current.cashPayment,
            creditAmount: current.creditAmount,
            selectedAccount: current.selectedAccount,
            selectedSupplier: current.selectedSupplier,
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
          return OrderPrintService().printDocument(
            order: order,
            company: company,
            language: language,
            orientation: orientation,
            pageFormat: pageFormat,
            selectedPrinter: selectedPrinter,
            copies: copies,

            storages: current.storages,
            productNames: current.productNames,
            storageNames: current.storageNames,
            cashPayment: current.cashPayment,
            creditAmount: current.creditAmount,
            selectedAccount: current.selectedAccount,
            selectedSupplier: current.selectedSupplier,
          );
        },
        onSave: ({
          required data,
          required language,
          required orientation,
          required pageFormat,
        }) {
          return OrderPrintService().createDocument(
            order: order,
            company: company,
            language: language,
            orientation: orientation,
            pageFormat: pageFormat,
            storages: current.storages,
            productNames: current.productNames,
            storageNames: current.storageNames,
            cashPayment: current.cashPayment,
            creditAmount: current.creditAmount,
            selectedAccount: current.selectedAccount,
            selectedSupplier: current.selectedSupplier,
          );
        },
      ),
    );
  }
}