import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/Bloc/localizations_bloc.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/features/currency_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/features/users_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/TxnReport/bloc/txn_report_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/TxnReport/features/txn_type_drop.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Transport/features/status_drop.dart';
import '../../../../../Features/Date/z_generic_date.dart';

class TransactionReportView extends StatelessWidget {
  const TransactionReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(),
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
  String? myLocale;
  @override
  void initState() {
    super.initState();
    fromDate = DateTime.now().toFormattedDate();
    toDate   = DateTime.now().toFormattedDate();
    myLocale = context.read<LocalizationBloc>().state.languageCode;
  }
  bool get hasAnyFilter {
    return status != null ||
        currency != null ||
        maker != null ||
        checker != null ||
        txnType != null;
  }

  int? status;
  String? currency;
  String? maker;
  String? checker;
  String? txnType;
  @override
  Widget build(BuildContext context) {
    TextStyle? titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface);
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text("${tr.transactions} ${tr.report}"),
       titleSpacing: 0,
       actionsPadding: EdgeInsets.symmetric(horizontal: 10),
        actions: [
          if (hasAnyFilter)
          ZOutlineButton(
              isActive: true,
              onPressed: (){
                setState(() {
                  maker = null;
                  checker = null;
                  txnType = null;
                  currency = null;
                  status = null;
                   fromDate = DateTime.now().toFormattedDate();
                   toDate = DateTime.now().toFormattedDate();
                });
                context.read<TxnReportBloc>().add(ResetTxnReportEvent());
              },
              width: 140,
              icon: Icons.filter_alt_off_outlined,
              label: Text(tr.clearFilters)),
          SizedBox(width: 8),
          ZOutlineButton(
              onPressed: (){},
              width: 120,
              icon: Icons.print,
              label: Text(tr.print)),
          SizedBox(width: 8),
          ZOutlineButton(
              onPressed: (){
                context.read<TxnReportBloc>().add(LoadTxnReportEvent(
                  fromDate: fromDate,
                  toDate: toDate,
                  checker: checker,
                  maker: maker,
                  status: status,
                  txnType: txnType,
                  currency: currency,
                ));
              },
              isActive: true,
              width: 120,
              icon: Icons.filter_alt,
              label: Text(tr.apply)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 8,
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
                  child: UserDropdown(
                    title: tr.maker,
                    isMulti: false,
                    onSingleChanged: (e) {
                      setState(() {
                        maker = e?.usrName;
                      });
                    },
                    onMultiChanged: (e) {},
                  ),
                ),
                Expanded(
                  child: TxnTypeDropDown(
                    title: tr.txnType,
                    isMulti: false,
                    onSingleChanged: (e) {
                     setState(() {
                       txnType = e?.trntCode;
                     });
                    },
                    onMultiChanged: (e) {},
                  ),
                ),
                Expanded(
                  child: UserDropdown(
                    isMulti: false,
                    title: tr.checker,
                    onSingleChanged: (e) {
                      setState(() {
                        checker = e?.usrName;
                      });
                    },
                    onMultiChanged: (e) {},
                  ),
                ),
                Expanded(
                  child: CurrencyDropdown(
                    isMulti: false,
                    title: tr.currencyTitle,
                    onSingleChanged: (e) {
                      setState(() {
                        currency = e?.ccyCode;
                      });
                    },
                    onMultiChanged: (e) {},
                  ),
                ),

                Expanded(
                  child: StatusDropdown(
                    value: status,
                    onChanged: (v) {
                      setState(() => status = v);
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 5),
            child: Row(
              children: [
                SizedBox(
                    width: 180,
                    child: Text(tr.date,style: titleStyle)),
                Expanded(
                    child: Text(tr.referenceNumber,style: titleStyle)),
                SizedBox(
                    width: 160,
                    child: Text(tr.txnType,style: titleStyle)),
                SizedBox(
                    width: 120,
                    child: Text(tr.maker,style: titleStyle)),
                SizedBox(
                    width: 120,
                    child: Text(tr.checker,style: titleStyle)),
                SizedBox(
                    width: 120,
                    child: Text(tr.status,style: titleStyle)),
                SizedBox(
                    width: 150,
                    child: Text(tr.amount,style: titleStyle, textAlign: myLocale == "en"? TextAlign.right : TextAlign.left)),
              ],
            ),
          ),
          Divider(indent: 12,endIndent: 12),
          Expanded(
            child: BlocBuilder<TxnReportBloc, TxnReportState>(
              builder: (context, state) {
                if(state is TxnReportInitial){
                  return NoDataWidget(
                    title: "Transaction Report",
                    message: "Select filters above and click Apply to view transactions.",
                    enableAction: false,
                  );
                }
                if(state is TxnReportLoadingState){
                  return Center(child: CircularProgressIndicator());
                }
                if(state is TxnReportErrorState){
                  return NoDataWidget(
                    title: "Error",
                    message: state.error,
                    enableAction: false,
                  );
                }if(state is TxnReportLoadedState){
                  return ListView.builder(
                      itemCount: state.txn.length,
                      itemBuilder: (context,index){
                      final txn = state.txn[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: index.isEven? Theme.of(context).colorScheme.primary.withValues(alpha: .05) : Colors.transparent
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 180,
                                  child: Text(txn.timing?.toDateTime ?? "")),
                              Expanded(
                                  child: Text(txn.reference.toString())),
                              SizedBox(
                                  width: 160,
                                  child: Text(txn.type.toString())),
                              SizedBox(
                                  width: 120,
                                  child: Text(txn.maker.toString())),
                              SizedBox(
                                  width: 120,
                                  child: Text(txn.checker.toString())),
                              SizedBox(
                                  width: 120,
                                  child: Text(txn.statusText??"")),
                              SizedBox(
                                  width: 150,
                                  child: Text("${txn.actualAmount.toAmount()} ${txn.currency}", textAlign: myLocale == "en"? TextAlign.right : TextAlign.left)),
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
