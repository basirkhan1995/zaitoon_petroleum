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
    final color = Theme.of(context).colorScheme;
    final locale = AppLocalizations.of(context)!;

    final shortcuts = {
      const SingleActivator(LogicalKeyboardKey.f1): onAdd,
      const SingleActivator(LogicalKeyboardKey.f5): onRefresh,
    };

    return Scaffold(

      body: GlobalShortcuts(
        shortcuts: shortcuts,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: color.surface
          ),
          child: Column(
            children: [
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 0),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      flex:5,
                      child: Text(locale.individuals,style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,

                      )),
                    ),
                    Expanded(
                      flex: 2,
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
                        label: Text(locale.refresh)),
                    ZOutlineButton(
                      toolTip: "F1",
                        width: 120,
                        icon: Icons.add,
                        isActive: true,
                        onPressed: onAdd,
                        label: Text(locale.newKeyword)),
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
                          message: locale.noDataFound,
                        );
                      }
                     return GridView.builder(
                        padding: const EdgeInsets.all(15),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 240, // control card width
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final stk = filteredList[index];

                          final firstName = stk.perName?.trim() ?? "";
                          final lastName  = stk.perLastName?.trim() ?? "";
                          final fullName  = "$firstName $lastName".trim();

                          return InfoCard(
                            image: ImageHelper.stakeholderProfile(
                              imageName: stk.imageProfile,
                              size: 46,
                            ),

                            title: fullName.isNotEmpty ? fullName : "—",
                            subtitle: stk.perEmail,

                            status: InfoStatus(
                              label: Utils.genderType(
                                gender: stk.perGender ?? "",
                                locale: locale,
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
