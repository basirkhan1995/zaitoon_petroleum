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
import 'Ui/Stakeholders/stakeholders.dart';
import 'Ui/Stock/stock.dart';
import 'bloc/menu_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(),
    );
  }
}

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  String comName = "";
  String adminName = "";
  @override
  Widget build(BuildContext context) {
    final currentTab = context.watch<MenuBloc>().state.tabs;
    final state = context.watch<AuthBloc>().state;
    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
   // final login = state.loginData;

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

    final isLoading = context.watch<CompanyProfileBloc>().state is CompanyProfileLoadingState;

    return Scaffold(
      body: BlocBuilder<CompanyProfileBloc, CompanyProfileState>(
        builder: (context, comState) {
          if (comState is CompanyProfileLoadedState) {
            comName = comState.company.comName ?? "";
          }
          return BlocConsumer<AuthBloc, AuthState>(
            listener: (context,state){
              if(state is UnAuthenticatedState){
                Utils.gotoReplacement(context, LoginView());
              }
            },
            builder: (context, state) {
              if (state is AuthenticatedState) {
                adminName = state.loginData.usrFullName ?? "";
              }
              return GenericMenuWithScreen<MenuName>(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                selectedValue: currentTab,
                onChanged: (val) =>
                    context.read<MenuBloc>().add(MenuOnChangedEvent(val)),
                items: menuItems,
                selectedColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: .09),
                selectedTextColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: .9),
                unselectedTextColor: Theme.of(context).colorScheme.secondary,
                menuHeaderBuilder: (isExpanded) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Container(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.09),
                        ),
                      ),
                      child: Image.asset("assets/images/zaitoonLogo.png"),
                    ),
                    if (isExpanded)
                      InkWell(
                        onTap: () {
                          context.read<MenuBloc>().add(
                            MenuOnChangedEvent(MenuName.settings),
                          );
                          context.read<SettingsTabBloc>().add(SettingsOnChangeEvent(SettingsTabName.company));
                          context.read<CompanySettingsMenuBloc>().add(CompanySettingsOnChangedEvent(CompanySettingsMenuName.profile));
                        },
                        child: isLoading? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                            strokeWidth: 3,
                          ),
                        ) :  SizedBox(
                          width: 150,
                          child: Text(
                            comName,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisAlignment: isExpanded
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    crossAxisAlignment: isExpanded
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,

                    children: [
                      InkWell(
                        onTap: logout,
                        child: Row(
                          spacing: 6,
                          mainAxisAlignment: isExpanded
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.center,
                          crossAxisAlignment: isExpanded
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.center,

                          children: [
                            InkWell(
                                onTap: logout,
                                child: Icon(Icons.power_settings_new_outlined),
                             ),
                            if (isExpanded)
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.logout,
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isExpanded) SizedBox(height: 5),
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
              );
            },
          );
        },
      ),
    );
  }
  void logout() async {
    final authBloc = context.read<AuthBloc>();
    await SecureStorage.clearCredentials();
    authBloc.add(OnLogoutEvent());
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
