import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/bloc/users_bloc.dart';
import '../../../../../../../../Features/Other/cover.dart';
import '../../../../../../../../Features/Widgets/no_data_widget.dart';
import '../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../../../Localizations/l10n/translations/app_localizations.dart';

class UsersByPerIdView extends StatelessWidget {
  final int perId;
  const UsersByPerIdView({super.key,required this.perId});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), tablet: _Tablet(), desktop: _Desktop(perId));
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
  final int perId;
  const _Desktop(this.perId);
  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<UsersBloc>().add(LoadUsersEvent(usrOwner: widget.perId));
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
    return Scaffold(
      backgroundColor: color.surface,
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 5),
            child: Row(
              children: [
                Expanded(child: Text(locale.userInformation,style: Theme.of(context).textTheme.titleMedium)),
                SizedBox(
                    width: 150,
                    child: Text(locale.userOwner,style: Theme.of(context).textTheme.titleMedium)),
                SizedBox(
                    width: 100,
                    child: Text(locale.branch,style: Theme.of(context).textTheme.titleMedium)),
                SizedBox(
                    width: 100,
                    child: Text(locale.usrRole,style: Theme.of(context).textTheme.titleMedium)),
                SizedBox(
                    width: 100,
                    child: Text(locale.status,style: Theme.of(context).textTheme.titleMedium)),

              ],
            ),
          ),

          SizedBox(height: 5),
          Divider(
            indent: 15,endIndent: 15,color: Theme.of(context).colorScheme.primary,height: 0,
          ),
          SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<UsersBloc, UsersState>(
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
                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final stk = filteredList[index];

                      // ---------- UI ----------
                      return InkWell(
                        highlightColor: color.primary.withValues(alpha: .06),
                        hoverColor: color.primary.withValues(alpha: .06),
                        onTap: () {

                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: index.isOdd
                                ? color.primary.withValues(alpha: .06)
                                : Colors.transparent,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ---------- Avatar ----------
                                CircleAvatar(
                                  backgroundColor: color.primary.withValues(alpha: .7),
                                  radius: 23,
                                  child: Text(
                                    stk.usrId.toString(),
                                    style: TextStyle(
                                      color: color.surface,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // ---------- Name + Details ----------
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Full Name
                                      Text(
                                        stk.usrName??"",
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),

                                      const SizedBox(height: 4),

                                      Padding(
                                        padding: const EdgeInsets.only(right: 6.0),
                                        child: ZCard(
                                          color: color.surface,
                                          child: Text(stk.usrEmail??""),
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                                SizedBox(
                                    width: 150,
                                    child: Text(stk.usrFullName??"")),
                                SizedBox(
                                    width: 100,
                                    child: Text(stk.usrBranch.toString())),
                                SizedBox(
                                    width: 100,
                                    child: Text(stk.usrRole??"")),
                                SizedBox(
                                    width: 100,
                                    child: Text(stk.usrStatus == 1? locale.active : locale.blocked)),

                              ],
                            ),
                          ),
                        ),
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
    context.read<UsersBloc>().add(LoadUsersEvent(usrOwner: widget.perId));
  }
}

