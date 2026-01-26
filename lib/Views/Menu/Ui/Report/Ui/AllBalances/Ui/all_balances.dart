import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/AllBalances/bloc/all_balances_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../Finance/Ui/GlAccounts/GlCategories/category_view.dart';

class AllBalancesView extends StatelessWidget {
  const AllBalancesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(), desktop: _Desktop(), tablet: _Tablet(),);
  }
}


class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


class _Mobile extends StatelessWidget {
  const _Mobile();

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

  int? catId;
  @override
  Widget build(BuildContext context) {
    TextStyle? titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.surface);
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text("All Balances"),
        actionsPadding: EdgeInsets.symmetric(horizontal: 10),
        actions: [
          if(catId !=null)
          ZOutlineButton(
              width: 130,
              backgroundHover: Theme.of(context).colorScheme.error,
              isActive: true,
              onPressed: (){
                setState(() {
                  catId = null;
                });
                context.read<AllBalancesBloc>().add(ResetAllBalancesEvent());
              },
              icon: Icons.filter_alt_off_outlined,
              label: Text(tr.clearFilters)),
          SizedBox(width: 8),
          ZOutlineButton(
              width: 100,
              onPressed: (){

              },
              icon: Icons.print,
              label: Text(tr.print)),
          SizedBox(width: 8),
          ZOutlineButton(
            width: 120,
              onPressed: (){
              context.read<AllBalancesBloc>().add(LoadAllBalancesEvent(catId: catId));
              },
              isActive: true,
              icon: Icons.filter_alt,
              label: Text(tr.apply)),


        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                SizedBox(
                  width: 300,
                  child: GlSubCategoriesDrop(
                      title: tr.accountCategory,
                      mainCategoryId: 0,
                      onChanged: (e){
                        setState(() {
                          catId = e?.acgId;
                        });
                        context.read<AllBalancesBloc>().add(LoadAllBalancesEvent(catId: catId));
                      }),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8,horizontal: 5),
            margin: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: .9),
            ),
            child: Row(
              children: [
                SizedBox(
                    width: 100,
                    child: Text(tr.accountNumber,style: titleStyle)),

                Expanded(
                    child: Text(tr.accountName,style: titleStyle)),

                SizedBox(
                    width: 100,
                    child: Text(tr.branchId,style: titleStyle)),

                SizedBox(
                    width: 250,
                    child: Text(tr.accountCategory,style: titleStyle)),

                SizedBox(
                    width: 150,
                    child: Text(tr.balance,style: titleStyle)),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<AllBalancesBloc, AllBalancesState>(
              builder: (context, state) {
                if(state is AllBalancesInitial){
                  return NoDataWidget(
                    title: "All Balances",
                    message: "View all accounts balances here",
                    enableAction: false,
                  );
                }
                if(state is AllBalancesLoadingState){
                  return Center(child: CircularProgressIndicator());
                }
                if(state is AllBalancesLoadedState){
                  if(state.balances.isEmpty){
                    return NoDataWidget(
                      title: tr.noData,
                      message: tr.noDataFound,
                    );
                  }
                  return ListView.builder(
                      itemCount: state.balances.length,
                      itemBuilder: (context,index){
                      final ab = state.balances[index];
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 8,horizontal: 5),
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: index.isOdd? Theme.of(context).colorScheme.primary.withValues(alpha: .05) : Colors.transparent
                          ),
                          child: Row(
                          children: [
                            SizedBox(
                                width: 100,
                                child: Text(ab.trdAccount.toString())),

                            Expanded(
                                child: Text(ab.accName.toString())),
                            SizedBox(
                                width: 100,
                                child: Text(ab.trdBranch.toString())),
                            SizedBox(
                                width: 30,
                                child: Text(ab.acgId.toString())),
                            SizedBox(
                                width: 220,
                                child: Text(ab.acgName.toString())),

                            SizedBox(
                                width: 150,
                                child: Text("${ab.balance.toAmount()} ${ab.trdCcy}")),
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
