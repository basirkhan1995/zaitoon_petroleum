import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/shortcut.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/GlAccounts/add_edit_gl.dart';
import '../../../../../../Features/Other/alert_dialog.dart';
import '../../../../../../Features/Other/utils.dart';
import '../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../Localizations/l10n/translations/app_localizations.dart';
import 'bloc/gl_accounts_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

class GlAccountsView extends StatelessWidget {
  const GlAccountsView({super.key});

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
  String? myLocale;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      myLocale = Localizations.localeOf(context).languageCode;
      context.read<GlAccountsBloc>().add(LoadGlAccountEvent());
    });
    super.initState();
  }
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final shortcuts = {
      const SingleActivator(LogicalKeyboardKey.f1): onAdd,
      const SingleActivator(LogicalKeyboardKey.f5): onRefresh,
    };
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GlobalShortcuts(
        shortcuts: shortcuts,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      flex: 5,
                      child: Text(tr.glAccountsComplete,style: textTheme.titleLarge?.copyWith(color: color.outline))),
                  Expanded(
                    flex: 3,
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
                      toolTip: 'F1',
                      width: 110,
                      icon: Icons.refresh,
                      onPressed: onRefresh,
                      label: Text(AppLocalizations.of(context)!.refresh)),
                  ZOutlineButton(
                      toolTip: 'F5',
                      width: 110,
                      isActive: true,
                      icon: Icons.add,
                      onPressed: onAdd,
                      label: Text(AppLocalizations.of(context)!.newKeyword)),
                ],
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 5),
              child: Row(
                children: [
                  Text(tr.accountNumber,style: textTheme.titleMedium?.copyWith(color: color.outline)),
                  SizedBox(width: 55),
                  Expanded(child: Text(tr.accountName,style: textTheme.titleMedium?.copyWith(color: color.outline))),
                  SizedBox(
                    width: 150,
                    child: Text(tr.categoryTitle,style: textTheme.titleMedium?.copyWith(color: color.outline)),
                  ),
                  SizedBox(
                    width: 185,
                    child: Text(tr.subCategory,style: textTheme.titleMedium?.copyWith(color: color.outline)),
                  ),

                ],
              ),
            ),
            Divider(endIndent: 2,indent: 2,color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),),

            Expanded(
              child: BlocConsumer<GlAccountsBloc, GlAccountsState>(
                listener: (context,state){
                  if(state is GlSuccessState){
                    Navigator.of(context).pop();
                  }
                  if(state is GlAccountsErrorState){
                    Utils.showOverlayMessage(context, message: state.message, isError: true);
                  }
                },
                builder: (context, state) {
                  if(state is GlAccountsLoadingState){
                   return Center(child: CircularProgressIndicator());
                  }
                  if(state is GlAccountLoadedState){
                    final query = searchController.text.toLowerCase().trim();

                    final filteredList = state.gl.where((item) {
                      final name = item.accName?.toLowerCase() ?? '';
                      final number = item.accNumber?.toString() ?? '';
                      return name.contains(query.toLowerCase()) || number.contains(query);
                    }).toList();

                    return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context,index){
                          final gl = filteredList[index];
                          return InkWell(
                            onTap: (){
                              showDialog(context: context, builder: (context){
                                return AddEditGl(model: gl);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 0,horizontal: 8),
                              decoration: BoxDecoration(
                                color: index.isEven ? Theme.of(context).colorScheme.primary.withValues(alpha: .05) : Colors.transparent,
                              ),
                              child: Row(
                                spacing: 10,
                                children: [
                                  SizedBox(
                                      width: 80,
                                      child: Text(gl.accNumber.toString(),style: Theme.of(context).textTheme.titleMedium)),
                                   myLocale == "en"? SizedBox(width: 50) : SizedBox(width: 20),
                                  Expanded(child: Text(gl.accName??"",style: Theme.of(context).textTheme.titleMedium)),
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                        Utils.glCategories(category: gl.accCategory!,locale: tr),
                                        style: Theme.of(context).textTheme.titleMedium,
                                        textAlign: TextAlign.center),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                        gl.acgName??"",
                                        style: Theme.of(context).textTheme.titleMedium,
                                        textAlign: TextAlign.center),
                                  ),

                                  SizedBox(
                                    width: 50,
                                    child: IconButton(
                                        onPressed: (){
                                          showDialog(context: context, builder: (context){
                                            return ZAlertDialog(title: tr.areYouSure,
                                                content: "Do wanna delete this code?",
                                                onYes: (){
                                                  context.read<GlAccountsBloc>().add(DeleteGlEvent(gl.accNumber!));
                                                });
                                          });
                                        },
                                        icon: Icon(Icons.delete_outline_rounded,color: color.outline,size: 20,)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  }
                  return SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onRefresh(){
    context.read<GlAccountsBloc>().add(LoadGlAccountEvent());
  }

  void onAdd(){
    showDialog(context: context, builder: (context){
      return AddEditGl();
    });
  }
}

