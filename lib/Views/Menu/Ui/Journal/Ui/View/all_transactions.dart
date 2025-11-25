import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/bloc/transactions_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                SizedBox(
                    width: 90,
                    child: Text(locale.txnDate,style: textTheme.titleMedium)),
                SizedBox(width: 20),
               Expanded(child: Text(locale.referenceNumber,style: textTheme.titleMedium)),
                SizedBox(
                    width: 110,
                    child: Text(locale.txnType,style: textTheme.titleMedium)),
                SizedBox(width: 20),
                SizedBox(
                    width: 110,
                    child: Text(locale.authoriser,style: textTheme.titleMedium)),
                SizedBox(width: 20),
                SizedBox(
                    width: 110,
                    child: Text(locale.txnMaker,style: textTheme.titleMedium)),
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
              listener: (context, state) {},
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
                if(state is TransactionLoadingState){
                 return Center(
                   child: CircularProgressIndicator(),
                 );
                }
                if(state is TransactionLoadedState){
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
                     itemCount: state.txn.length,
                     itemBuilder: (context,index){
                       final txn = state.txn[index];
                     return Material(
                       child: InkWell(
                         onTap: (){},
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
                                     width: 90,
                                     child: Text(txn.trnEntryDate!.toDateString)),
                                 SizedBox(width: 20),
                                 Expanded(
                                     child: Text(txn.trnReference.toString())),

                                 SizedBox(
                                     width: 110,
                                     child: Text(txn.trnType??"")),
                                 SizedBox(width: 20),
                                 SizedBox(
                                     width: 110,
                                     child: Text(txn.checker??"")),
                                 SizedBox(width: 20),
                                 SizedBox(
                                     width: 110,
                                     child: Text(txn.maker??"")),
                                 SizedBox(width: 20),
                                 SizedBox(
                                     width: 90,
                                     child: Text(txn.trnStatus == 1? locale.authorizedTransactions : locale.pendingTransactions)),
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
      ),
    );
  }
}

