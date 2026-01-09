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
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/bloc/storage_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/model/storage_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/Products/bloc/products_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/Products/model/product_stock_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/model/acc_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/individual_model.dart';
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

  // Edit mode variables
  bool _isEditing = false;
  final List<TextEditingController> _qtyControllers = [];
  final List<TextEditingController> _salePriceControllers = [];
  final List<TextEditingController> _storageControllers = [];
  final List<TextEditingController> _productControllers = [];
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _xRefController = TextEditingController();
  final Map<int, int> _qtyCursorPositions = {};
  final Map<int, int> _priceCursorPositions = {};

  // Selected data
  IndividualsModel? _selectedCustomer;
  final List<ProductsStockModel?> _selectedProducts = [];
  final List<StorageModel?> _selectedStorages = [];
  List<EstimateRecord> _records = [];

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
  void dispose() {
    for (final controller in _qtyControllers) {
      controller.dispose();
    }
    for (final controller in _salePriceControllers) {
      controller.dispose();
    }
    for (final controller in _storageControllers) {
      controller.dispose();
    }
    for (final controller in _productControllers) {
      controller.dispose();
    }
    _customerController.dispose();
    _xRefController.dispose();
    _creditAmountController.dispose();
    super.dispose();
  }

  void _initializeControllers(EstimateModel estimate) {
    _records = estimate.records ?? [];

    // Clear existing controllers
    for (final controller in _qtyControllers) {
      controller.dispose();
    }
    for (final controller in _salePriceControllers) {
      controller.dispose();
    }
    for (final controller in _storageControllers) {
      controller.dispose();
    }
    for (final controller in _productControllers) {
      controller.dispose();
    }

    _qtyControllers.clear();
    _salePriceControllers.clear();
    _storageControllers.clear();
    _productControllers.clear();
    _selectedProducts.clear();
    _selectedStorages.clear();

    // Set customer
    _customerController.text = estimate.ordPersonalName ?? '';
    _xRefController.text = estimate.ordxRef ?? '';

    // Initialize record controllers
    for (var i = 0; i < _records.length; i++) {
      final record = _records[i];

      _qtyControllers.add(TextEditingController(
          text: record.tstQuantity ?? "1"
      ));

      _salePriceControllers.add(TextEditingController(
          text: record.salePrice.toAmount()
      ));

      _storageControllers.add(TextEditingController(
          text: record.storageName ?? ''
      ));

      _productControllers.add(TextEditingController(
          text: record.productName ?? ''
      ));

      // Initialize selected items (these will be loaded from API)
      _selectedProducts.add(null);
      _selectedStorages.add(null);
    }
  }

  void _updateRecord(int index, {
    int? productId,
    double? quantity,
    double? salePrice,
    double? purchasePrice,
    int? storageId,
  }) {
    final record = _records[index];
    _records[index] = record.copyWith(
      tstProduct: productId ?? record.tstProduct,
      tstQuantity: quantity?.toAmount() ?? record.tstQuantity,
      tstSalePrice: salePrice?.toAmount() ?? record.tstSalePrice,
      tstPurPrice: purchasePrice?.toAmount() ?? record.tstPurPrice,
      tstStorage: storageId ?? record.tstStorage,
    );
    _updateTotalAmount();
  }

  void _updateTotalAmount() {
    double total = 0.0;
    for (final record in _records) {
      total += record.total;
    }
    setState(() {
      _totalAmount = total;
      _updateRemainingAmount();
    });
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

  void _addEmptyItem() {
    setState(() {
      _qtyControllers.add(TextEditingController(text: "1"));
      _salePriceControllers.add(TextEditingController(text: "0.00"));
      _storageControllers.add(TextEditingController());
      _productControllers.add(TextEditingController());
      _selectedProducts.add(null);
      _selectedStorages.add(null);

      _records.add(EstimateRecord(
        tstId: 0,
        tstOrder: widget.estimateId,
        tstProduct: 0,
        tstStorage: 0,
        tstQuantity: "1",
        tstPurPrice: "0.00",
        tstSalePrice: "0.00",
      ));

      _updateTotalAmount();
    });
  }

  void _removeItem(int index) {
    if (_records.length <= 1) {
      Utils.showOverlayMessage(context, message: 'Must have at least one item', isError: true);
      return;
    }

    setState(() {
      _qtyControllers.removeAt(index);
      _salePriceControllers.removeAt(index);
      _storageControllers.removeAt(index);
      _productControllers.removeAt(index);
      _selectedProducts.removeAt(index);
      _selectedStorages.removeAt(index);
      _records.removeAt(index);
      _updateTotalAmount();
    });
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
        if (state is EstimateSaved) {
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
          actionsPadding: EdgeInsets.symmetric(horizontal: 10),
          actions: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(23),
              child: IconButton(
                icon: Icon(Icons.print),
                onPressed: _toggleEditMode,
                hoverColor: Theme.of(context).colorScheme.primary.withAlpha(26),
                tooltip: AppLocalizations.of(context)!.print,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(23),
              child: IconButton(
                icon: Icon(_isEditing ? Icons.visibility : Icons.edit),
                onPressed: _toggleEditMode,
                hoverColor: Theme.of(context).colorScheme.primary.withAlpha(26),
                tooltip: _isEditing ? 'Cancel Edit' : 'Edit',
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(23),
              child: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  final state = context.read<EstimateBloc>().state;
                  if (state is EstimateDetailLoaded) {
                    _deleteEstimate(state.estimate);
                  }
                },
                hoverColor: Theme.of(context).colorScheme.primary.withAlpha(26),
                tooltip: 'Delete',
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(23),
              child: IconButton(
                icon: const Icon(Icons.cached_rounded),
                onPressed: () {
                  final state = context.read<EstimateBloc>().state;
                  if (state is EstimateDetailLoaded) {
                    _showConvertToSaleDialog(state.estimate);
                  }
                },
                hoverColor: Theme.of(context).colorScheme.primary.withAlpha(26),
                tooltip: 'Convert to Sale',
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(23),
                child: IconButton(
                  hoverColor: Theme.of(context).colorScheme.primary.withAlpha(26),
                  onPressed: _saveChanges,
                  tooltip: 'Save Changes',
                  icon: const Icon(Icons.check),
                ),
              ),
            ],
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

              // Initialize controllers on first load
              if (_records.isEmpty) {
                _initializeControllers(estimate);
                _totalAmount = estimate.grandTotal;
                _updateRemainingAmount();
              }

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
                        if (!_isEditing)
                          ZOutlineButton(
                            width: 120,
                            isActive: true,
                            icon: Icons.published_with_changes_rounded,
                            label: const Text('Convert'),
                            onPressed: () => _showConvertToSaleDialog(estimate),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Customer and Reference (Editable in edit mode)
                    if (_isEditing) _buildEditableHeaderFields(estimate),

                    // Items header
                    _buildItemsHeader(),

                    // Items list
                    _buildItemsList(estimate),

                    // Add item button in edit mode
                    if (_isEditing)
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ZOutlineButton(
                              width: 120,
                              icon: Icons.add,
                              label: Text(AppLocalizations.of(context)!.addItem),
                              onPressed: _addEmptyItem,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // Profit Summary Section
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
    final tr = AppLocalizations.of(context)!;
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
                  Text(tr.customer, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(estimate.ordPersonalName ?? ''),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr.referenceNumber, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(estimate.ordxRef ?? ''),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr.totalInvoice, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("${_totalAmount.toAmount()} $baseCurrency"),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: estimate.isPending ? Colors.orange : Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      estimate.isPending ? 'PENDING' : 'COMPLETED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableHeaderFields(EstimateModel estimate) {
    final tr = AppLocalizations.of(context)!;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GenericTextfield<IndividualsModel, IndividualsBloc, IndividualsState>(
                controller: _customerController,
                title: tr.customer,
                hintText: tr.customer,
                isRequired: true,
                bloc: context.read<IndividualsBloc>(),
                fetchAllFunction: (bloc) => bloc.add(LoadIndividualsEvent()),
                searchFunction: (bloc, query) => bloc.add(LoadIndividualsEvent()),
                itemBuilder: (context, ind) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${ind.perName ?? ''} ${ind.perLastName ?? ''}"),
                ),
                itemToString: (individual) => "${individual.perName ?? ''} ${individual.perLastName ?? ''}",
                stateToLoading: (state) => state is IndividualLoadingState,
                stateToItems: (state) {
                  if (state is IndividualLoadedState) return state.individuals;
                  return [];
                },
                onSelected: (value) {
                  _selectedCustomer = value;
                  _customerController.text = "${value.perName} ${value.perLastName}";
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ZTextFieldEntitled(
                title: tr.referenceNumber,
                controller: _xRefController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
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
          SizedBox(width: 120, child: Text(tr.profit, style: TextStyle(color: color.surface))),
          SizedBox(width: 150, child: Text(tr.storage, style: TextStyle(color: color.surface))),
          if (_isEditing)
            SizedBox(width: 60, child: Text(tr.actions, style: TextStyle(color: color.surface))),
        ],
      ),
    );
  }

  Widget _buildItemsList(EstimateModel estimate) {
    final records = _records;

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
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              SizedBox(width: 40, child: Text((index + 1).toString())),

              // Product
              Expanded(
                child: _isEditing
                    ? GenericUnderlineTextfield<ProductsStockModel, ProductsBloc, ProductsState>(
                  controller: _productControllers[index],
                  hintText: 'Product',
                  bloc: context.read<ProductsBloc>(),
                  fetchAllFunction: (bloc) => bloc.add(LoadProductsStockEvent()),
                  searchFunction: (bloc, query) => bloc.add(LoadProductsStockEvent()),
                  itemBuilder: (context, product) => ListTile(
                    title: Text(product.proName ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cost Price: ${product.purchasePrice?.toAmount() ?? "0.00"}'),
                        Text('Sale Price: ${product.sellPrice?.toAmount() ?? "0.00"}'),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Qty: ${product.available ?? '0'}'),
                        Text('Storage: ${product.stgName ?? ''}'),
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
                    final purchasePrice = double.tryParse(
                      product.purchasePrice?.replaceAll(',', '') ?? "0.0",
                    ) ?? 0.0;
                    final salePrice = double.tryParse(
                      product.sellPrice?.replaceAll(',', '') ?? "0.0",
                    ) ?? 0.0;

                    _selectedProducts[index] = product;
                    _productControllers[index].text = product.proName ?? '';
                    _storageControllers[index].text = product.stgName ?? '';
                    _salePriceControllers[index].text = salePrice.toAmount();

                    _updateRecord(index,
                      productId: product.proId,
                      salePrice: salePrice,
                      purchasePrice: purchasePrice,
                      storageId: product.stkStorage,
                    );
                  },
                  title: '',
                )
                    : Text(record.productName ?? 'Product ${record.tstProduct}'),
              ),

              // Quantity
              SizedBox(
                width: 80,
                child: _isEditing
                    ? TextField(
                  controller: _qtyControllers[index],
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    // Save cursor position
                    final cursorPos = _qtyControllers[index].selection.baseOffset;
                    _qtyCursorPositions[index] = cursorPos;

                    final qty = double.tryParse(value) ?? 0.0;
                    _updateRecord(index, quantity: qty);

                    // Restore cursor position
                    if (cursorPos != -1 && cursorPos <= _qtyControllers[index].text.length) {
                      Future.delayed(Duration.zero, () {
                        _qtyControllers[index].selection = TextSelection.collapsed(
                          offset: cursorPos,
                        );
                      });
                    }
                  },
                )
                    : Text(record.quantity.toStringAsFixed(2)),
              ),

              // Sale Price
              SizedBox(
                width: 120,
                child: _isEditing
                    ? TextField(
                  controller: _salePriceControllers[index],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    SmartThousandsDecimalFormatter(),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    // Save cursor position
                    final cursorPos = _salePriceControllers[index].selection.baseOffset;
                    _priceCursorPositions[index] = cursorPos;

                    final price = double.tryParse(value.replaceAll(',', '')) ?? 0.0;
                    _updateRecord(index, salePrice: price);

                    // Restore cursor position
                    if (cursorPos != -1 && cursorPos <= _salePriceControllers[index].text.length) {
                      Future.delayed(Duration.zero, () {
                        _salePriceControllers[index].selection = TextSelection.collapsed(
                          offset: cursorPos,
                        );
                      });
                    }
                  },
                )
                    : Text(record.salePrice.toAmount()),
              ),

              // Total
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
                  ],
                ),
              ),

              // Profit
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (record.purchasePrice > 0 && record.salePrice > 0)
                      Text(
                        record.profit.toAmount(),
                        style: TextStyle(
                          fontSize: 14,
                          color: record.profit >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    if (record.purchasePrice > 0 && record.salePrice > 0)
                      Text(
                        '(${record.profitPercentage.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: record.profit >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                  ],
                ),
              ),

              // Storage
              SizedBox(
                width: 150,
                child: _isEditing
                    ? GenericUnderlineTextfield<StorageModel, StorageBloc, StorageState>(
                  controller: _storageControllers[index],
                  hintText: 'Storage',
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
                    _selectedStorages[index] = storage;
                    _storageControllers[index].text = storage.stgName ?? '';
                    _updateRecord(index, storageId: storage.stgId);
                  },
                  title: '',
                )
                    : Text(record.storageName ?? ''),
              ),

              // Remove button in edit mode
              if (_isEditing)
                SizedBox(
                  width: 60,
                  child: IconButton(
                    icon: Icon(Icons.delete_outline, size: 18, color: Theme.of(context).colorScheme.error),
                    onPressed: () => _removeItem(index),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProfitSummarySection(EstimateModel estimate) {
    final color = Theme.of(context).colorScheme;
    final profitColor = estimate.totalProfit >= 0 ? Colors.green : Colors.red;

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
              const Text('Profit Summary', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Icon(Icons.ssid_chart, size: 22, color: color.primary),
            ],
          ),
          Divider(color: color.outline.withValues(alpha: .2)),

          _buildProfitRow(
            label: 'Total Cost',
            value: estimate.totalPurchaseCost,
            color: color.primary.withValues(alpha: .9),
          ),
          const SizedBox(height: 5),
          _buildProfitRow(
            label: 'Profit',
            value: estimate.totalProfit,
            color: profitColor,
            isBold: true,
          ),
          if (estimate.totalPurchaseCost > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Profit %', style: TextStyle(fontSize: 16)),
                Text(
                  '${estimate.profitPercentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 16,
                    color: profitColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          Divider(color: color.outline.withValues(alpha: .2)),

          // Grand Total
          _buildProfitRow(
            label: 'Grand Total',
            value: _totalAmount,
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

  void _toggleEditMode() {
    final state = context.read<EstimateBloc>().state;
    if (state is EstimateDetailLoaded) {
      setState(() {
        _isEditing = !_isEditing;
        if (!_isEditing) {
          // Reset to original data if cancelled
          _initializeControllers(state.estimate);
          _totalAmount = state.estimate.grandTotal;
          _updateRemainingAmount();
        }
      });
    }
  }

  void _saveChanges() {
    if (_userName == null) {
      Utils.showOverlayMessage(context, message: 'User not authenticated', isError: true);
      return;
    }

    // Validate customer
    if (_selectedCustomer == null && _customerController.text.isEmpty) {
      Utils.showOverlayMessage(context, message: 'Please select a customer', isError: true);
      return;
    }

    // Validate items
    for (var i = 0; i < _records.length; i++) {
      final record = _records[i];
      if (record.tstProduct == 0) {
        Utils.showOverlayMessage(context, message: 'Please select a product for item ${i + 1}', isError: true);
        return;
      }
      if (record.tstStorage == 0) {
        Utils.showOverlayMessage(context, message: 'Please select a storage for item ${i + 1}', isError: true);
        return;
      }
      final qty = record.quantity;
      if (qty <= 0) {
        Utils.showOverlayMessage(context, message: 'Please enter a valid quantity for item ${i + 1}', isError: true);
        return;
      }
      final price = record.salePrice;
      if (price <= 0) {
        Utils.showOverlayMessage(context, message: 'Please enter a valid price for item ${i + 1}', isError: true);
        return;
      }
    }

    final state = context.read<EstimateBloc>().state;
    if (state is! EstimateDetailLoaded) return;

    // Update the estimate
    context.read<EstimateBloc>().add(UpdateEstimateEvent(
      usrName: _userName!,
      orderId: state.estimate.ordId!,
      perID: _selectedCustomer?.perId ?? state.estimate.ordPersonal!,
      xRef: _xRefController.text.isNotEmpty ? _xRefController.text : null,
      records: _records,
    ));
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
                  // Payment Method Selection (same as before)
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

                  // Account Selection
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

                  // Credit Amount
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

    // Prepare API parameters
    int account = 0;
    String amount = "0";

    switch (_selectedPaymentMethod) {
      case PaymentMethod.cash:
        account = 0;
        amount = "0";
        break;
      case PaymentMethod.credit:
        account = _selectedAccount?.accNumber ?? 0;
        amount = _totalAmount.toStringAsFixed(2);
        break;
      case PaymentMethod.mixed:
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

    Navigator.pop(context);
  }
}

enum PaymentMethod {
  cash,
  credit,
  mixed,
}