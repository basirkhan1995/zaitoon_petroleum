import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/Bloc/localizations_bloc.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../../../../../../../Features/Date/gregorian_date_picker.dart';
import '../../../../../../../Features/Date/shamsi_date_picker.dart';
import '../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../../Features/Other/utils.dart';
import '../../../../../../../Features/PrintSettings/print_preview.dart';
import '../../../../../../../Features/PrintSettings/report_model.dart';
import '../../../../Finance/Ui/GlAccounts/bloc/gl_accounts_bloc.dart';
import '../../../../Finance/Ui/GlAccounts/model/gl_model.dart';
import '../../../../Journal/Ui/TxnByReference/bloc/txn_reference_bloc.dart';
import '../../../../Journal/Ui/TxnByReference/txn_reference.dart';
import 'PDF/pdf.dart';
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
  final formKey = GlobalKey<FormState>();

  String fromDate = DateTime.now()
      .subtract(Duration(days: 7))
      .toFormattedDate();
  String toDate = DateTime.now().toFormattedDate();
  Jalali shamsiFromDate = DateTime.now()
      .subtract(Duration(days: 7))
      .toAfghanShamsi;
  Jalali shamsiToDate = DateTime.now().toAfghanShamsi;

  List<AccountStatementModel> records = [];
  AccountStatementModel? accountStatementModel;
  final company = ReportModel();

  @override
  void initState() {
    myLocale = context.read<LocalizationBloc>().state.languageCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    context.read<AccStatementBloc>().add(ResetAccStmtEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocBuilder<CompanyProfileBloc, CompanyProfileState>(
      builder: (context, state) {
        if(state is CompanyProfileLoadedState){
          company.comName = state.company.comName??"";
          company.comAddress = state.company.addName??"";
          company.compPhone = state.company.comPhone??"";
          company.comEmail = state.company.comEmail??"";
          company.startDate = fromDate;
          company.endDate = toDate;
          company.statementDate = DateTime.now().toFullDateTime;

        }
    return BlocConsumer<TxnReferenceBloc, TxnReferenceState>(
        listener: (context, state) {
          if (state is TxnReferenceLoadedState) {
            showDialog(
              context: context,
              builder: (context) {
                return TxnReferenceView();
              },
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 5,
                  ),
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
                            onPressed: (){
                             if(formKey.currentState!.validate()){
                               showDialog(
                                 context: context,
                                 builder:
                                     (_) => PrintPreviewDialog<AccountStatementModel>(
                                   data: accountStatementModel!,
                                   company: company,
                                   buildPreview: ({
                                     required data,
                                     required language,
                                     required orientation,
                                     required pageFormat,
                                   }) {
                                     return AccountStatementPrintSettings().printPreview(
                                         company: company,
                                         language: language,
                                         orientation: orientation,
                                         pageFormat: pageFormat,
                                         info: accountStatementModel!
                                     );
                                   },
                                   onPrint: ({
                                     required data,
                                     required language,
                                     required orientation,
                                     required pageFormat,
                                     required selectedPrinter,
                                     required copies,
                                     required pages, // This will now work
                                   }) {
                                     return AccountStatementPrintSettings()
                                         .printDocument(
                                       statement: records,
                                       company: company,
                                       language: language,
                                       orientation: orientation,
                                       pageFormat: pageFormat,
                                       selectedPrinter: selectedPrinter,
                                       info: accountStatementModel!,
                                       copies: copies,
                                       pages: pages, // Pass pages to your print method
                                     );
                                   },
                                   onSave: ({
                                     required data,
                                     required language,
                                     required orientation,
                                     required pageFormat,
                                   }) {
                                     return AccountStatementPrintSettings().createDocument(
                                       statement: records,
                                       company: company,
                                       language: language,
                                       orientation: orientation,
                                       pageFormat: pageFormat,
                                       info: accountStatementModel!,
                                     );
                                   },
                                 ),
                               );
                             }else{
                               Utils.showOverlayMessage(context, message: locale.accountStatementMessage, isError: true);
                             }
                            },
                          ),
                          SizedBox(width: 8),
                          ZOutlineButton(
                            isActive: true,
                            icon: Icons.call_to_action_outlined,
                            width: 100,
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                              onSubmit();
                              }
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          locale.txnDate,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      SizedBox(
                        width: 190,
                        child: Text(
                          locale.referenceNumber,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          locale.narration,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                          textAlign: myLocale == "en"
                              ? TextAlign.right
                              : TextAlign.left,
                          locale.debitTitle,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                          textAlign: myLocale == "en"
                              ? TextAlign.right
                              : TextAlign.left,
                          locale.creditTitle,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      SizedBox(
                        width: 130,
                        child: Text(
                          textAlign: myLocale == "en"
                              ? TextAlign.right
                              : TextAlign.left,
                          locale.balance,
                          style: Theme.of(context).textTheme.titleSmall,
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
                        return Center(child: CircularProgressIndicator());
                      }
                      if (state is AccStatementErrorState) {
                        return Center(child: Text(state.message));
                      }
                      if (state is AccStatementLoadedState) {
                        final records = state.accStatementDetails.records;
                        accountStatementModel = state.accStatementDetails;
                        if (records == null || records.isEmpty) {
                          return Center(child: Text("No transactions found"));
                        }

                        return ListView.builder(
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            final stmt = records[index];
                            Color bg =
                                stmt.trdNarration == "Opening Balance" ||
                                    stmt.trdNarration == "Closing Balance"
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary;
                            bool isOp =
                                stmt.trdNarration == "Opening Balance" ||
                                stmt.trdNarration == "Closing Balance";
                            return InkWell(
                              hoverColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.05),
                              highlightColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.05),
                              onTap: isOp
                                  ? null
                                  : () {
                                      context.read<TxnReferenceBloc>().add(
                                        FetchTxnByReferenceEvent(
                                          stmt.trnReference ?? "",
                                        ),
                                      );
                                    },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: index.isOdd
                                      ? Theme.of(context).colorScheme.primary
                                            .withValues(alpha: 0.05)
                                      : Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        stmt.trnEntryDate?.toFormattedDate() ??
                                            "",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 190,
                                      child: Text(stmt.trnReference ?? ""),
                                    ),
                                    Expanded(
                                      child: Text(
                                        stmt.trdNarration ?? "",
                                        style: TextStyle(color: bg),
                                      ),
                                    ),
                                    Text(stmt.status??"",style: TextStyle(color: Theme.of(context).colorScheme.error),),
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        textAlign: myLocale == "en"
                                            ? TextAlign.right
                                            : TextAlign.left,
                                        "${stmt.debit?.toAmount()}",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),

                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        textAlign: myLocale == "en"
                                            ? TextAlign.right
                                            : TextAlign.left,
                                        "${stmt.credit?.toAmount()}",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 130,
                                      child: Text(
                                        textAlign: myLocale == "en"
                                            ? TextAlign.right
                                            : TextAlign.left,
                                        "${stmt.total?.toAmount()}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(color: bg),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return Center(
                        child: NoDataWidget(
                          title: locale.accountStatement,
                          message:
                              locale.accountStatementMessage,
                          enableAction: false,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
  },
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
                                  onSubmit();
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
                                onSubmit();
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
  void onSubmit(){
    context.read<AccStatementBloc>().add(
      LoadAccountStatementEvent(
        accountNumber: accNumber!,
        fromDate: fromDate,
        toDate: toDate,
      ),
    );
  }
}
