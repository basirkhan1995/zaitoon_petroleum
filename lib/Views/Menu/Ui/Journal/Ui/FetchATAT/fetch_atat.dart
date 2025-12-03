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
  FetchAtatModel? loadedAtat;
  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;
    TextStyle? titleStyle = textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold);
    TextStyle? bodyStyle = textTheme.bodyMedium?.copyWith();
    final isDeleteLoading = context.watch<TransactionsBloc>().state is TxnDeleteLoadingState;
    final isAuthorizeLoading = context.watch<TransactionsBloc>().state is TxnAuthorizeLoadingState;
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = auth.loginData;

    return ZFormDialog(
      width: MediaQuery.of(context).size.width * .7,
      isActionTrue: false,
      onAction: null,
      icon: Icons.home_repair_service_outlined,
      title: tr.accountTransfer,
      child: BlocConsumer<FetchAtatBloc, FetchAtatState>(
  listener: (context, state) {
    if (state is FetchATATLoadedState) {
      showDialog(
        context: context,
        builder: (context) {
          return FetchAtatView();
        },
      );
    }
  },
  builder: (context, state) {
    return BlocBuilder<FetchAtatBloc, FetchAtatState>(

        builder: (context, state) {
          if (state is FetchATATLoadedState) {
            loadedAtat = state.atat;
          }
          // Check if any buttons should be shown
          final bool showAuthorizeButton = loadedAtat?.trnStatus == 0 && login.usrName != loadedAtat?.maker;
          final bool showDeleteButton = loadedAtat?.trnStatus == 0 && loadedAtat?.maker == login.usrName;
          final bool showAnyButton = showAuthorizeButton || showDeleteButton;
          return Column(
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
                    Icon(Icons.print)
                  ],
                ),
              ),
              Divider(color: color.outline.withValues(alpha: .3),thickness: 1, endIndent: 8, indent: 8),
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
                          if(loadedAtat?.checker !=null && loadedAtat!.checker!.isNotEmpty)
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
                        Text(loadedAtat?.trnStatus == 1? tr.authorizedTransaction : tr.pendingTransactions, style: bodyStyle),
                        Text(loadedAtat?.trdBranch.toString() ?? "", style: bodyStyle),
                        Text(loadedAtat?.maker ?? "", style: bodyStyle),
                        if(loadedAtat?.checker !=null && loadedAtat!.checker!.isNotEmpty)
                        Text(loadedAtat?.checker ?? "", style: bodyStyle),
                        Text(loadedAtat?.trdNarration ?? "", style: bodyStyle),
                        Text(loadedAtat!.trnEntryDate!.toFullDateTime,style: bodyStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        spacing: 5,
                        children: [
                          Icon(Icons.arrow_circle_up_rounded,color: Colors.red),
                          Text(
                            tr.debitTitle,
                            style: textTheme.titleMedium?.copyWith(
                              color: color.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        spacing: 5,
                        children: [
                          Icon(Icons.arrow_circle_down_rounded,color: Colors.green),
                          Text(
                            tr.creditTitle,
                            style: textTheme.titleMedium?.copyWith(
                              color: color.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: color.outline.withValues(alpha: .3),thickness: 1, endIndent: 8, indent: 8),

              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8,vertical: 2),
                            padding: EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                            child: Row(
                              spacing: 5,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    tr.accountName,
                                    style: titleStyle,
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    tr.accountNumber,
                                    style: titleStyle,
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    tr.amount,
                                    style: titleStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: BlocConsumer<FetchAtatBloc, FetchAtatState>(
                              listener: (context, state) {},
                              builder: (context, state) {
                                if (state is FetchATATLoadedState) {
                                  return ListView.builder(
                                    itemCount: state.atat.debit?.length,
                                    itemBuilder: (context, index) {
                                      final dr = state.atat.debit?[index];
                                      return Container(
                                        margin: EdgeInsets.symmetric(horizontal: 8,vertical: 2),
                                        padding: EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                                        decoration: BoxDecoration(
                                            color: index.isOdd? color.primary.withValues(alpha: .05) : Colors.transparent,
                                            borderRadius: BorderRadius.circular(2),
                                            border: Border.all(color: color.outline.withValues(alpha: .3))
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
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8,vertical: 2),
                            padding: EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                            child: Row(
                              spacing: 5,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    tr.accountName,
                                    style: titleStyle,
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    tr.accountNumber,
                                    style: titleStyle,
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    tr.amount,
                                    style: titleStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: BlocConsumer<FetchAtatBloc, FetchAtatState>(
                              listener: (context, state) {},
                              builder: (context, state) {
                                if (state is FetchATATLoadedState) {
                                  return ListView.builder(
                                    itemCount: state.atat.credit?.length,
                                    itemBuilder: (context, index) {
                                      final cr = state.atat.credit?[index];
                                      return Container(
                                        margin: EdgeInsets.symmetric(horizontal: 8,vertical: 2),
                                        padding: EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                                        decoration: BoxDecoration(
                                            color: index.isOdd? color.primary.withValues(alpha: .05) : Colors.transparent,
                                            borderRadius: BorderRadius.circular(2),
                                            border: Border.all(color: color.outline.withValues(alpha: .3))
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
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
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
                              onPressed: () {
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
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                      ),
                                    )
                                  : Text(tr.authorize),
                            ),

                          if (showDeleteButton)
                            ZOutlineButton(
                              width: 130,
                              icon: isDeleteLoading
                                  ? null
                                  : Icons.delete_outline_rounded,
                              isActive: true,
                              backgroundHover: Theme.of(
                                context,
                              ).colorScheme.error,
                              onPressed: () {
                                context.read<TransactionsBloc>().add(
                                  DeletePendingTxnEvent(
                                    reference: loadedAtat?.trnReference ?? "",
                                    usrName: login.usrName ?? "",
                                  ),
                                );
                              },
                              label: isDeleteLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    )
                                  : Text(tr.delete),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              if (!showAnyButton) SizedBox(height: 10),
            ],
          );
        },
      );
  },
),
    );
  }

}
