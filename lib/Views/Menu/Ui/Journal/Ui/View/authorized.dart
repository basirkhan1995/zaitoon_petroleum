import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/bloc/transactions_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../Features/Other/utils.dart';
import '../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../Features/Widgets/search_field.dart';

class AuthorizedTransactionsView extends StatelessWidget {
  const AuthorizedTransactionsView({super.key});

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
      context.read<TransactionsBloc>().add(LoadAllTransactionsEvent('auth'));
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: ZSearchField(
                    icon: FontAwesomeIcons.magnifyingGlass,
                    controller: searchController,
                    hint: AppLocalizations.of(context)!.search,
                    onChanged: (e) {
                      setState(() {

                      });
                    },
                    title: "",
                  ),
                ),
                ZOutlineButton(
                    toolTip: "F5",
                    width: 120,
                    icon: Icons.refresh,
                    onPressed: (){
                      context.read<TransactionsBloc>().add(LoadAuthorizedTransactionsEvent('auth'));
                    },
                    label: Text(locale.refresh)),
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
                    child: Text(locale.maker,style: textTheme.titleMedium)),
                SizedBox(
                    width: 110,
                    child: Text(locale.checker,style: textTheme.titleMedium)),
                SizedBox(width: 20),

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
                        context.read<TransactionsBloc>().add(LoadAllTransactionsEvent('auth'));
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
                  final query = searchController.text.toLowerCase().trim();
                  final filteredList = state.txn.where((item) {
                    final name = item.trnReference?.toLowerCase() ?? '';
                    return name.contains(query);
                  }).toList();
                  if(filteredList.isEmpty){
                    return NoDataWidget(
                      message: locale.noDataFound,
                      onRefresh: (){
                        WidgetsBinding.instance.addPostFrameCallback((_){
                          context.read<TransactionsBloc>().add(LoadAllTransactionsEvent('auth'));
                        });
                      },
                    );
                  }
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredList.length,
                      itemBuilder: (context,index){
                        final txn = filteredList[index];
                        return InkWell(
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
                                  SizedBox(
                                      width: 110,
                                      child: Text(txn.checker??"")),
                                  SizedBox(width: 20),
                                ],
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

