import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import 'bloc/balance_sheet_bloc.dart';
import 'model/bs_model.dart';

class BalanceSheetScreen extends StatelessWidget {
  const BalanceSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String? baseCurrency;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.balanceSheet)),
      body: BlocBuilder<CompanyProfileBloc, CompanyProfileState>(
        builder: (context, comState) {
          if (comState is CompanyProfileLoadedState) {
            baseCurrency = comState.company.comLocalCcy;
          }

          return BlocBuilder<BalanceSheetBloc, BalanceSheetState>(
            builder: (context, state) {
              if (state is BalanceSheetLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is BalanceSheetError) {
                return Center(
                  child: Text(
                    state.message,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                );
              } else if (state is BalanceSheetLoaded) {
                final data = state.data;
                final t = AppLocalizations.of(context)!;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Assets
                      _buildMainTitle(context, t.assets),
                      _buildYearHeader(context, t),
                      ..._buildAssetSection(context, data.assets, baseCurrency, t),
                      const SizedBox(height: 16),

                      // Liabilities & Equity
                      _buildMainTitle(context, t.liabilitiesEquity),
                      _buildYearHeader(context, t),
                      ..._buildLiabilitySection(context, data.liability, baseCurrency, t),
                    ],
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          );
        },
      ),
    );
  }

  // Main section title (Assets / Liabilities & Equity)
  Widget _buildMainTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }

  // Year header (shown once at the top of balances)
  Widget _buildYearHeader(BuildContext context, AppLocalizations t) {
    return Row(
      children: [
        Expanded(flex: 4, child: SizedBox()),
        Expanded(
          flex: 3,
          child: Text(
            t.currentYear,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            t.lastYear,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  // Subsection title (grey)
  Widget _buildSubSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // Format amounts with currency
  String formatNumber(double value, String? currency) {
    final formatter = NumberFormat("#,##0.00");
    return "${formatter.format(value)} ${currency ?? ''}";
  }

  // Build asset sections with totals
  List<Widget> _buildAssetSection(BuildContext context, Assets? assets, String? currency, AppLocalizations t) {
    if (assets == null) return [];

    final sections = <Widget>[];

    double totalCurrentAsset = 0;
    double totalFixedAsset = 0;
    double totalIntangibleAsset = 0;

    void addSection(String title, List<AssetItem>? items, void Function(double) addTotal) {
      if (items == null || items.isEmpty) return;

      sections.add(_buildSubSectionTitle(context, title));

      double sectionCurrentTotal = 0;
      double sectionLastTotal = 0;

      for (var item in items) {
        final lastYear = double.tryParse(item.lastYear ?? "0") ?? 0;
        final currentYear = double.tryParse(item.currentYear ?? "0") ?? 0;

        sectionCurrentTotal += currentYear;
        sectionLastTotal += lastYear;

        sections.add(_buildTableRow(context, item.accName ?? "", currentYear, lastYear, currency));
      }

      sections.add(_buildTotalRow(context, "${t.totalTitle} $title", sectionCurrentTotal, sectionLastTotal, currency));

      addTotal(sectionCurrentTotal);
    }

    addSection(t.currentAssets, assets.currentAsset, (val) => totalCurrentAsset = val);
    addSection(t.fixedAssets, assets.fixedAsset, (val) => totalFixedAsset = val);
    addSection(t.intangibleAssets, assets.intangibleAsset, (val) => totalIntangibleAsset = val);

    final totalAssetsCurrent = totalCurrentAsset + totalFixedAsset + totalIntangibleAsset;
    final totalAssetsLast = (assets.currentAsset?.fold<double>(0, (p, e) => p + (double.tryParse(e.lastYear ?? "0") ?? 0)) ?? 0) +
        (assets.fixedAsset?.fold<double>(0, (p, e) => p + (double.tryParse(e.lastYear ?? "0") ?? 0)) ?? 0) +
        (assets.intangibleAsset?.fold<double>(0, (p, e) => p + (double.tryParse(e.lastYear ?? "0") ?? 0)) ?? 0);

    sections.add(_buildTotalRow(context, t.totalAssets, totalAssetsCurrent, totalAssetsLast, currency));

    return sections;
  }

  // Build liability & equity sections with totals
  List<Widget> _buildLiabilitySection(
      BuildContext context, Liability? liability, String? currency, AppLocalizations t) {
    if (liability == null) return [];

    final sections = <Widget>[];

    double totalCurrentLiability = 0;
    double totalOwnerEquity = 0;
    double totalStakeholders = 0;
    double totalNetProfit = 0;

    void addSection(String title, List<AssetItem>? items, void Function(double) addTotal) {
      if (items == null || items.isEmpty) return;

      sections.add(_buildSubSectionTitle(context, title));

      double sectionCurrentTotal = 0;
      double sectionLastTotal = 0;

      for (var item in items) {
        final lastYear = double.tryParse(item.lastYear ?? "0") ?? 0;
        final currentYear = double.tryParse(item.currentYear ?? "0") ?? 0;

        sectionCurrentTotal += currentYear;
        sectionLastTotal += lastYear;

        sections.add(_buildTableRow(context, item.accName ?? "", currentYear, lastYear, currency));
      }

      sections.add(_buildTotalRow(context, "${t.totalTitle} $title", sectionCurrentTotal, sectionLastTotal, currency));
      addTotal(sectionCurrentTotal);
    }

    addSection(t.currentLiabilities, liability.currentLiability, (val) => totalCurrentLiability = val);
    addSection(t.ownerEquity, liability.ownersEquity, (val) => totalOwnerEquity = val);
    addSection(t.stakeholders, liability.stakeholders, (val) => totalStakeholders = val);
    addSection(t.netProfit, liability.netProfit, (val) => totalNetProfit = val);

    // Calculate total liabilities and equity
    final totalLiabilitiesEquityCurrent = totalCurrentLiability +
        totalOwnerEquity +
        totalStakeholders +
        totalNetProfit;

    final totalLiabilitiesEquityLast = (liability.currentLiability?.fold<double>(0, (p, e) => p + (double.tryParse(e.lastYear ?? "0") ?? 0)) ?? 0) +
        (liability.ownersEquity?.fold<double>(0, (p, e) => p + (double.tryParse(e.lastYear ?? "0") ?? 0)) ?? 0) +
        (liability.stakeholders?.fold<double>(0, (p, e) => p + (double.tryParse(e.lastYear ?? "0") ?? 0)) ?? 0) +
        (liability.netProfit?.fold<double>(0, (p, e) => p + (double.tryParse(e.lastYear ?? "0") ?? 0)) ?? 0);

    sections.add(_buildTotalRow(context, t.totalLiabilitiesEquity,
        totalLiabilitiesEquityCurrent, totalLiabilitiesEquityLast, currency));

    return sections;
  }

  // Individual row
  Widget _buildTableRow(BuildContext context, String name, double currentYear, double lastYear, String? currency) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(name)),
          Expanded(
            flex: 3,
            child: Text(
              formatNumber(currentYear, currency),
              textAlign: TextAlign.end,
              style: TextStyle(color: currentYear < 0 ? theme.colorScheme.error : theme.colorScheme.outline),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              formatNumber(lastYear, currency),
              textAlign: TextAlign.end,
              style: TextStyle(color: lastYear < 0 ? theme.colorScheme.error : theme.colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }

  // Total row
  Widget _buildTotalRow(BuildContext context, String title, double currentTotal, double lastTotal, String? currency) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(title, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            flex: 3,
            child: Text(
              formatNumber(currentTotal, currency),
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.bold, color: currentTotal < 0 ? theme.colorScheme.error : theme.colorScheme.primary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              formatNumber(lastTotal, currency),
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.bold, color: lastTotal < 0 ? theme.colorScheme.error : theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}