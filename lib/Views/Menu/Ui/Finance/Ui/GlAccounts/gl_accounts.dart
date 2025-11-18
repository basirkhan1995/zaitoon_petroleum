import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import '../../../../../../Features/Other/utils.dart';
import '../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../Localizations/l10n/translations/app_localizations.dart';
import 'bloc/gl_accounts_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      context.read<GlAccountsBloc>().add(LoadGlAccountEvent(myLocale??"en"));
    });
    super.initState();
  }

  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final currentLocale = Localizations.localeOf(context).languageCode;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 10),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
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
                      // showDialog(context: context, builder: (context){
                      //   return GlActionView();
                      // });
                    },
                    label: Text(AppLocalizations.of(context)!.newKeyword)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 5),
            child: Row(
              children: [
                Text(locale.accountNumber,style: textTheme.titleMedium),
                SizedBox(width: currentLocale == "en"? 55 : 35),
                Text(locale.accountName,style: textTheme.titleMedium),
                Spacer(),
                Text(locale.accountCategory,style: textTheme.titleMedium,textAlign: TextAlign.center,),
              ],
            ),
          ),
          Divider(endIndent: 10,indent: 10,color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),),

          Expanded(
            child: BlocConsumer<GlAccountsBloc, GlAccountsState>(
              listener: (context,state){
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
                            // showDialog(context: context, builder: (context){
                            //   return GlActionView(gl: gl);
                            // });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                            margin: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: index.isEven ? Theme.of(context).colorScheme.primary.withValues(alpha: .09) : Colors.transparent,
                            ),
                            child: Row(
                              spacing: 10,
                              children: [
                                Text(gl.accNumber.toString(),style: Theme.of(context).textTheme.titleMedium),
                                 myLocale == "en"? SizedBox(width: 50) : SizedBox(width: 20),
                                Text(gl.accName??"",style: Theme.of(context).textTheme.titleMedium),
                                Spacer(),
                                Text(
                                    Utils.glCategories(category: gl.accCategory!,locale: locale),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center),
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
    );
  }

  void onRefresh(){
    context.read<GlAccountsBloc>().add(LoadGlAccountEvent(myLocale??"en"));
  }
}

