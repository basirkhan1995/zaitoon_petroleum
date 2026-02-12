import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/blur_loading.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/UserDetail/Ui/Permissions/per_model.dart';
import '../../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../Users/model/user_model.dart';
import 'bloc/permissions_bloc.dart';

class PermissionsView extends StatelessWidget {
  final UsersModel user;
  const PermissionsView({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Desktop(user),
      tablet: _Desktop(user),
      desktop: _Desktop(user),
    );
  }
}

class _Desktop extends StatefulWidget {
  final UsersModel user;
  const _Desktop(this.user);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {


  @override
  void initState() {
    context.read<PermissionsBloc>().add(
      LoadPermissionsEvent(widget.user.usrName ?? ""),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;

    final Map<String, List<int>> permissionGroups = {
      locale.menuTitle: [1,10,18,31,35,42,66,57,71],
      locale.dashboard: [2, 3, 4, 5,8],
      locale.finance: [6,7,9,33],
      locale.inventory: [11, 12, 13,48],
      locale.usersAndAuthorizations: [15, 14, 16, 17, 45, 46],
      locale.cashOperations: [19, 20, 21, 22, 23, 24, 25],
      locale.settings: [32,26],
      locale.transport: [28, 29, 30],
      locale.report: [51, 52, 53,49, 50, 54,40,27, 34, 36, 37, 38, 39, 41, 43, 44, 55, 56],
      locale.other: [58,59,60,61,62,63,64,65,67,68,69,70,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105]
    };


    return Scaffold(
      backgroundColor: color.surface,
      body: BlocBuilder<PermissionsBloc, PermissionsState>(
        builder: (context, state) {
          if (state is PermissionsErrorState) {
            return Center(child: Text(state.message));
          }

          if (state is PermissionsLoadingState) {
            return Center(
              child: BlurLoader(
                blur: 4,
                isLoading: true,
                child: SizedBox(),
              ),
            );
          }

          if (state is PermissionsLoadedState) {
            // GROUP PERMISSIONS BY CATEGORY
            final grouped = <String, List<UserPermissionsModel>>{};

            for (final entry in permissionGroups.entries) {
              grouped[entry.key] = state.permissions
                  .where((p) => entry.value.contains(p.uprRole))
                  .toList();
            }

            return ListView(
              padding: EdgeInsets.symmetric(vertical: 10),
              children: grouped.entries.map((entry) {
                final categoryName = entry.key;
                final items = entry.value;

                if (items.isEmpty) return SizedBox();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 16, 6),
                      child: Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 15,
                          color: color.primary,
                        ),
                      ),
                    ),

                    // Bordered Permission Group
                    Container(
                      margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: color.primary.withValues(alpha: .3),
                        ),
                      ),
                      child: Column(
                        children: items.map((per) {
                          return ListTile(
                            hoverColor: color.primary.withValues(alpha: .05),
                            visualDensity: VisualDensity(vertical: -3),
                            dense: true,
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 5),

                            leading: Checkbox(
                              value: per.uprStatus == 1,
                              onChanged: (value) {
                                context.read<PermissionsBloc>().add(
                                  UpdatePermissionsStatusEvent(
                                    uprStatus: value ?? false,
                                    usrId: widget.user.usrId!,
                                    uprRole: per.uprRole!,
                                    usrName: widget.user.usrName!,
                                  ),
                                );
                              },
                            ),

                            title: Text("${per.uprRole} | ${per.rsgName}"),

                            trailing: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                per.uprStatus == 1
                                    ? locale.active
                                    : locale.blocked,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          }

          return SizedBox();
        },
      ),
    );
  }
}

