import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Generic/underline_searchable_textfield.dart';
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
  String? _userName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderByIdBloc>().add(LoadOrderByIdEvent(widget.orderId));
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

          // Navigate back if delete was successful
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
        }
      },
      child: Scaffold(
        appBar: AppBar(
        titleSpacing: 0,
        title: Text('Order #${widget.orderId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrderByIdBloc>().add(LoadOrderByIdEvent(widget.orderId));
            },
          ),
          BlocBuilder<OrderByIdBloc, OrderByIdState>(
            builder: (context, state) {
              if (state is OrderByIdLoaded && state.order.trnStateText == 'Pending') {
                return Row(
                  children: [
                    IconButton(
                      icon: Icon(state.isEditing ? Icons.visibility : Icons.edit),
                      onPressed: () => _toggleEditMode(context, state),
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
                      label: Text("retry"),
                      onPressed: () => context.read<OrderByIdBloc>().add(LoadOrderByIdEvent(widget.orderId)),
                    ),
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
                    _buildOrderHeader(context, order),
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
                    _buildActionButtons(context, order, isEditing),
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

  Widget _buildOrderHeader(BuildContext context, OrderByIdModel order) {
    final statusColor = _getStatusColor(order.trnStateText);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.ordName} Order',
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Supplier:', style: TextStyle(color: Colors.grey[600])),
                      Text(order.personal ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reference:', style: TextStyle(color: Colors.grey[600])),
                      Text(order.ordxRef ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transaction Ref:', style: TextStyle(color: Colors.grey[600])),
                      Text(order.ordTrnRef ?? '-', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Entry Date:', style: TextStyle(color: Colors.grey[600])),
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
            if (order.acc != null)
              Row(
                children: [
                  Icon(Icons.credit_card, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Credit Transaction',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
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
          SizedBox(width: 150, child: Text('Unit Price', style: title)),
          SizedBox(width: 100, child: Text(locale.totalTitle, style: title)),
          SizedBox(width: 180, child: Text(locale.storage, style: title)),
          if (isEditing) SizedBox(width: 60, child: Text('Actions', style: title)),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, OrderByIdModel order, OrderByIdLoaded state, bool isEditing) {
    if (order.records == null || order.records!.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
            final nodes = _rowFocusNodes[index];
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
                  label: Text("Add Item"),
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
    final priceController = _priceControllers[index] ?? TextEditingController(text: record.stkPurPrice?.toAmount());
    final storageController = TextEditingController(text: storageName);

    final qty = double.tryParse(record.stkQuantity ?? "0") ?? 0;
    final price = double.tryParse(record.stkPurPrice ?? "0") ?? 0;
    final total = qty * price;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text((index + 1).toString())),

          // Product
          Expanded(
            child: isEditing
                ? GenericUnderlineTextfield<ProductsModel, ProductsBloc, ProductsState>(
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
                // Update product ID
                context.read<OrderByIdBloc>().add(UpdateOrderItemEvent(
                  index: index,
                  price: double.tryParse(record.stkPurPrice ?? "0") ?? 0,
                ));
              }, title: '',
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
                final qty = double.tryParse(value) ?? 1.0;
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
              }, title: '',
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            context,
            label: "Grand Total",
            value: state.grandTotal,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderByIdModel order, bool isEditing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (order.trnStateText?.toLowerCase() == 'pending')
          ZOutlineButton(
            width: 120,
            label: Text(isEditing ? "Cancel Edit" : "Edit Order"),
            onPressed: () => _toggleEditMode(context, null),
          ),
        if (isEditing) const SizedBox(width: 16),
        if (isEditing)
          ZButton(
            width: 120,
            onPressed: () => _saveChanges(context),
            label: Text("Save Changes"),
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
      _priceControllers[i] = TextEditingController(text: record.stkPurPrice?.toAmount());
    }
  }

  void _toggleEditMode(BuildContext context, OrderByIdLoaded? state) {
    if (state == null) {
      context.read<OrderByIdBloc>().add(ResetOrderEvent());
      return;
    }

    context.read<OrderByIdBloc>().add(ResetOrderEvent());
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