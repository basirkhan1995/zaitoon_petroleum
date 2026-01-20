import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/search_field.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/Treasury/bloc/cash_balances_bloc.dart';
import 'model/cash_balance_model.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load all cash balances when the screen loads
    context.read<CashBalancesBloc>().add(const LoadAllCashBalancesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cash Balances"),
        titleSpacing: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 20),

            // Search and Filter
            // _buildSearchFilter(),
            // const SizedBox(height: 20),

            // Main Content
            Expanded(
              child: BlocBuilder<CashBalancesBloc, CashBalancesState>(
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
                    final filteredList = _filterCashBalances(state.cashList);

                    if (filteredList.isEmpty) {
                      return const Center(
                        child: Text('No cash balances found'),
                      );
                    }

                    return _buildCashBalancesTable(filteredList);
                  }

                  return const Center(
                    child: Text('Load cash balances to view data'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
         Text(
          'Treasury - Cash Balances',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Row(
          children: [
            ZOutlineButton(
              width: 120,
              onPressed: () {
                context.read<CashBalancesBloc>().add(const LoadAllCashBalancesEvent());
              },
              icon:  Icons.refresh,
              label: const Text('Refresh'),

            ),

          ],
        ),
      ],
    );
  }

  Widget _buildSearchFilter() {
    return Row(
      children: [
        Expanded(
          child: ZSearchField(
            hint: "Search",
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            }, title: '',
          ),
        ),
      ],
    );
  }

  Widget _buildCashBalancesTable(List<CashBalancesModel> cashList) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Summary Cards
          _buildSummaryCards(cashList),
          const SizedBox(height: 20),

          // Main Table
          Expanded(
            child: ListView.builder(
              itemCount: cashList.length,
              itemBuilder: (context, index) {
                final branch = cashList[index];
                return _buildBranchCard(branch);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(List<CashBalancesModel> cashList) {
    double totalClosingUSD = 0;
    double totalClosingAFN = 0;


    for (var branch in cashList) {
      if (branch.records != null) {
        for (var record in branch.records!) {
          final closing = double.tryParse(record.closingSysEquivalent ?? '0') ?? 0;
          if (record.trdCcy == 'USD') {
            totalClosingUSD += closing;
          } else if (record.trdCcy == 'AFN') {
            totalClosingAFN += closing;
          }
        }
      }
    }

    return Row(
      children: [

        Expanded(
          child: _buildSummaryCard(
            title: 'Total',
            value: totalClosingUSD.toStringAsFixed(2),
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryCard(
            title: 'Total',
            value: totalClosingAFN.toStringAsFixed(2),
            icon: Icons.currency_exchange,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return ZCover(
      color: color.withValues(alpha: .1),
      radius: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchCard(CashBalancesModel branch) {
    return ZCover(
      margin: const EdgeInsets.only(bottom: 10),
      radius: 8,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: .1),
          child: const Icon(Icons.business, color: Colors.blue),
        ),
        title: Text(
          branch.brcName ?? 'Unnamed Branch',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Branch ID: ${branch.brcId} | Phone: ${branch.brcPhone ?? 'N/A'}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Branch Information
                _buildInfoRow('Address:', branch.address ?? 'N/A'),
                _buildInfoRow('Status:', branch.brcStatus == 1 ? 'Active' : 'Inactive'),
                _buildInfoRow('Entry Date:', branch.brcEntryDate?.toString() ?? 'N/A'),

                const SizedBox(height: 20),
                const Divider(),

                // Records Table
                if (branch.records != null && branch.records!.isNotEmpty)
                  _buildRecordsTable(branch.records!),
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
      ),
    );
  }

  Widget _buildRecordsTable(List<Record> records) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Account')),
          DataColumn(label: Text('Currency')),
          DataColumn(label: Text('Opening Balance'), numeric: true),
          DataColumn(label: Text('Opening (SYS)'), numeric: true),
          DataColumn(label: Text('Closing Balance'), numeric: true),
          DataColumn(label: Text('Closing (SYS)'), numeric: true),
          DataColumn(label: Text('Change')),
        ],
        rows: records.map((record) {
          final opening = double.tryParse(record.openingBalance ?? '0') ?? 0;
          final closing = double.tryParse(record.closingBalance ?? '0') ?? 0;
          final change = closing - opening;

          return DataRow(cells: [
            DataCell(Text(record.accName ?? 'N/A')),
            DataCell(Text('${record.ccyName} (${record.trdCcy})')),
            DataCell(Text(_formatNumber(opening))),
            DataCell(Text(_formatNumber(double.tryParse(record.openingSysEquivalent ?? '0') ?? 0))),
            DataCell(Text(_formatNumber(closing))),
            DataCell(Text(_formatNumber(double.tryParse(record.closingSysEquivalent ?? '0') ?? 0))),
            DataCell(
              Text(
                _formatNumber(change),
                style: TextStyle(
                  color: change >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(2);
  }

  List<CashBalancesModel> _filterCashBalances(List<CashBalancesModel> cashList) {
    if (_searchQuery.isEmpty) return cashList;

    return cashList.where((branch) {
      // Search in branch name
      if (branch.brcName?.toLowerCase().contains(_searchQuery) == true) {
        return true;
      }

      // Search in branch ID
      if (branch.brcId?.toString().contains(_searchQuery) == true) {
        return true;
      }

      // Search in currency names in records
      if (branch.records != null) {
        for (var record in branch.records!) {
          if (record.ccyName?.toLowerCase().contains(_searchQuery) == true ||
              record.trdCcy?.toLowerCase().contains(_searchQuery) == true) {
            return true;
          }
        }
      }

      return false;
    }).toList();
  }

}

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}