import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Localizations/Bloc/localizations_bloc.dart';
import 'package:zaitoon_petroleum/Views/Auth/models/login_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/GlAccounts/bloc/gl_accounts_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/GlAccounts/model/gl_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/View/all_transactions.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/View/authorized.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/View/pending.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/bloc/transactions_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/model/transaction_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/bloc/transaction_tab_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../Features/Generic/underline_tab.dart';
import '../../../../Features/Other/cover.dart';
import '../../../../Features/Other/responsive.dart';
import '../../../../Features/Other/shortcut.dart';
import '../../../../Features/Other/thousand_separator.dart';
import '../../../../Features/Widgets/outline_button.dart';
import '../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../Localizations/l10n/translations/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../Auth/bloc/auth_bloc.dart';
import '../Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import '../Stakeholders/Ui/Accounts/model/stk_acc_model.dart';
import 'Ui/FundTransfer/BulkTransfer/Ui/bulk_transfer.dart';


class JournalView extends StatelessWidget {
  const JournalView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(),
      tablet: _Tablet(),
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
  String? myLocale;
  String? usrName;

  @override
  void initState() {
    super.initState();
    // Delay context access until after initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          myLocale = context.read<LocalizationBloc>().state.languageCode;
        });
      }
    });
  }

  // Safe method to get base currency with fallback
  String? _getBaseCurrency(BuildContext context) {
    try {
      final companyState = context.read<CompanyProfileBloc>().state;
      if (companyState is CompanyProfileLoadedState) {
        return companyState.company.comLocalCcy;
      }
      return ""; // Fallback currency
    } catch (e) {
      return ""; // Fallback if provider not available
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseCurrency = _getBaseCurrency(context);
    final locale = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;
    final state = context.watch<AuthBloc>().state;
    TextStyle? headerStyle = textTheme.titleMedium?.copyWith(color: color.primary);
    TextStyle? titleStyle = textTheme.titleSmall?.copyWith(color: color.outline.withValues(alpha: .7));
    TextStyle? bodyStyle = textTheme.titleSmall;
    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = state.loginData;

    void onCashDepositWithdraw({String? trnType}) {
      final locale = AppLocalizations.of(context)!;
      final accountController = TextEditingController();
      final TextEditingController amount = TextEditingController();
      final TextEditingController narration = TextEditingController();

      String? currentBalance ;
      String? availableBalance;
      String? accName;
      int? accNumber;
      String? accCurrency;
      String? ccySymbol;
      String? accountLimit;
      int? status;
      showDialog(
        context: context,
        builder: (context) {
          return BlocBuilder<TransactionsBloc, TransactionsState>(
            builder: (context, trState) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return ZFormDialog(
                    width: 600,
                    icon: trnType == "CHDP" ? Icons.arrow_circle_down_rounded : Icons.arrow_circle_up_rounded,
                    title: trnType == "CHDP" ? locale.deposit : locale.withdraw,
                    onAction: () {
                      context.read<TransactionsBloc>().add(
                        OnCashTransactionEvent(
                          TransactionsModel(
                            usrName: login.usrName,
                            account: accNumber,
                            accCcy: accCurrency ?? "",
                            trnType: trnType,
                            amount: amount.text.cleanAmount,
                            narration: narration.text,
                          ),
                        ),
                      );
                    },
                    actionLabel: trState is TxnLoadingState
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.surface,
                              strokeWidth: 4,
                            ),
                          )
                        : Text(locale.create),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GenericTextfield<StakeholdersAccountsModel, AccountsBloc, AccountsState>(
                              showAllOnFocus: true,
                              controller: accountController,
                              title: locale.accounts,
                              hintText: locale.accNameOrNumber,
                              isRequired: true,
                              bloc: context.read<AccountsBloc>(),
                              fetchAllFunction: (bloc) => bloc.add(LoadStkAccountsEvent()),
                              searchFunction: (bloc, query) => bloc.add(LoadStkAccountsEvent(search: query)),
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${account.accnumber} | ${account.accName}",
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              itemToString: (acc) =>
                              "${acc.accnumber} | ${acc.accName}",
                              stateToLoading: (state) =>
                              state is AccountLoadingState,
                              loadingBuilder: (context) => const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 3),
                              ),
                              stateToItems: (state) {
                                if (state is StkAccountLoadedState) {
                                  return state.accounts;
                                }
                                return [];
                              },
                              onSelected: (value) {
                                setState(() {
                                  accNumber = value.accnumber;
                                  ccySymbol = value.ccySymbol;
                                  accCurrency = value.actCurrency;
                                  accName = value.accName ?? "";
                                  availableBalance = value.avilBalance;
                                  currentBalance = value.curBalance;
                                  accountLimit = value.actCreditLimit;
                                  status = value.actStatus ?? 0;
                                });
                              },
                              noResultsText: locale.noDataFound,
                              showClearButton: true,
                            ),
                            if(accName !=null && accName!.isNotEmpty)
                            Cover(
                              color: color.surface,
                              padding: EdgeInsets.symmetric(horizontal: 5,vertical: 8),
                              child: Column(
                                children: [
                                  if(accName !=null && accName!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Row(
                                        children: [
                                          Text(locale.details,style: headerStyle)
                                        ],
                                      ),
                                    ),
                                  if(accName !=null && accName!.isNotEmpty)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                      width: double.infinity,
                                      child: Row(
                                        spacing: 5,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            spacing: 5,
                                            children: [
                                              SizedBox(
                                                  width: 170,
                                                  child: Text("${locale.accountNumber}:",style: titleStyle)),
                                              SizedBox(
                                                  width: 170,
                                                  child: Text("${locale.accountName}:",style: titleStyle)),
                                              SizedBox(
                                                  width: 170,
                                                  child: Text("${locale.currencyTitle}:",style: titleStyle)),
                                              SizedBox(
                                                  width: 170,
                                                  child: Text("${locale.accountLimit}:",style: titleStyle)),
                                              SizedBox(
                                                  width: 170,
                                                  child: Text("${locale.status}:",style: titleStyle)),
                                              SizedBox(
                                                  width: 170,
                                                  child: Text("${locale.currentBalance}:",style: titleStyle)),
                                              SizedBox(
                                                  width: 170,
                                                  child: Text("${locale.availableBalance}:",style: titleStyle)),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            spacing: 5,
                                            children: [
                                              Text(accNumber.toString(),style: bodyStyle),
                                              Text(accName??""),
                                              Text(accCurrency??""),
                                              Text("$ccySymbol${accountLimit?.toAmount()}",style: bodyStyle),
                                              Text(status == 1? locale.active : locale.blocked,style: bodyStyle),
                                              Text("$ccySymbol${currentBalance?.toAmount()}",style: bodyStyle),
                                              Text("$ccySymbol${availableBalance?.toAmount()}",style: bodyStyle),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if(accName !=null && accName!.isNotEmpty)
                            SizedBox(height: 5),
                            ZTextFieldEntitled(
                              isRequired: true,
                              // onSubmit: (_)=> onSubmit(),
                              keyboardInputType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormat: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]*'),
                                ),
                                SmartThousandsDecimalFormatter(),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return locale.required(locale.exchangeRate);
                                }

                                // Remove formatting (e.g. commas)
                                final clean = value.replaceAll(
                                  RegExp(r'[^\d.]'),
                                  '',
                                );
                                final amount = double.tryParse(clean);

                                if (amount == null || amount <= 0.0) {
                                  return locale.amountGreaterZero;
                                }

                                return null;
                              },
                              controller: amount,
                              title: locale.amount,
                            ),
                            ZTextFieldEntitled(
                              // onSubmit: (_)=> onSubmit(),
                              keyboardInputType: TextInputType.multiline,
                              controller: narration,
                              title: locale.narration,
                            ),

                            if(trState is TransactionErrorState)
                            SizedBox(height: 10),
                            Row(
                              children: [
                                trState is TransactionErrorState? Text(trState.message) : SizedBox()
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              );
            },
          );
        },
      );
    }
    void onCashIncome({String? trnType}) {
      final locale = AppLocalizations.of(context)!;
      final accountController = TextEditingController();
      final TextEditingController amount = TextEditingController();
      final TextEditingController narration = TextEditingController();
      int? accNumber;

      showDialog(
        context: context,
        builder: (context) {
          return BlocBuilder<TransactionsBloc, TransactionsState>(
            builder: (context, trState) {
              return ZFormDialog(
                width: 600,
                icon: Icons.arrow_circle_down_rounded,
                title: locale.income,
                onAction: () {
                  context.read<TransactionsBloc>().add(
                    OnCashTransactionEvent(
                      TransactionsModel(
                        usrName: login.usrName,
                        account: accNumber,
                        accCcy: baseCurrency,
                        trnType: trnType,
                        amount: amount.text.cleanAmount,
                        narration: narration.text,
                      ),
                    ),
                  );
                },
                actionLabel: trState is TxnLoadingState
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      )
                    : Text(locale.create),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                              categories: [3],
                            ),
                          ),
                          searchFunction: (bloc, query) => bloc.add(
                            LoadGlAccountEvent(
                              local: myLocale ?? "en",
                              categories: [3],
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
                        ZTextFieldEntitled(
                          isRequired: true,
                          // onSubmit: (_)=> onSubmit(),
                          keyboardInputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormat: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]*'),
                            ),
                            SmartThousandsDecimalFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return locale.required(locale.exchangeRate);
                            }

                            // Remove formatting (e.g. commas)
                            final clean = value.replaceAll(
                              RegExp(r'[^\d.]'),
                              '',
                            );
                            final amount = double.tryParse(clean);

                            if (amount == null || amount <= 0.0) {
                              return locale.amountGreaterZero;
                            }

                            return null;
                          },
                          controller: amount,
                          title: locale.amount,
                        ),
                        ZTextFieldEntitled(
                          // onSubmit: (_)=> onSubmit(),
                          keyboardInputType: TextInputType.multiline,
                          controller: narration,
                          title: locale.narration,
                        ),

                        if(trState is TransactionErrorState)
                          SizedBox(height: 10),
                        Row(
                          children: [
                            trState is TransactionErrorState? Text(trState.message) : SizedBox()
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }
    void onCashExpense({String? trnType}) {
      final locale = AppLocalizations.of(context)!;
      final accountController = TextEditingController();
      final TextEditingController amount = TextEditingController();
      final TextEditingController narration = TextEditingController();
      int? accNumber;

      showDialog(
        context: context,
        builder: (context) {
          return BlocBuilder<TransactionsBloc, TransactionsState>(
            builder: (context, trState) {
              return ZFormDialog(
                width: 600,
                icon: Icons.arrow_circle_up_rounded,
                title: locale.expense,
                onAction: () {
                  context.read<TransactionsBloc>().add(
                    OnCashTransactionEvent(
                      TransactionsModel(
                        usrName: login.usrName,
                        account: accNumber,
                        accCcy: baseCurrency ?? "",
                        trnType: trnType ?? "",
                        amount: amount.text.cleanAmount,
                        narration: narration.text,
                      ),
                    ),
                  );
                },
                actionLabel: trState is TxnLoadingState
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      )
                    : Text(locale.create),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                              categories: [4],
                            ),
                          ),
                          searchFunction: (bloc, query) => bloc.add(
                            LoadGlAccountEvent(
                              local: myLocale ?? "en",
                              categories: [4],
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

                        ZTextFieldEntitled(
                          isRequired: true,
                          // onSubmit: (_)=> onSubmit(),
                          keyboardInputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormat: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]*'),
                            ),
                            SmartThousandsDecimalFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return locale.required(locale.exchangeRate);
                            }

                            // Remove formatting (e.g. commas)
                            final clean = value.replaceAll(
                              RegExp(r'[^\d.]'),
                              '',
                            );
                            final amount = double.tryParse(clean);

                            if (amount == null || amount <= 0.0) {
                              return locale.amountGreaterZero;
                            }

                            return null;
                          },
                          controller: amount,
                          title: locale.amount,
                        ),
                        ZTextFieldEntitled(
                          // onSubmit: (_)=> onSubmit(),
                          keyboardInputType: TextInputType.multiline,
                          controller: narration,
                          title: locale.narration,
                        ),
                        if(trState is TransactionErrorState)
                          SizedBox(height: 10),
                        Row(
                          children: [
                            trState is TransactionErrorState? Text(trState.message) : SizedBox()
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }
    void onGL({String? trnType}) {
      final locale = AppLocalizations.of(context)!;
      final accountController = TextEditingController();
      final TextEditingController amount = TextEditingController();
      final TextEditingController narration = TextEditingController();
      int? accNumber;

      showDialog(
        context: context,
        builder: (context) {
          return BlocBuilder<TransactionsBloc, TransactionsState>(
            builder: (context, trState) {
              return ZFormDialog(
                width: 600,
                icon: Icons.cached_rounded,
                title: trnType == "GLCR"
                    ? locale.glCreditTitle
                    : locale.glDebitTitle,
                onAction: () {
                  context.read<TransactionsBloc>().add(
                    OnCashTransactionEvent(
                      TransactionsModel(
                        usrName: login.usrName,
                        account: accNumber,
                        accCcy: baseCurrency,
                        trnType: trnType,
                        amount: amount.text.cleanAmount,
                        narration: narration.text,
                      ),
                    ),
                  );
                },
                actionLabel: trState is TxnLoadingState
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      )
                    : Text(locale.create),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GenericTextfield<
                          GlAccountsModel,
                          GlAccountsBloc,
                          GlAccountsState
                        >(
                          showAllOnFocus: true,
                          controller: accountController,
                          title: locale.accounts,
                          hintText: locale.accNameOrNumber,
                          isRequired: true,
                          bloc: context.read<GlAccountsBloc>(),
                          fetchAllFunction: (bloc) => bloc.add(
                            LoadGlAccountEvent(
                              local: myLocale ?? "en",
                              categories: [1, 2, 3, 4],
                              excludeAccounts: [10101010, 10101011],
                            ),
                          ),
                          searchFunction: (bloc, query) => bloc.add(
                            LoadGlAccountEvent(
                              local: myLocale ?? "en",
                              categories: [1, 2, 3, 4],
                              excludeAccounts: [10101010, 10101011],
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
                        ZTextFieldEntitled(
                          isRequired: true,
                          // onSubmit: (_)=> onSubmit(),
                          keyboardInputType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormat: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]*'),
                            ),
                            SmartThousandsDecimalFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return locale.required(locale.exchangeRate);
                            }

                            // Remove formatting (e.g. commas)
                            final clean = value.replaceAll(
                              RegExp(r'[^\d.]'),
                              '',
                            );
                            final amount = double.tryParse(clean);

                            if (amount == null || amount <= 0.0) {
                              return locale.amountGreaterZero;
                            }

                            return null;
                          },
                          controller: amount,
                          title: locale.amount,
                        ),
                        ZTextFieldEntitled(
                          // onSubmit: (_)=> onSubmit(),
                          keyboardInputType: TextInputType.multiline,
                          controller: narration,
                          title: locale.narration,
                        ),
                        if(trState is TransactionErrorState)
                          SizedBox(height: 10),
                        Row(
                          children: [
                            trState is TransactionErrorState? Text(trState.message) : SizedBox()
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }
    void accountToAccount({String? trnType}) {
    final locale = AppLocalizations.of(context)!;

      /// Debit .......................................
      final creditAccountCtrl = TextEditingController();
      String? creditAccCurrency;
      String? creditCurrentBalance;
      String? creditAvailableBalance;
      int? creditAccNumber;
      String? creditAccName;
      String? creditAccountLimit;
      String? creditCcySymbol;
      int? creditStatus;

      /// Credit .....................................
      final debitAccountCtrl = TextEditingController();
      String? debitAccCurrency;
      String? debitCurrentBalance ;
      String? debitAvailableBalance;
      int? debitAccNumber;
      String? debitAccName;
      String? debitAccountLimit;
      String? debitCcySymbol;
      int? debitStatus;

      final TextEditingController amount = TextEditingController();
      final TextEditingController narration = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return BlocBuilder<TransactionsBloc, TransactionsState>(
            builder: (context, trState) {
              return StatefulBuilder(
                builder: (context,setState) {
                  return ZFormDialog(
                    width: 800,
                    icon: Icons.swap_horiz_rounded,
                    title: locale.accountTransfer,
                    onAction: (){
                      context.read<TransactionsBloc>().add(OnACTATTransactionEvent(TransactionsModel(
                        usrName: login.usrName,
                        fromAccount: debitAccNumber,
                        fromAccCy: debitAccCurrency,
                        toAccount: creditAccNumber,
                        toAccCcy: creditAccCurrency,
                        amount: amount.text.cleanAmount,
                        narration: narration.text,
                      )));
                    },
                    actionLabel: trState is TxnLoadingState
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          )
                        : Text(locale.create),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              spacing: 8,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                               ///Debit Section
                               Expanded(
                                 child: Column(
                                   children: [
                                     GenericTextfield<StakeholdersAccountsModel, AccountsBloc, AccountsState>(
                                       showAllOnFocus: true,
                                       controller: debitAccountCtrl,
                                       title: locale.accounts,
                                       hintText: locale.accNameOrNumber,
                                       isRequired: true,
                                       bloc: context.read<AccountsBloc>(),
                                       fetchAllFunction: (bloc) => bloc.add(
                                         LoadStkAccountsEvent(),
                                       ),
                                       searchFunction: (bloc, query) => bloc.add(
                                         LoadStkAccountsEvent(),
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
                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                               children: [
                                                 Text(
                                                   "${account.accnumber} | ${account.accName}",
                                                   style: Theme.of(context).textTheme.bodyMedium,
                                                 ),
                                               ],
                                             ),
                                           ],
                                         ),
                                       ),
                                       itemToString: (acc) =>
                                       "${acc.accnumber} | ${acc.accName}",
                                       stateToLoading: (state) =>
                                       state is AccountLoadingState,
                                       loadingBuilder: (context) => const SizedBox(
                                         width: 16,
                                         height: 16,
                                         child: CircularProgressIndicator(strokeWidth: 3),
                                       ),
                                       stateToItems: (state) {
                                         if (state is StkAccountLoadedState) {
                                           return state.accounts;
                                         }
                                         return [];
                                       },
                                       onSelected: (value) {
                                         setState(() {
                                           debitAccNumber = value.accnumber;
                                           debitCcySymbol = value.ccySymbol;
                                           debitAccCurrency = value.actCurrency;
                                           debitAccName = value.accName ?? "";
                                           debitAvailableBalance = value.avilBalance;
                                           debitCurrentBalance = value.curBalance;
                                           debitAccountLimit = value.actCreditLimit;
                                           debitStatus = value.actStatus ?? 0;
                                         });
                                       },
                                       noResultsText: locale.noDataFound,
                                       showClearButton: true,
                                     ),
                                     if(debitAccName !=null && debitAccName!.isNotEmpty)
                                     Cover(
                                         color: color.surface,
                                         child: Column(
                                       children: [
                                         if(debitAccName !=null && debitAccName!.isNotEmpty)
                                           Padding(
                                             padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 3),
                                             child: Row(
                                               children: [
                                                 Text(locale.details,style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                   color: Theme.of(context).colorScheme.primary
                                                 ))
                                               ],
                                             ),
                                           ),
                                         if(debitAccName !=null && debitAccName!.isNotEmpty)
                                           Container(
                                             padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                             width: double.infinity,
                                             child: Row(
                                               spacing: 5,
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: [
                                                 Column(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   spacing: 5,
                                                   children: [
                                                     SizedBox(
                                                         width: 170,
                                                         child: Text(locale.accountNumber,style: titleStyle)),
                                                     SizedBox(
                                                         width: 170,
                                                         child: Text(locale.accountName,style: titleStyle)),
                                                     SizedBox(
                                                         width: 170,
                                                         child: Text(locale.currencyTitle,style: titleStyle)),
                                                     SizedBox(
                                                         width: 170,
                                                         child: Text(locale.accountLimit,style: titleStyle)),
                                                     SizedBox(
                                                         width: 170,
                                                         child: Text(locale.status,style: titleStyle)),
                                                     SizedBox(
                                                         width: 170,
                                                         child: Text(locale.currentBalance,style: titleStyle)),
                                                     SizedBox(
                                                         width: 170,
                                                         child: Text(locale.availableBalance,style: titleStyle)),
                                                   ],
                                                 ),
                                                 Column(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   spacing: 5,
                                                   children: [
                                                     Text(debitAccNumber.toString()),
                                                     Text(debitAccName??""),
                                                     Text(debitAccCurrency??""),
                                                     Text(debitAccountLimit?.toAmount()??""),
                                                     Text(debitStatus == 1? locale.active : locale.blocked),
                                                     Text("$debitCcySymbol${debitCurrentBalance?.toAmount()}",style: headerStyle),
                                                     Text("$debitCcySymbol${debitAvailableBalance?.toAmount()}",style: headerStyle),
                                                   ],
                                                 ),
                                               ],
                                             ),
                                           ),
                                       ],
                                     ))
                                   ],
                                 ),
                               ),

                               ///Credit Section
                               Expanded(
                                  child: Column(
                                    children: [
                                      GenericTextfield<StakeholdersAccountsModel, AccountsBloc, AccountsState>(
                                        showAllOnFocus: true,
                                        controller: creditAccountCtrl,
                                        title: locale.accounts,
                                        hintText: locale.accNameOrNumber,
                                        isRequired: true,
                                        bloc: context.read<AccountsBloc>(),
                                        fetchAllFunction: (bloc) => bloc.add(
                                          LoadStkAccountsEvent(),
                                        ),
                                        searchFunction: (bloc, query) => bloc.add(
                                          LoadStkAccountsEvent(),
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
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    "${account.accnumber} | ${account.accName}",
                                                    style: Theme.of(context).textTheme.bodyLarge,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        itemToString: (acc) =>
                                        "${acc.accnumber} | ${acc.accName}",
                                        stateToLoading: (state) =>
                                        state is AccountLoadingState,
                                        loadingBuilder: (context) => const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 3),
                                        ),
                                        stateToItems: (state) {
                                          if (state is StkAccountLoadedState) {
                                            return state.accounts;
                                          }
                                          return [];
                                        },
                                        onSelected: (value) {
                                          setState(() {
                                            creditAccNumber = value.accnumber;
                                            creditCcySymbol = value.ccySymbol;
                                            creditAccCurrency = value.actCurrency;
                                            creditAccName = value.accName ?? "";
                                            creditAvailableBalance = value.avilBalance;
                                            creditCurrentBalance = value.curBalance;
                                            creditAccountLimit = value.actCreditLimit;
                                            creditStatus = value.actStatus ?? 0;
                                          });
                                        },
                                        noResultsText: locale.noDataFound,
                                        showClearButton: true,
                                      ),
                                      if(creditAccName !=null && creditAccName!.isNotEmpty)
                                      Cover(
                                        color: Theme.of(context).colorScheme.surface,
                                        child: Column(
                                          children: [
                                            if(creditAccName !=null && creditAccName!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 3),
                                                child: Row(
                                                  children: [
                                                    Text(locale.details,style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      color: Theme.of(context).colorScheme.primary
                                                    ))
                                                  ],
                                                ),
                                              ),
                                            if(creditAccName !=null && creditAccName!.isNotEmpty)
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                                width: double.infinity,
                                                child: Row(
                                                  spacing: 5,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      spacing: 5,
                                                      children: [
                                                        SizedBox(
                                                            width: 170,
                                                            child: Text(locale.accountNumber,style: titleStyle)),
                                                        SizedBox(
                                                            width: 170,
                                                            child: Text(locale.accountName,style: titleStyle)),
                                                        SizedBox(
                                                            width: 170,
                                                            child: Text(locale.currencyTitle,style: titleStyle)),
                                                        SizedBox(
                                                            width: 170,
                                                            child: Text(locale.accountLimit,style: titleStyle)),
                                                        SizedBox(
                                                            width: 170,
                                                            child: Text(locale.status,style: titleStyle)),
                                                        SizedBox(
                                                            width: 170,
                                                            child: Text(locale.currentBalance,style: titleStyle)),
                                                        SizedBox(
                                                            width: 170,
                                                            child: Text(locale.availableBalance,style: titleStyle)),
                                                      ],
                                                    ),
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      spacing: 5,
                                                      children: [
                                                        Text(creditAccNumber.toString()),
                                                        Text(creditAccName??""),
                                                        Text(creditAccCurrency??""),
                                                        Text(creditAccountLimit?.toAmount()??""),
                                                        Text(creditStatus == 1? locale.active : locale.blocked),
                                                        Text("$creditCcySymbol${creditCurrentBalance?.toAmount()}",style: headerStyle),
                                                        Text("$creditCcySymbol${creditAvailableBalance?.toAmount()}",style: headerStyle),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            ZTextFieldEntitled(
                              isRequired: true,
                              // onSubmit: (_)=> onSubmit(),
                              keyboardInputType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormat: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]*'),
                                ),
                                SmartThousandsDecimalFormatter(),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return locale.required(locale.exchangeRate);
                                }

                                // Remove formatting (e.g. commas)
                                final clean = value.replaceAll(
                                  RegExp(r'[^\d.]'),
                                  '',
                                );
                                final amount = double.tryParse(clean);

                                if (amount == null || amount <= 0.0) {
                                  return locale.amountGreaterZero;
                                }

                                return null;
                              },
                              controller: amount,
                              title: locale.amount,
                            ),
                            ZTextFieldEntitled(
                              keyboardInputType: TextInputType.multiline,
                              controller: narration,
                              title: locale.narration,
                            ),
                            if(trState is TransactionErrorState)
                              SizedBox(height: 10),
                            Row(
                              children: [
                                trState is TransactionErrorState? Text(trState.message,style: textTheme.titleSmall?.copyWith(color: color.error)) : SizedBox()
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              );
            },
          );
        },
      );
    }


    final shortcuts = {
      const SingleActivator(LogicalKeyboardKey.f1): () => onCashDepositWithdraw(trnType: "CHDP"),
      const SingleActivator(LogicalKeyboardKey.f2): () => onCashDepositWithdraw(trnType: "CHWL"),
      const SingleActivator(LogicalKeyboardKey.f3): () => onCashIncome(trnType: "INCM"),
      const SingleActivator(LogicalKeyboardKey.f4): () => onCashExpense(trnType: "XPNS"),
      const SingleActivator(LogicalKeyboardKey.f5): () => accountToAccount(trnType: "ATAT"),
      const SingleActivator(LogicalKeyboardKey.f6): () => onGL(trnType: "GLCR"),
      const SingleActivator(LogicalKeyboardKey.f7): () => onGL(trnType: "GLDR"),
    };

    return Scaffold(
      body: BlocListener<TransactionsBloc, TransactionsState>(
        listener: (context, state) {},
        child: GlobalShortcuts(
          shortcuts: shortcuts,
          child: Column(
            children: [
              // -------------------- HEADER & TABS --------------------
              Cover(
                margin: const EdgeInsets.only(top: 6, bottom: 5),
                radius: 5,
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 7,
                      ),
                      child: Row(
                        children: [
                          Text(
                            locale.journal,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: context.scaledFont(0.015),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomUnderlineTabBar<JournalTabName>(
                      tabs: [
                        JournalTabName.allTransactions,
                        JournalTabName.authorized,
                        JournalTabName.pending,
                      ],
                      currentTab: context.watch<JournalTabBloc>().state.tab,
                      onTabChanged: (tab) => context.read<JournalTabBloc>().add(
                        JournalOnChangedEvent(tab),
                      ),
                      labelBuilder: (tab) {
                        switch (tab) {
                          case JournalTabName.allTransactions: return locale.allTransactions;
                          case JournalTabName.authorized: return locale.authorizedTransactions;
                          case JournalTabName.pending: return locale.pendingTransactions;
                        }
                      },
                    ),
                  ],
                ),
              ),

              // -------------------- MAIN CONTENT --------------------
              Expanded(
                child: Row(
                  children: [
                    // LEFT SIDE — TAB SCREENS
                    Expanded(
                      child: BlocBuilder<JournalTabBloc, JournalTabState>(
                        builder: (context, state) {
                          switch (state.tab) {
                            case JournalTabName.allTransactions: return const AllTransactionsView();
                            case JournalTabName.authorized: return const AuthorizedTransactionsView();
                            case JournalTabName.pending: return const PendingTransactionsView();
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 3),

                    // RIGHT SIDE — SHORTCUT BUTTONS PANEL
                    Container(
                      width: 190,
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            Wrap(
                              spacing: 5,
                              children: [
                                const Icon(Icons.reset_tv_rounded, size: 20),
                                Text(
                                  locale.cashFlow,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),

                            if (login.hasPermission(19) ?? false)
                              ZOutlineButton(
                                toolTip: "F1",
                                label: Text(locale.deposit),
                                icon: Icons.arrow_circle_down_rounded,
                                width: double.infinity,
                                onPressed: () =>
                                    onCashDepositWithdraw(trnType: "CHDP"),
                              ),
                            if (login.hasPermission(18) ?? false)
                              ZOutlineButton(
                                toolTip: "F2",
                                label: Text(locale.withdraw),
                                icon: Icons.arrow_circle_up_rounded,
                                width: double.infinity,
                                onPressed: () => onCashDepositWithdraw(trnType: "CHWL"),
                              ),
                            if (login.hasPermission(22) ?? false)
                              ZOutlineButton(
                                toolTip: "F3",
                                label: Text(locale.income),
                                icon: Icons.arrow_circle_down_rounded,
                                width: double.infinity,
                                onPressed: () => onCashIncome(trnType: "INCM"),
                              ),
                            if (login.hasPermission(23) ?? false)
                              ZOutlineButton(
                                toolTip: "F4",
                                label: Text(locale.expense),
                                icon: Icons.arrow_circle_up_rounded,
                                width: double.infinity,
                                onPressed: () => onCashExpense(trnType: "XPNS"),
                              ),
                            if (login.hasPermission(24) ?? false)
                              ZOutlineButton(
                                toolTip: "F5",
                                label: Text(locale.fundTransferTitle),
                                icon: Icons.swap_horiz_rounded,
                                width: double.infinity,
                                onPressed: () => accountToAccount(trnType: "ATAT"),
                              ),
                            if (login.hasPermission(24) ?? false)
                              ZOutlineButton(
                                toolTip: "F5",
                                label: Text(locale.fundTransferMultiTitle),
                                icon: Icons.swap_horiz_rounded,
                                width: double.infinity,
                                onPressed: (){
                                  showDialog(context: context, builder: (context){
                                    return BulkTransferScreen();
                                  });
                                },
                              ),
                            SizedBox(height: 5),
                            Wrap(
                              spacing: 5,
                              children: [
                                const Icon(Icons.computer_rounded, size: 20),
                                Text(
                                  locale.systemAction,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),

                            if (login.hasPermission(21) ?? false)
                              ZOutlineButton(
                                toolTip: "F6",
                                label: Text(locale.glCreditTitle),
                                width: double.infinity,
                                icon: Icons.call_to_action_outlined,
                                onPressed: () => onGL(trnType: "GLCR"),
                              ),
                            if (login.hasPermission(20) ?? false)
                              ZOutlineButton(
                                toolTip: "F7",
                                label: Text(locale.glDebitTitle),
                                width: double.infinity,
                                icon: Icons.call_to_action_outlined,
                                onPressed: () => onGL(trnType: "GLDR"),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
