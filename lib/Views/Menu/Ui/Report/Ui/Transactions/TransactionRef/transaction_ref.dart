import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Transactions/TransactionRef/bloc/txn_ref_report_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionByReferenceView extends StatelessWidget {
  const TransactionByReferenceView({super.key});

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
  final ref = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<TxnRefReportBloc>()
          .add(ResetTxnReportByReferenceEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final titleStyle =
    textTheme.titleSmall?.copyWith(color: color.outline);

    return Scaffold(
      backgroundColor: color.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: color.surface,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: color.outline.withValues(alpha: .9),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.userLog,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        tr.userLogActivity,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ZTextFieldEntitled(
                    controller: ref,
                    title: tr.referenceNumber,
                    isRequired: true,
                    onSubmit: (_) => onSubmit(),
                  ),
                ),
                const SizedBox(width: 8),
                ZOutlineButton(
                  width: 100,
                  onPressed: onSubmit,
                  label: Text(tr.apply),
                ),
              ],
            ),
          ),

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
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tr.date),
                                  Text(tr.referenceNumber),
                                  Text(tr.transactionType),
                                  Text(tr.maker),
                                  Text(tr.checker),
                                  Text(tr.status),
                                  Text(tr.txnType),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(state.txn.trnEntryDate?.toDateTime ?? ""),
                                Text(state.txn.trnReference ?? ""),
                                Text(state.txn.trntName ?? ""),
                                Text(state.txn.maker ?? ""),
                                Text(state.txn.checker ?? "Not Authorized yet"),
                                Text(state.txn.trnStateText ?? ""),
                                Text(state.txn.trnType ?? ""),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(tr.date, style: titleStyle),
                            ),
                          ],
                        ),
                      ),

                      const Divider(indent: 5, endIndent: 5),

                      Expanded(
                        child: ListView.builder(
                          itemCount: state.txn.records?.length ?? 0,
                          itemBuilder: (context, index) {
                            final records = state.txn.records![index];

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              decoration: BoxDecoration(
                                color: index.isEven
                                    ? color.primary.withValues(alpha: .05)
                                    : Colors.transparent,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 160,
                                      child: Text(
                                          records.trdEntryDate?.toDateTime ??
                                              ""),
                                    ),
                                    SizedBox(
                                      width: 85,
                                      child: Text(
                                          records.trdAccount.toString()),
                                    ),
                                    SizedBox(
                                      width: 170,
                                      child: Text(records.accName ?? ""),
                                    ),
                                    SizedBox(
                                      width: 350,
                                      child: Text(
                                          records.trdNarration ?? ""),
                                    ),

                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                          records.debitCredit.toString()),
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        "${records.trdAmount?.toAmount()} ${records.trdCcy}",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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

  void onSubmit() {
    context
        .read<TxnRefReportBloc>()
        .add(LoadTxnReportByReferenceEvent(ref.text.trim()));
  }
}
