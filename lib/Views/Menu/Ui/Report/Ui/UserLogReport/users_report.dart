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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersBloc>().add(LoadUsersReportEvent());
    });
  }

  String? role;
  int? branchId;
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onAdd() {
    showDialog(context: context, builder: (_) => const AddUserView());
  }

  void onRefresh() {
    context.read<UsersBloc>().add(LoadUsersReportEvent());
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text("User Report"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 8,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(""),
                  ),
                  Expanded(
                      child: UserRoleDropdown(onRoleSelected: (e){
                    setState(() {
                      role = e.name;
                    });
                    context.read<UsersBloc>().add(LoadUsersReportEvent(role: role));
                  })),
                  Expanded(
                    child: BranchDropdown(onBranchSelected: (e){
                      setState(() {
                       branchId = e.brcId;
                      });
                      context.read<UsersBloc>().add(LoadUsersReportEvent(branchId: branchId));
                    }),
                  ),
                  ZOutlineButton(
                    toolTip: 'F1',
                    width: 120,
                    icon: Icons.filter_alt_off,
                    onPressed: onRefresh,
                    label: Text("${tr.all} ${tr.users}"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<UsersBloc, UsersState>(
                builder: (context, state) {
                  if (state is UsersLoadingState) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is UsersErrorState) {
                    return NoDataWidget(
                      message: state.message,
                      onRefresh: () =>
                          context.read<UsersBloc>().add(LoadUsersEvent()),
                    );
                  }

                  if (state is UsersReportLoadedState) {
                    final query =
                    searchController.text.toLowerCase().trim();
                    final filteredList = state.users.where((item) {
                      final name = item.username?.toLowerCase() ?? '';
                      return name.contains(query);
                    }).toList();

                    if (filteredList.isEmpty) {
                      return NoDataWidget(
                        message: tr.noDataFound,
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(8),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.start,
                        spacing: 12,
                        runSpacing: 12,
                        children: filteredList.map((usr) {
                          return SizedBox(
                            width: 250,
                            child: ZCard(
                              title: usr.username ?? "-",
                              subtitle: usr.email,
                              status: InfoStatus(
                                label: usr.status??"",
                                color: usr.status == "Active"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              infoItems: [
                                InfoItem(
                                    icon: Icons.person,
                                    text: usr.fullName ?? "-"),
                                InfoItem(
                                    icon: Icons.apartment,
                                    text: usr.branch?.toString() ?? "-"),
                                InfoItem(
                                    icon: Icons.security,
                                    text: usr.role ?? "-"),
                              ],
                              onTap: () {},
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
