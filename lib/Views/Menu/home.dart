import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Auth/bloc/auth_bloc.dart';
import 'package:zaitoon_petroleum/Views/Auth/Ui/login.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/hr.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/Ui/individuals.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/transport.dart';
import '../../Features/Generic/generic_menu.dart';
import '../../Features/Other/responsive.dart';
import '../../Features/Other/secure_storage.dart';
import '../../Features/Other/utils.dart';
import '../../Localizations/l10n/translations/app_localizations.dart';
import 'Ui/Dashboard/dashboard.dart';
import 'Ui/Finance/finance.dart';
import 'Ui/Journal/journal.dart';
import 'Ui/Report/report.dart';
import 'Ui/Settings/Ui/Company/bloc/company_settings_menu_bloc.dart';
import 'Ui/Settings/bloc/settings_tab_bloc.dart';
import 'Ui/Settings/settings.dart';
import 'Ui/Stock/stock.dart';
import 'bloc/menu_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(),
    );
  }
}

// ================== DESKTOP ==================

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  String _comName = "";
  Uint8List _companyLogo = Uint8List(0);

  @override
  void initState() {
    super.initState();

    // Listen to company profile changes once
    final companyBloc = context.read<CompanyProfileBloc>();
    companyBloc.stream.listen((state) {
      if (state is CompanyProfileLoadedState) {
        setState(() {
          _comName = state.company.comName ?? "";
          final base64Logo = state.company.comLogo;
          if (base64Logo != null && base64Logo.isNotEmpty) {
            try {
              _companyLogo = base64Decode(base64Logo);
            } catch (_) {
              _companyLogo = Uint8List(0);
            }
          } else {
            _companyLogo = Uint8List(0);
          }
        });
      }
    });
  }

  void _logout() async {
    final authBloc = context.read<AuthBloc>();
    await SecureStorage.clearCredentials();
    authBloc.add(OnLogoutEvent());
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = context.watch<MenuBloc>().state.tabs;
    final authState = context.watch<AuthBloc>().state;

    if (authState is! AuthenticatedState) return const SizedBox();

    final String adminName = authState.loginData.usrFullName ?? "";

    final menuItems = [
      MenuDefinition(
        value: MenuName.dashboard,
        label: AppLocalizations.of(context)!.dashboard,
        screen: const DashboardView(),
        icon: Icons.add_home_outlined,
      ),
      MenuDefinition(
        value: MenuName.finance,
        label: AppLocalizations.of(context)!.finance,
        screen: const FinanceView(),
        icon: Icons.money,
      ),
      MenuDefinition(
        value: MenuName.journal,
        label: AppLocalizations.of(context)!.journal,
        screen: const JournalView(),
        icon: Icons.menu_book,
      ),
      MenuDefinition(
        value: MenuName.stakeholders,
        label: AppLocalizations.of(context)!.stakeholders,
        screen: const IndividualsView(),
        icon: Icons.account_circle_outlined,
      ),
      MenuDefinition(
        value: MenuName.hr,
        label: AppLocalizations.of(context)!.hr,
        screen: const HrTabView(),
        icon: Icons.group_rounded,
      ),
      MenuDefinition(
        value: MenuName.transport,
        label: AppLocalizations.of(context)!.transport,
        screen: const TransportView(),
        icon: Icons.fire_truck_rounded,
      ),
      MenuDefinition(
        value: MenuName.stock,
        label: AppLocalizations.of(context)!.inventory,
        screen: const StockView(),
        icon: Icons.add_shopping_cart_sharp,
      ),
      MenuDefinition(
        value: MenuName.settings,
        label: AppLocalizations.of(context)!.settings,
        screen: const SettingsView(),
        icon: Icons.settings_outlined,
      ),
      MenuDefinition(
        value: MenuName.report,
        label: AppLocalizations.of(context)!.report,
        screen: const ReportView(),
        icon: Icons.info_outlined,
      ),
    ];

    final isLoading =
    context.watch<CompanyProfileBloc>().state is CompanyProfileLoadingState;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UnAuthenticatedState) {
            Utils.gotoReplacement(context, const LoginView());
          }
        },
        child: GenericMenuWithScreen<MenuName>(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          selectedValue: currentTab,
          onChanged: (val) =>
              context.read<MenuBloc>().add(MenuOnChangedEvent(val)),
          items: menuItems,
          selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: .09),
          selectedTextColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: .9),
          unselectedTextColor: Theme.of(context).colorScheme.secondary,
          menuHeaderBuilder: (isExpanded) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                margin: const EdgeInsets.all(5),
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color:
                    Theme.of(context).colorScheme.primary.withValues(alpha: .09),
                  ),
                ),
                child: (_companyLogo.isEmpty)
                    ? Image.asset("assets/images/zaitoonLogo.png")
                    : Image.memory(_companyLogo),
              ),
              if (isExpanded)
                InkWell(
                  onTap: () {
                    context.read<MenuBloc>().add(
                      MenuOnChangedEvent(MenuName.settings),
                    );
                    context
                        .read<SettingsTabBloc>()
                        .add(SettingsOnChangeEvent(SettingsTabName.company));
                    context.read<CompanySettingsMenuBloc>().add(
                        CompanySettingsOnChangedEvent(
                            CompanySettingsMenuName.profile));
                  },
                  child: isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 3,
                    ),
                  )
                      : SizedBox(
                    width: 150,
                    child: Text(
                      _comName,
                      style: Theme.of(context).textTheme.titleSmall,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          menuFooterBuilder: (isExpanded) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4),
            child: Column(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              crossAxisAlignment: isExpanded
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: _logout,
                  child: Row(
                    mainAxisAlignment: isExpanded
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      Icon(Icons.power_settings_new_outlined),
                      if (isExpanded)
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.logout,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isExpanded) const SizedBox(height: 5),
                if (isExpanded)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          adminName,
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================== MOBILE / TABLET PLACEHOLDER ==================

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
