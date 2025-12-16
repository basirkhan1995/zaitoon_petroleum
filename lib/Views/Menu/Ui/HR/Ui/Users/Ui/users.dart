import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/Ui/add_user.dart';
import '../../../../../../../Features/Other/image_helper.dart';
import '../../../../../../../Features/Widgets/no_data_widget.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../Auth/bloc/auth_bloc.dart';
import '../../Employees/features/emp_card.dart';
import '../../UserDetail/user_details.dart';
import '../bloc/users_bloc.dart';


class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), tablet: _Tablet(), desktop: _Desktop());
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
    final color = Theme.of(context).colorScheme;
    final locale = AppLocalizations.of(context)!;
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
   // final login = state.loginData;
    return Scaffold(
     // backgroundColor: color.surface,
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 8),
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
                    width: 120,
                    icon: Icons.refresh,
                    onPressed: onRefresh,
                    label: Text(locale.refresh)),
                ZOutlineButton(
                    width: 120,
                    icon: Icons.add,
                    isActive: true,

                    onPressed: (){
                       showDialog(context: context, builder: (context){
                         return AddUserView();
                       });
                    },
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
                    padding: const EdgeInsets.all(15),
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
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => UserDetailsView(usr: usr),
                          );
                        },
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
    );
  }

  void onRefresh(){
    context.read<UsersBloc>().add(LoadUsersEvent());
  }
}

