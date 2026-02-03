import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';

import '../../../../Features/Other/extensions.dart';
import '../../../../Features/Widgets/outline_button.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import 'add_edit_reminders.dart';
import 'bloc/reminder_bloc.dart';

class ReminderView extends StatelessWidget {
  const ReminderView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), desktop: _Desktop(), tablet: _Tablet(),);
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
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<ReminderBloc>().add(LoadAlertReminders(alert: 0));
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      body: ZCover(
        radius: 5,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
        child: Column(
          children: [

            /// HEADER
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Text(
                    locale.reminders,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),

                  /// Refresh
                  ZOutlineButton(
                    width: 110,
                    height: 35,
                    icon: Icons.refresh,
                    label: Text(locale.refresh),
                    onPressed: () {
                      context.read<ReminderBloc>().add(LoadAlertReminders(alert: 0));
                    },
                  ),

                  const SizedBox(width: 5),

                  /// New Reminder
                  ZOutlineButton(
                    width: 110,
                    height: 35,
                    icon: Icons.add,
                    isActive: true,
                    label: Text(locale.newKeyword),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AddEditReminderView(),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(),

            /// LIST
            Expanded(
              child: BlocBuilder<ReminderBloc, ReminderState>(
                builder: (context, state) {

                  if (state.loading && state.reminders.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.reminders.isEmpty) {
                    return const Center(child: Text("No Reminders"));
                  }

                  return ListView.builder(
                    itemCount: state.reminders.length,
                    itemBuilder: (_, i) {
                      final r = state.reminders[i];

                      final isOverdue = r.rmdAlertDate != null &&
                          r.rmdAlertDate!.isBefore(DateTime.now());

                      return Material(
                        child: InkWell(
                          highlightColor: Theme.of(context).colorScheme.surface,
                          hoverColor: Theme.of(context).colorScheme.surface,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  AddEditReminderView(r: r),
                            );
                          },
                          child: ZCover(
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        color: Theme.of(context).colorScheme.surface,
                        borderColor: isOverdue
                            ? Colors.red.withValues(alpha: .4)
                            : Theme.of(context).colorScheme.outline.withValues(alpha: .2),
                        radius: 5,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AddEditReminderView(r: r),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                /// ICON
                                Icon(
                                  isOverdue
                                      ? Icons.warning_rounded
                                      : Icons.notifications_active_outlined,
                                  color: isOverdue
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).colorScheme.primary,
                                  size: 26,
                                ),

                                const SizedBox(width: 10),

                                /// MAIN CONTENT
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.rmdName ?? "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        r.fullName ?? "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(fontWeight: FontWeight.w600),
                                      ),

                                      if ((r.rmdDetails ?? "").isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            r.rmdDetails!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ),

                                      const SizedBox(height: 6),

                                      /// DUE STATUS
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.account_circle_outlined,size:  15,color: Theme.of(context).colorScheme.outline),
                                          SizedBox(width: 3),
                                          Text(
                                            r.rmdAccount.toString(),
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: isOverdue ?Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline,
                                            ),
                                          ),

                                          SizedBox(width: 5),

                                          Icon(Icons.date_range,size:  15,color: Theme.of(context).colorScheme.outline),
                                          SizedBox(width: 3),
                                          Text(
                                            r.rmdAlertDate?.toDateString ?? "",
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: isOverdue ?Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline,
                                            ),
                                          ),

                                          SizedBox(width: 5),

                                          Icon(Icons.access_time,size:  15,color: Theme.of(context).colorScheme.outline),
                                          SizedBox(width: 3),
                                          Text(
                                            r.rmdAlertDate?.toDueStatus() ?? "",
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: isOverdue ?Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                /// TRAILING (AMOUNT + CHECK)
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if ((r.rmdAmount ?? "").isNotEmpty)
                                      Text(
                                        "${r.rmdAmount.toAmount()} ${r.currency}",
                                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          color: Theme.of(context).colorScheme.error,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                    Checkbox(
                                      value: r.rmdStatus == 1,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      onChanged: (_) {
                                        context.read<ReminderBloc>().add(
                                          UpdateReminderEvent(
                                            r.copyWith(rmdStatus: 0),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


