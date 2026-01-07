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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MenuBloc()),
        // Add other providers if needed
      ],
      child: const ResponsiveLayout(
        mobile: _Mobile(),
        tablet: _Tablet(),
        desktop: _Desktop(),
      ),
    );
  }
}

// ================== DESKTOP ==================

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> with AutomaticKeepAliveClientMixin {
  Uint8List? _cachedLogo;
  String? _cachedComName;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Pre-fetch company profile when initializing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyProfileBloc>().add(LoadCompanyProfileEvent());
    });
  }

  void _logout() async {
    final authBloc = context.read<AuthBloc>();
    await SecureStorage.clearCredentials();
    authBloc.add(OnLogoutEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Use context.select here, at the top of build method
    final currentTab = context.select((MenuBloc bloc) => bloc.state.tabs);
    final authState = context.select((AuthBloc bloc) => bloc.state);

    if (authState is! AuthenticatedState) return const SizedBox();

    final String adminName = authState.loginData.usrFullName ?? "";
    final String usrPhoto = authState.loginData.usrPhoto ??"";
    final String usrRole = authState.loginData.usrRole ?? "";

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
          key: const Key('main_menu'), // Add a key for better widget identity
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          selectedValue: currentTab,
          onChanged: (val) {
            // Only update if the tab is different
            if (currentTab != val) {
              context.read<MenuBloc>().add(MenuOnChangedEvent(val));
            }
          },
          items: menuItems,
          selectedColor: Theme.of(context).colorScheme.primary.withAlpha(23),
          selectedTextColor: Theme.of(context).colorScheme.primary.withAlpha(230),
          unselectedTextColor: Theme.of(context).colorScheme.secondary,
          menuHeaderBuilder: (isExpanded) {
            return BlocConsumer<CompanyProfileBloc, CompanyProfileState>(
              listener: (context, state) {
                // Cache the logo and company name when loaded
                if (state is CompanyProfileLoadedState) {
                  if (_cachedComName != state.company.comName) {
                    _cachedComName = state.company.comName;
                  }

                  final base64Logo = state.company.comLogo;
                  if (base64Logo != null && base64Logo.isNotEmpty) {
                    try {
                      final newLogo = base64Decode(base64Logo);
                      // Only update if different
                      if (!_areBytesEqual(_cachedLogo, newLogo)) {
                        _cachedLogo = newLogo;
                      }
                    } catch (_) {
                      _cachedLogo = null;
                    }
                  } else {
                    _cachedLogo = null;
                  }
                }
              },
              builder: (context, state) {
                // Use cached values to prevent unnecessary rebuilds
                final logo = _cachedLogo;
                final comName = _cachedComName ?? "";

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
                              .withAlpha(23),
                        ),
                      ),
                      child: logo == null || logo.isEmpty
                          ? Image.asset(
                        "assets/images/zaitoonLogo.png",
                        cacheHeight: 120,
                        cacheWidth: 120,
                      )
                          : Image.memory(
                        logo,
                        cacheHeight: 120,
                        cacheWidth: 120,
                      ),
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
          menuFooterBuilder: (isExpanded) {
            // Pass the pre-fetched values instead of using context.select here
            return _MenuFooter(
              isExpanded: isExpanded,
              adminName: adminName,
              usrPhoto: usrPhoto,
              usrRole: usrRole,
              onProfileTap: () => _showProfileDialog(context),
            );
          },
        ),
      ),
    );
  }

  bool _areBytesEqual(Uint8List? a, Uint8List? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _showProfileDialog(BuildContext context) {
    final authState = context.read<AuthBloc>().state as AuthenticatedState;
    final isEnglish = context.read<LocalizationBloc>().state.languageCode == "en";

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          alignment: isEnglish
              ? Alignment.bottomLeft
              : Alignment.bottomRight,
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
                  color: Colors.black.withAlpha(25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: _ProfileDialogContent(
              authState: authState,
              onLogout: _logout,
            ),
          ),
        );
      },
    );
  }
}

// Separate widget for menu footer to avoid context.select issues
class _MenuFooter extends StatelessWidget {
  final bool isExpanded;
  final String adminName;
  final String usrPhoto;
  final String usrRole;
  final VoidCallback onProfileTap;

  const _MenuFooter({
    required this.isExpanded,
    required this.adminName,
    required this.usrPhoto,
    required this.usrRole,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            onTap: onProfileTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ImageHelper.stakeholderProfile(
                  imageName: usrPhoto,
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withAlpha(77),
                  ),
                  size: 40,
                ),

                if (!isExpanded) const SizedBox.shrink(),

                if (isExpanded) const SizedBox(width: 5),

                if (isExpanded)
                  Expanded(
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
                          usrRole,
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
    );
  }
}

// Separate widget for dialog content to optimize rebuilds
class _ProfileDialogContent extends StatelessWidget {
  final AuthenticatedState authState;
  final VoidCallback onLogout;

  const _ProfileDialogContent({
    required this.authState,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 15),
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.2,
                ),
              ),
              child: ImageHelper.stakeholderProfile(
                imageName: authState.loginData.usrPhoto,
                size: 80,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              authState.loginData.usrFullName ?? "No Name",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              authState.loginData.usrName ?? "No Name",
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),

        const Divider(indent: 10, endIndent: 10),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(
                icon: Icons.email_outlined,
                text: authState.loginData.usrEmail ?? "No Email",
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.work_outline,
                text: authState.loginData.usrRole ?? "No Role",
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.business_outlined,
                text: authState.loginData.brcName ?? "No Branch",
              ),
            ],
          ),
        ),

        InkWell(
          onTap: () {
            Navigator.of(context).pop();
            onLogout();
          },
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8.0),
            bottomRight: Radius.circular(8.0),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
              color: Theme.of(context).colorScheme.error.withAlpha(13),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.logout,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(204),
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