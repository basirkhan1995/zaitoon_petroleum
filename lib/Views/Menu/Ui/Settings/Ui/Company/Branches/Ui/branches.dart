import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Branch/branch_details.dart';
import '../../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../../Features/Widgets/search_field.dart';
import '../bloc/branch_bloc.dart';
import 'add_edit_branch.dart';

class BranchesView extends StatelessWidget {
  const BranchesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
        mobile: _Mobile(), tablet: _Tablet(), desktop: _Desktop());
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
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;

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
                  onPressed: (){
                    context.read<BranchBloc>().add(LoadBranchesEvent());
                  },
                  label: Text(locale.refresh)),
              ZOutlineButton(
                  toolTip: "F1",
                  width: 120,
                  icon: Icons.add,
                  isActive: true,
                  onPressed: (){
                    showDialog(context: context, builder: (context){
                      return BranchAddEditView();
                    });
                  },
                  label: Text(locale.newKeyword)),
            ],
          ),
        ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                SizedBox(
                    width: 70,
                    child: Text(locale.branchId,style: textTheme.titleMedium)),
                Expanded(child: Text(locale.branchName,style: textTheme.titleMedium)),
                SizedBox(
                    width: 150,
                    child: Text(locale.city ,style: textTheme.titleMedium)),
                SizedBox(
                    width: 120,
                    child: Text(locale.province,style: textTheme.titleMedium)),
                SizedBox(
                    width: 120,
                    child: Text(locale.country,style: textTheme.titleMedium))
              ],
            ),
          ),
          Divider(
            color: color.primary,
            indent: 15,
            endIndent: 15,
          ),
          Expanded(
            child: BlocConsumer<BranchBloc, BranchState>(
              listener: (context, state) {},
              builder: (context, state) {
                if(state is BranchErrorState){
                  return NoDataWidget(
                    message: state.message,
                    onRefresh: (){
                      context.read<BranchBloc>().add(LoadBranchesEvent());
                    },
                  );
                }
                if(state is BranchLoadingState){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if(state is BranchLoadedState){
                  final query = searchController.text.toLowerCase().trim();
                  final filteredList = state.branches.where((item) {
                    final name = item.brcName?.toLowerCase() ?? '';
                    return name.contains(query);
                  }).toList();
                  if(filteredList.isEmpty){
                    return NoDataWidget(
                      message: locale.noDataFound,
                      onRefresh: (){
                        context.read<BranchBloc>().add(LoadBranchesEvent());
                      },
                    );
                  }
                  return ListView.builder(
                      itemCount: filteredList.length,
                      shrinkWrap: true,
                      itemBuilder: (context,index){
                      final brc = filteredList[index];
                      return InkWell(
                        onTap: (){
                          showDialog(context: context, builder: (context){
                            return BranchDetailsView(branch: brc);
                          });
                        },
                        splashColor: color.primary.withValues(alpha: .05),
                        hoverColor: color.primary.withValues(alpha: .05),
                        child: Container(
                          decoration: BoxDecoration(
                            color: index.isOdd? color.primary.withValues(alpha: .05) : Colors.transparent
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 70,
                                    child: Text(brc.brcId.toString(),style: textTheme.bodyMedium)),
                               Expanded(child: Text(brc.brcName??"",style: textTheme.bodyMedium)),
                                SizedBox(
                                    width: 150,
                                    child: Text(brc.addCity??"",style: textTheme.bodyMedium)),
                                SizedBox(
                                    width: 120,
                                    child: Text(brc.addProvince??"",style: textTheme.bodyMedium)),
                                SizedBox(
                                    width: 120,
                                    child: Text(brc.addCountry??"",style: textTheme.bodyMedium)),
                              ],
                            ),
                          ),
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
    );
  }
}

