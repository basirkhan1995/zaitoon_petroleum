import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zaitoon_petroleum/Services/api_services.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Auth/login.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/bloc/currency_tab_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/bloc/financial_tab_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/bloc/hrtab_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/bloc/transaction_tab_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/bloc/company_settings_menu_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/bloc/stk_tab_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/bloc/stock_tab_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/bloc/menu_bloc.dart';
import 'Localizations/Bloc/localizations_bloc.dart';
import 'Localizations/l10n/l10n.dart';
import 'Localizations/l10n/translations/app_localizations.dart';
import 'Services/localization_services.dart';
import 'Themes/Bloc/themes_bloc.dart';
import 'Themes/Ui/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Views/Menu/Ui/Settings/Ui/General/bloc/general_tab_bloc.dart';
import 'Views/Menu/Ui/Settings/bloc/settings_tab_bloc.dart';
import 'Views/Menu/Ui/Settings/features/Visibility/bloc/settings_visible_bloc.dart';


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
        BlocProvider(create: (context) => CompanySettingsMenuBloc()),
        /// Data Management
        BlocProvider(create: (context) => IndividualsBloc(Repositories(ApiServices()))),
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
                  // 🔥 Add this builder:
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
