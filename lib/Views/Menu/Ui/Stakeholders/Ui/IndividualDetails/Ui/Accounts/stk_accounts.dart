import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/Ui/edit_add.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/individual_model.dart';
import '../../../../../../../../Features/Other/cover.dart';
import '../../../../../../../../Features/Widgets/no_data_widget.dart';
import '../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../../../Localizations/l10n/translations/app_localizations.dart';

class AccountsByPerIdView extends StatelessWidget {
  final IndividualsModel ind;
  const AccountsByPerIdView({super.key,required this.ind});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), tablet: _Tablet(), desktop: _Desktop(ind));
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
  final IndividualsModel ind;
  const _Desktop(this.ind);

  @override
  State<_Desktop> createState() => _DesktopState();
}
class _DesktopState extends State<_Desktop> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AccountsBloc>().add(LoadAccountsEvent(ownerId: widget.ind.perId));
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
            padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 8),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: ZSearchField(
                    icon: FontAwesomeIcons.magnifyingGlass,
                    controller: searchController,
                    hint: locale.accNameOrNumber,
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
                    onPressed: onRefresh,
                    label: Text(locale.refresh)),
                ZOutlineButton(
                    width: 120,
                    isActive: true,
                    icon: Icons.add,
                    onPressed: (){
                      showDialog(context: context, builder: (context){
                        return AccountsAddEditView(signatory: widget.ind.perId);
                      });
                    },
                    label: Text(locale.newKeyword)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 5),
            child: Row(
              children: [
                Expanded(child: Text(locale.accountInformation,style: Theme.of(context).textTheme.titleMedium)),

                SizedBox(
                    width: 100,
                    child: Text(locale.currencyTitle,style: Theme.of(context).textTheme.titleMedium)),
                SizedBox(
                    width: 100,
                    child: Text(locale.balance,style: Theme.of(context).textTheme.titleMedium)),

              ],
            ),
          ),

          SizedBox(height: 5),
          Divider(
            indent: 15,endIndent: 15,color: Theme.of(context).colorScheme.primary,height: 0,
          ),
          SizedBox(height: 10),
          Expanded(
            child: BlocConsumer<AccountsBloc, AccountsState>(
              listener: (context,state){},
              builder: (context, state) {
                if (state is AccountLoadingState) {
                  return Center(child: CircularProgressIndicator());
                }
                if (state is AccountErrorState) {
                  return NoDataWidget(
                    message: state.message,
                    onRefresh: () {
                      context.read<AccountsBloc>().add(
                        LoadAccountsEvent(),
                      );
                    },
                  );
                }
                if (state is AccountLoadedState) {
                  final query = searchController.text.toLowerCase().trim();
                  final q = query.toLowerCase();

                  final filteredList = state.accounts.where((item) {
                    final name = item.accName?.toLowerCase() ?? '';
                    final number = (item.accNumber ?? '').toString().toLowerCase();
                    return name.contains(q) || number.contains(q);
                  }).toList();

                  if(filteredList.isEmpty){
                    return NoDataWidget(
                      message: locale.noDataFound,
                    );
                  }
                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final acc = filteredList[index];

                      // ---------- UI ----------
                      return InkWell(
                        highlightColor: color.primary.withValues(alpha: .06),
                        hoverColor: color.primary.withValues(alpha: .06),
                        onTap: () {
                           showDialog(context: context, builder: (context){
                             return AccountsAddEditView(model: acc);
                           });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: index.isOdd
                                ? color.primary.withValues(alpha: .06)
                                : Colors.transparent,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ---------- Avatar ----------
                                CircleAvatar(
                                  backgroundColor: color.primary.withValues(alpha: .7),
                                  radius: 23,
                                  child: Text(
                                    acc.accName!.getFirstLetter,
                                    style: TextStyle(
                                      color: color.surface,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // ---------- Name + Details ----------
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Full Name
                                      Text(
                                        acc.accName??"",
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),

                                      const SizedBox(height: 4),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 6.0),
                                        child: Cover(
                                          color: color.surface,
                                          child: Text(acc.accNumber.toString()),
                                        ),
                                      ),

                                    ],
                                  ),
                                ),

                                SizedBox(
                                    width: 100,
                                    child: Text(acc.actCurrency.toString())),
                                SizedBox(
                                    width: 100,
                                    child: Text("2500\$")),

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

  void onRefresh(){
    context.read<AccountsBloc>().add(LoadAccountsEvent(ownerId: widget.ind.perId));
  }
}

