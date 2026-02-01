import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/features/branch_dropdown.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Stock/Cardx/bloc/stock_record_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Stock/StockAvailability/features/storage_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/Products/bloc/products_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/Products/model/product_model.dart';

import '../../../../../../../../Features/Date/z_generic_date.dart';
import '../../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../Localizations/Bloc/localizations_bloc.dart';
import '../../../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../../../../../Stock/Ui/OrderScreen/GetOrderById/order_by_id.dart';

class StockRecordReportView extends StatelessWidget {
  const StockRecordReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(),
      tablet: _Tablet(),
    );
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
  late String fromDate;
  late String toDate;
  int? storageId;
  int? productId;

  final _productController = TextEditingController();

  String? myLocale;
  String? baseCcy;
  @override
  void initState() {
    super.initState();
    baseCcy = _getBaseCurrency();
    fromDate = DateTime.now().subtract(Duration(days: 30)).toFormattedDate();
    toDate = DateTime.now().toFormattedDate();
    myLocale = context.read<LocalizationBloc>().state.languageCode;
    context.read<StockRecordBloc>().add(ResetStockRecordEvent());
  }

  bool get hasFilter {
    return storageId != null ||
        productId != null ||
        _productController.text.isNotEmpty;
  }

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
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    TextStyle? titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.surface);
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
          title: Text("Stock Record"),
        titleSpacing: 0,
        actionsPadding: EdgeInsets.symmetric(horizontal: 10),
        actions: [
          if(hasFilter)...[
            ZOutlineButton(
              onPressed: () {
                setState(() {
                  productId = null;
                  storageId = null;
                  _productController.clear();
                  fromDate = DateTime.now().toFormattedDate();
                  toDate = DateTime.now().toFormattedDate();
                });
                context.read<StockRecordBloc>().add(ResetStockRecordEvent());
              },
              backgroundHover: Theme.of(context).colorScheme.error,
              isActive: true,
              width: 140,
              icon: Icons.filter_alt_off_outlined,
              label: Text(tr.clearFilters),
            ),
            SizedBox(width: 8),
          ],
          ZOutlineButton(
            onPressed: () {},
            width: 120,
            icon: Icons.print,
            label: Text(tr.print),
          ),
          SizedBox(width: 8),
          ZOutlineButton(
            onPressed: () {
              if(productId !=null && _productController.text.isNotEmpty){
                context.read<StockRecordBloc>().add(LoadStockRecordEvent(
                  fromDate: fromDate,
                  toDate: toDate,
                  productId: productId,
                  storageId: storageId,
                ));
              }else{
                Utils.showOverlayMessage(context, message: "Please select a product first", isError: true);
              }
            },
            isActive: true,
            width: 120,
            icon: Icons.filter_alt_outlined,
            label: Text(tr.apply),
          ),
        ],
      ),

      body: Column(
        children: [
          //Filter section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child:
                      GenericTextfield<ProductsModel, ProductsBloc, ProductsState>(
                        key: const ValueKey('product_field'),
                        controller: _productController,
                        title: tr.products,
                        hintText: tr.products,
                        bloc: context.read<ProductsBloc>(),
                        fetchAllFunction: (bloc) => bloc.add(LoadProductsEvent()),
                        searchFunction: (bloc, query) => bloc.add(LoadProductsEvent()),
                        // showAllOption: true,
                        // allOption: ProductsModel(
                        //   proId: null,
                        //   proName: tr.all,
                        //   proCode: '',
                        // ),
                        itemBuilder: (context, ind) {
                          if (ind.proId == null) {
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
                            child: Text(
                              "${ind.proCode} | ${ind.proName ?? ''}",
                            ),
                          );
                        },
                        itemToString: (pro) => "${pro.proCode} | ${pro.proName ?? ''}",
                        stateToLoading: (state) => state is ProductsLoadingState,
                        stateToItems: (state) {
                          if (state is ProductsLoadedState) {
                            return state.products;
                          }
                          return [];
                        },
                        onSelected: (value) {
                          setState(() {
                            productId = value.proId;
                          });
                        },
                        showClearButton: true,
                      ),
                ),
                Expanded(
                  flex: 2,
                  child: BranchDropdown(
                    showAllOption: true,
                    title: tr.branch,
                    onBranchSelected: (e) {
                      setState(() {
                        storageId = e?.brcId;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: StorageDropDown(
                    title: tr.storage,
                    onChanged: (e) {
                      setState(() {
                        storageId = e?.stgId;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ZDatePicker(
                    label: tr.fromDate,
                    value: fromDate,
                    onDateChanged: (v) {
                      setState(() {
                        fromDate = v;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ZDatePicker(
                    label: tr.toDate,
                    value: toDate,
                    onDateChanged: (v) {
                      setState(() {
                        toDate = v;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),
          //Header Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15,vertical: 8),
            margin: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: .9),
            ),
            child: Row (
                children: [
              SizedBox(
                  width: 40,
                  child: Text(tr.id,style: titleStyle)),
                  SizedBox(
                      width: 100,
                      child: Text(tr.date,style: titleStyle)),

                  Expanded(
                      child: Text(tr.party,style: titleStyle)),
                  SizedBox(
                      width: 180,
                      child: Text(tr.storage,style: titleStyle)),
                  SizedBox(
                      width: 80,
                      child: Text(tr.inAndOut,style: titleStyle)),
                  SizedBox(
                      width: 100,
                      child: Text(tr.weight,style: titleStyle)),
                  SizedBox(
                      width: 120,
                      child: Text(tr.unitPrice,style: titleStyle)),
                  SizedBox(
                      width: 100,
                      child: Text(tr.stockBalance,style: titleStyle)),
            ]),
          ),

          Expanded(
            child: BlocBuilder<StockRecordBloc, StockRecordState>(
              builder: (context, state) {
                if(state is StockRecordErrorState){
                  return NoDataWidget(
                    imageName: "error.png",
                    title: tr.accessDenied,
                    message: state.error,
                    onRefresh: (){}
                  );
                }
                if(state is StockRecordLoadingState){
                  return Center(child: CircularProgressIndicator());
                }

                if(state is StockRecordInitial){
                  return NoDataWidget(
                      title: "Inventory Report",
                      message: "Stock IN & OUT Record",
                      enableAction: false,
                  );
                }
                if(state is StockRecordLoadedState){
                  if(state.cardX.isEmpty){
                    return NoDataWidget(
                      title: tr.noData,
                      message: tr.noDataFound,
                      enableAction: false,
                    );
                  }
                  return ListView.builder(
                      itemCount: state.cardX.length,
                      itemBuilder: (context,index){
                       final stock = state.cardX[index];
                        return InkWell(
                          highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: .05),
                          onTap: (){
                            Utils.goto(
                              context,
                              OrderByIdView(orderId: stock.orderId!,ordName: stock.entryType == "IN"? "Purchase" : "Sale"),
                            );
                          },
                          child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15,vertical: 8),
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: index.isEven ? Theme.of(context).colorScheme.primary.withValues(alpha: .05) : Colors.transparent
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 40,
                                  child: Text(stock.orderId.toString())),
                              SizedBox(
                                  width: 100,
                                  child: Text(stock.entryDate.toFormattedDate())),
                              Expanded(
                                  child: Text(stock.fullname.toString())),

                              SizedBox(
                                  width: 180,
                                  child: Text(stock.storageName.toString())),

                              SizedBox(
                                  width: 80,
                                  child: Text(stock.entryType.toString(),style: TextStyle(
                                    color: stock.entryType == "IN"? Colors.green : color.error,
                                  )),
                              ),

                              SizedBox(
                                  width: 100,
                                  child: Text(stock.quantity.toString())),

                              SizedBox(
                                  width: 120,
                                  child: Text("${stock.price.toAmount()} $baseCcy")),

                              SizedBox(
                                  width: 100,
                                  child: Text(stock.runningQuantity.toAmount(decimal: 4))),
                            ],
                          ),
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
