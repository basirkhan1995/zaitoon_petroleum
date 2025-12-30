import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Localizations/Bloc/localizations_bloc.dart';
import 'package:zaitoon_petroleum/Views/Auth/bloc/auth_bloc.dart';
import 'package:zaitoon_petroleum/Views/Auth/Ui/login.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/hr.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/Ui/individuals.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/transport.dart';
import '../../Features/Generic/generic_menu.dart';
import '../../Features/Other/image_helper.dart';
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
  @override
  void initState() {
    super.initState();

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
          selectedColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: .09),
          selectedTextColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: .9),
          unselectedTextColor: Theme.of(context).colorScheme.secondary,
          menuHeaderBuilder: (isExpanded) {
            return BlocBuilder<CompanyProfileBloc, CompanyProfileState>(
              builder: (context, state) {
                String comName = "";
                Uint8List logo = Uint8List(0);

                if (state is CompanyProfileLoadedState) {
                  comName = state.company.comName ?? "";

                  final base64Logo = state.company.comLogo;
                  if (base64Logo != null && base64Logo.isNotEmpty) {
                    try {
                      logo = base64Decode(base64Logo);
                    } catch (_) {}
                  }
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      margin: const EdgeInsets.all(5),
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: .09),
                        ),
                      ),
                      child: logo.isEmpty
                          ? Image.asset("assets/images/zaitoonLogo.png")
                          : Image.memory(logo),
                    ),

                    if (isExpanded)
                      InkWell(
                        onTap: () {
                          context.read<MenuBloc>().add(
                            MenuOnChangedEvent(MenuName.settings),
                          );
                          context.read<SettingsTabBloc>().add(
                            SettingsOnChangeEvent(SettingsTabName.company),
                          );
                          context.read<CompanySettingsMenuBloc>().add(
                            CompanySettingsOnChangedEvent(
                              CompanySettingsMenuName.profile,
                            ),
                          );
                        },
                        child: state is CompanyProfileLoadingState
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                            : SizedBox(
                          width: 150,
                          child: Text(
                            comName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },

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
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          alignment:
                              context.read<LocalizationBloc>().state.languageCode == "en"
                              ? AlignmentGeometry.bottomLeft
                              : AlignmentGeometry.bottomRight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          child: Container(
                            width: 320,
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .1),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Header with gradient background
                                SizedBox(height: 15),
                                Column(
                                  children: [
                                    // Profile image with border
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: ImageHelper.stakeholderProfile(
                                        imageName: authState.loginData.usrPhoto,
                                        size: 80,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    // User name
                                    Text(
                                      authState.loginData.usrFullName ?? "No Name",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      authState.loginData.usrName ?? "No Name",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),

                                Divider(indent: 10, endIndent: 10),
                                // User details
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Email
                                      _buildDetailRow(
                                        context,
                                        icon: Icons.email_outlined,
                                        text:
                                            authState.loginData.usrEmail ??
                                            "No Email",
                                      ),
                                      const SizedBox(height: 12),

                                      // Role
                                      _buildDetailRow(
                                        context,
                                        icon: Icons.work_outline,
                                        text:
                                            authState.loginData.usrRole ??
                                            "No Role",
                                      ),
                                      const SizedBox(height: 12),

                                      // Branch
                                      _buildDetailRow(
                                        context,
                                        icon: Icons.business_outlined,
                                        text:
                                            authState.loginData.brcName ??
                                            "No Branch",
                                      ),
                                    ],
                                  ),
                                ),
                                // Logout button
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop(); // Close dialog
                                    _logout();
                                  },
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(8.0),
                                    bottomRight: Radius.circular(8.0),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(8.0),
                                        bottomRight: Radius.circular(8.0),
                                      ),
                                      color: Theme.of(context).colorScheme.error
                                          .withValues(alpha: .05),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.logout_rounded,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(context)!.logout,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ImageHelper.stakeholderProfile(
                        imageName: authState.loginData.usrPhoto,
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: .3),
                        ),
                        size: 40,
                      ),

                      if (!isExpanded) const SizedBox.shrink(),

                      if (isExpanded) const SizedBox(width: 5),

                      if (isExpanded)
                        Expanded(
                          // or Flexible
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                adminName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                authState.loginData.usrRole ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for detail rows
  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .6),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: .8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
