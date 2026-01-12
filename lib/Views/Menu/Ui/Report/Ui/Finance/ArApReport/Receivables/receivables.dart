import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/status_badge.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/ArApReport/bloc/ar_ap_bloc.dart';
import '../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../Features/Widgets/search_field.dart';

import '../model/ar_ap_model.dart';

class ReceivablesView extends StatelessWidget {
  const ReceivablesView({super.key});

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
  final searchController = TextEditingController();
  List<ArApModel> receivables = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArApBloc>().add(LoadArApEvent());
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).textTheme.titleMedium;
    final subTitle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.outline);
    final subtitle1 = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurface);
    final tr = AppLocalizations.of(context)!;

    return BlocBuilder<ArApBloc, ArApState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(tr.debtors),
            titleSpacing: 0,
          ),
          body: Column(
            children: [
              // Total receivables row
              BlocBuilder<ArApBloc, ArApState>(
                builder: (context, state) {
                  if (state is ArApLoadedState) {
                    final filteredList = state.arAccounts;
                    final totalsByCurrency = calculateTotalReceivableByCurrency(filteredList);

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: totalsByCurrency.entries.map((entry) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: .05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "${tr.totalTitle} (${entry.key})",
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    entry.value.toAmount(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),

              // Search bar and PDF button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ZSearchField(
                        icon: FontAwesomeIcons.magnifyingGlass,
                        controller: searchController,
                        title: '',
                        hint: tr.accountName,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ZOutlineButton(
                      width: 110,
                      icon: FontAwesomeIcons.solidFilePdf,
                      label: const Text("PDF"),
                      onPressed: () {
                        // TODO: Implement PDF generation
                      },
                    ),
                  ],
                ),
              ),

              // Column headers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  children: [
                    SizedBox(width: 280, child: Text(tr.accounts, style: title)),
                    SizedBox(width: 200, child: Text(tr.accountLimit, style: title)),
                    Expanded(child: Text(tr.signatory, style: title)),
                    Text(tr.balance, style: title),
                  ],
                ),
              ),
              const Divider(indent: 15, endIndent: 15),

              // Receivables list
              Expanded(
                child: BlocBuilder<ArApBloc, ArApState>(
                  builder: (context, state) {
                    if (state is ArApErrorState) {
                      return NoDataWidget(message: state.error);
                    }
                    if (state is ArApLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ArApLoadedState) {
                      final query = searchController.text.toLowerCase().trim();
                      final filteredList = state.arAccounts.where((item) {
                        final name = item.accName?.toLowerCase() ?? '';
                        final accNumber = item.accNumber?.toString() ?? '';
                        return name.contains(query) || accNumber.contains(query);
                      }).toList();
                      receivables = filteredList;

                      if (filteredList.isEmpty) {
                        return NoDataWidget(message: tr.noData);
                      }

                      return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final ar = filteredList[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                            decoration: BoxDecoration(
                              color: index.isOdd
                                  ? Theme.of(context).colorScheme.outline.withValues(alpha: .05)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 280,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ar.accName ?? "", style: title),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          StatusBadge(
                                            status: ar.accStatus ?? 0,
                                            trueValue: tr.active,
                                            falseValue: tr.blocked,
                                          ),
                                          const SizedBox(width: 5),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primary.withValues(alpha: .03),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(ar.accNumber.toString(), style: subtitle1),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 200,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ar.accLimit?.toAmount() ?? '0', style: title),
                                      Text(ar.accCurrency ?? "", style: subTitle),
                                    ],
                                  ),
                                ),
                                Expanded(child: Text(ar.fullName ?? "", style: title)),
                                Text("${ar.balance.toAmount()} ${ar.accCurrency}", style: title),
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
        );
      },
    );
  }

  /// Calculate total receivables grouped by currency
  Map<String, double> calculateTotalReceivableByCurrency(List<ArApModel> list) {
    final Map<String, double> totals = {};
    for (var acc in list.where((e) => e.isAR)) {
      final currency = acc.accCurrency ?? 'N/A';
      totals[currency] = (totals[currency] ?? 0.0) + acc.absBalance;
    }
    return totals;
  }
}


