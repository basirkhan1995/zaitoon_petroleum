import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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


class _Desktop extends StatelessWidget {
  const _Desktop();

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        width: 500,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: .3)),
        ),
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
                      context.read<ReminderBloc>().add(LoadAlertReminders(alert: 1));
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
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  AddEditReminderView(r: r),
                            );
                          },
                          child: ListTile(
                            leading: Icon(
                              isOverdue
                                  ? Icons.warning_rounded
                                  : Icons.notifications_active,
                              color: isOverdue
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.primary,
                            ),
      
                            title: Text(r.fullName ?? ""),
      
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.rmdDetails ?? ""),
                                Text(
                                  r.rmdAlertDate?.toDueStatus() ?? "",
                                  style: TextStyle(
                                    color:
                                    isOverdue ? Colors.red : Colors.grey,
                                  ),
                                )
                              ],
                            ),
      
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  r.rmdAmount ?? "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error),
                                ),
      
                                Checkbox(
                                  value: r.rmdStatus == 1,
                                  onChanged: (_) {
                                    context.read<ReminderBloc>().add(
                                        UpdateReminderEvent(
                                            r.copyWith(rmdStatus: 1)));
                                  },
                                )
                              ],
                            ),
                          ),
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


