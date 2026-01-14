import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Auth/models/login_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Attendance/attendance.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/Ui/employees.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/bloc/hrtab_bloc.dart';
import '../../../../Features/Generic/tab_bar.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../Auth/bloc/auth_bloc.dart';
import 'Ui/Users/Ui/users.dart';

class HrTabView extends StatelessWidget {
  const HrTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = state.loginData;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: BlocBuilder<HrTabBloc, HrTabState>(
          builder: (context, state) {
            final tabs = <ZTabItem<HrTabName>>[
              if (login.hasPermission(14) ?? false)
                ZTabItem(
                  value: HrTabName.employees,
                  label: AppLocalizations.of(context)!.employees,
                  screen: const EmployeesView(),
                ),

              ZTabItem(
                value: HrTabName.attendance,
                label: AppLocalizations.of(context)!.attendence,
                screen: const AttendanceView(),
              ),

              if (login.hasPermission(15) ?? false)
                ZTabItem(
                  value: HrTabName.users,
                  label: AppLocalizations.of(context)!.users,
                  screen: const UsersView(),
                ),
            ];

            final availableValues = tabs.map((tab) => tab.value).toList();
            final selected = availableValues.contains(state.tabs)
                ? state.tabs
                : availableValues.first;

            return ZTabContainer<HrTabName>(
              title: AppLocalizations.of(context)!.hrTitle,
              description: AppLocalizations.of(context)!.hrManagement,
              /// Tab data
              tabs: tabs,
              selectedValue: selected,

              /// Bloc update
              onChanged: (val) => context.read<HrTabBloc>().add(HrOnchangeEvent(val)),

              /// Colors and style
              style: ZTabStyle.rounded,
              tabBarPadding: EdgeInsets.symmetric(horizontal: 8),
              borderRadius: 0,
              selectedColor: Theme.of(context).colorScheme.primary,
              unselectedTextColor: Theme.of(context).colorScheme.secondary,
              selectedTextColor: Theme.of(context).colorScheme.surface,
              tabContainerColor: Theme.of(context).colorScheme.surface,
            );
          },
        ),
      ),
    );
  }
}