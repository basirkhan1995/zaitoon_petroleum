import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/IndividualProfile/Ui/ind_profile.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';

import '../../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';

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
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IndividualsBloc>().add(LoadIndividualsEvent());
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
            padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 8),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
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
                    width: 120,
                    icon: Icons.refresh,
                    onPressed: (){
                      context.read<IndividualsBloc>().add(LoadIndividualsEvent());
                    },
                    label: Text(locale.refresh)),
                ZOutlineButton(
                    width: 120,
                    icon: Icons.add,
                    isActive: true,
                    label: Text(locale.newKeyword)),

              ],
            ),
          ),


          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 5),
            child: Row(
              children: [
                Text(locale.stakeholderInfo,style: Theme.of(context).textTheme.titleMedium)
              ],
            ),
          ),

          SizedBox(height: 5),
          Divider(
            indent: 5,endIndent: 5,color: Theme.of(context).colorScheme.primary,height: 0,
          ),
          SizedBox(height: 10),
          Expanded(
            child: BlocConsumer<IndividualsBloc, IndividualsState>(
              listener: (context,state){},
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
                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final stk = filteredList[index];
                      final fullName = "${stk.perName} ${stk.perLastName}";
                      return InkWell(
                        highlightColor: color.primary.withValues(alpha: .06),
                        hoverColor: color.primary.withValues(alpha: .06),
                        onTap: (){
                          Utils.goto(context, IndividualProfileView(ind: stk));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: index.isOdd
                                ? color.primary.withValues(alpha: .06)
                                : Colors.transparent,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color.primary.withValues(alpha: .8),
                                  radius: 28,
                                  child: Text(fullName.getFirstLetter,style: TextStyle(
                                    color: color.surface,
                                    fontSize: 17
                                  )),
                                ),
                                SizedBox(width: 6),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(fullName,style: Theme.of(context).textTheme.titleMedium),
                                    Text(stk.empEmail??"")
                                  ],
                                ),

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
  void onAdd() {}

  void onRefresh(){
    context.read<IndividualsBloc>().add(LoadIndividualsEvent());
  }
}
