import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/UserDetail/Ui/Log/bloc/user_log_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../../../Features/Date/z_generic_date.dart';
import '../../../HR/Ui/Users/features/date_range_string.dart';
import '../../../HR/Ui/Users/features/users_drop.dart';

class UserLogReportView extends StatelessWidget {
  final String? usrName;
  const UserLogReportView({super.key, this.usrName});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(usrName),
      tablet: _Tablet(),
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

class _Desktop extends StatefulWidget {
  final String? usrName;
  const _Desktop(this.usrName);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  String fromDate = DateTime.now().toFormattedDate();
  String toDate = DateTime.now().toFormattedDate();
  Jalali shamsiFromDate = DateTime.now().toAfghanShamsi;
  Jalali shamsiToDate = DateTime.now().toAfghanShamsi;
  String? usrName;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserLogBloc>().add(
        LoadUserLogEvent(usrName: usrName, fromDate: fromDate, toDate: toDate),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 8,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: color.surface,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: color.outline.withValues(alpha: .9),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.userLog,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        tr.userLogActivity,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: UserDropdown(
                    title: tr.users,
                    isMulti: false,
                    onMultiChanged: (_) {},
                    onSingleChanged: (user) {
                      usrName = user?.usrName ?? "";
                    },
                  ),
                ),

                SizedBox(
                  width: 200,
                  child: DateRangeDropdown(
                    onChanged: (fromDate, toDate) {
                      context.read<UserLogBloc>().add(
                        LoadUserLogEvent(
                          usrName: usrName,
                          fromDate: fromDate,
                          toDate: toDate,
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(
                  width: 150,
                  child: ZDatePicker(
                    label: tr.fromDate,
                    value: fromDate,
                    onDateChanged: (v) {
                      setState(() {
                        fromDate = v;
                        shamsiFromDate = v.toAfghanShamsi;
                      });
                    },
                  ),
                ),

                SizedBox(
                  width: 150,
                  child: ZDatePicker(
                    label: tr.toDate,
                    value: toDate,
                    onDateChanged: (v) {
                      setState(() {
                        toDate = v;
                        shamsiToDate = v.toAfghanShamsi;
                      });
                    },
                  ),
                ),

                ZOutlineButton(
                  height: 40,
                  width: 100,
                  icon: Icons.folder_open_rounded,
                  isActive: true,
                  label: Text(tr.apply),
                  onPressed: () {
                    context.read<UserLogBloc>().add(
                      LoadUserLogEvent(
                        usrName: usrName,
                        fromDate: fromDate,
                        toDate: toDate,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<UserLogBloc, UserLogState>(
              builder: (context, state) {
                if (state is UserLogLoadingState) {
                  return Center(child: CircularProgressIndicator());
                }
                if (state is UserLogErrorState) {
                  return NoDataWidget(
                    message: state.error,
                    onRefresh: () {
                      context.read<UserLogBloc>().add(
                        LoadUserLogEvent(usrName: widget.usrName),
                      );
                    },
                  );
                }
                if (state is UserLogLoadedState) {
                  if (state.log.isEmpty) {
                    return NoDataWidget(message: tr.noDataFound);
                  }
                  return ListView.builder(
                    itemCount: state.log.length,
                    itemBuilder: (context, index) {
                      final log = state.log[index];
                      return Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        margin: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: color.outline.withValues(alpha: .15),
                          ),
                          color: color.surface,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 8,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  child: Text(
                                    log.usrName?.getFirstLetter ?? "",
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        spacing: 5,
                                        children: [
                                          Text(
                                            log.usrName ?? "",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleSmall,
                                          ),

                                          Text(
                                            log.ualIp ?? "",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: color.outline,
                                                ),
                                          ),

                                          Text(
                                            log.ualDevice ?? "",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                              color: color.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        log.usrRole ?? "",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  log.fullName?? "",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.outline),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              spacing: 5,
                              children: [
                                Text(
                                  log.ualType ?? "",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall?.copyWith(fontSize: 12),
                                ),
                                Text(
                                  log.ualDetails ?? "",
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                    color: color.outline.withValues(alpha: .8),
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    spacing: 5,
                                    children: [
                                      Text(
                                        log.ualTiming?.toDateTime ?? "",
                                        style: Theme.of(context).textTheme.bodySmall
                                            ?.copyWith(color: color.primary),
                                      ),
                                      Text(
                                        log.ualTiming!.toTimeAgo(),
                                        style: Theme.of(context).textTheme.bodySmall
                                            ?.copyWith(color: color.outline),
                                      ),
                                    ],
                                  ),
                                ),
                                ZCard(
                                  radius: 3,
                                  padding: EdgeInsets.all(2),
                                  color: color.surface,
                                  child: Row(
                                    spacing: 5,
                                    children: [
                                      Text(
                                        tr.usrId,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      Text(
                                        log.usrId.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: color.outline),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 5),
                                ZCard(
                                  radius: 3,
                                  padding: EdgeInsets.all(2),
                                  color: color.surface,
                                  child: Row(
                                    spacing: 5,
                                    children: [
                                      Text(
                                        tr.branch,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      Text(
                                        log.usrBranch.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: color.outline),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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


}
