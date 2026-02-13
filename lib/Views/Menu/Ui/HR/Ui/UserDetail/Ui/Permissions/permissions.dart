import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/blur_loading.dart';
import 'package:zaitoon_petroleum/Features/Widgets/status_badge.dart';
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
      locale.dashboard: [2, 3, 4, 5, 8, 6, 9],
      locale.finance: [11,12,13,14,15,16,17,7],
      locale.journal: [19,20,21,22,23,24,25,26,27,28, 29, 30],
      locale.inventory: [48,49,50,46,51,52,53,54,55,56,],
      locale.hrTitle: [36,37,38,39,40,41],
      locale.settings: [58,59,60,61,62,63,64,69,67,68,70],
      locale.transport: [43, 44,96],
      locale.other: [32],
      locale.actions: [106,107,108,109],
      locale.report: [72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,110,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105],

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
                        color: color.surface,
                        border: Border.all(
                          color: color.outline.withValues(alpha: .3),
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
                            trailing: StatusBadge(status: per.uprStatus!, trueValue: locale.enableTitle, falseValue: locale.disabledTitle),

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

