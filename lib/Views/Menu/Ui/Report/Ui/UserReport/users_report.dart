import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/Ui/add_user.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/features/branch_dropdown.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/features/role_dropdown.dart';
import '../../../../../../../Features/Widgets/no_data_widget.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../HR/Ui/Users/bloc/users_bloc.dart';
import '../../../HR/Ui/Employees/features/emp_card.dart';
import '../Transport/features/status_drop.dart';

class UsersReportView extends StatelessWidget {
  const UsersReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(),
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
  final TextEditingController searchController = TextEditingController();

  String? role;
  int? branchId;
  int? status;

  /// 🔹 Derived state (NO stored bool)
  bool get isFilterActive =>
      role != null || branchId != null || status != null;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onAdd() {
    showDialog(context: context, builder: (_) => const AddUserView());
  }

  void onApply() {
    context.read<UsersBloc>().add(
      LoadUsersReportEvent(
        status: status,
        role: role,
        branchId: branchId,
      ),
    );
  }

  void onClearFilters() {
    setState(() {
      role = null;
      branchId = null;
      status = null;
    });

    context.read<UsersBloc>().add(ResetUserEvent());
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text("${tr.users} ${tr.report}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 FILTER BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 8,
                children: [
                  const Expanded(flex: 3, child: SizedBox()),

                  Expanded(
                    child: UserRoleDropdown(
                      onRoleSelected: (e) {
                        setState(() => role = e.name);
                      },
                    ),
                  ),

                  Expanded(
                    child: BranchDropdown(
                      onBranchSelected: (e) {
                        setState(() => branchId = e.brcId);
                      },
                    ),
                  ),

                  Expanded(
                    child: StatusDropdown(
                      value: status,
                      onChanged: (v) {
                        setState(() => status = v);
                      },
                    ),
                  ),

                  /// 🔹 CLEAR FILTERS (only when active)
                  if (isFilterActive)
                    ZOutlineButton(
                      isActive: true,
                      width: 140,
                      icon: Icons.filter_alt_off,
                      onPressed: onClearFilters,
                      label: Text(tr.clearFilters),
                    ),

                  /// 🔹 APPLY BUTTON
                  ZOutlineButton(
                    width: 120,
                    icon: Icons.filter_alt,
                    onPressed: onApply,
                    label: Text(tr.apply),
                  ),
                ],
              ),
            ),

            /// 🔹 DATA AREA
            Expanded(
              child: BlocBuilder<UsersBloc, UsersState>(
                builder: (context, state) {
                  if (state is UsersLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is UsersInitial) {
                    return NoDataWidget(
                      title: "${tr.users} ${tr.report}",
                      message: tr.usersHintReport,
                      enableAction: false,
                    );
                  }

                  if (state is UsersErrorState) {
                    return NoDataWidget(
                      message: state.message,
                      onRefresh: onApply,
                    );
                  }

                  if (state is UsersReportLoadedState) {
                    final query =
                    searchController.text.toLowerCase().trim();

                    final users = state.users.where((u) {
                      final name = u.username?.toLowerCase() ?? '';
                      return name.contains(query);
                    }).toList();

                    if (users.isEmpty) {
                      return NoDataWidget(message: tr.noDataFound,enableAction: false);
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(8),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: users.map((usr) {
                          return SizedBox(
                            width: 250,
                            child: ZCard(
                              title: usr.username ?? "-",
                              subtitle: usr.email,
                              status: InfoStatus(
                                label: usr.status ?? "",
                                color: usr.status == "Active"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              infoItems: [
                                InfoItem(
                                  icon: Icons.person,
                                  text: usr.fullName ?? "-",
                                ),
                                InfoItem(
                                  icon: Icons.apartment,
                                  text: usr.branch?.toString() ?? "-",
                                ),
                                InfoItem(
                                  icon: Icons.security,
                                  text: usr.role ?? "-",
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
