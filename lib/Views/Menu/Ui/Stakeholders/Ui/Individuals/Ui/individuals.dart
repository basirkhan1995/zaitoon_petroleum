import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/image_helper.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/shortcut.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/Ui/add_edit.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import '../../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../HR/Ui/Employees/features/emp_card.dart';
import '../../IndividualDetails/Ui/Profile/ind_profile.dart';
import 'package:flutter/services.dart';

class IndividualsView extends StatelessWidget {
  const IndividualsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
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
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      onRefresh();
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    final shortcuts = {
      const SingleActivator(LogicalKeyboardKey.f1): onAdd,
      const SingleActivator(LogicalKeyboardKey.f5): onRefresh,
    };

    return Scaffold(
      body: GlobalShortcuts(
        shortcuts: shortcuts,
        child: Container(

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      flex: 5,
                      child: ListTile(
                        tileColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                        title: Text(tr.individuals,style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                        )),
                        subtitle: Text(AppLocalizations.of(context)!.stakeholderManage,style: TextStyle(fontSize: 12),),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: ZSearchField(
                        icon: FontAwesomeIcons.magnifyingGlass,
                        controller: searchController,
                        hint: AppLocalizations.of(context)!.search,
                        onChanged: (e) {
                          setState(() {

                          });
                        },
                        title: "",
                      ),
                    ),
                    ZOutlineButton(
                        toolTip: "F5",
                        width: 120,
                        icon: Icons.refresh,
                        onPressed: onRefresh,
                        label: Text(tr.refresh)),
                    ZOutlineButton(
                      toolTip: "F1",
                        width: 120,
                        icon: Icons.add,
                        isActive: true,
                        onPressed: onAdd,
                        label: Text(tr.newKeyword)),
                  ],
                ),
              ),

              Expanded(
                child: BlocConsumer<IndividualsBloc, IndividualsState>(
                  listener: (context,state){
                    if(state is IndividualSuccessState || state is IndividualSuccessImageState){
                      onRefresh();
                    }
                  },
                  builder: (context, state) {
                    if (state is IndividualLoadingState) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (state is IndividualErrorState) {
                      return NoDataWidget(
                        message: state.message,
                        onRefresh: () {
                          context.read<IndividualsBloc>().add(
                            LoadIndividualsEvent(),
                          );
                        },
                      );
                    }
                    if (state is IndividualLoadedState) {
                      final query = searchController.text.toLowerCase().trim();
                      final filteredList = state.individuals.where((item) {
                        final name = item.perName?.toLowerCase() ?? '';
                        return name.contains(query);
                      }).toList();

                      if(filteredList.isEmpty){
                        return NoDataWidget(
                          message: tr.noDataFound,
                        );
                      }
                     return GridView.builder(
                        padding: const EdgeInsets.all(15),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 22,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final stk = filteredList[index];

                          final firstName = stk.perName?.trim() ?? "";
                          final lastName  = stk.perLastName?.trim() ?? "";
                          final fullName  = "$firstName $lastName".trim();

                          return ZCard(
                            image: ImageHelper.stakeholderProfile(
                              imageName: stk.imageProfile,
                              size: 46,
                            ),
                            title: fullName.isNotEmpty ? fullName : "—",
                            subtitle: stk.perEmail,
                            status: InfoStatus(
                              label: Utils.genderType(
                                gender: stk.perGender ?? "",
                                locale: tr,
                              ),
                              color: Theme.of(context).colorScheme.primary,
                            ),

                            infoItems: [
                              InfoItem(
                                icon: Icons.email,
                                text: stk.perEmail ?? "-",
                              ),
                              InfoItem(
                                icon: Icons.phone,
                                text: stk.perPhone ?? "-",
                              ),
                              InfoItem(
                                icon: Icons.badge,
                                text: stk.perEnidNo ?? "-",
                              ),
                            ],

                            onTap: () {
                              Utils.goto(
                                context,
                                IndividualProfileView(ind: stk),
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
        ),
      ),
    );
  }
  void onAdd() {
    showDialog(context: context, builder: (context){
      return IndividualAddEditView();
    });
  }

  void onRefresh(){
    context.read<IndividualsBloc>().add(LoadIndividualsEvent());
  }
}
