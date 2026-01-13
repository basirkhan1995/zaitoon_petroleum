import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'bloc/trial_balance_bloc.dart';
import 'model/trial_balance_model.dart';

class TrialBalanceView extends StatelessWidget {
  const TrialBalanceView({super.key});

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
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<TrialBalanceBloc>().add(
          LoadTrialBalanceEvent(currency: "USD", date: "2026-01-12")
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text("Trial Balance"),
      ),
      body: BlocBuilder<TrialBalanceBloc, TrialBalanceState>(
        builder: (context, state) {
          if(state is TrialBalanceErrorState){
            return NoDataWidget(
              message: state.message,
            );
          }
          if(state is TrialBalanceLoadingState){
            return const Center(child: CircularProgressIndicator());
          }
          if(state is TrialBalanceLoadedState){
            final data = state.balance;
            // Get currency from first item (assuming all items have same currency)
            final currency = data.isNotEmpty ? data.first.currency : "USD";
            final totalDebit = TrialBalanceHelper.getTotalDebit(data);
            final totalCredit = TrialBalanceHelper.getTotalCredit(data);
            final difference = TrialBalanceHelper.getDifference(data);
            final differencePercentage = TrialBalanceHelper.getDifferencePercentage(data);

            return Column(
              children: [
                // Header row
                _buildHeaderRow(context, currency),

                // Divider
                const Divider(height: 1, thickness: 1),

                // Data rows
                Expanded(
                  child: ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final tb = data[index];
                      final rowDifference = tb.debit - tb.credit;

                      return _buildDataRow(context, tb, rowDifference);
                    },
                  ),
                ),

                // Total row
                _buildTotalRow(
                  context,
                  totalDebit,
                  totalCredit,
                  difference,
                  differencePercentage,
                  currency,
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, String currency) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Account",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              "Debit ($currency)",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              "Credit ($currency)",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, TrialBalanceModel tb, double difference) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tb.accountName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  tb.accountNumber,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            child: _buildAmountCell(
              tb.debit,
              tb.currency,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(
            width: 150,
            child: _buildAmountCell(
              tb.credit,
              tb.currency,
              Theme.of(context).colorScheme.secondary,
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildAmountCell(double amount, String currency, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            amount.toStringAsFixed(2),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          currency,
          style: TextStyle(
            fontSize: 12,
            color: color.withValues(alpha: .7),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(
      BuildContext context,
      double totalDebit,
      double totalCredit,
      double difference,
      double differencePercentage,
      String currency,
      ) {
    final isBalanced = difference == 0;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(width: 2, color: Theme.of(context).colorScheme.outline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TOTAL",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isBalanced) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning,
                              size: 14,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Out of Balance",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 150,
            child: _buildTotalAmountCell(totalDebit, currency, theme.colorScheme.primary, theme),
          ),
          SizedBox(
            width: 150,
            child: _buildTotalAmountCell(totalCredit, currency, theme.colorScheme.secondary, theme),
          ),
          SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      difference.abs().toStringAsFixed(2),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isBalanced
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      currency,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isBalanced
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
                if (!isBalanced) ...[
                  const SizedBox(height: 4),
                  Text(
                    "${differencePercentage.toStringAsFixed(2)}%",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAmountCell(double amount, String currency, Color color, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          amount.toStringAsFixed(2),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          currency,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}

// Keep your mobile and tablet widgets as they are
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