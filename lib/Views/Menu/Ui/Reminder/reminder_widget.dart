import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';

import 'bloc/reminder_bloc.dart';
import 'model/reminder_model.dart';


class DashboardAlertReminder extends StatefulWidget {
  const DashboardAlertReminder({super.key});

  @override
  State<DashboardAlertReminder> createState() =>
      _DashboardAlertReminderState();
}

class _DashboardAlertReminderState extends State<DashboardAlertReminder> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderBloc>().add(const LoadAlertReminders());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        double totalDue = state.reminders.fold(
          0, (sum, e) =>
          sum + (double.tryParse(e.rmdAmount ?? "0") ?? 0),
        );

        return Stack(
          children: [
            ZCover(
              radius: 6,
              margin: const EdgeInsets.all(3),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// HEADER
                    Row(
                      children: [

                        /// Alert Icon
                        Icon(Icons.notifications_active,
                            color: Theme.of(context).colorScheme.error),

                        const SizedBox(width: 8),

                        Text(
                          AppLocalizations.of(context)!.reminders,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const Spacer(),

                        /// Total Amount
                        ZCover(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                           radius: 8,
                          child: Text(
                            totalDue.toAmount(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// EMPTY
                    if (state.reminders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          AppLocalizations.of(context)!.noAlertReminders,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),

                    /// LIST
                    ...state.reminders.map((e) {
                      return _ReminderTile(model: e);
                    }),
                  ],
                ),
              ),
            ),

            /// Loading overlay
            if (state.loading)
              Positioned.fill(
                child: Container(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: .05),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }
}
class _ReminderTile extends StatelessWidget {
  final ReminderModel model;

  const _ReminderTile({required this.model});

  String _formatDate(DateTime? date) {
    if (date == null) return "";
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {

    final isPaid = model.rmdStatus == 1;

    return ZCover(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      radius: 8,
      child: Row(
        children: [

          /// LEFT SIDE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Customer
                Text(
                  model.fullName ?? "",
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 3),

                /// Details
                Text(
                  model.rmdDetails ?? "",
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                const SizedBox(height: 6),

                /// Account + Date Row
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        size: 14,
                        color: Theme.of(context).hintColor),

                    const SizedBox(width: 4),

                    Text(
                      "${model.rmdAccount}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(width: 15),

                    Icon(Icons.calendar_today_outlined,
                        size: 14,
                        color: Theme.of(context).hintColor),

                    const SizedBox(width: 4),

                    Text(
                      _formatDate(model.rmdAlertDate),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(width: 15),
                    Icon(Icons.access_time_rounded,
                        size: 14,
                        color: Theme.of(context).hintColor),

                    const SizedBox(width: 4),
                    Text(
                        model.rmdAlertDate?.toDueStatus() ?? "",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// RIGHT SIDE
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              /// Amount
              Text(
                (model.rmdAmount ?? "0").toAmount(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              /// STATUS CHECK BUTTON
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {

                  final updated = model.copyWith(
                    rmdStatus: isPaid ? 0 : 1,
                  );

                  context
                      .read<ReminderBloc>()
                      .add(UpdateReminderEvent(updated));
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPaid
                        ? Colors.green.withValues(alpha: .15)
                        : Colors.grey.withValues(alpha: .15),
                  ),
                  child: Icon(
                    isPaid
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isPaid
                        ? Colors.green
                        : Theme.of(context).colorScheme.outline,
                    size: 20,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}


// onPressed: () {
// /// mark reminder as completed
// final updated = model.copyWith(rmdStatus: 1);
//
// context.read<ReminderBloc>()
//     .add(UpdateReminderEvent(updated));
// },