import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/section_title.dart';
import 'package:zaitoon_petroleum/Features/Widgets/txn_status_widget.dart';
import 'package:zaitoon_petroleum/Localizations/Bloc/localizations_bloc.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/ProjectsById/bloc/projects_by_id_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/ProjectsById/model/project_by_id_model.dart';

import '../../../../../Features/Date/shamsi_converter.dart';

class ProjectsByIdView extends StatelessWidget {
  final int projectId;

  const ProjectsByIdView({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(projectId: projectId),
      desktop: _Desktop(projectId: projectId),
      tablet: _Tablet(projectId: projectId),
    );
  }
}

class _Mobile extends StatelessWidget {
  final int projectId;

  const _Mobile({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return _ProjectByIdContent(projectId: projectId);
  }
}

class _Tablet extends StatelessWidget {
  final int projectId;

  const _Tablet({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return _ProjectByIdContent(projectId: projectId);
  }
}

class _Desktop extends StatelessWidget {
  final int projectId;

  const _Desktop({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return _ProjectByIdContent(projectId: projectId);
  }
}

class _ProjectByIdContent extends StatefulWidget {
  final int projectId;

  const _ProjectByIdContent({required this.projectId});

  @override
  State<_ProjectByIdContent> createState() => _ProjectByIdContentState();
}

class _ProjectByIdContentState extends State<_ProjectByIdContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? myLocale;

  @override
  void initState() {
    super.initState();
    myLocale = context.read<LocalizationBloc>().state.languageCode;
    _tabController = TabController(length: 3, vsync: this);

    // Load project data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProjectsByIdBloc>().add(
        LoadProjectByIdEvent(widget.projectId),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ProjectsByIdBloc, ProjectsByIdState>(
          builder: (context, state) {
            if (state is ProjectByIdLoadedState) {
              return Text(state.project.prjName ?? tr.details);
            }
            return Text(tr.details);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.info_outline)),
            Tab(text: 'Services', icon: Icon(Icons.build)),
            Tab(text: 'Income & Expense', icon: Icon(Icons.payments_outlined)),
          ],
        ),
      ),
      body: BlocBuilder<ProjectsByIdBloc, ProjectsByIdState>(
        builder: (context, state) {
          if (state is ProjectByIdLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProjectByIdErrorState) {
            return NoDataWidget(
              title: tr.errorTitle,
              message: state.message,
              onRefresh: () {
                context.read<ProjectsByIdBloc>().add(
                  LoadProjectByIdEvent(widget.projectId),
                );
              },
            );
          }

          if (state is ProjectByIdLoadedState) {
            final project = state.project;

            return TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                _buildOverviewTab(context, project),

                // Services Tab
                _buildServicesTab(context, project),

                // Income & Expense Tab
                _buildIncomeExpenseTab(context, project),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, ProjectByIdModel project) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Information Section
          SectionTitle(title: tr.projectInformation),
          const SizedBox(height: 12),

          _buildInfoCard(
            context,
            children: [
              _buildInfoRow(tr.projectName, project.prjName ?? '-'),
              _buildInfoRow(tr.details, project.prjDetails ?? '-'),
              _buildInfoRow(tr.location, project.prjLocation ?? '-'),
              _buildInfoRow(
                tr.deadline,
                project.prjDateLine?.toFormattedDate() ?? '-',
              ),
              _buildInfoRow(
                tr.entryDate,
                project.prjEntryDate?.toFormattedDate() ?? '-',
              ),
              _buildInfoRow(
                tr.status,
                project.prjStatus == 0 ? tr.inProgress : tr.completed,
                valueColor: project.prjStatus == 0 ? Colors.orange : Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Owner Information Section
          SectionTitle(title: tr.ownerInformation),
          const SizedBox(height: 12),

          _buildInfoCard(
            context,
            children: [
              _buildInfoRow("Owner Name", project.prjOwnerfullName ?? '-'),
              _buildInfoRow(
                "${tr.accountNumber}",
                project.prjOwnerAccount?.toString() ?? '-',
              ),
              _buildInfoRow(tr.currencyTitle, project.actCurrency ?? '-'),
            ],
          ),

          const SizedBox(height: 24),

          // Summary Section
          SectionTitle(title: tr.summary),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.outline.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    title: "Total Services",
                    value: project.projectServices?.length.toString() ?? '0',
                    icon: Icons.build,
                    color: color.primary,
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: color.outline.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    title: "Total Transactions",
                    value: project.projectPayments?.length.toString() ?? '0',
                    icon: Icons.payment,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab(BuildContext context, ProjectByIdModel project) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final services = project.projectServices ?? [];

    if (services.isEmpty) {
      return NoDataWidget(
        title: "No Services",
        message: "No services found for this project",
        enableAction: false,
      );
    }

    // Calculate total
    double totalSum = 0;
    for (var service in services) {
      totalSum += double.tryParse(service.total ?? '0') ?? 0;
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: color.primary,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(tr.projectServices,
                    style: textTheme.titleSmall?.copyWith(color: color.surface)
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(tr.qty,
                    style: textTheme.titleSmall?.copyWith(color: color.surface)
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(tr.amount,
                    textAlign: TextAlign.right,
                    style: textTheme.titleSmall?.copyWith(color: color.surface)
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(tr.totalTitle,
                    textAlign: TextAlign.right,
                    style: textTheme.titleSmall?.copyWith(color: color.surface)
                ),
              ),
            ],
          ),
        ),

        // Services List
        Expanded(
          child: ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: index.isOdd
                      ? color.primary.withValues(alpha: .05)
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withValues(alpha: .2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.srvName ?? '',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (service.pjdRemark != null)
                            Text(
                              service.pjdRemark!,
                              style: textTheme.bodySmall?.copyWith(
                                color: color.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          Text(
                            'Ref: ${service.prpTrnRef ?? ''}',
                            style: textTheme.bodySmall?.copyWith(
                              color: color.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(service.pjdQuantity?.toString() ?? '0'),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        "${(double.tryParse(service.pjdPricePerQty ?? '0') ?? 0).toAmount()} ${project.actCurrency}",
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        "${(double.tryParse(service.total ?? '0') ?? 0).toAmount()} ${project.actCurrency}",
                        textAlign: TextAlign.right,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Total Footer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          decoration: BoxDecoration(
            color: color.primary.withValues(alpha: 0.05),
            border: Border(
              top: BorderSide(color: color.primary.withValues(alpha: 0.3)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  tr.summary.toUpperCase(),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "${tr.totalTitle}: ${totalSum.toAmount()} ${project.actCurrency}",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseTab(BuildContext context, ProjectByIdModel project) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final payments = project.projectPayments ?? [];

    if (payments.isEmpty) {
      return NoDataWidget(
        title: "No Transactions",
        message: "No income or expense records found",
        enableAction: false,
      );
    }

    // Calculate totals
    double totalIncome = 0;
    double totalExpense = 0;
    double totalProjectAmount = 0;

    for (var payment in payments) {
      if (payment.prpType == 'Payment') {
        totalIncome += double.tryParse(payment.payments ?? '0') ?? 0;
      } else if (payment.prpType == 'Expense') {
        totalExpense += double.tryParse(payment.expenses ?? '0') ?? 0;
      }

      // For Entry type, add to project total
      if (payment.prpType == 'Entry') {
        totalProjectAmount += double.tryParse(payment.payments ?? '0') ?? 0;
        totalProjectAmount += double.tryParse(payment.expenses ?? '0') ?? 0;
      }
    }

    final balance = totalIncome - totalExpense;
    final currency = project.actCurrency ?? '';

    return Column(
      children: [
        // Summary Cards
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: tr.totalProjects,
                  amount: totalProjectAmount,
                  currency: currency,
                  color: color.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: tr.totalPayment,
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

        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: color.primary,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(tr.date,
                    style: textTheme.titleSmall?.copyWith(color: color.surface)
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(tr.referenceNumber,
                    style: textTheme.titleSmall?.copyWith(color: color.surface)
                ),
              ),
              Expanded(
                child: Text(tr.payment,
                    textAlign: TextAlign.right,
                    style: textTheme.titleSmall?.copyWith(color: color.surface)
                ),
              ),
              Expanded(
                child: Text(tr.expense,
                    textAlign: TextAlign.right,
                    style: textTheme.titleSmall?.copyWith(color: color.surface)
                ),
              ),
              Expanded(
                child: Text(tr.status,
                    textAlign: TextAlign.center,
                    style: textTheme.titleSmall?.copyWith(color: color.surface)
                ),
              ),
            ],
          ),
        ),

        // Transactions List
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
                  color: index.isOdd
                      ? color.primary.withValues(alpha: .05)
                      : Colors.transparent,
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
                            payment.prpType == "Payment"
                                ? tr.payment
                                : payment.prpType == "Expense"
                                ? tr.expense
                                : payment.prpType ?? "",
                            style: textTheme.bodySmall?.copyWith(
                              color: payment.prpType == 'Payment'
                                  ? Colors.green
                                  : payment.prpType == 'Expense'
                                  ? color.error
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        income > 0 ? '${income.toAmount()} $currency' : '-',
                        textAlign: TextAlign.right,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        expense > 0 ? '${expense.toAmount()} $currency' : '-',
                        textAlign: TextAlign.right,
                        style: textTheme.bodyMedium?.copyWith(
                          color: color.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: TransactionStatusBadge(
                          status: payment.trnStateText ?? "",
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, {required List<Widget> children}) {
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: color.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      BuildContext context, {
        required String title,
        required String value,
        required IconData icon,
        required Color color,
      }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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