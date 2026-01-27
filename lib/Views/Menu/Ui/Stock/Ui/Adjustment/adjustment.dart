import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/search_field.dart';
import '../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';

class AdjustmentView extends StatelessWidget {
  const AdjustmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), desktop: _Desktop(),tablet: _Tablet(),);
  }
}

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  String? baseCurrency;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

    });

    final companyState = context.read<CompanyProfileBloc>().state;
    if (companyState is CompanyProfileLoadedState) {
      baseCurrency = companyState.company.comLocalCcy ?? "";
    }
  }

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    TextStyle? titleStyle = textTheme.titleSmall?.copyWith(color: color.surface);
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      body:Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  flex: 5,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    tileColor: Colors.transparent,
                    title: Text(
                      tr.adjustment,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontSize: 20),
                    ),
                    subtitle: Text(
                      tr.ordersSubtitle,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ZSearchField(
                    icon: FontAwesomeIcons.magnifyingGlass,
                    controller: searchController,
                    hint: AppLocalizations.of(context)!.search,
                    onChanged: (e) {
                      setState(() {});
                    },
                    title: "",
                  ),
                ),
                ZOutlineButton(
                  toolTip: "F5",
                  width: 120,
                  icon: Icons.refresh,
                  // onPressed: onRefresh,
                  label: Text(tr.refresh),
                ),
                ZOutlineButton(
                  toolTip: "F5",
                  isActive: true,
                  width: 120,
                  icon: Icons.add,
                  // onPressed: () => Utils.goto(context, AddEstimateView()),
                  label: Text(tr.newKeyword),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 5),
            decoration: BoxDecoration(
                color: color.primary.withValues(alpha: .9)
            ),
            child: Row(
              children: [
                SizedBox(width: 30, child: Text("#", style: titleStyle)),
                SizedBox(
                  width: 215,
                  child: Text(tr.referenceNumber, style: titleStyle),
                ),
                Expanded(child: Text(tr.party, style: titleStyle)),
                SizedBox(
                  width: 150,
                  child: Text(tr.totalInvoice, style: titleStyle),
                ),
              ],
            ),
          ),
        ],
      ),
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
class _Mobile extends StatefulWidget {
  const _Mobile();

  @override
  State<_Mobile> createState() => _MobileState();
}

class _MobileState extends State<_Mobile> {
  String? baseCurrency;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

    });

    final companyState = context.read<CompanyProfileBloc>().state;
    if (companyState is CompanyProfileLoadedState) {
      baseCurrency = companyState.company.comLocalCcy ?? "";
    }
  }

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    TextStyle? titleStyle = textTheme.titleSmall?.copyWith(color: color.surface);
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      body:Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  flex: 5,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    tileColor: Colors.transparent,
                    title: Text(
                      tr.estimateTitle,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontSize: 20),
                    ),
                    subtitle: Text(
                      tr.ordersSubtitle,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ZSearchField(
                    icon: FontAwesomeIcons.magnifyingGlass,
                    controller: searchController,
                    hint: AppLocalizations.of(context)!.search,
                    onChanged: (e) {
                      setState(() {});
                    },
                    title: "",
                  ),
                ),
                ZOutlineButton(
                  toolTip: "F5",
                  width: 120,
                  icon: Icons.refresh,
                 // onPressed: onRefresh,
                  label: Text(tr.refresh),
                ),
                ZOutlineButton(
                  toolTip: "F5",
                  isActive: true,
                  width: 120,
                  icon: Icons.add,
                 // onPressed: () => Utils.goto(context, AddEstimateView()),
                  label: Text(tr.newKeyword),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 5),
            decoration: BoxDecoration(
                color: color.primary.withValues(alpha: .9)
            ),
            child: Row(
              children: [
                SizedBox(width: 30, child: Text("#", style: titleStyle)),
                SizedBox(
                  width: 215,
                  child: Text(tr.referenceNumber, style: titleStyle),
                ),
                Expanded(child: Text(tr.party, style: titleStyle)),
                SizedBox(
                  width: 150,
                  child: Text(tr.totalInvoice, style: titleStyle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
