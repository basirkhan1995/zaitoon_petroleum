import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/AllBalances/Ui/all_balances.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/Accounts/accounts.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/BalanceSheet/balance_sheet.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/GLStatement/gl_statement.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/Treasury/cash_branch.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Transport/shipping_report.dart';
import '../../../../Features/Other/utils.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import 'TransactionRef/transaction_ref.dart';
import 'TxnReport/txn_report.dart';
import 'Ui/Finance/AccountStatement/acc_statement.dart';
import 'Ui/Finance/ArApReport/Payables/payables.dart';
import 'Ui/Finance/ArApReport/Receivables/receivables.dart';
import 'Ui/Finance/ExchangeRate/exchange_rate.dart';
import 'Ui/Finance/Treasury/all_cash.dart';
import 'Ui/Finance/TrialBalance/trial_balance.dart';
import 'Ui/UserReport/user_log_report.dart';
import 'Ui/UserReport/users_report.dart';

enum ActionKey {
  //Finance
  accStatement,
  glStatement,
  glStatementSingleDate,
  payable,
  receivable,
  treasury,
  cashBalanceBranchWise,
  exchangeRate,
  accountsReport,
  trialBalance,

  users,

  //Transport
  shipping,

  //Transactions
  balanceSheet,
  activities,
  transactionByRef,
  transactionReport,
  allBalances,

  //Stock
  products,
  purchase,
  sale,

  userLog
}
class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), tablet: _Tablet(), desktop: _Desktop());
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
    final color = Theme.of(context).colorScheme;
    final tr = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> financeButtons = [
      {"title": tr.accountStatement, "icon": FontAwesomeIcons.buildingColumns, "action": ActionKey.accStatement},
      {"title": tr.glStatement, "icon": FontAwesomeIcons.buildingColumns, "action": ActionKey.glStatement},
      {"title": tr.glStatementSingleDate, "icon": FontAwesomeIcons.buildingColumns, "action": ActionKey.glStatementSingleDate},
      {"title": tr.creditors, "icon": FontAwesomeIcons.arrowTrendUp, "action": ActionKey.payable},
      {"title": tr.debtors, "icon": FontAwesomeIcons.arrowTrendDown, "action": ActionKey.receivable},

    ];

    final List<Map<String, dynamic>> stockButtons = [
      {"title": tr.products, "icon": Icons.shopping_bag_outlined, "action": ActionKey.products},
      {"title": tr.purchaseInvoice, "icon": Icons.add_shopping_cart_sharp, "action": ActionKey.purchase},
      {"title": tr.salesInvoice, "icon": Icons.add_shopping_cart_sharp, "action": ActionKey.sale},
    ];

    final List<Map<String, dynamic>> transactionsButtons = [
      {"title": "${tr.treasury} (${tr.all} ${tr.branches})", "icon": FontAwesomeIcons.sackDollar, "action": ActionKey.treasury},
      {"title": "${tr.treasury} (${tr.branch} Wise)", "icon": FontAwesomeIcons.sackDollar, "action": ActionKey.cashBalanceBranchWise},
      {"title": tr.exchangeRate, "icon": Icons.compare_arrows_rounded, "action": ActionKey.exchangeRate},
      {"title": tr.balanceSheet, "icon": Icons.balance_rounded, "action": ActionKey.balanceSheet},
      {"title": tr.trialBalance, "icon": Icons.balance_rounded, "action": ActionKey.trialBalance},
      {"title": tr.transactionDetails, "icon": Icons.qr_code_2_rounded, "action": ActionKey.transactionByRef},
      {"title": "${tr.transactions} ${tr.report}", "icon": Icons.line_axis_sharp, "action": ActionKey.transactionReport},
      {"title": "All Balances", "icon": Icons.line_axis_sharp, "action": ActionKey.allBalances},
    ];

    final List<Map<String, dynamic>> activitiesButtons = [
      {"title": tr.users, "icon": FontAwesomeIcons.users, "action": ActionKey.users},
      {"title": tr.userLog, "icon": Icons.scale_rounded, "action": ActionKey.userLog},
    ];

    final List<Map<String, dynamic>> transportButtons = [
      {"title": tr.shipping, "icon": Icons.local_shipping_outlined, "action": ActionKey.shipping},
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                 spacing: 5,
                 children: [
                   Icon(Icons.add_chart),
                   Text(tr.report,style: Theme.of(context).textTheme.titleLarge?.copyWith()),
                 ],
               ),
              SizedBox(height: 8),
              Divider(endIndent: 3,indent: 3,color: Theme.of(context).colorScheme.outline.withValues(alpha: .2),thickness: 1.5,),
               SizedBox(height: 15),
              _buildSectionTitle(title: tr.finance,icon: Icons.money_rounded),
              _buildButtonGroup(financeButtons, color),
              const SizedBox(height: 15),

              _buildSectionTitle(title: tr.inventory,icon: Icons.shopping_cart_checkout_rounded),
              _buildButtonGroup(stockButtons, color),

              const SizedBox(height: 15),

              _buildSectionTitle(title: "Cash & Balances",icon: Icons.ssid_chart),
              _buildButtonGroup(transactionsButtons, color),

              const SizedBox(height: 15),

              _buildSectionTitle(title: "${tr.users} & ${tr.activities}",icon: Icons.access_time),
              _buildButtonGroup(activitiesButtons, color),

              const SizedBox(height: 15),

              _buildSectionTitle(title: tr.transport,icon: Icons.local_shipping_outlined),
              _buildButtonGroup(transportButtons, color),
            ],
          ),
        ),
      ),
    );
  }

  /// Title widget for each section
  Widget _buildSectionTitle({required String title, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        spacing: 5,
        children: [
          Icon(icon,color: Theme.of(context).colorScheme.secondary,size: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
  /// Wrap-based button layout for compact and responsive placement
  Widget _buildButtonGroup(List<Map<String, dynamic>> buttons, ColorScheme color) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: buttons.map((btn) => _buildButton(btn)).toList(),
        ),
      ),
    );
  }
  Widget _buildButton(Map<String, dynamic> button) {
    final color = Theme.of(context).colorScheme;
    final hoverNotifier = ValueNotifier(false);

    return MouseRegion(
      onEnter: (_) => hoverNotifier.value = true,
      onExit: (_) => hoverNotifier.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: hoverNotifier,
        builder: (context, isHovered, _) {
          return GestureDetector(
            onTap: () => reportAction(button['action'] as ActionKey),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 150),
              width: 115,
              height: 125,
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  color: isHovered
                      ? color.primary
                      : color.surface,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(button['icon'], size: 35, color: isHovered
                      ? color.surface
                      : color.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    button['title'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isHovered
                          ? color.surface
                          : color.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  void reportAction(ActionKey action) {
    switch (action) {

      //Finance
      case ActionKey.accStatement: Utils.goto(context, AccountStatementView());
      case ActionKey.glStatement: Utils.goto(context, GlStatementView());
      case ActionKey.payable: Utils.goto(context, PayablesView());
      case ActionKey.receivable: Utils.goto(context, ReceivablesView());
      case ActionKey.exchangeRate: Utils.goto(context, FxRateReportView());
      case ActionKey.treasury: Utils.goto(context, TreasuryView());
      case ActionKey.cashBalanceBranchWise: Utils.goto(context, CashBalancesBranchWiseView());
      case ActionKey.accountsReport: Utils.goto(context, AccountsReportView());
      case ActionKey.trialBalance: Utils.goto(context, TrialBalanceView());
      case ActionKey.glStatementSingleDate: Utils.goto(context, GlStatementView(isSingleDate: true));

      //Transactions
      case ActionKey.balanceSheet: Utils.goto(context, BalanceSheetView());
      case ActionKey.activities:  Utils.goto(context, TransactionReportView());
      case ActionKey.transactionByRef:  Utils.goto(context, TransactionByReferenceView());
      case ActionKey.transactionReport: Utils.goto(context, TransactionReportView());
      case ActionKey.allBalances: Utils.goto(context, AllBalancesView());

      // Stock
      case ActionKey.products: throw UnimplementedError();
      case ActionKey.purchase: throw UnimplementedError();
      case ActionKey.sale: throw UnimplementedError();

      // Activity
      case ActionKey.userLog: Utils.goto(context, UserLogReportView());
      case ActionKey.users: Utils.goto(context, UsersReportView());

      //Transport
      case ActionKey.shipping: Utils.goto(context, ShippingReportView());
    }
  }
}

