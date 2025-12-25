import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/status_badge.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/ProductCategory/add_edit_cat.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/ProductCategory/bloc/pro_cat_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../Features/Widgets/search_field.dart';


class ProCatView extends StatelessWidget {
  const ProCatView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(), desktop: _Desktop(), tablet: _Tablet(),);
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
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<ProCatBloc>().add(LoadProCatEvent());
    });
    super.initState();
  }
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: color.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 10),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr.categoryTitle,style: Theme.of(context).textTheme.titleLarge),
                        Text(tr.productCategoryTitle,style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.outline)),
                      ],
                    )),
                Expanded(
                  flex: 2,
                  child: ZSearchField(
                    controller: searchController,
                    hint: AppLocalizations.of(context)!.accNameOrNumber,
                    title: '',
                    end: searchController.text.isNotEmpty? InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: (){
                          setState(() {
                            searchController.clear();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.clear,size: 15,),
                        )) : SizedBox(),
                    onChanged: (e){
                      setState(() {
                      });
                    },
                    icon: FontAwesomeIcons.magnifyingGlass,
                  ),
                ),
                ZOutlineButton(
                    width: 110,
                    icon: Icons.refresh,
                    onPressed: onRefresh,
                    label: Text(AppLocalizations.of(context)!.refresh)),
                ZOutlineButton(
                    width: 110,
                    isActive: true,
                    icon: Icons.add,
                    onPressed: (){
                      showDialog(context: context, builder: (context){
                        return AddEditProCategoryView();
                      });
                    },
                    label: Text(AppLocalizations.of(context)!.newKeyword)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 5),
            child: Row(
              children: [
                Expanded(child: Text("Category Information",style: textTheme.titleMedium)),
                SizedBox(
                    width: 60,
                    child: Text(tr.status,style: textTheme.titleMedium)),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<ProCatBloc, ProCatState>(
              listener: (context, state) {
                if(state is ProCatSuccessState){
                  Navigator.of(context).pop();
                }
              },
              builder: (context, state) {
                if(state is ProCatLoadingState){
                  return Center(child: CircularProgressIndicator());
                }
                if(state is ProCatErrorState){
                  return NoDataWidget(
                    message: state.message,
                    onRefresh: onRefresh,
                  );
                }
                if(state is ProCatLoadedState){
                  return ListView.builder(
                      itemCount: state.proCategory.length,
                      itemBuilder: (context,index){
                        final cat = state.proCategory[index];
                      return ListTile(
                        onTap: (){
                          showDialog(context: context, builder: (context){
                            return AddEditProCategoryView(model: cat);
                          });
                        },
                        tileColor: index.isEven? color.primary.withValues(alpha: .05) : Colors.transparent,
                        leading: Text(cat.pcId.toString()),
                        title: Text(cat.pcName ??""),
                        subtitle: Text(cat.pcDescription??""),
                        trailing: StatusBadge(status: cat.pcStatus!, trueValue: tr.active, falseValue: tr.inactive,)
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
  void onRefresh(){
    context.read<ProCatBloc>().add(LoadProCatEvent());
  }
}
