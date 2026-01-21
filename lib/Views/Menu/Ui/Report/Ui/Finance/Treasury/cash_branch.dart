import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Auth/bloc/auth_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/Treasury/bloc/cash_balances_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/Treasury/model/cash_balance_model.dart';
import '../../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';

class CashBalancesBranchWiseView extends StatelessWidget {
  const CashBalancesBranchWiseView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(),
      tablet: _Tablet(),
    );
  }
}

class _Desktop extends StatefulWidget {
  const _Desktop();
  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  String? baseCcy;
  int? branchId;
  @override
  void initState() {
    super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CashBalancesBloc>().add(
          LoadCashBalanceBranchWiseEvent(branchId: branchId),
        );
      });

      _loadBaseCurrency();
      _loadAuth();
  }

  void _loadBaseCurrency() {
    try {
      final companyState = context.read<CompanyProfileBloc>().state;
      if (companyState is CompanyProfileLoadedState) {
        baseCcy = companyState.company.comLocalCcy;
      }
    } catch (e) {
      baseCcy = "";
    }
  }

  void _loadAuth() {
    try {
      final auth = context.read<AuthBloc>().state;
      if (auth is AuthenticatedState) {
        branchId = auth.loginData.usrBranch;
      }
    } catch (e) {
      branchId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.cashBalances),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
                context.read<CashBalancesBloc>().add(
                  LoadCashBalanceBranchWiseEvent(branchId: branchId),
                );
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printReport,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<CashBalancesBloc, CashBalancesState>(
      builder: (context, state) {
        if (state is CashBalancesLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CashBalancesErrorState) {
          return Center(
            child: NoDataWidget(
               message: state.error,
              onRefresh: (){
                context.read<CashBalancesBloc>().add(
                  LoadCashBalanceBranchWiseEvent(branchId: branchId),
                );
              },
            ));
        }

        if (state is CashBalancesLoadedState) {
          return _buildBranchDetails(state.cash);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildBranchDetails(CashBalancesModel branch) {
    final tr = AppLocalizations.of(context)!;

    // Calculate branch totals
    double totalOpeningSys = 0;
    double totalClosingSys = 0;

    if (branch.records != null) {
      for (var record in branch.records!) {
        totalOpeningSys += double.tryParse(record.openingSysEquivalent ?? '0') ?? 0;
        totalClosingSys += double.tryParse(record.closingSysEquivalent ?? '0') ?? 0;
      }
    }

    final totalCashFlowSys = totalClosingSys - totalOpeningSys;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branch Information Card
          _buildBranchInfoCard(branch, tr),

          const SizedBox(height: 20),

          // Currency Balances Section
          _buildCurrencyBalancesSection(branch, tr),

          const SizedBox(height: 20),

          // Grand Total Card
          _buildGrandTotalCard(
            totalOpeningSys,
            totalClosingSys,
            totalCashFlowSys,
            tr,
          ),
        ],
      ),
    );
  }

  Widget _buildBranchInfoCard(CashBalancesModel branch, AppLocalizations tr) {
    return ZCover(
      color: Theme.of(context).colorScheme.surface,
      radius: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr.branchInformation,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Divider(),
            const SizedBox(height: 10),

            _buildInfoRow('${tr.branchId}:', branch.brcId?.toString() ?? 'N/A'),
            _buildInfoRow('${tr.branchName}:', branch.brcName ?? 'N/A'),
            _buildInfoRow('${tr.address}:', branch.address ?? 'N/A'),
            _buildInfoRow('${tr.mobile1}:', branch.brcPhone ?? 'N/A'),
            _buildInfoRow('${tr.status}:',
                branch.brcStatus == 1 ? tr.active : tr.inactive),
            _buildInfoRow('${tr.date}:',
                branch.brcEntryDate?.toLocal().toString().split(' ')[0] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyBalancesSection(CashBalancesModel branch, AppLocalizations tr) {
    if (branch.records == null || branch.records!.isEmpty) {
      return Center(
        child: Text(
          'No cash records found',
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.currencyBalances,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        const SizedBox(height: 10),

        // Currency Cards Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.3,
          ),
          itemCount: branch.records!.length,
          itemBuilder: (context, index) {
            final record = branch.records![index];
            return _buildCurrencyCard(record, tr);
          },
        ),
      ],
    );
  }

  Widget _buildCurrencyCard(Record record, AppLocalizations tr) {
    final opening = double.tryParse(record.openingBalance ?? '0') ?? 0;
    final closing = double.tryParse(record.closingBalance ?? '0') ?? 0;
    final openingSys = double.tryParse(record.openingSysEquivalent ?? '0') ?? 0;
    final closingSys = double.tryParse(record.closingSysEquivalent ?? '0') ?? 0;
    final cashFlow = closing - opening;
    final cashFlowSys = closingSys - openingSys;
    

    return ZCover(
      color: Theme.of(context).colorScheme.surface,
      radius: 8,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Currency Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    record.ccyName ?? record.trdCcy ?? 'Unknown',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Utils.currencyColors(record.trdCcy??""),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ZCover(
                  color: Utils.currencyColors(record.trdCcy ?? ''),
                  borderColor: Utils.currencyColors(record.trdCcy ?? ''),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      record.trdCcy ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Local Currency Balance
            _buildBalanceRow(
              label: tr.opening,
              amount: opening,
              symbol: record.trdCcy ?? '',
              isSys: false,
            ),

            const SizedBox(height: 4),

            _buildBalanceRow(
              label: tr.closing,
              amount: closing,
              symbol: record.trdCcy ?? '',
              isSys: false,
              isClosing: true,
            ),

            const SizedBox(height: 8),

            // System Equivalent
            _buildBalanceRow(
              label: '${tr.opening} (${tr.sys})',
              amount: openingSys,
              symbol: '$baseCcy',
              isSys: true,
            ),

            const SizedBox(height: 4),

            _buildBalanceRow(
              label: '${tr.closing} (${tr.sys})',
              amount: closingSys,
              symbol: '$baseCcy',
              isSys: true,
              isClosing: true,
            ),

            const SizedBox(height: 8),

            // Cash Flow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr.cashFlow,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${cashFlow.toAmount()} ${record.trdCcy}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: cashFlow >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      "${cashFlowSys.toAmount()} $baseCcy",
                      style: TextStyle(
                        fontSize: 12,
                        color: cashFlowSys >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceRow({
    required String label,
    required double amount,
    required String symbol,
    required bool isSys,
    bool isClosing = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        Text(
          "${amount.toAmount()} $symbol",
          style: TextStyle(
            fontSize: 14,
            fontWeight: isClosing ? FontWeight.bold : FontWeight.w500,
            color: isClosing
                ? (isSys ? Colors.purple : Colors.green)
                : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildGrandTotalCard(
      double openingSys,
      double closingSys,
      double cashFlowSys,
      AppLocalizations tr,
      ) {
    return ZCover(
      color: Colors.purple.withValues(alpha: .05),
      radius: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${tr.branch.toUpperCase()} | ${tr.grandTotal.toUpperCase()} (${tr.systemEquivalent})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTotalItem(
                    label: tr.openingBalance,
                    value: openingSys,
                    color: Colors.grey,
                    symbol: '$baseCcy',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTotalItem(
                    label: tr.closingBalance,
                    value: closingSys,
                    color: Colors.green,
                    symbol: '$baseCcy',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTotalItem(
                    label: tr.cashFlow,
                    value: cashFlowSys,
                    color: cashFlowSys >= 0 ? Colors.green : Colors.red,
                    symbol: '$baseCcy',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalItem({
    required String label,
    required double value,
    required Color color,
    required String symbol,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          spacing: 5,
          children: [
            Text(
              value.toAmount(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              symbol,
              style: TextStyle(
                fontSize: 16,
                color: color.withValues(alpha: .8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _printReport() {

  }
}

// Tablet View
class _Tablet extends StatelessWidget {


  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.cashBalances),
      ),
      body: Center(
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<CashBalancesBloc, CashBalancesState>(
      builder: (context, state) {
        if (state is CashBalancesLoadedState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildBranchDetails(state.cash, context),
          );
        }

        if (state is CashBalancesLoadingState) {
          return const CircularProgressIndicator();
        }

        if (state is CashBalancesErrorState) {
          return Text('Error: ${state.error}');
        }

        return const Text('Select a branch to view cash balance');
      },
    );
  }

  Widget _buildBranchDetails(CashBalancesModel branch, BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildBranchInfoCard(branch, tr, context),
          const SizedBox(height: 16),
          _buildCurrencyCards(branch, tr, context),
        ],
      ),
    );
  }

  Widget _buildBranchInfoCard(CashBalancesModel branch, AppLocalizations tr, BuildContext context) {
    return ZCover(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              branch.brcName ?? 'Unknown Branch',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('${tr.address}: ${branch.address ?? 'N/A'}'),
            Text('${tr.mobile1}: ${branch.brcPhone ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyCards(CashBalancesModel branch, AppLocalizations tr, BuildContext context) {
    if (branch.records == null || branch.records!.isEmpty) {
      return Center(
        child: Text(
          'No cash records',
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: branch.records!.length,
      itemBuilder: (context, index) {
        return _buildSimpleCurrencyCard(branch.records![index], context);
      },
    );
  }

  Widget _buildSimpleCurrencyCard(Record record, BuildContext context) {
    final closing = double.tryParse(record.closingBalance ?? '0') ?? 0;

    return ZCover(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              record.ccyName ?? record.trdCcy ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${closing.toAmount()} ${record.trdCcy}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
                AppLocalizations.of(context)!.closingBalance,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mobile View
class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
         AppLocalizations.of(context)!.cashBalances,
        ),
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<CashBalancesBloc, CashBalancesState>(
      builder: (context, state) {
        if (state is CashBalancesLoadedState) {
          return _buildMobileDetails(state.cash, context);
        }

        if (state is CashBalancesLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CashBalancesErrorState) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        return const Center(
          child: Text('Select a branch to view cash balance'),
        );
      },
    );
  }

  Widget _buildMobileDetails(CashBalancesModel branch, BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        // Branch Info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.brcName ?? 'Unknown Branch',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildMobileInfoRow('ID:', branch.brcId?.toString() ?? 'N/A'),
                _buildMobileInfoRow(tr.address, branch.address ?? 'N/A'),
                _buildMobileInfoRow(tr.mobile1, branch.brcPhone ?? 'N/A'),
                _buildMobileInfoRow(
                  tr.status,
                  branch.brcStatus == 1 ? tr.active : tr.inactive,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Currency Balances
        Text(
          'Currency Balances',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        const SizedBox(height: 12),

        if (branch.records != null && branch.records!.isNotEmpty)
          ...branch.records!.map((record) =>
              _buildMobileCurrencyCard(record, context)
          ),

        const SizedBox(height: 16),

        // Grand Total
        Card(
          color: Colors.purple.withValues(alpha: .05),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grand Total (SYS)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 8),
                _buildMobileTotalRow(
                  'Opening:',
                  _calculateTotalOpeningSys(branch),
                  'SYS',
                ),
                _buildMobileTotalRow(
                  'Closing:',
                  _calculateTotalClosingSys(branch),
                  'SYS',
                ),
                _buildMobileTotalRow(
                  'Cash Flow:',
                  _calculateTotalCashFlowSys(branch),
                  'SYS',
                  isCashFlow: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCurrencyCard(Record record, BuildContext context) {
    final opening = double.tryParse(record.openingBalance ?? '0') ?? 0;
    final closing = double.tryParse(record.closingBalance ?? '0') ?? 0;
    final cashFlow = closing - opening;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record.ccyName ?? record.trdCcy ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  record.trdCcy ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),

            const Divider(height: 16),

            _buildMobileBalanceRow('Opening:', opening, record.trdCcy ?? ''),
            _buildMobileBalanceRow('Closing:', closing, record.trdCcy ?? ''),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cash Flow:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${cashFlow.toAmount()} ${record.trdCcy}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cashFlow >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBalanceRow(String label, double amount, String symbol) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "${amount.toAmount()} $symbol",
            style: TextStyle(
              fontWeight: label.contains('Closing')
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: label.contains('Closing')
                  ? Colors.green
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTotalRow(
      String label,
      double amount,
      String symbol, {
        bool isCashFlow = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "${amount.toAmount()} $symbol",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCashFlow
                  ? (amount >= 0 ? Colors.green : Colors.red)
                  : Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalOpeningSys(CashBalancesModel branch) {
    double total = 0;
    if (branch.records != null) {
      for (var record in branch.records!) {
        total += double.tryParse(record.openingSysEquivalent ?? '0') ?? 0;
      }
    }
    return total;
  }

  double _calculateTotalClosingSys(CashBalancesModel branch) {
    double total = 0;
    if (branch.records != null) {
      for (var record in branch.records!) {
        total += double.tryParse(record.closingSysEquivalent ?? '0') ?? 0;
      }
    }
    return total;
  }

  double _calculateTotalCashFlowSys(CashBalancesModel branch) {
    return _calculateTotalClosingSys(branch) - _calculateTotalOpeningSys(branch);
  }
}