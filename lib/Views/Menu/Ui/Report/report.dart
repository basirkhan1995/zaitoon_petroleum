import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/Accounts/accounts.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/BalanceSheet/balance_sheet.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/GLStatement/gl_statement.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Transactions/Activities/activities.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Transactions/GeneralReport/general_report.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Transactions/IncomeStatement/income_statement.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Transactions/TransactionRef/transaction_ref.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/UserLogReport/user_log_report.dart';
import '../../../../Features/Other/utils.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import 'Ui/Finance/AccountStatement/acc_statement.dart';
import 'Ui/Finance/ArApReport/Payables/payables.dart';
import 'Ui/Finance/ArApReport/Receivables/receivables.dart';
import 'Ui/Finance/ExchangeRate/exchange_rate.dart';
import 'Ui/Finance/Treasury/treasury.dart';
import 'Ui/Finance/TrialBalance/trial_balance.dart';

enum ActionKey {
  //Finance
  accStatement,
  glStatement,
  glStatementSingleDate,
  payable,
  receivable,
  treasury,
  exchangeRate,
  accountsReport,
  trialBalance,


  //Transactions
  balanceSheet,
  generalReport,
  profitAndLoss,
  activities,
  transactionByRef,

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
    final locale = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> financeButtons = [
      {"title": locale.accountStatement, "icon": FontAwesomeIcons.buildingColumns, "action": ActionKey.accStatement},
      {"title": locale.glStatement, "icon": FontAwesomeIcons.buildingColumns, "action": ActionKey.glStatement},
      {"title": locale.glStatementSingleDate, "icon": FontAwesomeIcons.buildingColumns, "action": ActionKey.glStatementSingleDate},
      {"title": locale.creditors, "icon": FontAwesomeIcons.arrowTrendUp, "action": ActionKey.payable},
      {"title": locale.debtors, "icon": FontAwesomeIcons.arrowTrendDown, "action": ActionKey.receivable},

      {"title": locale.exchangeRate, "icon": Icons.compare_arrows_rounded, "action": ActionKey.exchangeRate},
      {"title": locale.treasury, "icon": FontAwesomeIcons.sackDollar, "action": ActionKey.treasury},
    ];

    final List<Map<String, dynamic>> stockButtons = [
      {"title": locale.products, "icon": Icons.shopping_bag_outlined, "action": ActionKey.products},
      {"title": locale.purchaseInvoice, "icon": Icons.add_shopping_cart_sharp, "action": ActionKey.purchase},
      {"title": locale.salesInvoice, "icon": Icons.add_shopping_cart_sharp, "action": ActionKey.sale},
    ];

    final List<Map<String, dynamic>> transactionsButtons = [
      {"title": locale.balanceSheet, "icon": Icons.balance_rounded, "action": ActionKey.balanceSheet},
      {"title": locale.trialBalance, "icon": Icons.balance, "action": ActionKey.trialBalance},
      {"title": locale.transactionDetails, "icon": Icons.qr_code_2_rounded, "action": ActionKey.transactionByRef},
    ];

    final List<Map<String, dynamic>> activitiesButtons = [
      {"title": locale.userLog, "icon": Icons.scale_rounded, "action": ActionKey.userLog},
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
              _buildSectionTitle(title: locale.finance,icon: Icons.money_rounded),
              _buildButtonGroup(financeButtons, color),
              const SizedBox(height: 15),

              _buildSectionTitle(title: locale.stock,icon: Icons.shopping_cart_checkout_rounded),
              _buildButtonGroup(stockButtons, color),

              const SizedBox(height: 15),

              _buildSectionTitle(title: locale.transactions,icon: Icons.ssid_chart),
              _buildButtonGroup(transactionsButtons, color),

              const SizedBox(height: 15),

              _buildSectionTitle(title: locale.activities,icon: Icons.access_time),
              _buildButtonGroup(activitiesButtons, color),
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
    final hoverNotifier = ValueNotifier(false); // Local state holder

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
      case ActionKey.accountsReport: Utils.goto(context, AccountsReportView());
      case ActionKey.trialBalance: Utils.goto(context, TrialBalanceView());

      //Transactions
      case ActionKey.profitAndLoss: Utils.goto(context, IncomeStatementView());
      case ActionKey.balanceSheet: Utils.goto(context, BalanceSheetView());
      case ActionKey.generalReport:  Utils.goto(context, SystemGeneralReportView());
      case ActionKey.activities:  Utils.goto(context, ActivitiesView());
      case ActionKey.transactionByRef:  Utils.goto(context, TransactionByReferenceView());

      // Stock
      case ActionKey.products: throw UnimplementedError();
      case ActionKey.purchase: throw UnimplementedError();
      case ActionKey.sale: throw UnimplementedError();

      // Activity
      case ActionKey.userLog: Utils.goto(context, UserLogReportView());
      case ActionKey.glStatementSingleDate: Utils.goto(context, GlStatementView(isSingleDate: true));
    }
  }
}

