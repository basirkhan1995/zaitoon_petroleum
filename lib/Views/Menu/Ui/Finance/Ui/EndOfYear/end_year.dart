import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/EndOfYear/bloc/eoy_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/EndOfYear/model/eoy_model.dart';

class EndOfYearView extends StatelessWidget {
  const EndOfYearView({super.key});

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

class _Desktop extends StatelessWidget {
  const _Desktop();

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.onSurface,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "P&L",
          style: titleStyle?.copyWith(fontSize: 25),
        ),
        actionsPadding: const EdgeInsets.all(8),
        actions: [
          ZOutlineButton(
            width: 100,
            label: Text(tr.print),
            icon: Icons.print,
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          ZOutlineButton(
            isActive: true,
            width: 150,
            label: const Text("EOY CLOSING"),
            icon: Icons.access_time_outlined,
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        children: [
          /// ================= HEADER =================
          _HeaderRow(titleStyle: titleStyle, tr: tr),

          /// ================= BODY =================
          Expanded(
            child: BlocBuilder<EoyBloc, EoyState>(
              builder: (context, state) {
                if (state is EoyErrorState) {
                  return NoDataWidget(message: state.error);
                }

                if (state is EoyLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is EoyLoadedState) {
                  final summary = state.eoy.summary;

                  return Column(
                    children: [
                      /// LIST
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.eoy.length,
                          itemBuilder: (context, index) {
                            final eoy = state.eoy[index];

                            return Container(
                              decoration: BoxDecoration(
                                color: index.isEven
                                    ? theme.colorScheme.primary
                                    .withValues(alpha: .05)
                                    : Colors.transparent,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: Text(eoy.accountNumber.toString()),
                                  ),
                                  Expanded(
                                    child: Text(eoy.accountName ?? ""),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Text(eoy.trdBranch.toString()),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Text(eoy.category ?? ""),
                                  ),
                                  _AmountCell(
                                    amount: eoy.debitAmount,
                                    currency: eoy.currency,
                                  ),
                                  _AmountCell(
                                    amount: eoy.creditAmount,
                                    currency: eoy.currency,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      /// ================= FOOTER SUMMARY =================
                      _BottomSummary(
                        tr: tr,
                        income: summary.totalIncome,
                        expense: summary.totalExpense,
                        retained: summary.retainedEarnings,
                      ),
                    ],
                  );
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

/// ================= HEADER ROW =================
class _HeaderRow extends StatelessWidget {
  final TextStyle? titleStyle;
  final AppLocalizations tr;

  const _HeaderRow({
    required this.titleStyle,
    required this.tr,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: .5),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            SizedBox(width: 120, child: Text(tr.accountNumber, style: titleStyle)),
            Expanded(child: Text(tr.accountName, style: titleStyle)),
            SizedBox(width: 100, child: Text(tr.branch, style: titleStyle)),
            SizedBox(width: 100, child: Text(tr.categoryTitle, style: titleStyle)),
            SizedBox(
              width: 150,
              child: Text(tr.debitTitle,
                  textAlign: TextAlign.right, style: titleStyle),
            ),
            SizedBox(
              width: 150,
              child: Text(tr.creditTitle,
                  textAlign: TextAlign.right, style: titleStyle),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= AMOUNT CELL =================
class _AmountCell extends StatelessWidget {
  final double amount;
  final String? currency;

  const _AmountCell({
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(amount.toAmount()),
          const SizedBox(width: 5),
          Text(
            currency ?? "",
            style: TextStyle(
              color: Utils.currencyColors(currency ?? ""),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= BOTTOM SUMMARY =================
class _BottomSummary extends StatelessWidget {
  final AppLocalizations tr;
  final double income;
  final double expense;
  final double retained;

  const _BottomSummary({
    required this.tr,
    required this.income,
    required this.expense,
    required this.retained,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: .3),
          ),
        ),
      ),
      child: Row(
        children: [
          /// LEFT TITLE
          Expanded(
            child: Text(
              tr.totalTitle,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          /// TOTAL EXPENSE
          _TotalColumn(
            title: "${tr.totalTitle} ${tr.expense}", // "Total Expense"
            amount: expense,
            color: Colors.red,
          ),

          const SizedBox(width: 16),

          /// TOTAL INCOME
          _TotalColumn(
            title: "${tr.totalTitle} ${tr.income}", // "Total Income"
            amount: income,
            color: Colors.green,
          ),

          const SizedBox(width: 32),

          /// RETAINED EARNINGS
          _TotalColumn(
            title: "Retained Earnings",
            amount: retained,
            color: retained >= 0 ? Colors.green : Colors.red,
            isBold: true,
          ),
        ],
      )
    );
  }
}

class _TotalColumn extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final bool isBold;

  const _TotalColumn({
    required this.title,
    required this.amount,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          Text(
            amount.toAmount(),
            textAlign: TextAlign.right,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
