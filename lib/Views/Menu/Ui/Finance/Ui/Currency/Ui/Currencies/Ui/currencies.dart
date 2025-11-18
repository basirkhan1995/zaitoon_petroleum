import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/Currencies/Ui/add_edit_ccy.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/Currencies/bloc/currencies_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flag/flag.dart';

import '../../../../../../../../../Features/Other/cover.dart';
import '../../../../../../../../../Features/Widgets/button.dart';
import '../../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../../Features/Widgets/search_field.dart';
class CurrenciesView extends StatelessWidget {
  const CurrenciesView({super.key});

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
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8,
              children: [
                Expanded(
                  child: ZSearchField(
                    controller: searchController,
                    title: '',
                    hint: locale.search,
                    end: searchController.text.isNotEmpty
                        ? InkWell(
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          searchController.clear();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        child: Icon(Icons.clear, size: 15),
                      ),
                    )
                        : SizedBox(),
                    onChanged: (e) {
                      setState(() {});
                    },
                    icon: FontAwesomeIcons.magnifyingGlass,
                  ),
                ),
                Row(
                  spacing: 8,
                  children: [
                    ZOutlineButton(
                      width: 110,
                      icon: Icons.refresh,
                      label: Text(AppLocalizations.of(context)!.refresh),
                      onPressed: (){
                        context.read<CurrenciesBloc>().add(LoadCurrenciesEvent());
                      },
                    ),
                    ZButton(
                      width: 110,
                      label: Text(AppLocalizations.of(context)!.newKeyword),
                      onPressed: (){
                        showDialog(context: context, builder: (context){
                          return AddEditCurrencyView();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    locale.flag,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    locale.currencyCode,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: Text(
                    locale.currencyTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),

                Spacer(),
                SizedBox(
                  width: 70,
                  child: Text(
                    locale.symbol,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),

                SizedBox(width: 10),
                SizedBox(
                  width: 60,
                  child: Text(
                    locale.status,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: .09),
          ),
          Expanded(
            child: BlocBuilder<CurrenciesBloc, CurrenciesState>(
              builder: (context, state) {
                if(state is CurrenciesLoadingState){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } if(state is CurrenciesErrorState){
                  return NoDataWidget(
                    message: state.message,
                    onRefresh: (){
                      context.read<CurrenciesBloc>().add(LoadCurrenciesEvent());
                    },
                  );
                } if(state is CurrenciesLoadedState){

                  final query = searchController.text.toLowerCase().trim();
                  final filteredCcy = state.ccy.where((item) {
                    final ccyCode = item.ccyCode?.toLowerCase() ?? '';
                    final ccyName = item.ccyName?.toLowerCase() ?? '';
                    return ccyCode.contains(query) || ccyName.contains(query);
                  }).toList();

                  return ListView.builder(
                      itemCount: filteredCcy.length,
                      itemBuilder: (context,index){
                        final ccy = filteredCcy[index];
                      return InkWell(
                        hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: .05),
                        highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: .05),
                        onTap: (){
                          showDialog(context: context, builder: (context){
                            return AddEditCurrencyView(currency: ccy);
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: index.isOdd
                                ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: .05)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 30,
                                child: Flag.fromString(
                                  ccy.ccyCountryCode??"",
                                  height: 20,
                                  width: 30,
                                  borderRadius: 2,
                                  fit: BoxFit.fill,
                                ),
                              ),

                              SizedBox(width: 20),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  ccy.ccyCode ?? "",
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),

                              SizedBox(
                                width: 190,
                                child: Text(
                                  ccy.ccyName ?? "",
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Spacer(),
                              Cover(
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  ccy.ccySymbol ?? "",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              SizedBox(width: 30),
                              SizedBox(
                                width: 70,
                                child: Checkbox(
                                    visualDensity: VisualDensity(vertical: -4),
                                    value: ccy.ccyStatus == 1? true : false,
                                    onChanged: (e){
                                     // context.read<CurrenciesBloc>().add(UpdateCcyStatusEvent(ccyId: ccy.ccyId!,ccyStatus: e == true? 1 : 0));
                                    }),
                              ),
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

