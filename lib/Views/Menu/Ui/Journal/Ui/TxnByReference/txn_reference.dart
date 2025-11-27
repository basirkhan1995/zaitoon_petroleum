import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/TxnByReference/bloc/txn_reference_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/bloc/transactions_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/model/transaction_model.dart';

import '../../../../../../Features/Other/thousand_separator.dart';
import '../../../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';

class TxnReferenceView extends StatelessWidget {
  const TxnReferenceView({super.key});
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(),
    );
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile();

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
  final TextEditingController narration = TextEditingController();
  final TextEditingController amount = TextEditingController();
  String? reference;
  @override
  void dispose() {
    narration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;
    final isLoading = context.watch<TransactionsBloc>().state is TransactionLoadingState;
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = auth.loginData;
    return ZFormDialog(
      width: 450,
      icon: Icons.add_chart_rounded,
       alignment: AlignmentGeometry.centerRight,
      expandedAction: Row(
        children: [
          IconButton(
              onPressed: (){
                context.read<TransactionsBloc>().add(UpdatePendingTransactionEvent(TransactionsModel(
                  usrName: login.usrName,
                  accCcy: "USD",
                  narration: "",
                  amount: "",
                  trnReference: "",
                )));
              },
              icon: Icon(Icons.delete))
        ],
      ),
      onAction: () {
        context.read<TransactionsBloc>().add(
          AuthorizeTxnEvent(
            reference: reference ?? "",
            usrName: login.usrName ?? "",
          ),
        );
      },
      actionLabel: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Theme.of(context).colorScheme.surface,
              ),
            )
          : Text(locale.authorize),
      title: locale.txnDetails,
      child: Column(
        children: [
          Expanded(
            child: BlocConsumer<TxnReferenceBloc, TxnReferenceState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is TxnReferenceLoadedState) {
                  narration.text = state.transaction.narration ?? "";
                  reference = state.transaction.trnReference ?? "";
                  amount.text = state.transaction.amount?.toAmount()??"";
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 8,
                        ),
                        width: double.infinity,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  locale.details,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: color.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8,
                                  children: [
                                    Text(locale.transactionRef),

                                    Text(locale.accountNumber),
                                    Text(locale.accountName),
                                    Text(locale.amount),
                                    Text(locale.currencyTitle),
                                    Text(locale.branch),
                                    Text(locale.txnType),
                                    Text(locale.status),
                                    Text(locale.maker),
                                    Text(locale.transactionDate),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8,
                                  children: [
                                    Text(
                                      state.transaction.trnReference ?? "",
                                      style: textTheme.titleSmall,
                                    ),
                                    Text(
                                      state.transaction.account.toString(),
                                      style: textTheme.titleSmall,
                                    ),
                                    Text(
                                      state.transaction.accName.toString(),
                                      style: textTheme.titleSmall,
                                    ),
                                    Text(
                                      state.transaction.amount?.toAmount() ??
                                          "",
                                      style: textTheme.titleSmall,
                                    ),
                                    Text(
                                      state.transaction.currency ?? "",
                                      style: textTheme.titleSmall,
                                    ),
                                    Text(
                                      state.transaction.branch.toString(),
                                      style: textTheme.titleSmall,
                                    ),
                                    Text(
                                      state.transaction.trnType ?? "",
                                      style: textTheme.titleSmall,
                                    ),
                                    Text(
                                      state.transaction.trnStatus == 0
                                          ? locale.pendingTransactions
                                          : locale.authorizedTransactions,
                                      style: textTheme.titleSmall,
                                    ),
                                    Text(
                                      state.transaction.maker ?? "",
                                      style: textTheme.titleSmall,
                                    ),
                                    Text(
                                      state
                                          .transaction
                                          .trnEntryDate!
                                          .toFullDateTime,
                                      style: textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
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
                              readOnly: true,
                              title: locale.narration,
                            ),
                          ],
                        ),
                      ),
                    ],
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
}
