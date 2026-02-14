
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Attendance/features/status_selector.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/HR/AttendanceReport/bloc/attendance_report_bloc.dart';
import '../../../../../../../Features/Date/z_generic_date.dart';
import '../../../../../../../Features/Other/attendance_status.dart';
import '../../../../../../../Features/Other/utils.dart';
import '../../../../../../../Features/Widgets/no_data_widget.dart';
import '../../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../HR/Ui/Attendance/bloc/attendance_bloc.dart';


class AttendanceReportView extends StatelessWidget {
  const AttendanceReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), tablet: _Tablet(), desktop: _Desktop());
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
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  late String fromDate;
  late String toDate;
  int? status;
  int? empId;
  @override
  void initState() {
    fromDate = DateTime.now().toFormattedDate();
    toDate = DateTime.now().toFormattedDate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceReportBloc>().add(ResetAttendanceReportEvent());
    });
    super.initState();
  }
  String? usrName;
  @override
  Widget build(BuildContext context) {
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

    final login = state.loginData;
    usrName = state.loginData.usrName;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.attendance),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr.attendance,
                  style:
                  Theme.of(context).textTheme.titleMedium,
                ),
                Text(fromDate.compact, style: subtitle),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                    width: 200,
                    child: AttendanceDropdown(
                        onStatusSelected: (e){
                          setState(() {

                          });
                        })),
                SizedBox(width: 5),
                SizedBox(
                  width: 160,
                  child: ZDatePicker(
                    label: tr.fromDate,
                    value: fromDate,
                    onDateChanged: (v) {
                      setState(() {
                        fromDate = v;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 160,
                  child: ZDatePicker(
                    label: tr.toDate,
                    value: toDate,
                    onDateChanged: (v) {
                      setState(() {
                        toDate = v;
                      });
                      context.read<AttendanceReportBloc>().add(
                        LoadAttendanceReportEvent(fromDate: fromDate,toDate: toDate),
                      );
                    },
                  ),
                ),
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
                    width: 100,
                    child: Text(tr.date, style: headerTitle)),
                Expanded(
                    child:
                    Text(tr.employeeName, style: headerTitle)),
                SizedBox(
                    width: 100,
                    child: Text(tr.checkIn, style: headerTitle)),
                SizedBox(
                    width: 100,
                    child: Text(tr.checkOut, style: headerTitle)),
                SizedBox(
                    width: 100,
                    child: Text(tr.status, style: headerTitle)),
              ],
            ),
          ),
          SizedBox(height: 5),
          Expanded(
            child: BlocConsumer<AttendanceReportBloc, AttendanceReportState>(
              listener: (BuildContext context, AttendanceReportState state) {
                if (state is AttendanceReportErrorState) {
                  Utils.showOverlayMessage(context,
                      message: state.error??"", isError: true);
                }
              },
              builder: (context, state) {
                if (state is AttendanceLoadingState) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (state is AttendanceReportErrorState) {
                  return NoDataWidget(
                    title: tr.accessDenied,
                    message: state.error,
                    onRefresh: () {
                      context.read<AttendanceReportBloc>().add(
                          LoadAttendanceReportEvent(fromDate: fromDate, toDate: toDate,status: status,empId: empId));
                    },
                  );
                }
                if(state is AttendanceReportInitial){
                  return NoDataWidget(
                    title: tr.attendance,
                    message: "Search for employees attendance here",
                    enableAction: false,
                  );
                }

                if(state is AttendanceReportLoadedState){
                 return Column(
                   children: [
                     Expanded(
                       child: ListView.builder(
                         itemCount: state.attendance.length,
                         itemBuilder: (context, index) {
                           final at = state.attendance[index];
                           return InkWell(
                             child: Container(
                               padding: const EdgeInsets.symmetric(
                                   vertical: 8, horizontal: 5),
                               margin:
                               const EdgeInsets.symmetric(horizontal: 5),
                               decoration: BoxDecoration(
                                 color: index.isEven
                                     ? Theme.of(context)
                                     .colorScheme
                                     .primary
                                     .withValues(alpha: .05)
                                     : Colors.transparent,
                               ),
                               child: Row(
                                 crossAxisAlignment:
                                 CrossAxisAlignment.start,
                                 children: [
                                   SizedBox(
                                       width: 100,
                                       child:
                                       Text(at.emaDate.compact)),
                                   Expanded(
                                     child: Column(
                                       crossAxisAlignment:
                                       CrossAxisAlignment.start,
                                       children: [
                                         Text(at.fullName ?? "",
                                             style: titleStyle),
                                         Text(at.empPosition ?? "",
                                             style: subtitle),
                                       ],
                                     ),
                                   ),
                                   SizedBox(
                                       width: 100,
                                       child: Text(
                                           at.emaCheckedIn ?? "")),
                                   SizedBox(
                                       width: 100,
                                       child: Text(
                                           at.emaCheckedOut ?? "")),
                                   SizedBox(
                                     width: 100,
                                     child: AttendanceStatusBadge(
                                       status: at.emaStatus ?? "",
                                     ),
                                   ),
                                 ],
                               ),
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
          ),
        ],
      ),
    );
  }

}
