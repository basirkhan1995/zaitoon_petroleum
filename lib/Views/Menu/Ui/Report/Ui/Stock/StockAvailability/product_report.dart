import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Stock/StockAvailability/bloc/product_report_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../Localizations/Bloc/localizations_bloc.dart';


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

  String? myLocale;
  @override
  void initState() {
    super.initState();
    myLocale = context.read<LocalizationBloc>().state.languageCode;
    context.read<ProductReportBloc>().add(ResetProductReportEvent());
  }
  // bool get hasAnyFilter {
  //   return status != null ||
  //       currency != null ||
  //       maker != null ||
  //       checker != null ||
  //       txnType != null;
  // }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text("Stock Availability"),
        actionsPadding: EdgeInsets.symmetric(horizontal: 10),
        actions: [
          ZOutlineButton(
              width: 140,
              icon: Icons.filter_alt_off_outlined,
              backgroundHover: Theme.of(context).colorScheme.error,
              onPressed: (){
                context.read<ProductReportBloc>().add(ResetProductReportEvent());
              },
              label: Text(tr.clearFilters)),
           SizedBox(width: 8),
          ZOutlineButton(
              width: 120,
              icon: Icons.filter_alt,
              isActive: true,
              onPressed: (){
                context.read<ProductReportBloc>().add(LoadProductsReportEvent(
                  isNoStock: 1
                ));
              },
              label: Text(tr.apply)),
        ],
      ),

      body: Column(
        children: [

          Expanded(
            child: BlocBuilder<ProductReportBloc, ProductReportState>(
              builder: (context, state) {
                if(state is ProductReportErrorState){
                  return NoDataWidget(
                    title: "Error",
                    message: state.message,
                    enableAction: false,
                  );
                }
                if(state is ProductReportInitial){
                  return NoDataWidget(
                    title: "Stock Availability",
                    message: "Stock Report",
                    enableAction: false,
                  );
                }
                if(state is ProductReportLoadingState){
                  return Center(child: CircularProgressIndicator());
                }
                if(state is ProductReportLoadedState){
                  if(state.stock.isEmpty){
                    return NoDataWidget(
                      title: "No Data",
                      message: "item not found",
                      enableAction: false,
                    );
                  }
                  return ListView.builder(
                      itemCount: state.stock.length,
                      itemBuilder: (context,index){
                        final stk = state.stock[index];
                        return Container(
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
                                  width: 120,
                                  child: Text(stk.availableQuantity.toAmount(decimal: 4))),
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

