import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/Bloc/localizations_bloc.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../../Features/Date/gregorian_date_picker.dart';
import '../../../../../../../Features/Date/shamsi_date_picker.dart';
import '../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../../Features/Other/utils.dart';
import '../../../../../../../Features/PrintSettings/report_model.dart';
import '../../../../Finance/Ui/GlAccounts/bloc/gl_accounts_bloc.dart';
import '../../../../Finance/Ui/GlAccounts/model/gl_model.dart';
import 'bloc/acc_statement_bloc.dart';
import 'model/stmt_model.dart';
import 'package:shamsi_date/shamsi_date.dart';

class AccountStatementView extends StatelessWidget {
  const AccountStatementView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(),
    );
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
  final accountController = TextEditingController();
  int? accNumber;
  String? myLocale;

  String fromDate = DateTime.now()
      .subtract(Duration(days: 7))
      .toFormattedDate();
  String toDate = DateTime.now().toFormattedDate();
  Jalali shamsiFromDate = DateTime.now()
      .subtract(Duration(days: 7))
      .toAfghanShamsi;
  Jalali shamsiToDate = DateTime.now().toAfghanShamsi;

  List<AccountStatementModel> records = [];
  final accountStatementModel = AccountStatementModel();
  final company = ReportModel();

  @override
  void initState() {
    myLocale = context.read<LocalizationBloc>().state.languageCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    //context.read<AccStatementBloc>().add(ResetAccountStatementEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Utils.zBackButton(context),
                    Text(
                      locale.accountStatement,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                Row(
                  children: [
                    ZOutlineButton(
                      width: 100,
                      icon: FontAwesomeIcons.filePdf,
                      label: Text("PDF"),
                      onPressed: () {},
                    ),
                    SizedBox(width: 8),
                    ZOutlineButton(
                      isActive: true,
                      icon: Icons.call_to_action_outlined,
                      width: 100,
                      onPressed: () {
                        context.read<AccStatementBloc>().add(LoadAccountStatementEvent(
                            accountNumber: accNumber!, fromDate: fromDate, toDate: toDate));
                      },
                      label: Text(locale.apply),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 500,
                  child:
                      GenericTextfield<GlAccountsModel, GlAccountsBloc, GlAccountsState>(
                        showAllOnFocus: true,
                        controller: accountController,
                        title: locale.accounts,
                        hintText: locale.accNameOrNumber,
                        isRequired: true,
                        bloc: context.read<GlAccountsBloc>(),
                        fetchAllFunction: (bloc) => bloc.add(
                          LoadGlAccountEvent(
                            local: myLocale ?? "en",
                            categories: [5],
                          ),
                        ),
                        searchFunction: (bloc, query) => bloc.add(
                          LoadGlAccountEvent(
                            local: myLocale ?? "en",
                            categories: [5],
                            search: query,
                          ),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return locale.required(locale.accounts);
                          }
                          return null;
                        },
                        itemBuilder: (context, account) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 5,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${account.accNumber} | ${account.accName}",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        itemToString: (acc) =>
                            "${acc.accNumber} | ${acc.accName}",
                        stateToLoading: (state) =>
                            state is GlAccountsLoadingState,
                        loadingBuilder: (context) => const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                        stateToItems: (state) {
                          if (state is GlAccountLoadedState) {
                            return state.gl;
                          }
                          return [];
                        },
                        onSelected: (value) {
                          setState(() {
                            accNumber = value.accNumber;
                          });
                        },
                        noResultsText: locale.noDataFound,
                        showClearButton: true,
                      ),
                ),
                fromDateWidget(),
                toDateWidget(),
              ],
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    locale.txnDate,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),

                SizedBox(
                  width: 170,
                  child: Text(
                    locale.referenceNumber,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),

                Expanded(
                  child: Text(
                    locale.narration,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    locale.txnType,
                    textAlign: myLocale == "en"
                        ? TextAlign.left
                        : TextAlign.right,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    locale.debitTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    locale.creditTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: Text(
                    locale.balance,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            endIndent: 10,
            indent: 10,
            color: Theme.of(context).colorScheme.primary,
          ),
          Expanded(
            child: BlocBuilder<AccStatementBloc, AccStatementState>(
              builder: (context, state) {
                if (state is AccStatementLoadingState) {
                  return CircularProgressIndicator();
                }
                if (state is AccStatementErrorState) {
                  return Text(state.message);
                }
                if (state is AccStatementLoadedState) {
                  return ListView.builder(
                    itemCount: state.record.length,
                    itemBuilder: (context, index) {
                      final stmt = state.record[index];

                      return InkWell(
                        hoverColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .09),
                        highlightColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .09),
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: index.isOdd
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.05)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  stmt.trnEntryDate.toFormattedDate(),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              SizedBox(
                                width: 160,
                                child: Text(stmt.trnReference ?? ""),
                              ),
                              Expanded(child: Text(stmt.trdNarration ?? "")),

                              SizedBox(
                                width: 110,
                                child: Text(
                                  stmt.debit?.toAmount() ?? "",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),

                              SizedBox(
                                width: 110,
                                child: Text(
                                  stmt.credit?.toAmount() ?? "",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              SizedBox(
                                width: 145,
                                child: Text(
                                  stmt.total?.toAmount() ?? "",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ],
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

  Widget fromDateWidget() {
    final locale = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    return Flexible(
      flex: 2,
      child: Column(
        spacing: 4,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locale.fromDate, style: TextStyle(color: color.secondary)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            width: 160,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: color.secondary.withValues(alpha: .4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //From Gregorian
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return GregorianDatePicker(
                              onDateSelected: (value) {
                                setState(() {
                                  fromDate = value.toFormattedDate();
                                  //  accountStatementModel.startDate = fromDate;
                                });
                              },
                            );
                          },
                        );
                      },
                      child: Text(fromDate, style: TextStyle(fontSize: 12)),
                    ),

                    //From Shamsi
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AfghanDatePicker(
                              onDateSelected: (value) {
                                setState(() {
                                  fromDate = value.toGregorianString();
                                });
                              },
                            );
                          },
                        );
                      },
                      child: Text(
                        fromDate.shamsiDateFormatted,
                        style: TextStyle(
                          fontSize: 10,
                          color: color.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Icon(Icons.calendar_today_rounded, color: color.secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget toDateWidget() {
    final locale = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    return Flexible(
      flex: 2,
      child: Column(
        spacing: 4,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locale.toDate, style: TextStyle(color: color.secondary)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            width: 160,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: color.secondary.withValues(alpha: .4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return GregorianDatePicker(
                              onDateSelected: (value) {
                                setState(() {
                                  toDate = value.toFormattedDate();
                                  // accountStatementModel.endDate = toDate;
                                });
                              },
                            );
                          },
                        );
                      },
                      child: Text(toDate, style: TextStyle(fontSize: 12)),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AfghanDatePicker(
                              onDateSelected: (value) {
                                setState(() {
                                  toDate = value.toGregorianString();
                                });
                              },
                            );
                          },
                        );
                      },
                      child: Text(
                        toDate.shamsiDateFormatted,
                        style: TextStyle(
                          fontSize: 10,
                          color: color.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Icon(Icons.calendar_today_rounded, color: color.secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
