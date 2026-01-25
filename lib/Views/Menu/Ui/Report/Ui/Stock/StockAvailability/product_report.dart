import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Stock/StockAvailability/bloc/product_report_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Stock/StockAvailability/features/storage_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Transport/features/status_drop.dart';
import '../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../../Localizations/Bloc/localizations_bloc.dart';
import '../../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../../../../Settings/Ui/Stock/Ui/Products/bloc/products_bloc.dart';
import '../../../../Settings/Ui/Stock/Ui/Products/model/product_model.dart';


class ProductReportView extends StatelessWidget {
  const ProductReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
        mobile: _Mobile(), tablet: _Tablet(), desktop: _Desktop());
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  int? storageId;
  String? baseCcy;
  String? myLocale;
  int? productId;
  int? isNoStock;

  String? _getBaseCurrency() {
    try {
      final companyState = context.read<CompanyProfileBloc>().state;
      if (companyState is CompanyProfileLoadedState) {
        return companyState.company.comLocalCcy;
      }
      return "";
    } catch (e) {
      return "";
    }
  }
  @override
  void initState() {
    super.initState();
    baseCcy = _getBaseCurrency();
    myLocale = context.read<LocalizationBloc>().state.languageCode;
    context.read<ProductReportBloc>().add(ResetProductReportEvent());
  }

  bool get hasAnyFilter {
    return isNoStock != null ||
        storageId != null ||
        productId != null;
  }

  final productController = TextEditingController();
  void _clearFilters() {
    setState(() {
      isNoStock = null;
      productId = null;
      storageId = null;
      productController.clear(); // Clear the textfield
    });
    context.read<ProductReportBloc>().add(ResetProductReportEvent());
  }
  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    TextStyle? titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.surface);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text("${tr.stock} ${tr.report}"),
        actionsPadding: EdgeInsets.symmetric(horizontal: 10),
        actions: [
          if(hasAnyFilter)...[
            ZOutlineButton(
                width: 140,
                icon: Icons.filter_alt_off_outlined,
                backgroundHover: Theme.of(context).colorScheme.error,
                onPressed: _clearFilters,
                label: Text(tr.clearFilters)),
            SizedBox(width: 8),
          ],
          ZOutlineButton(
              width: 100,
              icon: Icons.print,
              backgroundHover: Theme.of(context).colorScheme.error,
              onPressed: (){},
              label: Text(tr.print)),
          SizedBox(width: 8),
          ZOutlineButton(
              width: 100,
              icon: Icons.filter_alt,
              isActive: true,
              onPressed: (){
                context.read<ProductReportBloc>().add(LoadProductsReportEvent(
                  isNoStock: isNoStock,
                  storageId: storageId,
                  productId: productId,
                ));
              },
              label: Text(tr.apply)),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 8,
              children: [
                SizedBox(
                  width: 250,
                  child: StorageDropDown(
                    height: 40,
                    title: tr.storage,
                    selectedId: storageId, // Pass current storageId
                    onChanged: (e){
                      setState(() {
                        storageId = e?.stgId;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: StatusDropdown(
                    height: 40,
                    items: [
                      StatusItem(null, tr.all),
                      StatusItem(1, tr.available),
                      StatusItem(0, tr.outOfStock),
                    ],
                    value: isNoStock,
                    onChanged: (e) {
                      setState(() {
                        isNoStock = e;
                      });
                    },
                  ),
                ),
                // Product Selection
                Expanded(
                  child: GenericTextfield<ProductsModel, ProductsBloc, ProductsState>(
                    title: tr.products,
                    controller: productController,
                    hintText: tr.products,
                    bloc: context.read<ProductsBloc>(),
                    fetchAllFunction: (bloc) => bloc.add(LoadProductsEvent()),
                    searchFunction: (bloc, query) => bloc.add(LoadProductsEvent()),
                    itemBuilder: (context, product) {
                      // Check if this is the "All" option
                      if (product.proId == null) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            tr.all,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(product.proName ?? ''),
                      );
                    },
                    itemToString: (product) => product.proName ?? (product.proId == null ? tr.all : ''),
                    stateToLoading: (state) => state is ProductsLoadingState,
                    stateToItems: (state) {
                      if (state is ProductsLoadedState) return state.products;
                      return [];
                    },
                    onSelected: (product) {
                      setState(() {
                        // product will be null when "All" is selected
                        productId = product.proId; // This will be null for "All"
                      });
                    },
                    // Add "All" option configuration
                    showAllOption: true,
                    allOption: ProductsModel(
                      proId: null,
                      proName: tr.all,
                      proCode: '',
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 15.0),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: .8)
            ),
            child: Row(
              children: [
                SizedBox(
                    width: 40,
                    child: Text(tr.id,style: titleStyle)),
                Expanded(
                    child: Text(tr.productName,style: titleStyle)),
                SizedBox(
                    width: 150,
                    child: Text(tr.storage,style: titleStyle)),
                SizedBox(
                    width: 150,
                    child: Text(tr.unitPrice,style: titleStyle)),
                SizedBox(
                    width: 120,
                    child: Text(tr.qty,style: titleStyle)),
                SizedBox(
                    width: 120,
                    child: Text(tr.totalTitle,style: titleStyle)),
              ],
            ),
          ),
          SizedBox(height: 5),
          Expanded(
            child: BlocBuilder<ProductReportBloc, ProductReportState>(
              builder: (context, state) {
                if(state is ProductReportErrorState){
                  return NoDataWidget(
                    title: tr.accessDenied,
                    message: state.message,
                    enableAction: false,
                  );
                }
                if(state is ProductReportInitial){
                  return NoDataWidget(
                    title: "Inventory Overview",
                    message: "Stock Availability Summary",
                    enableAction: false,
                  );
                }
                if(state is ProductReportLoadingState){
                  return Center(child: CircularProgressIndicator());
                }
                if(state is ProductReportLoadedState){
                  if(state.stock.isEmpty){
                    return NoDataWidget(
                      title: tr.noData,
                      message: tr.noDataFound,
                      enableAction: false,
                    );
                  }
                  return ListView.builder(
                      itemCount: state.stock.length,
                      itemBuilder: (context,index){
                        final stk = state.stock[index];
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                          margin:  EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                              color: index.isEven? Theme.of(context).colorScheme.primary.withValues(alpha: .05) : Colors.transparent
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 40,
                                  child: Text(stk.no.toString())),
                              Expanded(
                                  child: Text(stk.proName??"")),
                              SizedBox(
                                  width: 150,
                                  child: Text(stk.stgName??"")),

                              SizedBox(
                                  width: 150,
                                  child: Text("${stk.pricePerUnit.toAmount()} $baseCcy")),

                              SizedBox(
                                  width: 120,
                                  child: Text(stk.availableQuantity.toAmount(decimal: 4))),
                              SizedBox(
                                  width: 120,
                                  child: Text("${stk.total.toAmount(decimal: 2)} $baseCcy")),
                            ],
                          ),
                        );
                      });
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}