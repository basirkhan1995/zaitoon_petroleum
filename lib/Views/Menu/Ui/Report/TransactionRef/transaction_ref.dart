import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/txn_ref_report_bloc.dart';

class TransactionByReferenceView extends StatelessWidget {
  const TransactionByReferenceView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const _Mobile(),
      tablet: const _Tablet(),
      desktop: const _Desktop(),
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
  final ref = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TxnRefReportBloc>().add(ResetTxnReportByReferenceEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleSmall?.copyWith(
      color: color.surface,
      fontWeight: FontWeight.w500,
    );

    return Scaffold(
      backgroundColor: color.surface,
      body: Column(
        children: [
          // Header with search
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                BackButton(),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.transactionByRef,
                        style: textTheme.titleLarge?.copyWith(
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        flex: 2,
                        child: ZTextFieldEntitled(
                          controller: ref,
                          icon: Icons.qr_code_2_outlined,
                          title: '',
                          isRequired: true,
                          hint: tr.referenceNumber,
                          onSubmit: (_) => onSubmit(),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ZOutlineButton(
                        width: 120,
                        isActive: true,
                        onPressed: onSubmit,
                        icon: Icons.call_to_action_outlined,
                        label: Text(tr.submit),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: BlocBuilder<TxnRefReportBloc, TxnRefReportState>(
              builder: (context, state) {
                if (state is TxnRefReportLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is TxnRefReportErrorState) {
                  return NoDataWidget(
                    title: tr.noDataFound,
                    message: state.message,
                  );
                }

                if (state is TxnRefReportLoadedState) {
                  final txn = state.txn;
                  final records = txn.records ?? [];

                  return Column(
                    children: [
                      // Transaction Summary Card
                      ZCover(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        radius: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              spacing:5,
                              children: [
                                Icon(Icons.qr_code_2_outlined),
                                Text(
                                  tr.transactionDetails,
                                  style: textTheme.titleMedium
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Divider(),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 32,
                              runSpacing: 16,
                              children: [
                                _buildSummaryItem(
                                  tr.date,
                                  txn.trnEntryDate?.toDateTime ?? "-",
                                  color,
                                ),
                                _buildSummaryItem(
                                  tr.referenceNumber,
                                  txn.trnReference ?? "-",
                                  color,
                                ),
                                _buildSummaryItem(
                                  tr.transactionType,
                                  txn.trntName ?? "-",
                                  color,
                                ),
                                _buildSummaryItem(
                                  tr.maker,
                                  txn.maker ?? "-",
                                  color,
                                ),
                                _buildSummaryItem(
                                  tr.checker,
                                  txn.checker ?? tr.notAuthorizedYet,
                                  color,
                                ),
                                _buildSummaryItem(
                                  tr.txnType,
                                  txn.trnType ?? "-",
                                  color,
                                ),
                                _buildSummaryItem(
                                  tr.status,
                                  txn.trnStateText ?? "-",
                                  color,
                                  isStatus: true,
                                ),

                              ],
                            ),
                          ],
                        ),
                      ),

                      // Records Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,

                        ),
                        decoration: BoxDecoration(
                          color: color.primary.withValues(alpha: .9),

                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 170,
                              child: Text(
                                tr.date,
                                  style: titleStyle
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                tr.accounts,
                                  style: titleStyle
                              ),
                            ),
                            SizedBox(
                             width: 150,
                              child: Text(
                                tr.accountName,
                                  style: titleStyle
                              ),
                            ),
                            Expanded(
                              child: Text(
                                tr.narration,
                                style: titleStyle
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                "CR/DR",
                                  style: titleStyle
                              ),
                            ),
                            SizedBox(
                              width: 150,
                              child: Text(
                                tr.amount,
                                  style: titleStyle
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Records List
                      Expanded(
                        child: ListView.separated(
                          itemCount: records.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: color.outline.withValues(alpha: .1),
                          ),
                          itemBuilder: (context, index) {
                            final record = records[index];

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              color: index.isEven
                                  ? color.primary.withValues(alpha: .03)
                                  : Colors.transparent,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 170,
                                    child: Text(
                                      record.trdEntryDate?.toDateTime ?? "-",
                                      style: textTheme.bodyMedium,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      record.trdAccount?.toString() ?? "-",
                                      style: textTheme.bodyMedium,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      record.accName ?? "-",
                                      style: textTheme.bodyMedium,
                                    ),
                                  ),
                                  Expanded(
                                    child: Tooltip(
                                      message: record.trdNarration ?? "",
                                      child: Text(
                                        record.trdNarration ?? "-",
                                        style: textTheme.bodyMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      record.debitCredit?.toString() ?? "-",
                                      style: textTheme.bodyMedium,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      "${record.trdAmount?.toAmount() ?? "0.00"} ${record.trdCcy ?? ""}",
                                      style: textTheme.bodyMedium
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: color.outline.withValues(alpha: .3),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tr.transactionSummary,
                        style: textTheme.bodyLarge?.copyWith(
                          color: color.outline.withValues(alpha: .6),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String title,
      String value,
      ColorScheme color, {
        bool isStatus = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: color.outline.withValues(alpha: .7),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void onSubmit() {
    if (ref.text.trim().isEmpty) return;
    context
        .read<TxnRefReportBloc>()
        .add(LoadTxnReportByReferenceEvent(ref.text.trim()));
  }
}