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
  // Track local changes
  final Map<int, bool> _localChanges = {};
  bool _hasChanges = false;

  @override
  void initState() {
    context.read<PermissionsBloc>().add(
      LoadPermissionsEvent(widget.user.usrName ?? ""),
    );
    super.initState();
  }

  void _onPermissionChanged(int uprRole, bool newValue) {
    setState(() {
      _localChanges[uprRole] = newValue;
      _hasChanges = true;
    });
  }

  void _saveAllChanges() {
    if (!_hasChanges) return;

    final permissions = _localChanges.entries.map((entry) {
      return {
        "uprRole": entry.key,
        "uprStatus": entry.value,
      };
    }).toList();

    context.read<PermissionsBloc>().add(
      UpdatePermissionsEvent(
        usrName: widget.user.usrName ?? "",
        usrId: widget.user.usrId!,
        permissions: permissions,
      ),
    );

    // Clear local changes after save
    setState(() {
      _localChanges.clear();
      _hasChanges = false;
    });
  }

  void _cancelChanges() {
    setState(() {
      _localChanges.clear();
      _hasChanges = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;

    final Map<String, List<int>> permissionGroups = {
      locale.menuTitle: [1, 10, 18, 31, 35, 42, 46, 57, 71],
      locale.dashboard: [2, 3, 4, 5, 8, 6, 9],
      locale.finance: [11, 12, 13, 14, 15, 16, 17, 7],
      locale.journal: [19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30],
      locale.inventory: [48, 49, 50, 47, 51, 52, 53, 54, 55, 56],
      locale.hrTitle: [36, 37, 38, 39, 40, 41],
      locale.settings: [58, 59, 60, 61, 62, 63, 64, 66, 69, 67, 68, 70],
      locale.transport: [43, 44, 96],
      locale.other: [32, 33, 34, 45, 65],
      locale.actions: [106, 107, 108, 109],
      locale.report: [
        72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 110,
        88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103,
        104, 105
      ],
    };

    return Scaffold(
      backgroundColor: color.surface,
      floatingActionButton: _hasChanges
          ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                heroTag: locale.cancel,
                onPressed: _cancelChanges,
                backgroundColor: color.errorContainer,
                child: Icon(Icons.close, color: color.error),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                heroTag: locale.saveChanges,
                onPressed: _saveAllChanges,
                backgroundColor: color.primary,
                child: Icon(Icons.check_rounded, color: color.onPrimary),
              ),
            ],
          )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: BlocBuilder<PermissionsBloc, PermissionsState>(
        builder: (context, state) {
          if (state is PermissionsErrorState) {
            return Center(child: Text(state.message));
          }

          if (state is PermissionsLoadingState) {
            return const Center(
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
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                ...grouped.entries.map((entry) {
                  final categoryName = entry.key;
                  final items = entry.value;

                  if (items.isEmpty) return const SizedBox();

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
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: color.surface,
                          border: Border.all(
                            color: color.outline.withValues(alpha: .3),
                          ),
                        ),
                        child: Column(
                          children: items.map((per) {
                            // Check if there's a local change for this permission
                            final hasLocalChange =
                            _localChanges.containsKey(per.uprRole);
                            final currentValue = hasLocalChange
                                ? _localChanges[per.uprRole]!
                                : per.uprStatus == 1;

                            return ListTile(
                              hoverColor: color.primary.withValues(alpha: .05),
                              visualDensity: const VisualDensity(vertical: -3),
                              dense: true,
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 5),

                              leading: Checkbox(
                                value: currentValue,
                                onChanged: (value) {
                                  if (value != null) {
                                    _onPermissionChanged(
                                        per.uprRole!, value);
                                  }
                                },
                              ),

                              title: Text("${per.uprRole} | ${per.rsgName}"),
                              subtitle: hasLocalChange
                                  ? Text(
                                locale.changedTitle,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: color.primary,
                                  fontStyle: FontStyle.normal,
                                ),
                              )
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (hasLocalChange)
                                    Icon(
                                      Icons.pending,
                                      size: 16,
                                      color: color.primary,
                                    ),
                                  const SizedBox(width: 8),
                                  StatusBadge(
                                    status: currentValue ? 1 : 0,
                                    trueValue: locale.enableTitle,
                                    falseValue: locale.disabledTitle,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}