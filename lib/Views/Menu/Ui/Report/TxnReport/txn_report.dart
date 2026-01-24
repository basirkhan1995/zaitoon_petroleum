import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
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

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    String fromDate = DateTime.now().toFormattedDate();
    String toDate = DateTime.now().toFormattedDate();

    int? status;
    String? currency;
    String? maker;
    String? checker;
    String? txnType;

    return Scaffold(
      appBar: AppBar(title: Text("TXN REPORT"),
       actionsPadding: EdgeInsets.symmetric(horizontal: 10),
        actions: [

          ZOutlineButton(
              isActive: true,
              onPressed: (){
                setState(() {
                  maker = null;
                  checker = null;
                  txnType = null;
                  currency = null;
                   fromDate = DateTime.now().toFormattedDate();
                   toDate = DateTime.now().toFormattedDate();
                });
              },
              width: 140,
              icon: Icons.filter_alt_off_outlined,
              label: Text(tr.clearFilters)),
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
              width: 120,
              icon: Icons.filter_alt,
              label: Text(tr.apply)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 8,
              children: [
                SizedBox(
                  width: 150,
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
                SizedBox(
                  width: 150,
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

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                    width: 180,
                    child: Text(tr.referenceNumber)),
              ],
            ),
          ),
          Divider(indent: 10,endIndent: 5),
          SizedBox(height: 3),
          Expanded(
            child: BlocBuilder<TxnReportBloc, TxnReportState>(
              builder: (context, state) {
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
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 180,
                                child: Text(txn.reference.toString())),
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
