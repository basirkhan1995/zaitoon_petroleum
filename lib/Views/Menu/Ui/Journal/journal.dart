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
import '../../../../Features/Other/shortcut.dart';
import '../../../../Features/Widgets/outline_button.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import 'package:flutter/services.dart';
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

    // Define the actions for each F-key
    void onSell() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('F1 pressed: Sell Transaction')),
      );
    }

    void onBuy() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('F2 pressed: Buy Transaction')),
      );
    }

    void onReturn() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('F3 pressed: Return Goods')),
      );
    }

    // The shortcut mapping
    final shortcuts = {
      const SingleActivator(LogicalKeyboardKey.f1): onSell,
      const SingleActivator(LogicalKeyboardKey.f2): onBuy,
      const SingleActivator(LogicalKeyboardKey.f3): onReturn,
    };

    return Scaffold(
      body: GlobalShortcuts(
        shortcuts: shortcuts,
        child: Column(
          children: [
            // -------------------- HEADER & TABS --------------------
            Cover(
              margin: const EdgeInsets.only(top: 6, bottom: 5),
              radius: 5,
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 7),
                    child: Row(
                      children: [
                        Text(
                          locale.journal,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: context.scaledFont(0.015),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomUnderlineTabBar<JournalTabName>(
                    tabs: [
                      JournalTabName.allTransactions,
                      JournalTabName.authorized,
                      JournalTabName.pending,
                    ],
                    currentTab: context.watch<JournalTabBloc>().state.tab,
                    onTabChanged: (tab) => context
                        .read<JournalTabBloc>()
                        .add(JournalOnChangedEvent(tab)),
                    labelBuilder: (tab) {
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

            // -------------------- MAIN CONTENT --------------------
            Expanded(
              child: Row(
                children: [
                  // LEFT SIDE — TAB SCREENS
                  Expanded(
                    child: BlocBuilder<JournalTabBloc, JournalTabState>(
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

                  const SizedBox(width: 3),

                  // RIGHT SIDE — SHORTCUT BUTTONS PANEL
                  Container(
                    width: 190,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Wrap(
                            spacing: 5,
                            children: [
                              const Icon(Icons.shopify_rounded, size: 20),
                              Text(locale.stock,
                                  style:
                                  Theme.of(context).textTheme.titleSmall),
                            ],
                          ),

                          // ---------- Buttons with keyboard shortcuts ----------
                          ShortcutButton(
                            onPressed: onSell,
                            child: ZOutlineButton(
                              label: Text(locale.sellTitle),
                              toolTip: 'F1',
                              icon: Icons.shopping_cart_outlined,
                              iconSize: 20,
                              width: double.infinity,
                              onPressed: onSell,
                            ),
                          ),
                          ShortcutButton(
                            onPressed: onBuy,
                            child: ZOutlineButton(
                              label: Text(locale.buyTitle),
                              toolTip: 'F2',
                              icon: Icons.shopping_cart_outlined,
                              iconSize: 20,
                              width: double.infinity,
                              onPressed: onBuy,
                            ),
                          ),
                          ShortcutButton(
                            onPressed: onReturn,
                            child: ZOutlineButton(
                              label: Text(locale.returnGoods),
                              toolTip: 'F3',
                              icon: Icons.refresh_rounded,
                              iconSize: 18,
                              width: double.infinity,
                              onPressed: onReturn,
                            ),
                          ),

                          Wrap(
                            spacing: 5,
                            children: [
                              const Icon(Icons.reset_tv_rounded, size: 20),
                              Text(locale.cashFlow,
                                  style:
                                  Theme.of(context).textTheme.titleSmall),
                            ],
                          ),

                          ZOutlineButton(
                            label: Text(locale.deposit),
                            icon: Icons.arrow_circle_down_rounded,
                            width: double.infinity,
                            onPressed: () {},
                          ),
                          ZOutlineButton(
                            label: Text(locale.withdraw),
                            icon: Icons.arrow_circle_up_rounded,
                            width: double.infinity,
                            onPressed: () {},
                          ),
                          ZOutlineButton(
                            label: Text(locale.income),
                            icon: Icons.arrow_circle_down_rounded,
                            width: double.infinity,
                            onPressed: () {},
                          ),
                          ZOutlineButton(
                            label: Text(locale.expense),
                            icon: Icons.arrow_circle_up_rounded,
                            width: double.infinity,
                            onPressed: () {},
                          ),
                          ZOutlineButton(
                            label: Text(locale.accountTransfer),
                            icon: Icons.swap_horiz_rounded,
                            width: double.infinity,
                            onPressed: () {},
                          ),
                          ZOutlineButton(
                            label: Text(locale.fxTransaction),
                            icon: Icons.swap_horiz_rounded,
                            width: double.infinity,
                            onPressed: () {},
                          ),

                          Wrap(
                            spacing: 5,
                            children: [
                              const Icon(Icons.computer_rounded, size: 20),
                              Text(locale.systemAction,
                                  style:
                                  Theme.of(context).textTheme.titleSmall),
                            ],
                          ),

                          ZOutlineButton(
                            label: Text(locale.glCreditTitle),
                            width: double.infinity,
                            icon: Icons.call_to_action_outlined,
                            onPressed: () {},
                          ),
                          ZOutlineButton(
                            label: Text(locale.glDebitTitle),
                            width: double.infinity,
                            icon: Icons.call_to_action_outlined,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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


