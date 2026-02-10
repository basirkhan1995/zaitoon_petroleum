import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
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
        mobile: _Mobile(), tablet: _Tablet(), desktop: _Desktop());
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
    String? usrName;
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    TextStyle? titleStyle = Theme.of(context).textTheme.titleSmall;
    TextStyle? headerTitle =
    Theme.of(context).textTheme.titleSmall?.copyWith(
      color: color.surface,
    );
    TextStyle? subtitle =
    Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: color.outline.withValues(alpha: .9),
    );

    final state = context.watch<AuthBloc>().state;
    if (state is! AuthenticatedState) {
      return const SizedBox();
    }

    usrName = state.loginData.usrName;
    return Scaffold(
      body: Column(
        children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr.payRoll,
                  style:
                  Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            Row(
              children: [
                ZOutlineButton(
                  height: 46,
                  icon: Icons.payments_outlined,
                  onPressed: (){
                   /// Here to post payroll to their accounts
                  },
                  label: Text(tr.payment),
                ),

                const SizedBox(width: 8),

                ZOutlineButton(
                  height: 46,
                  isActive: true,
                  icon: Icons.refresh,
                  onPressed: (){
                    showDialog(context: context, builder: (context){
                      return MonthYearPicker(
                        onMonthYearSelected: (date) {
                          context.read<PayrollBloc>().add(LoadPayrollEvent(date));
                        },
                        initialDate: DateTime.now(),
                        minYear: 2020,
                        maxYear: 2200,
                        disablePastDates: true,
                      );
                    });
                  },
                  label: Text(tr.loadPayroll),
                )
              ],
            ),
          ],
                ),
        ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: .9),
            ),
            child: Row(
              children: [
                SizedBox(
                    width: 80,
                    child: Text(tr.date, style: headerTitle)),
                Expanded(
                    child:
                    Text(tr.employees, style: headerTitle)),
                SizedBox(
                    width: 120,
                    child: Text(tr.salaryBase, style: headerTitle)),
                SizedBox(
                    width: 120,
                    child: Text(tr.baseHours, style: headerTitle)),
                SizedBox(
                    width: 120,
                    child: Text(tr.workedDays, style: headerTitle)),
                SizedBox(
                    width: 120,
                    child: Text(tr.salaryAmount, style: headerTitle)),
                SizedBox(
                    width: 120,
                    child: Text(tr.overtime, style: headerTitle)),
                SizedBox(
                    width: 120,
                    child: Text(tr.totalPayable, style: headerTitle)),
                SizedBox(
                    width: 90,
                    child: Text(tr.status, style: headerTitle)),
              ],
            ),
          ),
          SizedBox(height: 5),
          Expanded(
            child: BlocConsumer<PayrollBloc, PayrollState>(
              listener: (context, state) {},
              builder: (context, payState) {

                final payroll = payState is PayrollLoadedState
                    ? payState.attendance
                    : payState is PayrollSilentLoadingState
                    ? payState.attendance
                    : <PayrollModel>[];
                if (payroll.isEmpty) {
                  return NoDataWidget(
                    title: tr.noData,
                    message: tr.noDataFound,
                    enableAction: false,
                  );
                }

                if (payState is PayrollLoadingState) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (payState is PayrollErrorState) {
                  return NoDataWidget(
                    title: tr.accessDenied,
                    message: payState.message,
                    onRefresh: () {
                      context.read<PayrollBloc>().add(LoadPayrollEvent(""));
                    },
                  );
                }

                return Stack(
                  children: [

                    //Payroll Data here
                    Column(
                      children: [
                       Expanded(
                         child: ListView.builder(
                             itemCount: payroll.length,
                             itemBuilder: (context,index){
                             final py = payroll[index];
                               return Container(
                                 padding: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                                 margin: EdgeInsets.symmetric(horizontal: 5),
                                 decoration: BoxDecoration(
                                   color: index.isEven ? Theme.of(context).colorScheme.primary.withValues(alpha: .05) : Colors.transparent
                                 ),
                                 child: Row(
                                 children: [
                                   SizedBox(
                                       width: 80,
                                       child: Text(py.monthYear.toString())),
                                   Expanded(child: Column(
                                     mainAxisAlignment: MainAxisAlignment.start,
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text(py.fullName??""),
                                       Text(py.salaryAccount.toString())
                                     ],
                                   )),
                                   SizedBox(
                                       width: 120,
                                       child: Text("${py.salary.toAmount()} ${py.currency}",style: titleStyle)),
                                   SizedBox(
                                       width: 120,
                                       child: Column(
                                         mainAxisAlignment: MainAxisAlignment.start,
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Text("${py.hoursInMonth.toAmount(decimal: 2)} hr",style: titleStyle),
                                           Text(py.calculationBase.toString(),style: subtitle?.copyWith(fontSize: 12))
                                         ],
                                       )),
                                   SizedBox(
                                       width: 120,
                                       child: Column(
                                         mainAxisAlignment: MainAxisAlignment.start,
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Text("${py.totalDays.toAmount(decimal: 0)} days",style: titleStyle),
                                           Text("${py.workedHours.toAmount(decimal: 2)} hr",style: subtitle?.copyWith(fontSize: 12))
                                         ],
                                       )),

                                   SizedBox(
                                       width: 120,
                                       child: Text("${py.salaryPayable.toAmount()} ${py.currency}")),
                                   SizedBox(
                                       width: 120,
                                       child: Text("${py.overtimePayable.toAmount()} ${py.currency}")),
                                   SizedBox(
                                       width: 120,
                                       child: Text("${py.totalPayable.toAmount()} ${py.currency}",style: titleStyle)),
                                   SizedBox(
                                       width: 90,
                                       child: StatusBadge(status: py.payment!,trueValue: tr.paidTitle,falseValue: tr.unpaidTitle)),
                                 ],
                                                              ),
                               );
                         }),
                       ),
                      ],
                    ),

                    if (payState is PayrollSilentLoadingState)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .3),
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface,
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

