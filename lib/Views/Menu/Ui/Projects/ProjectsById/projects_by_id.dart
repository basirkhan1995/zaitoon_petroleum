import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/txn_status_widget.dart';
import 'package:zaitoon_petroleum/Localizations/Bloc/localizations_bloc.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/ProjectsById/bloc/projects_by_id_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/ProjectsById/model/project_by_id_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/bloc/project_tabs_bloc.dart';
import '../../../../../Features/Generic/tab_bar.dart';
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

class _ProjectByIdContentState extends State<_ProjectByIdContent> {
  String? myLocale;

  @override
  void initState() {
    super.initState();
    myLocale = context.read<LocalizationBloc>().state.languageCode;

    // Load project data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProjectsByIdBloc>().add(
        LoadProjectByIdEvent(widget.projectId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: BlocBuilder<ProjectsByIdBloc, ProjectsByIdState>(
          builder: (context, state) {
            if (state is ProjectByIdLoadedState) {
              return Text(state.project.prjName ?? tr.details);
            }
            return Text(tr.details);
          },
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

            return BlocBuilder<ProjectTabsBloc, ProjectTabsState>(
              builder: (context, tabState) {
                // Define tabs based on project data
                final tabs = <ZTabItem<ProjectTabsName>>[
                  ZTabItem(
                    value: ProjectTabsName.overview,
                    label: tr.overview,
                    screen: _buildOverviewTab(context, project),
                  ),
                  ZTabItem(
                    value: ProjectTabsName.services,
                    label: tr.services,
                    screen: _buildServicesTab(context, project),
                  ),
                  ZTabItem(
                    value: ProjectTabsName.incomeExpense,
                    label: tr.incomeAndExpenses,
                    screen: _buildIncomeExpenseTab(context, project),
                  ),
                ];

                // Safely get selected tab with fallback
                final available = tabs.map((t) => t.value).toList();
                final selected = available.contains(tabState.tabs)
                    ? tabState.tabs
                    : tabs.first.value;

                return ZTabContainer<ProjectTabsName>(
                  /// Tab data
                  tabs: tabs,
                  selectedValue: selected,

                  /// Bloc update
                  onChanged: (val) => context.read<ProjectTabsBloc>().add(ProjectTabOnChangedEvent(val)),

                  /// Styling
                  style: ZTabStyle.rounded,
                  tabBarPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  borderRadius: 0,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  unselectedTextColor: Theme.of(context).colorScheme.onSurface,
                  selectedTextColor: Theme.of(context).colorScheme.surface,
                  tabContainerColor: Theme.of(context).colorScheme.surface,
                  margin: const EdgeInsets.all(0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  // OVERVIEW TAB - Mobile Optimized
  Widget _buildOverviewTab(BuildContext context, ProjectByIdModel project) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards Row
          Row(
            children: [
              Expanded(
                child: _buildMobileSummaryCard(
                  context,
                  title: "Services",
                  value: project.projectServices?.length.toString() ?? '0',
                  icon: Icons.build,
                  color: color.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMobileSummaryCard(
                  context,
                  title: "Transactions",
                  value: project.projectPayments?.length.toString() ?? '0',
                  icon: Icons.payment,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Project Information Section
          _buildMobileInfoSection(
            context,
            title: tr.projectInformation,
            children: [
              _buildMobileInfoRow(tr.projectName, project.prjName ?? '-'),
              _buildMobileInfoRow(tr.details, project.prjDetails ?? '-', isMultiline: true),
              _buildMobileInfoRow(tr.location, project.prjLocation ?? '-'),
              _buildMobileInfoRow(
                tr.deadline,
                project.prjDateLine?.toFormattedDate() ?? '-',
              ),
              _buildMobileInfoRow(
                tr.entryDate,
                project.prjEntryDate?.toFormattedDate() ?? '-',
              ),
              _buildMobileStatusRow(
                tr.status,
                project.prjStatus == 0 ? tr.inProgress : tr.completed,
                isActive: project.prjStatus == 0,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Owner Information Section
          _buildMobileInfoSection(
            context,
            title: tr.ownerInformation,
            children: [
              _buildMobileInfoRow("Owner Name", project.prjOwnerfullName ?? '-'),
              _buildMobileInfoRow(
                tr.accountNumber,
                project.prjOwnerAccount?.toString() ?? '-',
              ),
              _buildMobileInfoRow(tr.currencyTitle, project.actCurrency ?? '-'),
            ],
          ),
        ],
      ),
    );
  }

  // SERVICES TAB - Mobile Optimized
  Widget _buildServicesTab(BuildContext context, ProjectByIdModel project) {

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
        // Total Summary Card
        _buildMobileTotalCard(
          context,
          count: services.length,
          totalAmount: totalSum,
          currency: project.actCurrency ?? '',
        ),

        const SizedBox(height: 8),

        // Services List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildMobileServiceCard(context, service, index, project.actCurrency ?? '');
            },
          ),
        ),
      ],
    );
  }

  // INCOME/EXPENSE TAB - Mobile Optimized
  Widget _buildIncomeExpenseTab(BuildContext context, ProjectByIdModel project) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;

    final payments = project.projectPayments ?? [];
    final services = project.projectServices ?? [];

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

    // Calculate total services amount
    double totalServicesAmount = 0;
    for (var service in services) {
      totalServicesAmount += double.tryParse(service.total ?? '0') ?? 0;
    }

    for (var payment in payments) {
      if (payment.prpType == 'Payment') {
        totalIncome += double.tryParse(payment.payments ?? '0') ?? 0;
      } else if (payment.prpType == 'Expense') {
        totalExpense += double.tryParse(payment.expenses ?? '0') ?? 0;
      }
    }

    final balance = totalIncome - totalExpense;
    final currency = project.actCurrency ?? '';

    return Column(
      children: [
        // Summary Cards Grid
        Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: [
              _buildMobileFinancialCard(
                context,
                title: "Services",
                amount: totalServicesAmount,
                currency: currency,
                color: color.primary,
                icon: Icons.build,
              ),
              _buildMobileFinancialCard(
                context,
                title: tr.payment,
                amount: totalIncome,
                currency: currency,
                color: Colors.green,
                icon: Icons.arrow_downward,
              ),
              _buildMobileFinancialCard(
                context,
                title: tr.expense,
                amount: totalExpense,
                currency: currency,
                color: color.error,
                icon: Icons.arrow_upward,
              ),
              _buildMobileFinancialCard(
                context,
                title: tr.balance,
                amount: balance,
                currency: currency,
                color: balance >= 0 ? Colors.blue : Colors.orange,
                icon: Icons.account_balance_wallet,
              ),
            ],
          ),
        ),

        // Transactions List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return _buildMobileTransactionCard(context, payment, index, currency);
            },
          ),
        ),
      ],
    );
  }

  // ==================== MOBILE COMPONENTS ====================

  Widget _buildMobileSummaryCard(BuildContext context,
      {required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildMobileInfoSection(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMobileInfoRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: isMultiline ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStatusRow(String label, String value, {required bool isActive}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.orange.withValues(alpha: .1)
                  : Colors.green.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.orange : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTotalCard(BuildContext context,
      {required int count, required double totalAmount, required String currency}) {
    final color = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.primaryContainer,
            color.primary.withValues(alpha: .1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.primary.withValues(alpha: .1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Services",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.onPrimaryContainer.withValues(alpha: .7),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.list_alt, size: 16, color: color.primary),
                  const SizedBox(width: 4),
                  Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Total Amount",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.onPrimaryContainer.withValues(alpha: .7),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: color.primary),
                  Text(
                    "${totalAmount.toAmount()} $currency",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileServiceCard(BuildContext context,
      dynamic service, int index, String currency) {
    final color = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.outline.withValues(alpha: .1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Name and Reference
          Row(
            children: [
              Expanded(
                child: Text(
                  service.srvName ?? 'Service',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Ref: ${service.prpTrnRef ?? ''}',
                  style: TextStyle(
                    fontSize: 10,
                    color: color.primary,
                  ),
                ),
              ),
            ],
          ),

          // Remark if exists
          if (service.pjdRemark?.isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            Text(
              service.pjdRemark!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.onSurface.withValues(alpha: .6),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Details Grid
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  label: "QTY",
                  value: service.pjdQuantity?.toString() ?? '0',
                  icon: Icons.format_list_numbered,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  context,
                  label: "Price",
                  value: (double.tryParse(service.pjdPricePerQty ?? '0') ?? 0).toAmount(),
                  icon: Icons.attach_money,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  context,
                  label: AppLocalizations.of(context)!.totalTitle,
                  value: (double.tryParse(service.total ?? '0') ?? 0).toAmount(),
                  icon: Icons.calculate,
                  isHighlighted: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFinancialCard(BuildContext context,
      {required String title, required double amount, required String currency,
        required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${amount.toAmount()} $currency',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTransactionCard(BuildContext context,
      dynamic payment, int index, String currency) {
    final color = Theme.of(context).colorScheme;
    final isPayment = payment.prpType == 'Payment';
    final isExpense = payment.prpType == 'Expense';
    final amount = double.tryParse(isPayment ? payment.payments ?? '0' : payment.expenses ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.outline.withValues(alpha: .1)),
      ),
      child: Column(
        children: [
          // Top Row - Date, Type, Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  payment.trnEntryDate != null
                      ? '${payment.trnEntryDate!.day}/${payment.trnEntryDate!.month}'
                      : '',
                  style: TextStyle(
                    fontSize: 12,
                    color: color.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  payment.prpTrnRef ?? 'No Reference',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TransactionStatusBadge(
                status: payment.trnStateText ?? "",
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bottom Row - Type and Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isPayment
                          ? Colors.green.withValues(alpha: .1)
                          : isExpense
                          ? color.error.withValues(alpha: .1)
                          : Colors.grey.withValues(alpha: .1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPayment
                          ? Icons.arrow_downward
                          : isExpense
                          ? Icons.arrow_upward
                          : Icons.swap_horiz,
                      size: 12,
                      color: isPayment
                          ? Colors.green
                          : isExpense
                          ? color.error
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isPayment ? "Payment" : isExpense ? "Expense" : payment.prpType ?? "",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPayment
                          ? Colors.green
                          : isExpense
                          ? color.error
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
              Text(
                '${amount.toAmount()} $currency',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPayment ? Colors.green : color.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context,
      {required String label, required String value, required IconData icon, bool isHighlighted = false}) {
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 10, color: isHighlighted ? color.primary : color.outline),
              const SizedBox(width: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: isHighlighted ? color.primary : color.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? color.primary : color.onSurface,
              fontSize: isHighlighted ? 14 : 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}