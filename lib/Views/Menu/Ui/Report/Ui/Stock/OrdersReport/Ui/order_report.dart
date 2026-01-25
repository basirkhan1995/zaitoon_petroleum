import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/features/branch_dropdown.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Stock/OrdersReport/bloc/order_report_bloc.dart';
import '../../../../../../../../Features/Date/z_generic_date.dart';
import '../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../Localizations/Bloc/localizations_bloc.dart';
import '../../../../../../../../Localizations/l10n/translations/app_localizations.dart';

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

  String? myLocale;

  @override
  void initState() {
    super.initState();
    fromDate = DateTime.now().toFormattedDate();
    toDate = DateTime.now().toFormattedDate();
    myLocale = context.read<LocalizationBloc>().state.languageCode;
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
          ZOutlineButton(
            onPressed: () {
              setState(() {
                customerId = null;
                branchId = null;
              });
             context.read<OrderReportBloc>().add(ResetOrderReportEvent());
            },
            width: 140,
            icon: Icons.filter_alt_off_outlined,
            label: Text(tr.clearFilters),
          ),
          SizedBox(width: 8),
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
            padding: const EdgeInsets.all(15.0),
            child: Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                Expanded(
                  child: BranchDropdown(
                      title: tr.branch,
                      onBranchSelected: (e){
                        setState(() {
                          branchId = e.brcId;
                        });
                      }),
                ),

              ],
            ),
          ),
          Row(
            children: [
              SizedBox(
                  width: 40,
                  child: Text(tr.orderId,style: titleStyle)),
              SizedBox(
                  width: 150,
                  child: Text(tr.referenceNumber,style: titleStyle)),

            ],
          ),
          Expanded(
            child: BlocBuilder<OrderReportBloc, OrderReportState>(
              builder: (context, state) {
                if(state is OrderReportInitial){
                  return NoDataWidget(
                    title: "Purchased Orders",
                    message: "Reports",
                  );
                }
                if(state is OrderReportLoadingState){
                  return Center(child: CircularProgressIndicator());
                }
                if(state is OrderReportErrorState){
                  return NoDataWidget(
                    title: tr.accessDenied,
                    message: state.error,
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
                    return Row(
                      children: [
                        SizedBox(
                            width: 40,
                            child: Text(ord.no.toString())),
                        SizedBox(
                            width: 150,
                            child: Text(ord.ordxRef ??"")),
                      ],
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
