import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/toast.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/txn_status_widget.dart';
import 'package:zaitoon_petroleum/Localizations/Bloc/localizations_bloc.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/AllProjects/model/pjr_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/IncomeExpense/bloc/project_inc_exp_bloc.dart';

import 'add_edit_inc_exp.dart';

class ProjectIncomeExpenseView extends StatelessWidget {
  final ProjectsModel? project;
  const ProjectIncomeExpenseView({super.key, this.project});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(project),
      tablet: _Tablet(project),
      desktop: _Desktop(project),
    );
  }
}

class _Mobile extends StatelessWidget {
  final ProjectsModel? project;
  const _Mobile(this.project);
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Tablet extends StatelessWidget {
  final ProjectsModel? project;
  const _Tablet(this.project);
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Desktop extends StatefulWidget {
  final ProjectsModel? project;
  const _Desktop(this.project);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  String? myLocale;

  @override
  void initState() {
    myLocale = context.read<LocalizationBloc>().state.languageCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.project?.prjId != null) {
        context.read<ProjectIncExpBloc>().add(
          LoadProjectIncExpEvent(widget.project!.prjId!),
        );
      }
    });
    super.initState();
  }
  void _showAddTransactionDialog() {
    if (widget.project == null) return;

    showDialog(
      context: context,
      builder: (context) => AddEditIncomeExpenseDialog(
        project: widget.project!,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    TextStyle? titleStyle = textTheme.titleSmall?.copyWith(color: color.surface);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: _showAddTransactionDialog,
          child: Icon(Icons.add)),
      body: BlocConsumer<ProjectIncExpBloc, ProjectIncExpState>(
        listener: (context, state) {
          if (state is ProjectIncExpErrorState) {
            ToastManager.show(
              context: context,
              title: tr.errorTitle,
              message: state.message,
              type: ToastType.error,
            );
          }
          if (state is ProjectIncExpSuccessState) {
            ToastManager.show(
              context: context,
              title: tr.successTitle,
              message: tr.successMessage,
              type: ToastType.success,
            );
          }
        },
        builder: (context, state) {
          if (state is ProjectIncExpLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProjectIncExpErrorState) {
            return NoDataWidget(
              title: tr.errorTitle,
              message: state.message,
              onRefresh: () {
                if (widget.project?.prjId != null) {
                  context.read<ProjectIncExpBloc>().add(
                    LoadProjectIncExpEvent(widget.project!.prjId!),
                  );
                }
              },
            );
          }

          if (state is ProjectIncExpLoadedState) {
            final inOut = state.inOut;
            final payments = inOut.payments ?? [];

            // Calculate totals
            double totalIncome = 0;
            double totalExpense = 0;

            for (var payment in payments) {
              if (payment.prpType == 'Payment') {
                totalIncome += double.tryParse(payment.payments ?? '0') ?? 0;
              } else if (payment.prpType == 'Expense') {
                totalExpense += double.tryParse(payment.expenses ?? '0') ?? 0;
              }
            }

            final balance = totalIncome - totalExpense;
            final currency = inOut.trdCcy ?? widget.project?.actCurrency ?? '';

            if (payments.isEmpty) {
              return NoDataWidget(
                title: "No Transactions",
                message: "No income or expense records found",
                enableAction: false,
              );
            }

            return Column(
              children: [
                // Summary Cards
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          title: tr.projectBudget,
                          amount: inOut.totalProjectAmount.toDoubleAmount(),
                          currency: currency,
                          color: color.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          title: tr.totalIncome,
                          amount: totalIncome,
                          currency: currency,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          title: tr.totalExpense,
                          amount: totalExpense,
                          currency: currency,
                          color: color.error,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          title: tr.balance,
                          amount: balance,
                          currency: currency,
                          color: balance >= 0 ? Colors.blue : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 8),

                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.primary,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(tr.date, style: titleStyle),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(tr.referenceNumber, style: titleStyle),
                      ),



                      Expanded(
                        child: Text(
                          tr.income,
                          style: titleStyle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          tr.expense,
                          style: titleStyle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          tr.status,
                          style: titleStyle,
                        ),
                      ),
                    ],
                  ),
                ),

                // List of Transactions
                Expanded(
                  child: ListView.builder(
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      final income = double.tryParse(payment.payments ?? '0') ?? 0;
                      final expense = double.tryParse(payment.expenses ?? '0') ?? 0;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withValues(alpha: .2),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(
                                payment.trnEntryDate != null
                                    ? '${payment.trnEntryDate!.day}/${payment.trnEntryDate!.month}/${payment.trnEntryDate!.year}'
                                    : '',
                                style: textTheme.bodyMedium,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    payment.prpTrnRef ?? '',
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    payment.prpType == "Payment"? tr.payment : payment.prpType == "Expense" ? tr.expense : payment.prpType ?? "",
                                    style: textTheme.bodySmall?.copyWith(
                                      color: payment.prpType == 'Payment'
                                          ? Colors.green
                                          : color.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              child: Text(
                                income > 0 ? '${income.toAmount()} $currency' : '',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                expense > 0 ? '${expense.toAmount()} $currency' : '',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: color.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            
                            Expanded(child: TransactionStatusBadge(status: payment.trnStateText??""))

                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, {
        required String title,
        required double amount,
        required String currency,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${amount.toAmount()} $currency',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }


}