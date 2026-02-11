import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchATAT/bloc/fetch_atat_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchATAT/model/fetch_atat_model.dart';

import '../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';
import '../bloc/transactions_bloc.dart';

class FetchAtatView extends StatelessWidget {
  const FetchAtatView({super.key});

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
  String getTitle(BuildContext context, String code) {
    switch (code) {
      case "SLRY": return AppLocalizations.of(context)!.postSalary;
      case "ATAT": return AppLocalizations.of(context)!.accountTransfer;
      case "CRFX": return AppLocalizations.of(context)!.fxTransaction;
      case "PLCL": return AppLocalizations.of(context)!.profitAndLoss;
      default: return "";
    }
  }

  FetchAtatModel? loadedAtat;

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;
    TextStyle? titleStyle = textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold);
    TextStyle? headerStyle = textTheme.titleSmall?.copyWith(color: color.surface);
    TextStyle? bodyStyle = textTheme.bodyMedium?.copyWith();
    final isDeleteLoading = context.watch<TransactionsBloc>().state is TxnDeleteLoadingState;
    final isAuthorizeLoading = context.watch<TransactionsBloc>().state is TxnAuthorizeLoadingState;
    final auth = context.watch<AuthBloc>().state;

    if (auth is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = auth.loginData;

    return BlocConsumer<FetchAtatBloc, FetchAtatState>(
      listener: (context, state) {
        if (state is FetchATATLoadedState) {
          loadedAtat = state.atat;
        }
      },
      builder: (context, state) {
        if (state is FetchATATLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is FetchATATLoadedState) {
          loadedAtat = state.atat;
        }

        if (state is FetchATATErrorState) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // Check if any buttons should be shown
        final bool showAuthorizeButton = loadedAtat?.trnStatus == 0 &&
            login.usrName != loadedAtat?.maker;
        final bool showDeleteButton = loadedAtat?.trnStatus == 0 &&
            loadedAtat?.maker == login.usrName;
        final bool showAnyButton = showAuthorizeButton || showDeleteButton;

        return ZFormDialog(
          width: MediaQuery.of(context).size.width * .7,
          isActionTrue: false,
          onAction: null,
          icon: Icons.ssid_chart,
          title: getTitle(context, loadedAtat?.trnType ?? ""),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr.details,
                      style: textTheme.titleMedium?.copyWith(
                          color: color.primary,
                          fontSize: 18
                      ),
                    ),
                    const Icon(Icons.print)
                  ],
                ),
              ),
              Divider(color: color.outline.withValues(alpha: .3), thickness: 1, endIndent: 8, indent: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          Text(tr.referenceNumber, style: titleStyle),
                          Text(tr.status, style: titleStyle),
                          Text(tr.branch, style: titleStyle),
                          Text(tr.maker, style: titleStyle),
                          if(loadedAtat?.checker != null && loadedAtat!.checker!.isNotEmpty)
                            Text(tr.checker, style: titleStyle),
                          Text(tr.narration, style: titleStyle),
                          Text(tr.date, style: titleStyle),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        Text(loadedAtat?.trnReference ?? "", style: bodyStyle),
                        Text(
                            loadedAtat?.trnStatus == 1
                                ? tr.authorizedTransaction
                                : tr.pendingTransactions,
                            style: bodyStyle
                        ),
                        Text(loadedAtat?.trdBranch.toString() ?? "", style: bodyStyle),
                        Text(loadedAtat?.maker ?? "", style: bodyStyle),
                        if(loadedAtat?.checker != null && loadedAtat!.checker!.isNotEmpty)
                          Text(loadedAtat?.checker ?? "", style: bodyStyle),
                        Text(loadedAtat?.trdNarration ?? "", style: bodyStyle),
                        Text(
                          loadedAtat!.trnEntryDate!.toFullDateTime,
                          style: bodyStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        tr.debitTitle,
                        style: textTheme.titleMedium?.copyWith(
                          color: color.outline,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 5),
                        child: Text(
                          tr.creditTitle,
                          style: textTheme.titleMedium?.copyWith(
                            color: color.outline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),


              Expanded(
                child: Row(
                  children: [
                    // Debit Column
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary
                            ),
                            child: Row(
                              spacing: 5,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    tr.accountName,
                                    style: headerStyle,
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    tr.accountNumber,
                                    style: headerStyle,
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    tr.amount,
                                    style: headerStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: state is FetchATATLoadedState
                                ? ListView.builder(
                              itemCount: state.atat.debit?.length ?? 0,
                              itemBuilder: (context, index) {
                                final dr = state.atat.debit?[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: index.isOdd
                                          ? color.primary.withValues(alpha: .05)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 5,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          dr?.accName ?? "",
                                          style: bodyStyle,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Text(
                                          dr?.trdAccount.toString() ?? "",
                                          style: bodyStyle,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          "${dr?.trdAmount?.toAmount()} ${dr?.trdCcy}",
                                          style: bodyStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                                : const SizedBox(),
                          ),
                        ],
                      ),
                    ),
                    // Credit Column
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary
                            ),
                            child: Row(
                              spacing: 5,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    tr.accountName,
                                    style: headerStyle,
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    tr.accountNumber,
                                    style: headerStyle,
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    tr.amount,
                                    style: headerStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: state is FetchATATLoadedState
                                ? ListView.builder(
                              itemCount: state.atat.credit?.length ?? 0,
                              itemBuilder: (context, index) {
                                final cr = state.atat.credit?[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: index.isOdd
                                          ? color.primary.withValues(alpha: .05)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(2),

                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 5,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          cr?.accName ?? "",
                                          style: bodyStyle,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Text(
                                          cr?.trdAccount.toString() ?? "",
                                          style: bodyStyle,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          "${cr?.trdAmount?.toAmount()} ${cr?.trdCcy}",
                                          style: bodyStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                                : const SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (showAnyButton)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          Text(
                            tr.actions,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      indent: 12,
                      endIndent: 12,
                      color: color.primary,
                      thickness: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5,
                      ),
                      child: Row(
                        spacing: 8,
                        children: [
                          if (showAuthorizeButton)
                            ZOutlineButton(
                              width: 130,
                              onPressed: isAuthorizeLoading
                                  ? null
                                  : () {
                                context.read<TransactionsBloc>().add(
                                  AuthorizeTxnEvent(
                                    reference: loadedAtat?.trnReference ?? "",
                                    usrName: login.usrName ?? "",
                                  ),
                                );
                              },
                              icon: isAuthorizeLoading
                                  ? null
                                  : Icons.check_box_outlined,
                              isActive: true,
                              label: isAuthorizeLoading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              )
                                  : Text(tr.authorize),
                            ),
                          if (showDeleteButton)
                            ZOutlineButton(
                              width: 130,
                              onPressed: isDeleteLoading
                                  ? null
                                  : () {
                                context.read<TransactionsBloc>().add(
                                  DeletePendingTxnEvent(
                                    reference: loadedAtat?.trnReference ?? "",
                                    usrName: login.usrName ?? "",
                                  ),
                                );
                              },
                              icon: isDeleteLoading
                                  ? null
                                  : Icons.delete_outline_rounded,
                              isActive: true,
                              backgroundHover: Theme.of(
                                context,
                              ).colorScheme.error,
                              label: isDeleteLoading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              )
                                  : Text(tr.delete),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              if (!showAnyButton) const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
