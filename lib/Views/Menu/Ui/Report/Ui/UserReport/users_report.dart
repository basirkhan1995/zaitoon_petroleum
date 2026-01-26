import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/features/branch_dropdown.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/features/role_dropdown.dart';
import '../../../../../../../Features/Widgets/no_data_widget.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../HR/Ui/Users/bloc/users_bloc.dart';
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
  void initState() {
    context.read<UsersBloc>().add(ResetUserEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    TextStyle? titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.surface);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text("${tr.users} ${tr.report}"),
        actionsPadding: EdgeInsets.symmetric(horizontal: 8),
        actions: [
          /// 🔹 CLEAR FILTERS (only when active)
          if (isFilterActive)
            ZOutlineButton(
              backgroundHover: Theme.of(context).colorScheme.error,
              isActive: true,
              width: 140,
              icon: Icons.filter_alt_off,
              onPressed: onClearFilters,
              label: Text(tr.clearFilters),
            ),

          SizedBox(width: 8),
          /// 🔹 APPLY BUTTON
          ZOutlineButton(
            width: 100,
            icon: FontAwesomeIcons.solidFilePdf,
            onPressed: onApply,
            label: Text("PDF"),
          ),
          SizedBox(width: 8),

          /// 🔹 APPLY BUTTON
          ZOutlineButton(
            width: 100,
            isActive: true,
            icon: Icons.filter_alt,
            onPressed: onApply,
            label: Text(tr.apply),
          ),
        ],
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
                 // const Expanded(flex: 3, child: SizedBox()),

                  Expanded(
                    child: UserRoleDropdown(
                      showAllOption: true,
                      onRoleSelected: (e) {
                        setState(() => role = e?.name);
                      },
                    ),
                  ),

                  Expanded(
                    child: BranchDropdown(
                      showAllOption: true,
                      onBranchSelected: (e) {
                        setState(() => branchId = e?.brcId);
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
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: .8),
              ),
              child: Row(
                children: [
                 SizedBox(
                     width: 100,
                     child: Text(tr.date,style: titleStyle)),
                  Expanded(
                      child: Text(tr.userInformation,style: titleStyle)),
                  SizedBox(
                      width: 180,
                      child: Text(tr.userOwner,style: titleStyle)),
                  SizedBox(
                      width: 120,
                      child: Text(tr.usrRole,style: titleStyle)),
                  SizedBox(
                      width: 80,
                      child: Text(tr.branch,style: titleStyle)),
                  SizedBox(
                      width: 80,
                      child: Text("ALF",style: titleStyle)),
                  SizedBox(
                      width: 80,
                      child: Text(tr.fcp,style: titleStyle)),
                  SizedBox(
                      width: 80,
                      child: Text(tr.verified,style: titleStyle)),
                  SizedBox(
                      width: 80,
                      child: Text(tr.status,style: titleStyle)),

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

                    return ListView.builder(
                        itemCount: state.users.length,
                        itemBuilder: (context,index){
                          final usr = state.users[index];
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: index.isEven? Theme.of(context).colorScheme.primary.withValues(alpha: .05) : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 100,
                                  child: Text(usr.createDate.toFormattedDate())),
                              Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(usr.username??"",style: Theme.of(context).textTheme.titleSmall),
                                      Text(usr.email??"",style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),),
                                    ],
                                  )),
                              SizedBox(
                                  width: 180,
                                  child: Text(usr.fullName??"")),

                              SizedBox(
                                  width: 120,
                                  child: Text(usr.role??"")),
                              SizedBox(
                                  width: 80,
                                  child: Text(usr.branch.toString())),
                              SizedBox(
                                  width: 80,
                                  child: Text(usr.alf.toString())),

                              SizedBox(
                                  width: 80,
                                  child: Text(usr.fcp??"")),
                              SizedBox(
                                  width: 80,
                                  child: Text(usr.verification??"")),
                              SizedBox(
                                  width: 80,
                                  child: Text(usr.status??"")),
                            ],
                          ),
                        );
                    });
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
