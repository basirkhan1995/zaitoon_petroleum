import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/status_badge.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/ArApReport/bloc/ar_ap_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/ArApReport/model/ar_ap_model.dart';
import '../../../../../../../../Features/PrintSettings/report_model.dart';
import '../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../../Auth/bloc/auth_bloc.dart';

class PayablesView extends StatelessWidget {
  const PayablesView({super.key});

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
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<ArApBloc>().add(LoadArApEvent());
    });
    super.initState();
  }

  final searchController = TextEditingController();
  final company = ReportModel();
  List<ArApModel> payables = [];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle? title = Theme.of(context).textTheme.titleMedium;
    TextStyle? subTitle = Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline);
    TextStyle? subtitle1 = Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface);
    final tr = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Get company info from auth state
        if (state is AuthenticatedState) {

        }

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(tr.creditors),
            titleSpacing: 0,
          ),
          body: Column(
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 8,
                  children: [
                    Expanded(
                      child: ZSearchField(
                        icon: FontAwesomeIcons.magnifyingGlass,
                        controller: searchController,
                        title: '',
                        onChanged: (e){
                          setState(() {});
                        },
                        hint: tr.accountName,
                      ),
                    ),
                    ZOutlineButton(
                      width: 110,
                      icon: FontAwesomeIcons.solidFilePdf,
                      label: Text("PDF"),
                      onPressed: (){


                      },
                    )
                  ],
                ),
              ),
              // Rest of your UI remains the same...
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  children: [
                    SizedBox(
                        width: 280,
                        child: Text(tr.accounts,style: title,)),
                    SizedBox(
                        width: 200,
                        child: Text(tr.accountLimit,style: title,)),
                    Expanded(child: Text(tr.signatory,style: title,)),
                    Text(tr.balance,style: title,),
                  ],
                ),
              ),
              Divider(
                indent: 15,endIndent: 15,
              ),
              Expanded(
                child: BlocBuilder<ArApBloc, ArApState>(
                  builder: (context, state) {
                    if(state is ArApErrorState){
                      return NoDataWidget(
                        message: state.error,
                      );
                    }
                    if(state is ArApLoadingState){
                      return Center(
                          child: CircularProgressIndicator());
                    }
                    if(state is ArApLoadedState){
                      final query = searchController.text.toLowerCase().trim();
                      final filteredList = state.apAccounts.where((item) {
                        final name = item.accName?.toLowerCase() ?? '';
                        final accNumber = item.accNumber?.toString() ?? '';
                        return name.contains(query) || accNumber.contains(query);
                      }).toList();
                      payables = filteredList; // Store for PDF

                      return ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (context,index){
                            final ap = filteredList[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 8),
                              decoration: BoxDecoration(
                                  color: index.isOdd? Theme.of(context).colorScheme.outline.withValues(alpha: .05) : Colors.transparent
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 280,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(ap.accName??"",style: title),
                                        SizedBox(height: 2),
                                        Row(
                                          spacing: 5,
                                          children: [
                                            StatusBadge(status: ap.accStatus!,trueValue: tr.active,falseValue: tr.blocked),
                                            ZCard(
                                                color: Theme.of(context).colorScheme.primary.withValues(alpha: .03),
                                                padding: EdgeInsets.symmetric(horizontal: 5,vertical: 2),
                                                child: Text(ap.accNumber.toString(),style: subtitle1)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    width: 200,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(ap.accLimit.toAmount(),style: title),
                                        Text(ap.accCurrency??"",style: subTitle),
                                      ],
                                    ),
                                  ),

                                  Expanded(child: Text(ap.fullName??"",style: Theme.of(context).textTheme.titleMedium)),
                                  Text("${ap.accBalance.toAmount()} ${ap.accCurrency}",style: Theme.of(context).textTheme.titleMedium),

                                ],
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
      },
    );
  }
  Widget totalPayableCard({
    required BuildContext context,
    required double amount,
    required String currency,
  }) {
    final color = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.primary.withValues(alpha: .2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.handHoldingDollar,
                  color: color.primary),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.totalTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          Text(
            "${amount.toAmount()} $currency",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
              fontWeight: FontWeight.bold,
              color: color.primary,
            ),
          ),
        ],
      ),
    );
  }

}

