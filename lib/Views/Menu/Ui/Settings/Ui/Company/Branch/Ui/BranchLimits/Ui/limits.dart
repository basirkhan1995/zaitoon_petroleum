import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Branch/Ui/BranchLimits/Ui/add_edit_limit.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Branch/Ui/BranchLimits/bloc/branch_limit_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Branches/model/branch_model.dart';
import '../../../../../../../../../../Features/Widgets/no_data_widget.dart';
import '../../../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../../../../../Localizations/l10n/translations/app_localizations.dart';

class BranchLimitsView extends StatelessWidget {
  final BranchModel branch;
  const BranchLimitsView({super.key,required this.branch});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), tablet: _Tablet(), desktop: _Desktop(branch));
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
  final BranchModel branch;
  const _Desktop(this.branch);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<BranchLimitBloc>().add(LoadBranchLimitEvent(widget.branch.brcId));
    });
    super.initState();
  }
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
                      context.read<BranchLimitBloc>().add(LoadBranchLimitEvent(widget.branch.brcId));
                    },
                    label: Text(locale.refresh)),
                ZOutlineButton(
                    toolTip: "F1",
                    width: 120,
                    icon: Icons.add,
                    isActive: true,
                    onPressed: (){
                      showDialog(context: context, builder: (context){
                        return BranchLimitAddEditView(branchCode: widget.branch.brcId);
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
                    width: 60,
                    child: Text(locale.branchId,
                        style: textTheme.titleSmall)),
                Text(locale.currencyTitle,style: textTheme.titleSmall),
                Spacer(),

                SizedBox(
                    width: 150,
                    child: Text(locale.amount,style: textTheme.titleSmall))
              ],
            ),
          ),
          Divider(
            color: color.primary,
            indent: 15,
            endIndent: 15,
          ),
          Expanded(
            child: BlocConsumer<BranchLimitBloc, BranchLimitState>(
              listener: (context, state) {
                if(state is BranchLimitSuccessState){
                  Navigator.of(context).pop();
                  context.read<BranchLimitBloc>().add(LoadBranchLimitEvent(widget.branch.brcId));

                }
              },
              builder: (context, state) {
                if(state is BranchLimitErrorState){
                  return NoDataWidget(
                    message: state.message,
                    onRefresh: (){
                      context.read<BranchLimitBloc>().add(LoadBranchLimitEvent(widget.branch.brcId));
                      },
                  );
                }
                if(state is BranchLimitLoadingState){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if(state is BranchLimitLoadedState){
                  final query = searchController.text.toLowerCase().trim();
                  final filteredList = state.limits.where((item) {
                    final name = item.balCurrency?.toLowerCase() ?? '';
                    return name.contains(query);
                  }).toList();
                  if(filteredList.isEmpty){
                    return NoDataWidget(
                      message: locale.noDataFound,
                      onRefresh: (){
                        context.read<BranchLimitBloc>().add(LoadBranchLimitEvent(widget.branch.brcId));
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
                              return BranchLimitAddEditView(branchLimit: brc);
                            });
                          },
                          splashColor: color.primary.withValues(alpha: .05),
                          hoverColor: color.primary.withValues(alpha: .05),
                          child: Container(
                            decoration: BoxDecoration(
                                color: index.isOdd? color.primary.withValues(alpha: .05) : Colors.transparent
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 5),
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: 60,
                                      child: Text(brc.balId.toString(),style: textTheme.bodyMedium)),
                                  ZCard(child: Text(brc.balCurrency??"",style: textTheme.bodyMedium)),
                                  Spacer(),
                                  SizedBox(
                                      width: 150,
                                      child: Text(brc.balLimitAmount!.toAmount(),style: textTheme.bodyMedium)),
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
