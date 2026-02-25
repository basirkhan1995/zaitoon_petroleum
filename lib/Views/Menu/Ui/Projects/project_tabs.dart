import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/AllProjects/model/pjr_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/IncomeExpense/project_inc_exp.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/Overview/project_overview.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/bloc/project_tabs_bloc.dart';
import '../../../../Features/Generic/tab_bar.dart';
import '../../../Auth/bloc/auth_bloc.dart';
import '../../../Auth/models/login_model.dart';
import 'Ui/ProjectServices/project_services.dart';

class ProjectTabsView extends StatelessWidget {
  final ProjectsModel? project;
  const ProjectTabsView({super.key,this.project});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = state.loginData;
    return Scaffold(
      body: BlocBuilder<ProjectTabsBloc, ProjectTabsState>(
        builder: (context, state) {
          final tabs = <ZTabItem<ProjectTabsName>>[
            if (login.hasPermission(55) ?? false)
              ZTabItem(
                value: ProjectTabsName.overview,
                label: tr.overview,
                screen: ProjectOverview(model: project),
              ),
            if (login.hasPermission(34) ?? false)
              ZTabItem(
                value: ProjectTabsName.services,
                label: tr.services,
                screen: ProjectServicesView(project: project),
              ),
            if (login.hasPermission(34) ?? false)
              ZTabItem(
                value: ProjectTabsName.incomeExpense,
                label: tr.incomeAndExpenses,
                screen: ProjectIncomeExpenseView(project: project),
              ),
          ];

          // 🟢 FIX: Handle empty tabs case
          if (tabs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.no_accounts_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.accessDenied,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please contact administrator",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .4),
                    ),
                  ),
                ],
              ),
            );
          }

          // 🟢 FIX: Safely get selected tab with fallback
          final available = tabs.map((t) => t.value).toList();
          final selected = available.contains(state.tabs)
              ? state.tabs
              : tabs.first.value; // Use tabs.first.value instead of available.first

          return ZTabContainer<ProjectTabsName>(
            /// Tab data
            tabs: tabs,
            selectedValue: selected,

            /// Bloc update
            onChanged: (val) => context
                .read<ProjectTabsBloc>()
                .add(ProjectTabOnChangedEvent(val)),

            /// Colors for underline style
            style: ZTabStyle.rounded,
            tabBarPadding: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
            borderRadius: 0,
            selectedColor: Theme.of(context).colorScheme.primary,
            unselectedTextColor: Theme.of(context).colorScheme.secondary,
            selectedTextColor: Theme.of(context).colorScheme.surface,
            tabContainerColor: Theme.of(context).colorScheme.surface,
          );
        },
      ),
    );
  }
}

