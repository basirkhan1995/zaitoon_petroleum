import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Attendance/bloc/attendance_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Attendance/time_selector.dart';
import '../../../../../../Features/Date/z_generic_date.dart';
import '../../../../../../Features/Other/attendance_status.dart';
import '../../../../../../Features/Other/toast.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../../Auth/models/login_model.dart';
import 'edit_attendance.dart';
import 'model/attendance_model.dart';

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(),
      tablet: _Desktop(),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, attState) {
                final attendance = attState is AttendanceLoadedState
                    ? attState.attendance
                    : attState is AttendanceSilentLoadingState
                    ? attState.attendance
                    : <AttendanceRecord>[];

                return Row(
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
                        Text(date.compact, style: subtitle),
                      ],
                    ),
                    Row(
                      children: [
                        if (attendance.isNotEmpty)
                          AttendanceSummary(attendance: attendance),
                        const SizedBox(width: 3),
                        SizedBox(
                          width: 160,
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
                        if(login.hasPermission(106) ?? false)...[
                          const SizedBox(width: 8),
                          ZOutlineButton(
                            height: 46,
                            isActive: true,
                            onPressed: () => addAttendance(tr),
                            icon: Icons.add,
                            label: Text(tr.addAttendance),
                          )
                        ],

                      ],
                    ),
                  ],
                );
              },
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
            child: BlocConsumer<AttendanceBloc, AttendanceState>(
              listener: (BuildContext context, AttendanceState state) {
                if (state is AttendanceErrorState) {
                  Utils.showOverlayMessage(context,
                      message: state.message, isError: true);
                }
              },
              builder: (context, state) {
                if (state is AttendanceLoadingState) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (state is AttendanceErrorState) {
                  return NoDataWidget(
                    title: tr.accessDenied,
                    message: state.message,
                    onRefresh: () {
                      context.read<AttendanceBloc>().add(
                          LoadAllAttendanceEvent());
                    },
                  );
                }

                final attendance = state is AttendanceLoadedState
                    ? state.attendance
                    : state is AttendanceSilentLoadingState
                    ? state.attendance
                    : <AttendanceRecord>[];

                if (attendance.isEmpty) {
                  return NoDataWidget(
                    title: tr.noDataFound,
                    message: "${tr.noAttendance} - ${date.compact}",
                    enableAction: false,
                  );
                }
                return Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: attendance.length,
                            itemBuilder: (context, index) {
                              final at = attendance[index];
                              return InkWell(
                                onTap: login.hasPermission(108) ?? false ? () => _editAttendance(at, tr) : null,
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
                    ),

                    if (state is AttendanceSilentLoadingState)
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

  void addAttendance(AppLocalizations tr) {
    String? checkIn;
    String? checkOut;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocListener<AttendanceBloc, AttendanceState>(
          listenWhen: (prev, curr) =>
          curr is AttendanceSuccessState || curr is AttendanceErrorState,
          listener: (context, state) {
            /// ✅ CLOSE dialog on success
            if (state is AttendanceLoadedState) {
              Navigator.pop(dialogContext);
            }

            if (state is AttendanceSuccessState) {
              Navigator.pop(dialogContext);
              Utils.showOverlayMessage(context, title: tr.successTitle, message: state.message, isError: false);
            }

            /// ❌ Keep dialog open on error
            if (state is AttendanceErrorState) {
              ToastManager.show(
                context: context,
                title: tr.operationFailedTitle,
                message: state.message,
                type: ToastType.error,
                durationInSeconds: 4,
              );
            }
          },
          child: ZFormDialog(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            icon: Icons.access_time,
            title: tr.addAttendance,
            width: 500,
            onAction: () {
              context.read<AttendanceBloc>().add(
                AddAttendanceEvent(
                  usrName: usrName ?? "",
                  checkIn: checkIn ?? "08:00:00",
                  checkOut: checkOut ?? "16:00:00",
                  date: date,
                ),
              );
            },

            actionLabel: BlocBuilder<AttendanceBloc, AttendanceState>(
              buildWhen: (prev, curr) =>
              curr is AttendanceSilentLoadingState ||
                  curr is AttendanceLoadedState ||
                  curr is AttendanceErrorState,
              builder: (context, state) {
                final isLoading = state is AttendanceSilentLoadingState;

                if (isLoading) {
                  return const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                return Text(tr.submit);
              },
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ZDatePicker(
                    label: tr.date,
                    value: date,
                    onDateChanged: (v) {
                      setState(() => date = v);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TimePickerField(
                  label: tr.checkIn,
                  initialTime: '08:00:00',
                  onChanged: (time) => checkIn = time,
                ),
                const SizedBox(height: 12),
                TimePickerField(
                  label: tr.checkOut,
                  initialTime: '16:00:00',
                  onChanged: (time) => checkOut = time,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editAttendance(AttendanceRecord record, AppLocalizations tr) {
    showDialog(
      context: context,
      builder: (context) {
        return EditAttendanceDialog(
          record: record,
          currentDate: date,
        );
      },
    );
  }

}


class AttendanceSummary extends StatelessWidget {
  final List<AttendanceRecord> attendance;

  const AttendanceSummary({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildCard(context, tr.presentTitle, attendance.present, Colors.green),
          _buildCard(context, tr.lateTitle, attendance.late, Colors.orange),
          _buildCard(context, tr.absentTitle, attendance.absent, Colors.red),
          _buildCard(context, tr.leaveTitle, attendance.leave, Colors.blue),
          _buildCard(
            context,
            tr.totalTitle,
            attendance.length,
            Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      BuildContext context,
      String title,
      int value,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w500, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
