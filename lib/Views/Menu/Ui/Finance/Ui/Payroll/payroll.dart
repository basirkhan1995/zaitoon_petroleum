import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/alert_dialog.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/toast.dart';
import 'package:zaitoon_petroleum/Features/Widgets/status_badge.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Payroll/bloc/payroll_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Payroll/model/payroll_model.dart';
import '../../../../../../Features/Date/month_year_picker.dart';
import '../../../../../../Features/Widgets/no_data_widget.dart';
import '../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';

class PayrollView extends StatelessWidget {
  const PayrollView({super.key});

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

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => __DesktopState();
}

class __DesktopState extends State<_Desktop> {
  final Set<int> _selectedIds = {};
  bool _selectAll = false;

  void _toggleRecordSelection(int perId, bool isPaid) {
    setState(() {
      if (_selectedIds.contains(perId)) {
        _selectedIds.remove(perId);
      } else if (!isPaid) {
        _selectedIds.add(perId);
      }
    });
  }

  void _toggleSelectAll(List<PayrollModel> payroll) {
    setState(() {
      if (_selectAll) {
        _selectedIds.clear();
      } else {
        // Select only unpaid records
        _selectedIds.addAll(
          payroll
              .where((record) => (record.payment ?? 0) == 0)
              .map((record) => record.perId!)
              .toList(),
        );
      }
      _selectAll = !_selectAll;
    });
  }

  void _postSelectedPayroll(
    BuildContext context,
    String usrName,
    List<PayrollModel> payroll,
  ) {
    final selectedRecords = payroll
        .where((record) => _selectedIds.contains(record.perId))
        .map((record) => record.copyWith(payment: 1))
        .toList();

    if (selectedRecords.isEmpty) {
      ToastManager.show(
        context: context,
        message: "Please select a record to post",
        type: ToastType.error,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return ZAlertDialog(
          title: AppLocalizations.of(context)!.confirmPayment,
          content: 'Post salary for ${selectedRecords.length} employees?',
          onYes: () {
            context.read<PayrollBloc>().add(
              PostPayrollEvent(usrName, selectedRecords),
            );
            setState(() {
              _selectedIds.clear();
              _selectAll = false;
            });
          },
        );
      },
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
      _selectAll = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthenticatedState) {
      return const SizedBox();
    }

    final usrName = authState.loginData.usrName;

    return Scaffold(
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr.payRoll, style: textTheme.titleLarge),
                    BlocBuilder<PayrollBloc, PayrollState>(
                      builder: (context, state) {
                        final payroll = state.payroll;
                        final unpaidCount = payroll
                            .where((r) => (r.payment ?? 0) == 0)
                            .length;
                        return Text(
                          '${_selectedIds.length} ${tr.selected} | $unpaidCount ${tr.unpaidTitle}',
                          style: textTheme.bodySmall?.copyWith(
                            color: color.outline.withValues(alpha: .9),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Clear Selection
                    if (_selectedIds.isNotEmpty)
                      ZOutlineButton(
                        height: 45,
                        isActive: true,
                        backgroundHover: Theme.of(context).colorScheme.error,
                        icon: Icons.clear,
                        onPressed: _clearSelection,
                        label: Text(tr.clear),
                      ),
                    const SizedBox(width: 8),
                    // Select All
                    BlocBuilder<PayrollBloc, PayrollState>(
                      builder: (context, state) {
                        final payroll = state.payroll;
                        final unpaidCount = payroll
                            .where((r) => (r.payment ?? 0) == 0)
                            .length;
                        final allSelected =
                            unpaidCount > 0 &&
                            _selectedIds.length == unpaidCount;

                        return ZOutlineButton(
                          height: 45,
                          icon: allSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          onPressed: unpaidCount > 0
                              ? () => _toggleSelectAll(payroll)
                              : null,
                          label: Text(
                            allSelected ? tr.disselect : tr.selectAll,
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 8),

                    // Payment Button
                    BlocBuilder<PayrollBloc, PayrollState>(
                      builder: (context, state) {
                        return ZOutlineButton(
                          height: 45,
                          icon: Icons.payment_rounded,
                          onPressed: _selectedIds.isNotEmpty
                              ? () => _postSelectedPayroll(
                                  context,
                                  usrName!,
                                  state.payroll,
                                )
                              : null,
                          label: Text(tr.postSalary),
                        );
                      },
                    ),

                    const SizedBox(width: 8),

                    // Refresh Button
                    ZOutlineButton(
                      height: 45,
                      isActive: true,
                      icon: Icons.refresh,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => MonthYearPicker(
                            onMonthYearSelected: (date) {
                              context.read<PayrollBloc>().add(
                                LoadPayrollEvent(date),
                              );
                              _clearSelection();
                            },
                            initialDate: DateTime.now(),
                            minYear: 2020,
                            maxYear: 2200,
                            disablePastDates: false,
                          ),
                        );
                      },
                      label: Text(tr.loadPayroll),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: .9),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    tr.date,
                    style: textTheme.titleSmall?.copyWith(color: color.surface),
                  ),
                ),
                Expanded(
                  child: Text(
                    tr.employees,
                    style: textTheme.titleSmall?.copyWith(color: color.surface),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    tr.salaryBase,
                    style: textTheme.titleSmall?.copyWith(color: color.surface),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    tr.baseHours,
                    style: textTheme.titleSmall?.copyWith(color: color.surface),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    tr.workedDays,
                    style: textTheme.titleSmall?.copyWith(color: color.surface),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    tr.salaryAmount,
                    style: textTheme.titleSmall?.copyWith(color: color.surface),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    tr.overtime,
                    style: textTheme.titleSmall?.copyWith(color: color.surface),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    tr.totalPayable,
                    style: textTheme.titleSmall?.copyWith(color: color.surface),
                  ),
                ),
                SizedBox(
                  width: 105,
                  child: Text(
                    tr.status,
                    style: textTheme.titleSmall?.copyWith(color: color.surface),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Payroll List
          Expanded(
            child: BlocConsumer<PayrollBloc, PayrollState>(
              listener: (context, state) {
                if (state is PayrollSuccessState) {
                  ToastManager.show(
                    context: context,
                    title: tr.successTitle,
                    message: state.message,
                    type: ToastType.success,
                  );
                }
                if (state is PayrollErrorState && state.message.isNotEmpty) {
                  ToastManager.show(
                    context: context,
                    title: tr.operationFailedTitle,
                    message: state.message,
                    type: ToastType.error,
                  );
                }
              },
              builder: (context, state) {
                final payroll = state.payroll;

                if (payroll.isEmpty && state is! PayrollLoadingState) {
                  return NoDataWidget(
                    title: tr.noData,
                    message: tr.noDataFound,
                    enableAction: false,
                  );
                }

                if (state is PayrollLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Stack(
                  children: [
                    ListView.builder(
                      itemCount: payroll.length,
                      itemBuilder: (context, index) {
                        final record = payroll[index];
                        final isPaid = (record.payment ?? 0) == 1;
                        final isSelected = _selectedIds.contains(record.perId);

                        return InkWell(
                          hoverColor: color.surface,
                          splashColor: color.surface,
                          highlightColor: color.surface,
                          onTap: () => _toggleRecordSelection(record.perId!, isPaid),
                          onLongPress: () => _toggleRecordSelection(record.perId!, isPaid),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.primary.withValues(alpha: .03)
                                  : index.isEven
                                  ? color.primary.withValues(alpha: .03)
                                  : Colors.transparent,
                              border: isSelected
                                  ? Border.all(
                                      color: color.primary.withValues(
                                        alpha: .2,
                                      ),
                                      width: 1,
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Row(
                              children: [
                                // Checkbox
                                SizedBox(
                                  width: 25,
                                  child: Center(
                                    child: Checkbox(
                                      visualDensity: VisualDensity(
                                        horizontal: -4,
                                        vertical: -4,
                                      ),
                                      value: isSelected,
                                      onChanged: isPaid
                                          ? null
                                          : (value) => _toggleRecordSelection(
                                              record.perId!,
                                              isPaid,
                                            ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: 5),
                                // Date
                                SizedBox(
                                  width: 80,
                                  child: Text(record.monthYear ?? ''),
                                ),

                                // Employee
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(record.fullName ?? ''),
                                      Text(
                                        '${record.salaryAccount}',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: color.outline.withValues(
                                            alpha: .7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Salary Base
                                SizedBox(
                                  width: 120,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        record.salary.toAmount(),
                                        style: textTheme.titleSmall,
                                      ),
                                      Text(
                                        record.currency ?? '',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: color.outline.withValues(
                                            alpha: .7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Base Hours
                                SizedBox(
                                  width: 120,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${double.tryParse(record.hoursInMonth ?? '0')?.toStringAsFixed(1) ?? '0.0'} hr',
                                        style: textTheme.titleSmall,
                                      ),
                                      Text(
                                        record.calculationBase ?? '',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: color.outline.withValues(
                                            alpha: .7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Worked Days
                                SizedBox(
                                  width: 120,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${record.totalDays ?? 0} days',
                                        style: textTheme.titleSmall,
                                      ),
                                      Text(
                                        '${double.tryParse(record.workedHours ?? '0')?.toStringAsFixed(1) ?? '0.0'} hr',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: color.outline.withValues(
                                            alpha: .7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Salary Payable
                                SizedBox(
                                  width: 120,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        record.salaryPayable.toAmount(),
                                      ),
                                      Text(
                                        record.currency ?? '',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: color.outline.withValues(
                                            alpha: .7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Overtime
                                SizedBox(
                                  width: 100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        record.overtimePayable.toAmount(),
                                      ),
                                      Text(
                                        record.currency ?? '',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: color.outline.withValues(
                                            alpha: .7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Total Payable
                                SizedBox(
                                  width: 120,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        record.totalPayable.toAmount(),
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        record.currency ?? '',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: color.outline.withValues(
                                            alpha: .7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Status
                                SizedBox(
                                  width: 105,
                                  child: StatusBadge(
                                    status: record.payment ?? 0,
                                    trueValue: tr.paidTitle,
                                    falseValue: tr.unpaidTitle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    if (state is PayrollSilentLoadingState)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
