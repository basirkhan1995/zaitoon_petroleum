import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/features/branch_dropdown.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Stock/OrdersReport/bloc/order_report_bloc.dart';
import '../../../../../../../../Features/Date/z_generic_date.dart';
import '../../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../Localizations/Bloc/localizations_bloc.dart';
import '../../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../../../../../Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import '../../../../../Stakeholders/Ui/Individuals/model/individual_model.dart';

class OrderReportView extends StatelessWidget {
  final String? orderName;
  const OrderReportView({super.key,this.orderName});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(orderName),
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
  final String? orderName;
  const _Desktop(this.orderName);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  late String fromDate;
  late String toDate;
  int? branchId;
  int? customerId;
  final _personController = TextEditingController();
  String? myLocale;
  String? baseCcy;
  @override
  void initState() {
    super.initState();
    baseCcy = _getBaseCurrency();
    fromDate = DateTime.now().toFormattedDate();
    toDate = DateTime.now().toFormattedDate();
    myLocale = context.read<LocalizationBloc>().state.languageCode;
    context.read<OrderReportBloc>().add(ResetOrderReportEvent());
  }

  bool get hasFilter {
    return branchId !=null || customerId !=null || _personController.text.isNotEmpty;
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
    TextStyle? titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: Theme.of(context).colorScheme.surface,
    );
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderName == "Purchase"? "${tr.purchaseTitle} ${tr.invoiceTitle}" : widget.orderName == "Sale"? "${tr.saleTitle} ${tr.invoiceTitle}" : "${tr.estimateTitle} ${tr.invoiceTitle}"),
        titleSpacing: 0,
        actionsPadding: EdgeInsets.symmetric(horizontal: 10),
        actions: [
          if(hasFilter)...[
            ZOutlineButton(
              onPressed: () {
                setState(() {
                  customerId = null;
                  branchId = null;
                  _personController.clear();
                  fromDate = DateTime.now().toFormattedDate();
                  toDate = DateTime.now().toFormattedDate();
                });
                context.read<OrderReportBloc>().add(ResetOrderReportEvent());
              },
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
              if(widget.orderName !=null){
                context.read<OrderReportBloc>().add(LoadOrderReportEvent(
                    fromDate: fromDate,
                    toDate: toDate,
                    branchId: branchId,
                    customerId: customerId,
                    orderName: widget.orderName
                ));
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: GenericTextfield<IndividualsModel, IndividualsBloc, IndividualsState>(
                    key: const ValueKey('person_field'),
                    controller: _personController,
                    title: tr.supplier,
                    hintText: tr.supplier,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr.required(tr.supplier);
                      }
                      return null;
                    },

                    bloc: context.read<IndividualsBloc>(),
                    fetchAllFunction: (bloc) => bloc.add(LoadIndividualsEvent()),
                    searchFunction: (bloc, query) => bloc.add(LoadIndividualsEvent()),
                    showAllOption: true,
                    allOption: IndividualsModel(
                      perId: null,
                      perName: tr.all,
                      perLastName: '',
                    ),
                    itemBuilder: (context, ind) {
                      if (ind.perId == null) {
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
                        child: Text("${ind.perName ?? ''} ${ind.perLastName ?? ''}"),
                      );
                    },
                    itemToString: (individual) => "${individual.perName} ${individual.perLastName}",
                    stateToLoading: (state) => state is IndividualLoadingState,
                    stateToItems: (state) {
                      if (state is IndividualLoadedState) return state.individuals;
                      return [];
                    },
                    onSelected: (value) {
                      setState(() {
                        customerId = value.perId;
                      });
                    },
                    showClearButton: true,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: BranchDropdown(
                      title: tr.branch,
                      onBranchSelected: (e){
                        setState(() {
                          branchId = e.brcId;
                        });
                      }),
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
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15,vertical: 8),
            margin: EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: .8),
            ),
            child: Row(
              children: [
                SizedBox(
                    width: 50,
                    child: Text("#",style: titleStyle)),

                SizedBox(
                    width: 100,
                    child: Text(tr.date,style: titleStyle)),

                SizedBox(
                    width: 180,
                    child: Text(tr.referenceNumber,style: titleStyle)),
                Expanded(
                    child: Text(tr.customer,style: titleStyle)),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<OrderReportBloc, OrderReportState>(
              builder: (context, state) {
                if(state is OrderReportInitial){
                  return NoDataWidget(
                    title: "Purchased Orders",
                    message: "Reports",
                    enableAction: false,
                  );
                }
                if(state is OrderReportLoadingState){
                  return Center(child: CircularProgressIndicator());
                }
                if(state is OrderReportErrorState){
                  return NoDataWidget(
                    title: tr.accessDenied,
                    message: state.error,
                    enableAction: false,
                  );
                }if(state is OrderReportLoadedSate){
                  if(state.orders.isEmpty){
                    return NoDataWidget(
                      title: tr.noData,
                      message: tr.noDataFound,
                      enableAction: false,
                    );
                  }
                  return ListView.builder(
                      itemCount: state.orders.length,
                      itemBuilder: (context,index){
                       final ord = state.orders[index];
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 8),
                      decoration: BoxDecoration(
                        color: index.isEven? Theme.of(context).colorScheme.primary.withValues(alpha: .05) : Colors.transparent
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 50,
                              child: Text(ord.ordId.toString())),
                          SizedBox(
                              width: 100,
                              child: Text(ord.timing.toFormattedDate())),
                          SizedBox(
                              width: 180,
                              child: Text(ord.ordTrnRef ??"")),
                          Expanded(
                              child: Text(ord.fullName??"")),

                          SizedBox(
                              width: 150,
                              child: Text(ord.ordBranchName ??"")),
                          SizedBox(
                              width: 150,
                              child: Text("${ord.totalBill.toAmount()} $baseCcy" )),
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
