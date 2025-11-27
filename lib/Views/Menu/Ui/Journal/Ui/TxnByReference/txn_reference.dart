import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/TxnByReference/bloc/txn_reference_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/bloc/transactions_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/model/transaction_model.dart';

import '../../../../../../Features/Other/thousand_separator.dart';
import '../../../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';
import 'model/txn_ref_model.dart';

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
  TxnByReferenceModel? loadedTxn;

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
    final isLoading = context.watch<TransactionsBloc>().state is TxnLoadingState;
    final isDeleteLoading = context.watch<TransactionsBloc>().state is TxnDeleteLoadingState;
    final isUpdateLoading = context.watch<TransactionsBloc>().state is TxnUpdateLoadingState;
    final isAuthorizeLoading = context.watch<TransactionsBloc>().state is TxnAuthorizeLoadingState;
    final isReverseLoading = context.watch<TransactionsBloc>().state is TxnReverseLoadingState;
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = auth.loginData;
    return ZFormDialog(
      width: 500,
      isActionTrue: false,
      icon: Icons.add_chart_rounded,
       alignment: AlignmentGeometry.centerRight,
      onAction: null,
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocConsumer<TxnReferenceBloc, TxnReferenceState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is TxnReferenceLoadedState) {
                  loadedTxn = state.transaction;
                  narration.text = state.transaction.narration ?? "";
                  reference = state.transaction.trnReference ?? "";
                  amount.text = state.transaction.amount?.toAmount() ?? "";
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        width: double.infinity,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${loadedTxn?.amount?.toAmount()} ${loadedTxn?.currency}",
                                  style: textTheme.titleMedium?.copyWith(
                                    fontSize: 25
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
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

                              children: [
                                SizedBox(
                                  width: 170,
                                  child: Column(
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
                                      Utils.getTxnCode(txn: state.transaction.trnType ?? "", context: context),
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
                              keyboardInputType: TextInputType.multiline,
                              controller: narration,
                              title: locale.narration,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                           Text(locale.actions,style: Theme.of(context).textTheme.titleMedium)
                          ],
                        ),
                      ),
                      Divider(indent: 12,endIndent: 12,color: color.primary,thickness: 2,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                        child: Row(
                          spacing: 8,
                          children: [
                            Expanded(
                              child: ZOutlineButton(
                                  onPressed: (){
                                    context.read<TransactionsBloc>().add(
                                      AuthorizeTxnEvent(
                                        reference: reference ?? "",
                                        usrName: login.usrName ?? "",
                                      ),
                                    );
                                    },
                                  icon: isAuthorizeLoading? null : Icons.check_box_outlined,
                                  isActive: true,
                                  label: isAuthorizeLoading
                                      ? SizedBox(
                                    width: 20,
                                    height: 20,

                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  )
                                      : Text(locale.authorize)),
                            ),
                            Expanded(
                              child: ZOutlineButton(
                                  onPressed: (){
                                    context.read<TransactionsBloc>().add(
                                      ReverseTxnEvent(
                                        reference: reference ?? "",
                                        usrName: login.usrName ?? "",
                                      ),
                                    );
                                  },
                                  icon: isReverseLoading? null : Icons.screen_rotation_alt_rounded,
                                  backgroundHover: Colors.orange,
                                  label: isReverseLoading
                                      ? SizedBox(
                                    width: 20,
                                    height: 20,

                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                      : Text(locale.reverseTitle)),
                            ),
                            Expanded(
                              child: ZOutlineButton(
                                  backgroundHover: Colors.green,
                                  icon: isUpdateLoading? null : Icons.refresh,
                                  onPressed: (){
                                    context.read<TransactionsBloc>().add(UpdatePendingTransactionEvent(TransactionsModel(
                                      trnReference: loadedTxn?.trnReference??"",
                                      usrName: login.usrName,
                                      accCcy: loadedTxn?.currency??"",
                                      narration: narration.text,
                                      amount: amount.text.cleanAmount,
                                    )));
                                  },
                                  label: isUpdateLoading
                                      ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                      : Text(locale.update)),
                            ),
                            Expanded(
                              child: ZOutlineButton(
                                  icon: isDeleteLoading? null : Icons.delete_outline_rounded,
                                  backgroundHover: Theme.of(context).colorScheme.error,
                                  onPressed: (){
                                    context.read<TransactionsBloc>().add(DeletePendingTxnEvent(reference: loadedTxn?.trnReference??"",usrName: login.usrName??""));
                                  },
                                  label: isDeleteLoading
                                      ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                      : Text(locale.delete)),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10)
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
