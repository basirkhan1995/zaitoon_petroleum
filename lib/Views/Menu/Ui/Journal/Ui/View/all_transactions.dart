import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/bloc/transactions_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../Features/Widgets/search_field.dart';
import '../TxnByReference/bloc/txn_reference_bloc.dart';
import '../TxnByReference/txn_reference.dart';

class AllTransactionsView extends StatelessWidget {
  const AllTransactionsView({super.key});

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
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<TransactionsBloc>().add(LoadAllTransactionsEvent('all'));
    });
    super.initState();
  }
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocConsumer<TxnReferenceBloc, TxnReferenceState>(
      listener: (context, state) {
        if (state is TxnReferenceLoadedState) {
          showDialog(
            context: context,
            builder: (context) {
              return TxnReferenceView();
            },
          );
        }
      },
  builder: (context, state) {
    if (state is TxnReferenceLoadingState) {
      return Center(child: CircularProgressIndicator());
    }
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 8,
            ),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: ZSearchField(
                    icon: FontAwesomeIcons.magnifyingGlass,
                    controller: searchController,
                    hint: AppLocalizations.of(context)!.search,
                    onChanged: (e) {
                      setState(() {});
                    },
                    title: "",
                  ),
                ),
                ZOutlineButton(
                  toolTip: "F5",
                  width: 120,
                  icon: Icons.refresh,
                  onPressed: () {
                    context.read<TransactionsBloc>().add(
                      LoadAuthorizedTransactionsEvent('all'),
                    );
                  },
                  label: Text(locale.refresh),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                SizedBox(
                    width: 140,
                    child: Text(locale.txnDate,style: textTheme.titleMedium)),
                SizedBox(width: 20),
               Expanded(child: Text(locale.referenceNumber,style: textTheme.titleMedium)),
                SizedBox(
                    width: 110,
                    child: Text(locale.txnType,style: textTheme.titleMedium)),
                SizedBox(width: 20),
                SizedBox(
                    width: 110,
                    child: Text(locale.createdBy,style: textTheme.titleMedium)),
                SizedBox(width: 20),
                SizedBox(
                    width: 110,
                    child: Text(locale.checker,style: textTheme.titleMedium)),
                SizedBox(width: 20),
                SizedBox(
                    width: 90,
                    child: Text(locale.status,style: textTheme.titleMedium)),

              ],
            ),
          ),
          Divider(
           indent: 8,endIndent: 8, color: Theme.of(context).colorScheme.primary,
          ),
          Expanded(
            child: BlocConsumer<TransactionsBloc, TransactionsState>(
              listener: (context, state) {
                if(state is TransactionSuccessState){
                  WidgetsBinding.instance.addPostFrameCallback((_){
                    Navigator.of(context).pop();
                    context.read<TransactionsBloc>().add(LoadAllTransactionsEvent('all'));
                  });
                }
              },
              builder: (context, state) {
                if(state is TransactionErrorState){
                  return NoDataWidget(
                    message: state.message,
                    onRefresh: (){
                      WidgetsBinding.instance.addPostFrameCallback((_){
                        context.read<TransactionsBloc>().add(LoadAllTransactionsEvent('all'));
                      });
                    },
                  );
                }
                if(state is TxnLoadingState){
                 return Center(
                   child: CircularProgressIndicator(),
                 );
                }
                if(state is TransactionLoadedState){
                  final query = searchController.text.toLowerCase().trim();
                  final filteredList = state.txn.where((item) {
                    final name = item.trnReference?.toLowerCase() ?? '';
                    final status = item.trnStateText?.toLowerCase() ?? '';
                    final trnName = item.trnType?.toLowerCase() ?? '';
                    final usrName = item.usrName?.toLowerCase() ?? '';
                    return name.contains(query) || status.contains(query) || usrName.contains(query) || trnName.contains(query);
                  }).toList();
                  if(state.txn.isEmpty){
                    return NoDataWidget(
                      message: locale.noDataFound,
                      onRefresh: (){
                        WidgetsBinding.instance.addPostFrameCallback((_){
                          context.read<TransactionsBloc>().add(LoadAllTransactionsEvent('all'));
                        });
                      },
                    );
                  }
                 return ListView.builder(
                     shrinkWrap: true,
                     itemCount: filteredList.length,
                     itemBuilder: (context,index){
                       final txn = filteredList[index];
                     return Material(
                       child: InkWell(
                         onTap: (){
                           context.read<TxnReferenceBloc>().add(
                             FetchTxnByReferenceEvent(txn.trnReference??""),
                           );
                         },
                         hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: .05),
                         highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: .05),
                         child: Container(
                           decoration: BoxDecoration(
                             color: index.isOdd? Theme.of(context).colorScheme.primary.withValues(alpha: .06) : Colors.transparent
                           ),
                           child: Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: Row(
                               children: [
                                 SizedBox(
                                     width: 140,
                                     child: Text(txn.trnEntryDate!.toFullDateTime)),
                                 SizedBox(width: 20),
                                 Expanded(
                                     child: Text(txn.trnReference.toString())),

                                 SizedBox(
                                     width: 110,
                                     child: Text(Utils.getTxnCode(txn: txn.trnType??"", context: context))),
                                 SizedBox(width: 20),
                                 SizedBox(
                                     width: 110,
                                     child: Text(txn.maker??"")),
                                 SizedBox(width: 20),
                                 SizedBox(
                                     width: 110,
                                     child: Text(txn.checker??"")),
                                 SizedBox(width: 20),
                                 SizedBox(
                                     width: 90,
                                     child: Text(Utils.getTxnName(txn: txn.trnStateText??"", context: context))),
                               ],
                             ),
                           ),
                         ),
                       ),
                     );
                 });
                }
                return const SizedBox() ;
              },
            ),
          ),
        ],
      );
  },
),
    );
  }
}

