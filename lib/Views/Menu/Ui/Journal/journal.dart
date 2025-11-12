import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/all_transactions.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/authorized.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/pending.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/bloc/transaction_tab_bloc.dart';
import '../../../../Features/Generic/underline_tab.dart';
import '../../../../Features/Other/cover.dart';
import '../../../../Features/Other/responsive.dart';
import '../../../../Features/Widgets/outline_button.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';

class JournalView extends StatelessWidget {
  const JournalView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(),
      tablet: _Tablet(),
    );
  }
}

class _Desktop extends StatelessWidget {
  const _Desktop();

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    //final visible = context.read<SettingsVisibleBloc>().state;
    return Scaffold(
      body: Column(
        children: [
          //Tabs & Title
          Cover(
            margin: EdgeInsets.only(top: 6, bottom: 5),
            radius: 5,
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 7,
                  ),
                  child: Row(
                    children: [
                      Text(
                        locale.journal,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary,
                          fontSize: context.scaledFont(0.015),
                        ),
                      ),
                    ],
                  ),
                ),
                //Tab Names
                CustomUnderlineTabBar<JournalTabName>(
                  tabs: [
                    JournalTabName.allTransactions,
                    JournalTabName.authorized,
                    JournalTabName.pending,
                  ],
                  currentTab: context.watch<JournalTabBloc>().state.tab,
                  onTabChanged: (tab) => context.read<JournalTabBloc>().add(JournalOnChangedEvent(tab)),
                  labelBuilder: (tab) {
                    final locale = AppLocalizations.of(context)!;
                    switch (tab) {
                      case JournalTabName.allTransactions:
                        return locale.allTransactions;
                      case JournalTabName.authorized:
                        return locale.authorizedTransactions;
                      case JournalTabName.pending:
                        return locale.pendingTransactions;
                    }
                  },
                ),
              ],
            ),
          ),

          //Tab Screens
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child:
                  BlocBuilder<JournalTabBloc, JournalTabState>(
                    builder: (context, state) {
                      switch (state.tab) {
                        case JournalTabName.allTransactions:
                          return const AllTransactionsView();
                        case JournalTabName.authorized:
                          return const AuthorizedTransactionsView();
                        case JournalTabName.pending:
                          return const PendingTransactionsView();
                      }
                    },
                  ),
                ),
                SizedBox(width: 3),
                Container(
                  height: double.infinity,
                  width: 190,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.start,
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                         // if (visible.stock)
                            Wrap(
                              spacing: 5,
                              children: [
                                Icon(
                                  Icons.shopify_rounded,
                                  size: 20,
                                ),
                                Text(
                                  locale.stock,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall,
                                ),
                              ],
                            ),

                         // if (visible.stock)
                            ZOutlineButton(
                              label: Text(locale.sellTitle),
                              toolTip: 'F1',
                              icon:
                              Icons.shopping_cart_outlined,
                              iconSize: 20,
                              width: double.infinity,
                              onPressed: () {},
                            ),

                          //if (visible.stock)
                            ZOutlineButton(
                              label: Text(locale.buyTitle),
                              toolTip: 'F2',
                              icon: Icons.shopping_cart_outlined,
                              iconSize: 20,
                              width: double.infinity,
                              onPressed:() {},
                            ),

                          //if (visible.stock)
                            ZOutlineButton(
                              label: Text(locale.returnGoods),
                              toolTip: 'F3',
                              icon:
                              Icons.refresh_rounded,
                              iconSize: 18,
                              width: double.infinity,
                              onPressed: (){},
                            ),
                          Wrap(
                            spacing: 5,
                            children: [
                              Icon(
                                Icons.reset_tv_rounded,
                                size: 20,
                              ),
                              Text(
                                locale.cashFlow,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall,
                              ),
                            ],
                          ),
                          ZOutlineButton(
                            label: Text(locale.deposit),
                            icon: Icons.arrow_circle_down_rounded,
                            width: double.infinity,
                            onPressed: (){},
                          ),
                          ZOutlineButton(
                            label: Text(locale.withdraw),
                            icon: Icons.arrow_circle_up_rounded,
                            width: double.infinity,
                            onPressed: (){}
                          ),
                          ZOutlineButton(
                            label: Text(locale.income),
                            icon: Icons.arrow_circle_down_rounded,
                            width: double.infinity,
                            onPressed: (){},
                          ),
                          ZOutlineButton(
                            label: Text(locale.expense),
                            icon: Icons.arrow_circle_up_rounded,
                            width: double.infinity,
                            onPressed: (){}
                          ),

                          ZOutlineButton(
                            label: Text(locale.accountTransfer),
                            icon: Icons.swap_horiz_rounded,
                            width: double.infinity,
                            onPressed: (){}
                          ),
                          ZOutlineButton(
                            label: Text(locale.fxTransaction),
                            icon: Icons.swap_horiz_rounded,
                            width: double.infinity,
                            onPressed: (){}
                          ),

                          Wrap(
                            spacing: 5,
                            children: [
                              Icon(
                                Icons.computer_rounded,
                                size: 20,
                              ),
                              Text(
                                locale.systemAction,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall,
                              ),
                            ],
                          ),

                          ZOutlineButton(
                            label: Text(
                              locale.glCreditTitle,
                            ),
                            width: double.infinity,
                            icon: Icons.call_to_action_outlined,
                            onPressed: (){}
                          ),

                          ZOutlineButton(
                            label: Text(
                              locale.glDebitTitle,
                            ),
                            width: double.infinity,
                            icon: Icons.call_to_action_outlined,
                            onPressed: (){}
                          ),

                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
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


