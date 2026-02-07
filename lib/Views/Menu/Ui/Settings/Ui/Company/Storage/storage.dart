import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/add_edit_storage.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/bloc/storage_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../Features/Widgets/no_data_widget.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/search_field.dart';


class StorageView extends StatelessWidget {
  const StorageView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
        mobile: _Mobile(), tablet: _Tablet(), desktop: _Desktop());
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Mobile extends StatelessWidget {

  const _Mobile();

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
  void initState() {
    context.read<StorageBloc>().add(LoadStorageEvent());
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
    TextStyle? titleStyle = textTheme.titleSmall?.copyWith();
    TextStyle? bodyStyle = textTheme.bodyMedium?.copyWith(color: color.secondary);

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
                      context.read<StorageBloc>().add(LoadStorageEvent());
                    },
                    label: Text(locale.refresh)),
                ZOutlineButton(
                    toolTip: "F1",
                    width: 120,
                    icon: Icons.add,
                    isActive: true,
                    onPressed: (){
                      showDialog(context: context, builder: (context){
                        return StorageAddEditView();
                      });
                    },
                    label: Text(locale.newKeyword)),
              ],
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 0),
            child: Row(
              children: [
               Expanded(child: Text(locale.storage,style: titleStyle)),
                SizedBox(
                   width: 300,
                   child: Text(locale.details,style: titleStyle)),
                SizedBox(
                    width: 280,
                    child: Text(locale.address,style: titleStyle)),
                SizedBox(
                    width: 60,
                    child: Text(locale.status,style: titleStyle)),
              ],
            ),
          ),
          Divider(indent: 15,endIndent: 15, color: color.outline.withValues(alpha: .4)),
          SizedBox(height: 2),
          Expanded(
            child: BlocBuilder<StorageBloc, StorageState>(
              builder: (context, state) {
                if(state is StorageLoadingState){
                  return Center(child: CircularProgressIndicator());
                }
                if(state is StorageLoadedState){
                  final query = searchController.text.toLowerCase().trim();
                  final filteredList = state.storage.where((item) {
                    final name = item.stgName?.toLowerCase() ?? '';
                    return name.contains(query);
                  }).toList();

                  if(filteredList.isEmpty){
                    return NoDataWidget(
                      message: locale.noDataFound,
                      onRefresh: (){
                        context.read<StorageBloc>().add(LoadStorageEvent());
                      },
                    );
                  }

                  return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context,index){
                        final st = filteredList[index];
                      return InkWell(
                        onTap: (){
                          showDialog(context: context, builder: (context){
                            return StorageAddEditView(selectedStorage: st);
                          });
                        },
                        hoverColor: color.primary.withValues(alpha: .05),
                        highlightColor: color.primary.withValues(alpha: .05),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12,horizontal: 15),
                          decoration: BoxDecoration(
                           color: index.isOdd? color.primary.withValues(alpha: .05) : Colors.transparent
                          ),
                          child: Row(
                            children: [
                                Expanded(child: Text(st.stgName??"",style: bodyStyle)),
                              SizedBox(
                                  width: 300,
                                  child: Text(st.stgDetails??"")),
                                SizedBox(
                                    width: 280,
                                    child: Text(st.stgLocation??"")),

                                SizedBox(
                                    width: 60,
                                    child: Text(st.stgStatus == 1? locale.active : locale.inactive))
                            ],
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

