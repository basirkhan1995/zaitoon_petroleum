import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Orders/bloc/orders_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersBloc>().add(const LoadOrdersEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    TextStyle? titleStyle = textTheme.titleSmall;
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: color.surface,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(height: 10),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(tr.orderTitle,style: textTheme.titleMedium),
          //       Text(tr.ordersSubtitle,style: subtitleStyle),
          //     ],
          //   ),
          // ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                SizedBox(
                    width: 30,
                    child: Text("#",style: titleStyle)),
               SizedBox(
                   width: 180,
                   child: Text(tr.referenceNumber,style: titleStyle)),

                SizedBox(
                    width: 100,
                    child: Text(tr.date,style: titleStyle)),

                Expanded(
                    child: Text(tr.customer,style: titleStyle)),

                SizedBox(
                    width: 100,
                    child: Text(tr.txnType,style: titleStyle)),


                SizedBox(
                    width: 100,
                    child: Text(tr.billNo,style: titleStyle)),

                SizedBox(
                    width: 100,
                    child: Text(tr.totalTitle,style: titleStyle)),
              ],
            ),
          ),
          Divider(endIndent: 8,indent: 8),
          Expanded(
            child: BlocBuilder<OrdersBloc, OrdersState>(
              builder: (context, state) {
                if(state is OrdersErrorState){
                  return NoDataWidget(
                    message: state.message,
                  );
                }
                if(state is OrdersLoadingState){
                  return Center(child: CircularProgressIndicator());
                }
                if(state is OrdersLoadedState){
                  return ListView.builder(
                      itemCount: state.order.length,
                      itemBuilder: (context,index){
                        final ord = state.order[index];
                     return InkWell(
                       onTap: (){

                       },
                       child: Container(
                         padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                         decoration: BoxDecoration(
                           color: index.isEven? color.primary.withValues(alpha: .05) : Colors.transparent
                         ),
                         child: Row(
                           children: [
                             SizedBox(
                                 width: 30,
                                 child: Text(ord.ordId.toString())),
                             SizedBox(
                                 width: 180,
                                 child: Text(ord.ordTrnRef??"")),
                             SizedBox(
                                 width: 100,
                                 child: Text(ord.ordEntryDate?.toFormattedDate()??"")),
                             Expanded(
                               child: Text(ord.personal??""),
                             ),
                             SizedBox(
                               width: 100,
                               child: Text(ord.ordName.toString()),
                             ),

                             SizedBox(
                                 width: 100,
                                 child: Text(ord.ordxRef.toString())),

                             SizedBox(
                                 width: 100,
                                 child: Text(ord.totalBill?.toAmount()??"0.0")),
                           ],
                         ),
                       ),
                     );
                  });
                }
                return const SizedBox();
              },
            ),
          )
        ],
      ),
    );
  }
}

