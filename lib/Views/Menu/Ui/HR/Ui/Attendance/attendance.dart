import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Attendance/bloc/attendance_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Attendance/model/attendance_model.dart';
import '../../../../../../Features/Date/z_generic_date.dart';
import '../../../../../../Features/Other/attendance_status.dart';

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(),
      tablet: _Tablet(),
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
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  late String date;
  @override
  void initState() {
    date = DateTime.now().toFormattedDate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceBloc>().add(LoadAllAttendanceEvent());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    TextStyle? titleStyle = Theme.of(context).textTheme.titleSmall;
    TextStyle? headerTitle = Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(color: color.surface);
    TextStyle? subtitle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: color.outline.withValues(alpha: .9),
    );
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.attendance,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(date.compact, style: subtitle),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: ZDatePicker(
                        label: "",
                        value: date,
                        onDateChanged: (v) {
                          setState(() {
                            date = v;
                          });
                          context.read<AttendanceBloc>().add(
                            LoadAllAttendanceEvent(date: date),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    ZOutlineButton(
                        height: 46,
                        isActive: true,
                        icon: Icons.add,
                        label: Text("${tr.newKeyword} ${tr.attendance}"))
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: .9),
            ),
            child: Row(
              children: [
                SizedBox(width: 100, child: Text(tr.date, style: headerTitle)),
                Expanded(child: Text(tr.employeeName, style: headerTitle)),
                SizedBox(
                  width: 100,
                  child: Text(tr.checkIn, style: headerTitle),
                ),

                SizedBox(
                  width: 100,
                  child: Text(tr.checkOut, style: headerTitle),
                ),

                SizedBox(
                  width: 100,
                  child: Text(tr.status, style: headerTitle),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Expanded(
            child: BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, state) {
                if (state is AttendanceLoadingState) {
                  return Center(child: CircularProgressIndicator());
                }
                if (state is AttendanceErrorState) {
                  return NoDataWidget(
                    title: AppLocalizations.of(context)!.accessDenied,
                    message: state.message,
                    onRefresh: () {
                      context.read<AttendanceBloc>().add(
                        LoadAllAttendanceEvent(),
                      );
                    },
                  );
                }
                if (state is AttendanceLoadedState) {
                  if (state.attendance.isEmpty) {
                    return NoDataWidget(
                      title: AppLocalizations.of(context)!.noDataFound,
                      message: "${tr.noAttendance} - ${date.compact}",
                      enableAction: false,
                    );
                  }
                  return ListView.builder(
                    itemCount: state.attendance.length,
                    itemBuilder: (context, index) {
                      final at = state.attendance[index];
                      return Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 5,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: index.isEven
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: .05)
                              : Colors.transparent,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(at.emaDate.compact),
                            ),

                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(at.fullName ?? "", style: titleStyle),
                                  Text(at.empPosition ?? "", style: subtitle),
                                ],
                              ),
                            ),

                            SizedBox(
                              width: 100,
                              child: Text(at.emaCheckedIn ?? ""),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(at.emaCheckedOut ?? ""),
                            ),
                            SizedBox(
                              width: 100,
                              child: AttendanceStatusBadge(
                                status: at.emaStatus ?? "",
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

  void addAttendance(AppLocalizations tr){
    showDialog(context: context, builder: (context){
      return ZFormDialog(
          onAction: (){
            context.read<AttendanceBloc>().add(AddAttendanceEvent(AttendanceModel(

            )));
          },
          actionLabel: Text(tr.submit),
          title: tr.newKeyword,
        child: Column(
          children: [
            SizedBox(
              width: 200,
              child: ZDatePicker(
                label: "",
                value: date,
                onDateChanged: (v) {
                  setState(() {
                    date = v;
                  });
                  context.read<AttendanceBloc>().add(
                    LoadAllAttendanceEvent(date: date),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
