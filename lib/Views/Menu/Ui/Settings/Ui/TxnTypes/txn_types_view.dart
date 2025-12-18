import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/alert_dialog.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/TxnTypes/add_edit_type.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/TxnTypes/bloc/txn_types_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../Features/Widgets/search_field.dart';


class TxnTypesView extends StatelessWidget {
  const TxnTypesView({super.key});

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
      context.read<TxnTypesBloc>().add(LoadTxnTypesEvent());
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 10),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 3,
                    child: Text("Transaction Types",style: textTheme.titleMedium)),
                Expanded(
                  flex: 2,
                  child: ZSearchField(
                    controller: searchController,
                    hint: tr.search,
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
                        return AddEditTxnTypesView();
                      });
                    },
                    label: Text(AppLocalizations.of(context)!.newKeyword)),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<TxnTypesBloc, TxnTypesState>(
              listener: (context,state){
                if(state is TxnTypeSuccessState){
                  Navigator.of(context).pop();
                }
              },
              builder: (context, state) {
                if(state is TxnTypeLoadingState){
                  return Center(child: CircularProgressIndicator());
                }
                if(state is TxnTypeErrorState){
                  return NoDataWidget(
                    title: AppLocalizations.of(context)!.noData,
                    message: state.message,
                  );
                }
                if(state is TxnTypesLoadedState){
                  final query = searchController.text.toLowerCase().trim();

                  final filteredList = state.types.where((item) {
                    final name = item.trntName?.toLowerCase() ?? '';
                    final number = item.trntCode?.toString() ?? '';

                    return name.contains(query.toLowerCase()) || number.contains(query);
                  }).toList();

                  return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context,index){
                        final type = filteredList[index];
                        return ListTile(
                          onTap: (){
                            showDialog(context: context, builder: (context){
                              return AddEditTxnTypesView(model: type);
                            });
                          },
                          tileColor: index.isEven? color.primary.withValues(alpha: .05) : Colors.transparent,
                          leading: Text(type.trntCode??""),
                          title: Text(type.trntName??""),
                          subtitle: Text(type.trntDetails??""),
                          trailing: IconButton(
                              onPressed: (){
                                showDialog(context: context, builder: (context){
                                  return ZAlertDialog(title: tr.areYouSure,
                                      content: "Do wanna delete this code?",
                                      onYes: (){
                                       context.read<TxnTypesBloc>().add(DeleteTxnTypeEvent(type.trntCode!));
                                      });
                                });
                              },
                              icon: Icon(Icons.delete,color: color.error)),
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
    context.read<TxnTypesBloc>().add(LoadTxnTypesEvent());
  }
}
