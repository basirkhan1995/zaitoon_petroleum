import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'bloc/dashboard_stats_bloc.dart';

class DashboardStatsView extends StatelessWidget {
  const DashboardStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), desktop: _Desktop(),tablet: _Tablet(),);
  }
}
class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: _StatsContent(),
    );
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: _StatsContent(),
    );
  }
}

class _Desktop extends StatelessWidget {
  const _Desktop();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(5),
      child: _StatsContent(),
    );
  }
}


class _StatsContent extends StatelessWidget {
  const _StatsContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tr = AppLocalizations.of(context)!;
    return BlocBuilder<DashboardStatsBloc, DashboardStatsState>(
      builder: (context, state) {
        if (state is DashboardStatsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DashboardStatsError) {
          return Center(child: Text(state.message));
        }

        if (state is DashboardStatsLoaded) {
          final stats = state.stats;

          final data = [
            {
              "title": tr.users,
              "value": stats.usersCount,
              "color": theme.colorScheme.primary,
              "icon": Icons.person,
            },
            {
              "title": tr.employees,
              "value": stats.employeesCount,
              "color": Colors.green,
              "icon": Icons.badge,
            },
            {
              "title": tr.accounts,
              "value": stats.accountsCount,
              "color": Colors.orange,
              "icon": Icons.account_balance,
            },
            {
              "title": tr.stakeholders,
              "value": stats.personalsCount,
              "color": Colors.teal,
              "icon": Icons.people,
            },
          ];

          final filtered =
          data.where((e) => (e['value'] as int) > 0).toList();

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: filtered.map((item) {
              final color = item['color'] as Color;

              return Container(
                width: 135,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withValues(alpha: .3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 35,
                          color: color.withValues(alpha: .4),
                        ),
                        Text(
                          item['value'].toString(),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Directionality.of(context) ==
                          TextDirection.ltr
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Text(
                        item['title'].toString(),
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }

        return const SizedBox();
      },
    );
  }
}
