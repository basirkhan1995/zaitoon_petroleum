import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/shortcut.dart';
import 'package:zaitoon_petroleum/Views/Auth/models/login_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/Ui/add_user.dart';
import '../../../../../../../Features/Other/image_helper.dart';
import '../../../../../../../Features/Other/utils.dart';
import '../../../../../../../Features/Widgets/no_data_widget.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../../Features/Widgets/zcard_mobile.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../Auth/bloc/auth_bloc.dart';
import '../../Employees/features/emp_card.dart';
import '../../UserDetail/user_details.dart';
import '../bloc/users_bloc.dart';
import 'package:flutter/services.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), tablet: _Desktop(), desktop: _Desktop());
  }
}

class _Mobile extends StatefulWidget {
  const _Mobile();

  @override
  State<_Mobile> createState() => _MobileState();
}

class _MobileState extends State<_Mobile> {
  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(LoadUsersEvent());
  }

  Future<void> _onRefresh() async {
    context.read<UsersBloc>().add(LoadUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = state.loginData;

    return Scaffold(
      body: BlocConsumer<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UsersErrorState) {
            Utils.showOverlayMessage(
              context,
              message: state.message,
              isError: true,
            );
          }
        },
        builder: (context, state) {
          if (state is UsersLoadingState && state is! UsersLoadedState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is UsersErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: Text(locale.retry),
                  ),
                ],
              ),
            );
          }

          if (state is UsersLoadedState) {
            final users = state.users;

            if (users.isEmpty) {
              return Center(
                child: Text(locale.noDataFound),
              );
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final usr = users[index];

                  return MobileInfoCard(
                    imageUrl: usr.usrPhoto,
                    title: usr.usrName ?? "-",
                    subtitle: usr.usrRole ?? "-",
                    infoItems: [
                      MobileInfoItem(
                        icon: Icons.person_outline,
                        text: usr.usrFullName ?? "-",
                      ),
                      MobileInfoItem(
                        icon: Icons.email_outlined,
                        text: usr.usrEmail ?? "-",
                      ),
                      MobileInfoItem(
                        icon: Icons.apartment_outlined,
                        text: usr.usrEmail ?? usr.usrBranch?.toString() ?? "-",
                      ),
                    ],
                    status: MobileStatus(
                      label: usr.usrStatus == 1 ? locale.active : locale.blocked,
                      color: usr.usrStatus == 1 ? Colors.green : Colors.red,
                      backgroundColor: usr.usrStatus == 1
                          ? Colors.green.withValues(alpha: .1)
                          : Colors.red.withValues(alpha: .1),
                    ),
                    onTap: (login.hasPermission(107) ?? false)
                        ? () {
                      Utils.goto(context, UserDetailsView(usr: usr));
                    }
                        : null,
                    showActions: false, // Hide the "View Details" button
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}


class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}
class _DesktopState extends State<_Desktop> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersBloc>().add(LoadUsersEvent());
    });
    super.initState();
  }

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = {
      const SingleActivator(LogicalKeyboardKey.f1): onAdd,
      const SingleActivator(LogicalKeyboardKey.f5): onRefresh,
    };
    final locale = AppLocalizations.of(context)!;
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = state.loginData;
    return Scaffold(
      body: GlobalShortcuts(
        shortcuts: shortcuts,
        child: Column(
          children: [
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: ZSearchField(
                      icon: FontAwesomeIcons.magnifyingGlass,
                      controller: searchController,
                      hint: locale.search,
                      onChanged: (e) {
                        setState(() {

                        });
                      },
                      title: "",
                    ),
                  ),
                  ZOutlineButton(
                      toolTip: 'F1',
                      width: 120,
                      icon: Icons.refresh,
                      onPressed: onRefresh,
                      label: Text(locale.refresh)),

                  if(login.hasPermission(106) ?? false)
                  ZOutlineButton(
                      toolTip: 'F5',
                      width: 120,
                      icon: Icons.add,
                      isActive: true,
                      onPressed: onAdd,
                      label: Text(locale.newKeyword)),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<UsersBloc, UsersState>(
                listener: (context,state){
                  if(state is UserSuccessState){
                    Navigator.of(context).pop();
                  }
                },
                builder: (context, state) {
                  if (state is UsersLoadingState) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (state is UsersErrorState) {
                    return NoDataWidget(
                      message: state.message,
                      onRefresh: () {
                        context.read<UsersBloc>().add(
                          LoadUsersEvent(),
                        );
                      },
                    );
                  }
                  if (state is UsersLoadedState) {
                    final query = searchController.text.toLowerCase().trim();
                    final filteredList = state.users.where((item) {
                      final name = item.usrName?.toLowerCase() ?? '';
                      return name.contains(query);
                    }).toList();

                    if(filteredList.isEmpty){
                      return NoDataWidget(
                        message: locale.noDataFound,
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredList.length,
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final usr = filteredList[index];

                        return ZCard(
                          // ---------- Avatar ----------
                          image: ImageHelper.stakeholderProfile(
                          imageName: usr.usrPhoto,
                          size: 46,
                        ),

                          // ---------- Title ----------
                          title: usr.usrName ?? "-",
                          subtitle: usr.usrEmail,

                          // ---------- Status ----------
                          status: InfoStatus(
                            label: usr.usrStatus == 1 ? locale.active : locale.blocked,
                            color: usr.usrStatus == 1 ? Colors.green : Colors.red,
                          ),

                          // ---------- Info Rows ----------
                          infoItems: [
                            InfoItem(
                              icon: Icons.person,
                              text: usr.usrFullName ?? "-",
                            ),
                            InfoItem(
                              icon: Icons.apartment,
                              text: usr.usrBranch?.toString() ?? "-",
                            ),
                            InfoItem(
                              icon: Icons.security,
                              text: usr.usrRole ?? "-",
                            ),
                          ],

                          // ---------- Action ----------

                          onTap: login.hasPermission(107) ?? false ? () {
                            showDialog(
                              context: context,
                              builder: (_) => UserDetailsView(usr: usr),
                            );
                          } : null,
                        );
                      },
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

  void onAdd(){
    showDialog(context: context, builder: (context){
      return AddUserView();
    });
  }

  void onRefresh(){
    context.read<UsersBloc>().add(LoadUsersEvent());
  }
}

