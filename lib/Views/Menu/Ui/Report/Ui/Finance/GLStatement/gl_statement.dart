import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Date/z_generic_date.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/Bloc/localizations_bloc.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/features/currency_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/GlAccounts/bloc/gl_accounts_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/GlAccounts/model/gl_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/features/branch_dropdown.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/GLStatement/bloc/gl_statement_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/GLStatement/model/gl_statement_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../../Features/Other/utils.dart';
import '../../../../../../../Features/PrintSettings/print_preview.dart';
import '../../../../../../../Features/PrintSettings/report_model.dart';
import '../../../../Journal/Ui/TxnByReference/bloc/txn_reference_bloc.dart';
import '../../../../Journal/Ui/TxnByReference/txn_reference.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'dart:typed_data';

import 'PDF/pdf.dart';

class GlStatementView extends StatelessWidget {
  const GlStatementView({super.key});

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
  final Map<String, bool> _copiedStates = {};
  final accountController = TextEditingController();
  int? accNumber;
  String? myLocale;
  String? currency;
  int branchCode = 1000;
  String? baseCurrency;
  final formKey = GlobalKey<FormState>();
  Uint8List _companyLogo = Uint8List(0);
  final company = ReportModel();
  String fromDate = DateTime.now().subtract(Duration(days: 7)).toFormattedDate();
  String toDate = DateTime.now().toFormattedDate();
  Jalali shamsiFromDate = DateTime.now().subtract(Duration(days: 7)).toAfghanShamsi;
  Jalali shamsiToDate = DateTime.now().toAfghanShamsi;

  List<GlStatementModel> records = [];
  GlStatementModel? accountStatementModel;

  @override
  void initState() {
    myLocale = context.read<LocalizationBloc>().state.languageCode;
    context.read<GlStatementBloc>().add(ResetGlStmtEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    double dateWith = 100;
    double refWidth = 240;
    double amountWidth = 130;
    double balanceWidth =  160;

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
            final base64Logo = state.company.comLogo;
            if (base64Logo != null && base64Logo.isNotEmpty) {
              try {
                _companyLogo = base64Decode(base64Logo);
                company.comLogo = _companyLogo;
              } catch (e) {
                _companyLogo = Uint8List(0);
              }
            }
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                                  tr.glStatement,
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
                                        pdf();
                                    }else{
                                      Utils.showOverlayMessage(context, message: tr.accountStatementMessage, isError: true);
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
                                  label: Text(tr.apply),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child:
                              GenericTextfield<GlAccountsModel, GlAccountsBloc, GlAccountsState>(
                                showAllOnFocus: true,
                                controller: accountController,
                                title: tr.accounts,
                                hintText: tr.accNameOrNumber,
                                isRequired: true,
                                bloc: context.read<GlAccountsBloc>(),
                                fetchAllFunction: (bloc) => bloc.add(
                                  LoadGlAccountEvent(),
                                ),
                                searchFunction: (bloc, query) => bloc.add(
                                  LoadGlAccountEvent(

                                  ),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return tr.required(tr.accounts);
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
                                noResultsText: tr.noDataFound,
                                showClearButton: true,
                              ),

                            ),
                            SizedBox(
                              width: 200,
                              child: BranchDropdown(
                                  height: 40,
                                  onBranchSelected: (e){
                                    setState(() {
                                      branchCode = e.brcId ?? 1000;
                                    });
                                  }),
                            ),
                            SizedBox(
                              width: 160,
                              child: CurrencyDropdown(
                                   title: AppLocalizations.of(context)!.currencyTitle,
                                  isMulti: false,
                                  onMultiChanged: (e){},
                                 onSingleChanged: (e){
                                   setState(() {
                                     currency = e?.ccyCode ??"";
                                   });
                                 },
                              ),
                            ),
                            SizedBox(
                              width: 150,
                              child: ZDatePicker(
                                label: tr.fromDate,
                                value: fromDate,
                                onDateChanged: (v) {
                                  setState(() {
                                    fromDate = v;
                                    shamsiFromDate = v.toAfghanShamsi;
                                  });
                                },
                              ),
                            ),

                            SizedBox(
                              width: 150,
                              child: ZDatePicker(
                                label: tr.toDate,
                                value: toDate,
                                onDateChanged: (v) {
                                  setState(() {
                                    toDate = v;
                                    shamsiToDate = v.toAfghanShamsi;
                                  });
                                },
                              ),
                            ),


                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: dateWith,
                              child: Text(
                                tr.txnDate,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            SizedBox(
                              width: refWidth,
                              child: Text(
                                tr.referenceNumber,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                tr.narration,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            SizedBox(
                              width: amountWidth,
                              child: Text(
                                textAlign: myLocale == "en"
                                    ? TextAlign.right
                                    : TextAlign.left,
                                tr.debitTitle,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            SizedBox(
                              width: amountWidth,
                              child: Text(
                                textAlign: myLocale == "en"
                                    ? TextAlign.right
                                    : TextAlign.left,
                                tr.creditTitle,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            SizedBox(
                              width: balanceWidth,
                              child: Text(
                                textAlign: myLocale == "en"
                                    ? TextAlign.right
                                    : TextAlign.left,
                                tr.balance,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            SizedBox(width: 15),
                          ],
                        ),
                      ),
                      Divider(
                        endIndent: 10,
                        indent: 10,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Expanded(
                        child: BlocBuilder<GlStatementBloc, GlStatementState>(
                          builder: (context, state) {
                            if (state is GlStatementLoadingState) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (state is GlStatementErrorState) {
                              return Center(child: Text(state.message));
                            }
                            if (state is GlStatementLoadedState) {
                              final records = state.stmt.records;
                              accountStatementModel = state.stmt;
                              if (records == null || records.isEmpty) {
                                return Center(child: Text("No transactions found"));
                              }

                              return ListView.builder(
                                itemCount: records.length,
                                itemBuilder: (context, index) {

                                  final stmt = records[index];
                                  final isCopied = _copiedStates[stmt.trnReference ?? ""] ?? false;
                                  final reference = stmt.trnReference ?? "";
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
                                        vertical: 8,
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
                                            width: dateWith,
                                            child: Text(
                                              stmt.trnEntryDate?.toFormattedDate() ??
                                                  "",
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleSmall,
                                            ),
                                          ),
                                          SizedBox(
                                            width: refWidth,
                                            child: Row(
                                              children: [
                                                if(stmt.trnReference !=null && stmt.trnReference!.isNotEmpty)...[
                                                  SizedBox(
                                                    width: 28,
                                                    height: 28,
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () => _copyToClipboard(reference, context),
                                                        borderRadius: BorderRadius.circular(4),
                                                        hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: .05),
                                                        child: AnimatedContainer(
                                                          duration: const Duration(milliseconds: 100),
                                                          decoration: BoxDecoration(
                                                            color: isCopied
                                                                ? Theme.of(context).colorScheme.primary.withAlpha(25)
                                                                : Colors.transparent,
                                                            border: Border.all(
                                                              color: isCopied
                                                                  ? Theme.of(context).colorScheme.primary
                                                                  : Theme.of(context).colorScheme.outline.withValues(alpha: .3),
                                                              width: 1,
                                                            ),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: Center(
                                                            child: AnimatedSwitcher(
                                                              duration: const Duration(milliseconds: 300),
                                                              child: Icon(
                                                                isCopied ? Icons.check : Icons.content_copy,
                                                                key: ValueKey<bool>(isCopied), // Important for AnimatedSwitcher
                                                                size: 15,
                                                                color: isCopied
                                                                    ? Theme.of(context).colorScheme.primary
                                                                    : Theme.of(context).colorScheme.outline.withValues(alpha: .6),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                ],
                                                Expanded(
                                                    child:
                                                    Text(stmt.trnReference.toString())),
                                              ],
                                            ),
                                          ),

                                          Expanded(
                                            child: Text(stmt.trdNarration ?? ""),
                                          ),

                                          SizedBox(
                                            width: amountWidth,
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
                                            width: amountWidth,
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
                                            width: balanceWidth,
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
                                          SizedBox(
                                              width: 15,
                                              child: Text(stmt.status??"",
                                                textAlign: myLocale == "en"? TextAlign.right : TextAlign.left,
                                                style: TextStyle(color: Theme.of(context).colorScheme.error),)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                            return Center(
                              child: NoDataWidget(
                                title: tr.glStatement,
                                message:
                                tr.accountStatementMessage,
                                enableAction: false,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }



  void onSubmit(){
    context.read<GlStatementBloc>().add(
      LoadGlStatementEvent(
        currency: currency ?? "USD",
        branchCode: branchCode,
        accountNumber: accNumber!,
        fromDate: fromDate,
        toDate: toDate,
      ),
    );
  }

  void pdf(){
    showDialog(
      context: context,
      builder: (_) => PrintPreviewDialog<GlStatementModel>(
        data: accountStatementModel!,
        company: company,
        buildPreview: ({
          required data,
          required language,
          required orientation,
          required pageFormat,
        }) {
          return GlStatementPrintSettings().printPreview(
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
          required pages,
        }) {
          return GlStatementPrintSettings().printDocument(
            statement: records,
            company: company,
            language: language,
            orientation: orientation,
            pageFormat: pageFormat,
            selectedPrinter: selectedPrinter,
            info: accountStatementModel!,
            copies: copies,
            pages: pages,
          );
        },
        onSave: ({
          required data,
          required language,
          required orientation,
          required pageFormat,
        }) {
          return GlStatementPrintSettings().createDocument(
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
  }
  // Method to copy reference to clipboard
  Future<void> _copyToClipboard(String reference, BuildContext context) async {
    await Utils.copyToClipboard(reference);

    // Set copied state to true
    setState(() {
      _copiedStates[reference] = true;
    });

    // Reset after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedStates.remove(reference);
        });
      }
    });
  }
}
