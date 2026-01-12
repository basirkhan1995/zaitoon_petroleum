import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/status_badge.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/ArApReport/bloc/ar_ap_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/ArApReport/model/ar_ap_model.dart';
import '../../../../../../../../Features/PrintSettings/report_model.dart';
import '../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../../Auth/bloc/auth_bloc.dart';

class PayablesView extends StatelessWidget {
  const PayablesView({super.key});

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
  final searchController = TextEditingController();
  final company = ReportModel();
  List<ArApModel> payables = [];

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

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(tr.creditors),
            titleSpacing: 0,
          ),
          body: Column(
            children: [
              // Total payables row
              BlocBuilder<ArApBloc, ArApState>(
                builder: (context, state) {
                  if (state is ArApLoadedState) {
                    final filteredList = state.apAccounts;
                    final totalsByCurrency = calculateTotalPayableByCurrency(filteredList);

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          spacing: 25,
                          children: totalsByCurrency.entries.map((entry) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${tr.totalUpperCase} ${entry.key}",style: TextStyle(color: Theme.of(context).colorScheme.outline)),
                                Row(
                                  children: [
                                    Text(
                                      entry.value.toAmount(),
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      entry.key,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Utils.currencyColors(entry.key)),
                                    ),
                                  ],
                                ),
                              ],
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 8,
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
                    ZOutlineButton(
                      width: 110,
                      icon: FontAwesomeIcons.solidFilePdf,
                      label: Text("PDF"),
                      onPressed: () {},
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
              Divider(indent: 15, endIndent: 15),

              // Accounts list
              Expanded(
                child: BlocBuilder<ArApBloc, ArApState>(
                  builder: (context, state) {
                    if (state is ArApErrorState) {
                      return NoDataWidget(message: state.error);
                    }
                    if (state is ArApLoadingState) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (state is ArApLoadedState) {
                      final query = searchController.text.toLowerCase().trim();
                      final filteredList = state.apAccounts.where((item) {
                        final name = item.accName?.toLowerCase() ?? '';
                        final accNumber = item.accNumber?.toString() ?? '';
                        return name.contains(query) || accNumber.contains(query);
                      }).toList();
                      payables = filteredList;

                      return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final ap = filteredList[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                            decoration: BoxDecoration(
                              color: index.isOdd
                                  ? Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withValues(alpha: .05)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 280,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ap.accName ?? "", style: title),
                                      SizedBox(height: 2),
                                      Row(
                                        children: [
                                          StatusBadge(
                                            status: ap.accStatus!,
                                            trueValue: tr.active,
                                            falseValue: tr.blocked,
                                          ),
                                          SizedBox(width: 5),
                                          ZCard(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: .03),
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            child: Text(ap.accNumber.toString(), style: subtitle1),
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
                                      Text(ap.accLimit.toAmount(), style: title),
                                      Text(ap.accCurrency ?? "", style: subTitle),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: Text(ap.fullName ?? "", style: Theme.of(context).textTheme.titleMedium)),
                                Text("${ap.accBalance.toAmount()} ${ap.accCurrency}",
                                    style: Theme.of(context).textTheme.titleMedium),
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

  /// Calculate total payables grouped by currency
  Map<String, double> calculateTotalPayableByCurrency(List<ArApModel> list) {
    final Map<String, double> totals = {};
    for (var acc in list.where((e) => e.isAP)) {
      final currency = acc.accCurrency ?? 'N/A';
      totals[currency] = (totals[currency] ?? 0.0) + acc.balance;
    }
    return totals;
  }
}


// 🔹 EXTENSION FOR CLEANER TOTAL CALCULATION
extension ArApExtensions on List<ArApModel> {
  double calculateTotalPayable() {
    return where((e) => e.isAP).fold(0.0, (sum, e) => sum + e.balance);
  }

  double calculateTotalReceivable() {
    return where((e) => e.isAR).fold(0.0, (sum, e) => sum + e.balance);
  }
}
