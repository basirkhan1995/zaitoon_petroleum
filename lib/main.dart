import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zaitoon_petroleum/Services/api_services.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Auth/bloc/auth_bloc.dart';
import 'package:zaitoon_petroleum/Views/Auth/Ui/login.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/Currencies/bloc/currencies_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/ExchangeRate/bloc/exchange_rate_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/bloc/currency_tab_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/GlAccounts/bloc/gl_accounts_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/bloc/financial_tab_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/UserDetail/bloc/user_details_tab_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Users/bloc/users_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/bloc/hrtab_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/bloc/transactions_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/bloc/transaction_tab_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Branch/bloc/brc_tab_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/bloc/company_settings_menu_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/IndividualByID/bloc/stakeholder_by_id_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/IndividualDetails/bloc/ind_detail_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/bloc/stk_tab_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/bloc/stock_tab_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/bloc/transport_tab_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/bloc/menu_bloc.dart';
import 'Localizations/Bloc/localizations_bloc.dart';
import 'Localizations/l10n/l10n.dart';
import 'Localizations/l10n/translations/app_localizations.dart';
import 'Services/localization_services.dart';
import 'Themes/Bloc/themes_bloc.dart';
import 'Themes/Ui/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Views/Menu/Ui/HR/Ui/UserDetail/Ui/Permissions/bloc/permissions_bloc.dart';
import 'Views/Menu/Ui/Settings/Ui/Company/Branch/Branches/bloc/branch_bloc.dart';
import 'Views/Menu/Ui/Settings/Ui/General/bloc/general_tab_bloc.dart';
import 'Views/Menu/Ui/Settings/bloc/settings_tab_bloc.dart';
import 'Views/Menu/Ui/Settings/features/Visibility/bloc/settings_visible_bloc.dart';
import 'Views/PasswordSettings/bloc/password_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [

        /// Tabs & Others
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider(create: (context) => LocalizationBloc()),
        BlocProvider(create: (context) => MenuBloc()),
        BlocProvider(create: (context) => JournalTabBloc()),
        BlocProvider(create: (context) => GeneralTabBloc()),
        BlocProvider(create: (context) => StockTabBloc()),
        BlocProvider(create: (context) => HrTabBloc()),
        BlocProvider(create: (context) => FinanceTabBloc()),
        BlocProvider(create: (context) => CurrencyTabBloc()),
        BlocProvider(create: (context) => StakeholderTabBloc()),
        BlocProvider(create: (context) => SettingsTabBloc()),
        BlocProvider(create: (context) => SettingsVisibleBloc()),
        BlocProvider(create: (context) => IndividualDetailTabBloc()),
        BlocProvider(create: (context) => CompanySettingsMenuBloc()),
        BlocProvider(create: (context) => UserDetailsTabBloc()),
        BlocProvider(create: (context) => TransportTabBloc()),
        BlocProvider(create: (context) => BranchTabBloc()),

        /// Data Management
        BlocProvider(create: (context) => IndividualsBloc(Repositories(ApiServices()))..add(LoadIndividualsEvent())),
        BlocProvider(create: (context) => AccountsBloc(Repositories(ApiServices()))..add(LoadAccountsEvent())),
        BlocProvider(create: (context) => UsersBloc(Repositories(ApiServices()))..add(LoadUsersEvent())),
        BlocProvider(create: (context) => CurrenciesBloc(Repositories(ApiServices()))..add(LoadCurrenciesEvent())),
        BlocProvider(create: (context) => GlAccountsBloc(Repositories(ApiServices()))..add(LoadAllGlAccountEvent('en'))),
        BlocProvider(create: (context) => StakeholderByIdBloc(Repositories(ApiServices()))),
        BlocProvider(create: (context) => PermissionsBloc(Repositories(ApiServices()))),
        BlocProvider(create: (context) => AuthBloc(Repositories(ApiServices()))),
        BlocProvider(create: (context) => PasswordBloc(Repositories(ApiServices()))),
        BlocProvider(create: (context) => ExchangeRateBloc(Repositories(ApiServices()))),
        BlocProvider(create: (context) => TransactionsBloc(Repositories(ApiServices()))),
        BlocProvider(create: (context) => CompanyProfileBloc(Repositories(ApiServices()))..add(LoadCompanyProfileEvent())),
        BlocProvider(create: (context) => BranchBloc(Repositories(ApiServices()))..add(LoadBranchesEvent())),
      ],
      child: BlocBuilder<LocalizationBloc, Locale>(
        builder: (context, locale) {
          return BlocBuilder<ThemeBloc, ThemeMode>(
            builder: (context, themeMode) {
              final theme = AppThemes(TextTheme.of(context));
              return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Zaitoon Petroleum',
                  localizationsDelegates: [

                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  locale: locale,
                  supportedLocales: L10n.all,
                  themeMode: themeMode,
                  darkTheme: theme.dark(),
                  theme: theme.light(),
                  builder: (context, child) {
                    localizationService.update(AppLocalizations.of(context)!);
                    return child!;
                  },
                  home: LoginView()
              );
            },
          );
        },
      ),
    );
  }
}
