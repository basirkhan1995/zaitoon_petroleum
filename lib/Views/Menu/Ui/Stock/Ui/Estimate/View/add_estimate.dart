import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Generic/rounded_searchable_textfield.dart';
import 'package:zaitoon_petroleum/Features/Generic/underline_searchable_textfield.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/thousand_separator.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/bloc/storage_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/model/storage_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/Products/bloc/products_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/Products/model/product_stock_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/individual_model.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../bloc/estimate_bloc.dart';
import '../model/estimate_model.dart';

class AddEstimateView extends StatefulWidget {
  const AddEstimateView({super.key});

  @override
  State<AddEstimateView> createState() => _AddEstimateViewState();
}

class _AddEstimateViewState extends State<AddEstimateView> {
  final List<TextEditingController> _productControllers = [];
  final List<TextEditingController> _qtyControllers = [];
  final List<TextEditingController> _priceControllers = [];
  final List<TextEditingController> _storageControllers = [];

  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _xRefController = TextEditingController();

  String? _userName;
  String? baseCurrency;
  int? _selectedCustomerId;
  final List<EstimateRecord> _records = [];

  // For storing selected product details
  final List<ProductsStockModel?> _selectedProducts = [];
  final List<StorageModel?> _selectedStorages = [];

  @override
  void initState() {
    super.initState();

    // Start with one empty item
    _addEmptyItem();

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
    for (final controller in _productControllers) {
      controller.dispose();
    }
    for (final controller in _qtyControllers) {
      controller.dispose();
    }
    for (final controller in _priceControllers) {
      controller.dispose();
    }
    for (final controller in _storageControllers) {
      controller.dispose();
    }
    _customerController.dispose();
    _xRefController.dispose();
    super.dispose();
  }

  void _addEmptyItem() {
    _productControllers.add(TextEditingController());
    _qtyControllers.add(TextEditingController(text: "1.000"));
    _priceControllers.add(TextEditingController(text: "0.00"));
    _storageControllers.add(TextEditingController());
    _selectedProducts.add(null);
    _selectedStorages.add(null);

    _records.add(EstimateRecord(
      tstId: 0,
      tstOrder: 0,
      tstProduct: 0,
      tstStorage: 0,
      tstQuantity: "1.000",
      tstPurPrice: "0.0000",
      tstSalePrice: "0.0000",
    ));
  }

  void _removeItem(int index) {
    if (_records.length <= 1) {
      Utils.showOverlayMessage(context, message: 'Must have at least one item', isError: true);
      return;
    }

    setState(() {
      _productControllers.removeAt(index);
      _qtyControllers.removeAt(index);
      _priceControllers.removeAt(index);
      _storageControllers.removeAt(index);
      _selectedProducts.removeAt(index);
      _selectedStorages.removeAt(index);
      _records.removeAt(index);
    });
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
      tstQuantity: quantity?.toStringAsFixed(3) ?? record.tstQuantity,
      tstSalePrice: salePrice?.toStringAsFixed(4) ?? record.tstSalePrice,
      tstPurPrice: purchasePrice?.toStringAsFixed(4) ?? record.tstPurPrice,
      tstStorage: storageId ?? record.tstStorage,
    );
  }

  double get _grandTotal {
    double total = 0.0;
    for (final record in _records) {
      final qty = double.tryParse(record.tstQuantity ?? "0") ?? 0;
      final price = double.tryParse(record.tstSalePrice ?? "0") ?? 0;
      total += qty * price;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return BlocListener<EstimateBloc, EstimateState>(
      listener: (context, state) {
        if (state is EstimateError) {
          Utils.showOverlayMessage(context, message: state.message, isError: true);
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
        backgroundColor: color.surface,
        appBar: AppBar(
          backgroundColor: color.surface,
          title: const Text('New Estimate'),
          titleSpacing: 0,
          actionsPadding: EdgeInsets.all(8),
          actions: [
            ZOutlineButton(
              icon: Icons.print,
              width: 110,
              height: 38,
              label: Text(AppLocalizations.of(context)!.print),
              onPressed: _createEstimate,
            ),
            SizedBox(width: 8),
            ZButton(
              width: 110,
              height: 38,
              label: Text('Create'),
              onPressed: _createEstimate,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Customer and Reference
              Row(
                children: [
                  Expanded(
                    child: GenericTextfield<IndividualsModel, IndividualsBloc, IndividualsState>(
                      controller: _customerController,
                      title: 'Customer',
                      hintText: 'Select customer',
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
                        _selectedCustomerId = value.perId;
                        _customerController.text = "${value.perName} ${value.perLastName}";
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ZTextFieldEntitled(
                      title: 'Reference Number',
                      controller: _xRefController,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Items header
              _buildItemsHeader(),

              // Items list
              ...List.generate(_records.length, (index) {
                return _buildItemRow(index);
              }),

              // Add item button
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ZOutlineButton(
                      width: 120,
                      icon: Icons.add,
                      label: const Text('Add Item'),
                      onPressed: () {
                        setState(() {
                          _addEmptyItem();
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Summary section
              _buildSummarySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsHeader() {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        children: [
          SizedBox(width: 40, child: Text('#', style: TextStyle(color: Colors.white))),
          Expanded(child: Text('Product', style: TextStyle(color: Colors.white))),
          SizedBox(width: 100, child: Text('Qty', style: TextStyle(color: Colors.white))),
          SizedBox(width: 120, child: Text('Price', style: TextStyle(color: Colors.white))),
          SizedBox(width: 120, child: Text('Total', style: TextStyle(color: Colors.white))),
          SizedBox(width: 150, child: Text('Storage', style: TextStyle(color: Colors.white))),
          SizedBox(width: 60, child: Text('Action', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildItemRow(int index) {
    final color = Theme.of(context).colorScheme;
    final record = _records[index];
    final qty = double.tryParse(record.tstQuantity ?? "0") ?? 0;
    final price = double.tryParse(record.tstSalePrice ?? "0") ?? 0;
    final total = qty * price;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: color.outline.withAlpha(50))),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text((index + 1).toString())),

          // Product
          Expanded(
            child: GenericUnderlineTextfield<ProductsStockModel, ProductsBloc, ProductsState>(
              controller: _productControllers[index],
              hintText: 'Product',
              bloc: context.read<ProductsBloc>(),
              fetchAllFunction: (bloc) => bloc.add(LoadProductsStockEvent()),
              searchFunction: (bloc, query) => bloc.add(LoadProductsStockEvent()),
              itemBuilder: (context, product) => ListTile(
                title: Text(product.proName ?? ''),
                subtitle: Text('Sale: ${product.sellPrice?.toAmount()}'),
                trailing: Text(product.available ?? ''),
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
                _storageControllers[index].text = product.stgName ?? '';
                _priceControllers[index].text = salePrice.toAmount();

                _updateRecord(index,
                  productId: product.proId,
                  salePrice: salePrice,
                  purchasePrice: purchasePrice,
                  storageId: product.stkStorage,
                );
              },
              title: '',
            ),
          ),

          // Quantity
          SizedBox(
            width: 100,
            child: TextField(
              controller: _qtyControllers[index],
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                hintText: 'Qty',
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) {
                final qty = double.tryParse(value) ?? 0.0;
                _updateRecord(index, quantity: qty);
                setState(() {}); // Update UI
              },
            ),
          ),

          // Price
          SizedBox(
            width: 120,
            child: TextField(
              controller: _priceControllers[index],
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
                final price = double.tryParse(value.replaceAll(',', '')) ?? 0.0;
                _updateRecord(index, salePrice: price);
                setState(() {}); // Update UI
              },
            ),
          ),

          // Total
          SizedBox(
            width: 120,
            child: Text(
              total.toAmount(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color.primary,
              ),
            ),
          ),

          // Storage
          SizedBox(
            width: 150,
            child: GenericUnderlineTextfield<StorageModel, StorageBloc, StorageState>(
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
                _updateRecord(index, storageId: storage.stgId);
              },
              title: '',
            ),
          ),

          // Remove button
          SizedBox(
            width: 60,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () => _removeItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    double totalCost = 0.0;
    double totalProfit = 0.0;

    for (final record in _records) {
      final qty = double.tryParse(record.tstQuantity ?? "0") ?? 0;
      final purPrice = double.tryParse(record.tstPurPrice ?? "0") ?? 0;
      final salePrice = double.tryParse(record.tstSalePrice ?? "0") ?? 0;
      totalCost += qty * purPrice;
      totalProfit += qty * (salePrice - purPrice);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(100)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Total Cost', totalCost),
          _buildSummaryRow('Profit', totalProfit, color: totalProfit >= 0 ? Colors.green : Colors.red),
          _buildSummaryRow('Grand Total', _grandTotal, isBold: true),
        ],
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

  void _createEstimate() {
    if (_userName == null) {
      Utils.showOverlayMessage(context, message: 'User not authenticated', isError: true);
      return;
    }

    if (_selectedCustomerId == null) {
      Utils.showOverlayMessage(context, message: 'Please select a customer', isError: true);
      return;
    }

    // Validate items
    for (var i = 0; i < _records.length; i++) {
      final record = _records[i];
      if (record.tstProduct == null || record.tstProduct == 0) {
        Utils.showOverlayMessage(context, message: 'Please select a product for item ${i + 1}', isError: true);
        return;
      }
      if (record.tstStorage == null || record.tstStorage == 0) {
        Utils.showOverlayMessage(context, message: 'Please select a storage for item ${i + 1}', isError: true);
        return;
      }
      final qty = double.tryParse(record.tstQuantity ?? "0") ?? 0;
      if (qty <= 0) {
        Utils.showOverlayMessage(context, message: 'Please enter a valid quantity for item ${i + 1}', isError: true);
        return;
      }
      final price = double.tryParse(record.tstSalePrice ?? "0") ?? 0;
      if (price <= 0) {
        Utils.showOverlayMessage(context, message: 'Please enter a valid price for item ${i + 1}', isError: true);
        return;
      }
    }

    // Create the estimate
    context.read<EstimateBloc>().add(AddEstimateEvent(
      usrName: _userName!,
      perID: _selectedCustomerId!,
      xRef: _xRefController.text.isNotEmpty ? _xRefController.text : null,
      records: _records,
    ));
  }
}