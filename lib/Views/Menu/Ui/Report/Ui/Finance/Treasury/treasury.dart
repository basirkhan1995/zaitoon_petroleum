import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/Treasury/bloc/cash_balances_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/Treasury/model/cash_balance_model.dart';
import '../../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';

class TreasuryView extends StatelessWidget {
  const TreasuryView({super.key});

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
    return const Scaffold(
      body: Center(
        child: Text('Mobile view for Treasury'),
      ),
    );
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Tablet view for Treasury'),
      ),
    );
  }
}

class _DesktopState extends State<_Desktop> {
  String? baseCcy;

  @override
  void initState() {
    super.initState();
    context.read<CashBalancesBloc>().add(const LoadAllCashBalancesEvent());
    _loadBaseCurrency();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cash Balances"),
        titleSpacing: 0,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        actions: [
          ZOutlineButton(
            width: 120,
            onPressed: () {},
            icon: Icons.print,
            label: Text(AppLocalizations.of(context)!.print),
          ),
          const SizedBox(width: 8),
          ZOutlineButton(
            width: 120,
            onPressed: () {
              context.read<CashBalancesBloc>().add(const LoadAllCashBalancesEvent());
            },
            icon: Icons.refresh,
            label: const Text('Refresh'),
          ),
        ],
      ),
      body: BlocBuilder<CashBalancesBloc, CashBalancesState>(
        builder: (context, state) {
          if (state is CashBalancesLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CashBalancesErrorState) {
            return Center(
              child: Text(
                'Error: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is AllCashBalancesLoadedState) {
            if (state.cashList.isEmpty) {
              return const Center(
                child: Text('No cash balances found'),
              );
            }

            // Calculate all totals
            final currencyTotals = _calculateCurrencyTotals(state.cashList);
            final systemTotals = _calculateSystemTotals(state.cashList);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP SECTION: General Currency Totals
                  _buildGeneralTotalsSection(currencyTotals, systemTotals),
                  const SizedBox(height: 20),

                  // BOTTOM SECTION: Branch List
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'CASH BALANCES - BRANCH WISE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  _buildCashBalancesList(state.cashList),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Load cash balances to view data'),
          );
        },
      ),
    );
  }

  // Calculate currency totals across all branches
  Map<String, Map<String, dynamic>> _calculateCurrencyTotals(List<CashBalancesModel> cashList) {
    final Map<String, Map<String, dynamic>> currencyTotals = {};

    for (var branch in cashList) {
      if (branch.records != null) {
        for (var record in branch.records!) {
          final currencyCode = record.trdCcy ?? 'UNKNOWN';
          final currencyName = record.ccyName ?? currencyCode;
          final symbol = record.ccySymbol ?? '';

          if (!currencyTotals.containsKey(currencyCode)) {
            currencyTotals[currencyCode] = {
              'name': currencyName,
              'symbol': symbol,
              'totalClosing': 0.0,
              'totalOpening': 0.0,
            };
          }

          final opening = double.tryParse(record.openingBalance ?? '0') ?? 0;
          final closing = double.tryParse(record.closingBalance ?? '0') ?? 0;

          currencyTotals[currencyCode]!['totalOpening'] =
              (currencyTotals[currencyCode]!['totalOpening'] as double) + opening;
          currencyTotals[currencyCode]!['totalClosing'] =
              (currencyTotals[currencyCode]!['totalClosing'] as double) + closing;
        }
      }
    }

    return currencyTotals;
  }

  // Calculate system equivalent totals across all branches
  Map<String, double> _calculateSystemTotals(List<CashBalancesModel> cashList) {
    double totalOpeningSys = 0;
    double totalClosingSys = 0;

    for (var branch in cashList) {
      if (branch.records != null) {
        for (var record in branch.records!) {
          totalOpeningSys += double.tryParse(record.openingSysEquivalent ?? '0') ?? 0;
          totalClosingSys += double.tryParse(record.closingSysEquivalent ?? '0') ?? 0;
        }
      }
    }

    final totalCashFlowSys = totalClosingSys - totalOpeningSys;

    return {
      'opening': totalOpeningSys,
      'closing': totalClosingSys,
      'cashFlow': totalCashFlowSys,
    };
  }

  Widget _buildGeneralTotalsSection(
      Map<String, Map<String, dynamic>> currencyTotals,
      Map<String, double> systemTotals,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'TOTAL CASH BALANCES - ALL BRANCHES',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),

        // Currency Total Cards - Responsive Grid
        _buildCurrencyTotalsGrid(currencyTotals),

        // Grand Total Card (System Equivalent)
        const SizedBox(height: 16),
        _buildGrandTotalCard(systemTotals),
      ],
    );
  }

  Widget _buildCurrencyTotalsGrid(Map<String, Map<String, dynamic>> currencyTotals) {
    // Determine grid column count based on screen width
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        int crossAxisCount;

        if (screenWidth > 1400) {
          crossAxisCount = 5;
        } else if (screenWidth > 1100) {
          crossAxisCount = 4;
        } else if (screenWidth > 800) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.0, // Wider cards
          ),
          itemCount: currencyTotals.length,
          itemBuilder: (context, index) {
            final entry = currencyTotals.entries.elementAt(index);
            final currencyCode = entry.key;
            final data = entry.value;
            final currencyName = data['name'] as String;
            final symbol = data['symbol'] as String;
            final totalOpening = data['totalOpening'] as double;
            final totalClosing = data['totalClosing'] as double;
            final cashFlow = totalClosing - totalOpening;

            // Different colors for different currencies
            final colors = [
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.purple,
              Colors.red,
              Colors.teal,
              Colors.amber,
              Colors.indigo,
            ];
            final color = colors[index % colors.length];

            return ZCover(
              color: color.withValues(alpha: .05),
              radius: 8,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Currency Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            currencyName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: color,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                       ZCover(
                           color: Utils.currencyColors(currencyCode),
                           child: Text(currencyCode,style: TextStyle(color: Theme.of(context).colorScheme.surface),))
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Opening Balance
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Opening',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                        Text(
                          "${totalOpening.toAmount()} $symbol",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Closing Balance
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Closing',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                        Text(
                          "${totalClosing.toAmount()} $symbol",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Cash Flow
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.cashFlow,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        Text(
                          "${cashFlow.toAmount()} $symbol",
                          style: TextStyle(
                            fontSize: 11,
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
          },
        );
      },
    );
  }

  Widget _buildGrandTotalCard(Map<String, double> systemTotals) {
    return ZCover(
      color: Colors.purple.withValues(alpha: .05),
      radius: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GRAND TOTAL CASH FLOW',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.purple,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'System Equivalent ($baseCcy)',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),

            const SizedBox(height: 16),

            // Totals in a row
            Row(
              children: [
                Expanded(
                  child: _buildTotalItem(
                    label: AppLocalizations.of(context)!.openingBalance,
                    value: systemTotals['opening']!,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTotalItem(
                    label: 'Closing Balance',
                    value: systemTotals['closing']!,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTotalItem(
                    label: AppLocalizations.of(context)!.cashFlow,
                    value: systemTotals['cashFlow']!,
                    color: systemTotals['cashFlow']! >= 0 ? Colors.green : Colors.red,
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
          children: [
            Expanded(
              child: Text(
                value.toAmount(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              baseCcy ?? '',
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: .8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCashBalancesList(List<CashBalancesModel> cashList) {
    return Column(
      children: List.generate(cashList.length, (index) {
        final branch = cashList[index];
        return _buildBranchCard(branch);
      }),
    );
  }

  Widget _buildBranchCard(CashBalancesModel branch) {
    final tr = AppLocalizations.of(context)!;
    return ZCover(
      margin: const EdgeInsets.only(bottom: 10),
      radius: 8,
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: .1),
          child: Icon(Icons.business, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          branch.brcName ?? 'Unnamed Branch',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '${tr.branch}: ${branch.brcId} | ${tr.mobile1}: ${branch.brcPhone ?? 'N/A'}',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Branch Information
                _buildInfoRow('${tr.address}:', branch.address ?? 'N/A'),
                _buildInfoRow('${tr.status}:', branch.brcStatus == 1 ? tr.active : tr.inactive),
                _buildInfoRow('${tr.date}:', branch.brcEntryDate?.toDateTime ?? 'N/A'),
                const SizedBox(height: 20),

                // Records Section
                if (branch.records != null && branch.records!.isNotEmpty)
                  _buildRecordsList(branch.records!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: Text(value),
            ),
          ],
        )
    );
  }

  Widget _buildRecordsList(List<Record> records) {
    final color = Theme.of(context).colorScheme;
    final tr = AppLocalizations.of(context)!;

    // Calculate branch totals for SYS equivalent
    double branchOpeningSys = 0;
    double branchClosingSys = 0;

    for (var record in records) {
      branchOpeningSys += double.tryParse(record.openingSysEquivalent ?? '0') ?? 0;
      branchClosingSys += double.tryParse(record.closingSysEquivalent ?? '0') ?? 0;
    }

    final branchCashFlowSys = branchClosingSys - branchOpeningSys;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: .1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  tr.currencyTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color.primary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  tr.openingBalance,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color.primary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Opening (SYS)',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color.primary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Closing Balance',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color.primary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Closing (SYS)',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color.primary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  tr.cashFlow,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Records Items
        ...records.map((record) {
          final opening = double.tryParse(record.openingBalance ?? '0') ?? 0;
          final closing = double.tryParse(record.closingBalance ?? '0') ?? 0;
          final openingSys = double.tryParse(record.openingSysEquivalent ?? '0') ?? 0;
          final closingSys = double.tryParse(record.closingSysEquivalent ?? '0') ?? 0;
          final cashFlow = closing - opening;
        //  final cashFlowSys = closingSys - openingSys;

          return Container(
            margin: const EdgeInsets.only(bottom: 1),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: color.outline.withValues(alpha: .05),
              border: Border.all(color: color.outline.withValues(alpha: .1)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '${record.ccyName} (${record.trdCcy})',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Text(
                    "${opening.toAmount()} ${record.ccySymbol}",
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Text(
                    "${openingSys.toAmount()} $baseCcy",
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Text(
                    "${closing.toAmount()} ${record.ccySymbol}",
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    "${closingSys.toAmount()} $baseCcy",
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Text(
                    "${cashFlow.toAmount()} ${record.ccySymbol}",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cashFlow >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        // Branch Grand Total Row (Added at the end)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: .1),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(3),
              bottomRight: Radius.circular(3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '${tr.grandTotal} ($baseCcy)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "", // Empty for Opening Balance column
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                child: Text(
                  "${branchOpeningSys.toAmount()} $baseCcy",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "", // Empty for Closing Balance column
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                child: Text(
                  "${branchClosingSys.toAmount()} $baseCcy",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: branchCashFlowSys >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}