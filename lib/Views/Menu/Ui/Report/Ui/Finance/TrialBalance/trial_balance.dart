import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/features/currency_drop.dart';
import '../../../../../../../Features/Date/z_generic_date.dart';
import 'bloc/trial_balance_bloc.dart';
import 'model/trial_balance_model.dart';
import 'package:shamsi_date/shamsi_date.dart';

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

  String ccy = "USD";
  String todayDate = DateTime.now().toFormattedDate();
  Jalali shamsiTodayDate = DateTime.now().toAfghanShamsi;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<TrialBalanceBloc>().add(
          LoadTrialBalanceEvent(currency: ccy, date: todayDate)
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        titleSpacing: 0,
        title: Text(tr.trialBalance),
        actionsPadding: EdgeInsets.symmetric(horizontal: 10),
        actions: [
          SizedBox(
            width: 150,
            child: CurrencyDropdown(
                isMulti: false,
                onSingleChanged: (e){
                  setState(() {
                    ccy = e?.ccyCode ??"";
                    context.read<TrialBalanceBloc>().add(
                        LoadTrialBalanceEvent(currency: ccy, date: todayDate)
                    );
                  });
                },
                onMultiChanged: (e){}),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 150,
            child: ZDatePicker(
              label: '',
              value: todayDate,
              onDateChanged: (v) {
                setState(() {
                  todayDate = v;
                  shamsiTodayDate = v.toAfghanShamsi;
                });
                context.read<TrialBalanceBloc>().add(
                    LoadTrialBalanceEvent(currency: ccy, date: todayDate)
                );
              },
            ),
          ),

        ],
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
            final currency = data.isNotEmpty ? data.first.currency : ccy;
            final totalDebit = TrialBalanceHelper.getTotalDebit(data);
            final totalCredit = TrialBalanceHelper.getTotalCredit(data);
            final difference = TrialBalanceHelper.getDifference(data);
            final differencePercentage = TrialBalanceHelper.getDifferencePercentage(data);

            return Column(
              children: [
                // Header row
                _buildHeaderRow(currency),

                // Divider
                 Divider(height: 1, thickness: 1,color: Theme.of(context).colorScheme.primary),

                // Data rows
                Expanded(
                  child: ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (context, index) => Divider(height: 1,color: Theme.of(context).colorScheme.outline.withValues(alpha: .2),),
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
                  ccy,
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildHeaderRow(String currency) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.accounts,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              AppLocalizations.of(context)!.debitTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              AppLocalizations.of(context)!.creditTitle,
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
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tb.accountName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  tb.accountNumber,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
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
              Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(
            width: 150,
            child: _buildAmountCell(
              tb.credit,
              Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAmountCell(double amount,Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            amount.toAmount(),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  Widget _buildTotalRow(BuildContext context, double totalDebit, double totalCredit, double difference, double differencePercentage, String currency) {
    final isBalanced = difference == 0;
    final theme = Theme.of(context);

    return ZCard(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 18),
      margin: EdgeInsets.all(8),
      radius: 5,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.totalUpperCase,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.outline
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
                              AppLocalizations.of(context)!.outOfBalance,
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
            child: _buildTotalAmountCell(totalDebit, currency, theme.colorScheme.primary, theme,AppLocalizations.of(context)!.totalDebit),
          ),
          SizedBox(
            width: 150,
            child: _buildTotalAmountCell(totalCredit, currency, theme.colorScheme.secondary, theme,AppLocalizations.of(context)!.totalCredit),
          ),
          SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(AppLocalizations.of(context)!.difference,style: theme.textTheme.bodySmall),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      difference.abs().toAmount(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isBalanced
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (!isBalanced) ...[
                      Text(
                        "${differencePercentage.toStringAsFixed(2)}%",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTotalAmountCell(double amount, String currency, Color color, ThemeData theme,String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title,style: theme.textTheme.bodySmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              amount.toAmount(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
        ),
      ],
    );
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