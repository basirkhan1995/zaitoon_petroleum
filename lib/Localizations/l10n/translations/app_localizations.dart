import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'translations/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fa'),
  ];

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String hello(String name);

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'{name} is required'**
  String required(String name);

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemMode;

  /// No description provided for @newDatabase.
  ///
  /// In en, this message translates to:
  /// **'New Database'**
  String get newDatabase;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @zaitoonSlogan.
  ///
  /// In en, this message translates to:
  /// **'Empowering Ideas. Building Trust'**
  String get zaitoonSlogan;

  /// No description provided for @zaitoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Zaitoon Software Inc.'**
  String get zaitoonTitle;

  /// No description provided for @initialStock.
  ///
  /// In en, this message translates to:
  /// **'Initial Stock'**
  String get initialStock;

  /// No description provided for @serverConnection.
  ///
  /// In en, this message translates to:
  /// **'Server Connection'**
  String get serverConnection;

  /// No description provided for @connectToServer.
  ///
  /// In en, this message translates to:
  /// **'Connect to Server'**
  String get connectToServer;

  /// No description provided for @currentServer.
  ///
  /// In en, this message translates to:
  /// **'Current Server'**
  String get currentServer;

  /// No description provided for @deviceIp.
  ///
  /// In en, this message translates to:
  /// **'Device IP'**
  String get deviceIp;

  /// No description provided for @serverIpAddress.
  ///
  /// In en, this message translates to:
  /// **'Server IP Address'**
  String get serverIpAddress;

  /// No description provided for @quickConnect.
  ///
  /// In en, this message translates to:
  /// **'Quick Connect'**
  String get quickConnect;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @connectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Connected Successfully'**
  String get connectedSuccessfully;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get connectionFailed;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get report;

  /// No description provided for @journal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journal;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @stakeholders.
  ///
  /// In en, this message translates to:
  /// **'Stakeholders'**
  String get stakeholders;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @incorrectCredential.
  ///
  /// In en, this message translates to:
  /// **'Username or password is incorrect'**
  String get incorrectCredential;

  /// No description provided for @urlNotFound.
  ///
  /// In en, this message translates to:
  /// **'URL not found.'**
  String get urlNotFound;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @glAccounts.
  ///
  /// In en, this message translates to:
  /// **'GL Accounts'**
  String get glAccounts;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Acc Number'**
  String get accountNumber;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Acc Name'**
  String get accountName;

  /// No description provided for @accountCategory.
  ///
  /// In en, this message translates to:
  /// **'Acc Category'**
  String get accountCategory;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @mobile1.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile1;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessName;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @newKeyword.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newKeyword;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// No description provided for @userOwner.
  ///
  /// In en, this message translates to:
  /// **'User onwer'**
  String get userOwner;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @manager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get manager;

  /// No description provided for @viewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get viewer;

  /// No description provided for @adminstrator.
  ///
  /// In en, this message translates to:
  /// **'Adminstrator'**
  String get adminstrator;

  /// No description provided for @userInformation.
  ///
  /// In en, this message translates to:
  /// **'User Informations'**
  String get userInformation;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemSettings;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @checkConnectivity.
  ///
  /// In en, this message translates to:
  /// **'Check Connectivity'**
  String get checkConnectivity;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @flag.
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get flag;

  /// No description provided for @currencyCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get currencyCode;

  /// No description provided for @currencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyTitle;

  /// No description provided for @ccyLocalName.
  ///
  /// In en, this message translates to:
  /// **'Local name'**
  String get ccyLocalName;

  /// No description provided for @ccySymbol.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get ccySymbol;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @countryCode.
  ///
  /// In en, this message translates to:
  /// **'Country code'**
  String get countryCode;

  /// No description provided for @ccyName.
  ///
  /// In en, this message translates to:
  /// **'Currency name'**
  String get ccyName;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @financialPeriod.
  ///
  /// In en, this message translates to:
  /// **'Financial Period'**
  String get financialPeriod;

  /// No description provided for @nationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalId;

  /// No description provided for @newStakeholder.
  ///
  /// In en, this message translates to:
  /// **'New Stakeholder'**
  String get newStakeholder;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @emailValidationMessage.
  ///
  /// In en, this message translates to:
  /// **'Email is not valid.'**
  String get emailValidationMessage;

  /// No description provided for @categoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryTitle;

  /// No description provided for @profileAndAccounts.
  ///
  /// In en, this message translates to:
  /// **'Profile & Accounts'**
  String get profileAndAccounts;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created By'**
  String get createdBy;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @baseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Base Currency'**
  String get baseCurrency;

  /// No description provided for @comDetails.
  ///
  /// In en, this message translates to:
  /// **'Company Details'**
  String get comDetails;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Manage you company address.'**
  String get addressHint;

  /// No description provided for @profileHint.
  ///
  /// In en, this message translates to:
  /// **'Manage your company profile'**
  String get profileHint;

  /// No description provided for @welcomeBoss.
  ///
  /// In en, this message translates to:
  /// **'Welcome Boss!'**
  String get welcomeBoss;

  /// No description provided for @emailOrUsrname.
  ///
  /// In en, this message translates to:
  /// **'Email or Username'**
  String get emailOrUsrname;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @settingsHint.
  ///
  /// In en, this message translates to:
  /// **'Adjust preferences to suit your needs'**
  String get settingsHint;

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @zPetroleum.
  ///
  /// In en, this message translates to:
  /// **'Zaitoon Petroleum Software'**
  String get zPetroleum;

  /// No description provided for @hijriShamsi.
  ///
  /// In en, this message translates to:
  /// **'Hijri Shamsi'**
  String get hijriShamsi;

  /// No description provided for @gregorian.
  ///
  /// In en, this message translates to:
  /// **'Gregorian'**
  String get gregorian;

  /// No description provided for @dateTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'System Date'**
  String get dateTypeTitle;

  /// No description provided for @dashboardClock.
  ///
  /// In en, this message translates to:
  /// **'Digital Clock'**
  String get dashboardClock;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date Format'**
  String get dateFormat;

  /// No description provided for @clockHint.
  ///
  /// In en, this message translates to:
  /// **'Display a digital clock on the main dashboard'**
  String get clockHint;

  /// No description provided for @exchangeRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate'**
  String get exchangeRateTitle;

  /// No description provided for @exhangeRateHint.
  ///
  /// In en, this message translates to:
  /// **'Display the latest currency exchange rate for quick reference.'**
  String get exhangeRateHint;

  /// No description provided for @buyTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buyTitle;

  /// No description provided for @sellTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sellTitle;

  /// No description provided for @pendingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingTransactions;

  /// No description provided for @authorizedTransactions.
  ///
  /// In en, this message translates to:
  /// **'Authorized'**
  String get authorizedTransactions;

  /// No description provided for @allTransactions.
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get allTransactions;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @accountTransfer.
  ///
  /// In en, this message translates to:
  /// **'Account Transfer'**
  String get accountTransfer;

  /// No description provided for @fxTransaction.
  ///
  /// In en, this message translates to:
  /// **'FX Transaction'**
  String get fxTransaction;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expense;

  /// No description provided for @returnGoods.
  ///
  /// In en, this message translates to:
  /// **'Return Goods'**
  String get returnGoods;

  /// No description provided for @cashFlow.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow'**
  String get cashFlow;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @systemAction.
  ///
  /// In en, this message translates to:
  /// **'System Actions'**
  String get systemAction;

  /// No description provided for @glCreditTitle.
  ///
  /// In en, this message translates to:
  /// **'GL Credit'**
  String get glCreditTitle;

  /// No description provided for @glDebitTitle.
  ///
  /// In en, this message translates to:
  /// **'GL Debit'**
  String get glDebitTitle;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @accountStatement.
  ///
  /// In en, this message translates to:
  /// **'Account Statement'**
  String get accountStatement;

  /// No description provided for @creditors.
  ///
  /// In en, this message translates to:
  /// **'Creditors'**
  String get creditors;

  /// No description provided for @debtors.
  ///
  /// In en, this message translates to:
  /// **'Debtors'**
  String get debtors;

  /// No description provided for @treasury.
  ///
  /// In en, this message translates to:
  /// **'Treasury'**
  String get treasury;

  /// No description provided for @exchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate'**
  String get exchangeRate;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @salesInvoice.
  ///
  /// In en, this message translates to:
  /// **'Sales Invoice'**
  String get salesInvoice;

  /// No description provided for @purchaseInvoice.
  ///
  /// In en, this message translates to:
  /// **'Purchase Invoice'**
  String get purchaseInvoice;

  /// No description provided for @referenceTransaction.
  ///
  /// In en, this message translates to:
  /// **'Reference Transaction'**
  String get referenceTransaction;

  /// No description provided for @balanceSheet.
  ///
  /// In en, this message translates to:
  /// **'Balance Sheet'**
  String get balanceSheet;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @incomeStatement.
  ///
  /// In en, this message translates to:
  /// **'Profit & Loss'**
  String get incomeStatement;

  /// No description provided for @glReport.
  ///
  /// In en, this message translates to:
  /// **'GL Report'**
  String get glReport;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @glStatement.
  ///
  /// In en, this message translates to:
  /// **'GL Statement'**
  String get glStatement;

  /// No description provided for @branches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get branches;

  /// No description provided for @shift.
  ///
  /// In en, this message translates to:
  /// **'Goods Shift'**
  String get shift;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @attendence.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendence;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @hr.
  ///
  /// In en, this message translates to:
  /// **'HR Manager'**
  String get hr;

  /// No description provided for @hrTitle.
  ///
  /// In en, this message translates to:
  /// **'Human Resource Management'**
  String get hrTitle;

  /// No description provided for @fiscalYear.
  ///
  /// In en, this message translates to:
  /// **'EOY Operation'**
  String get fiscalYear;

  /// No description provided for @manageFinance.
  ///
  /// In en, this message translates to:
  /// **'Manage fiscal years, currencies, and exchange rates.'**
  String get manageFinance;

  /// No description provided for @hrManagement.
  ///
  /// In en, this message translates to:
  /// **'Manage employees, attendance, and user access.'**
  String get hrManagement;

  /// No description provided for @stakeholderManage.
  ///
  /// In en, this message translates to:
  /// **'Manage Stakeholders & Accounts.'**
  String get stakeholderManage;

  /// No description provided for @payRoll.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get payRoll;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No result found'**
  String get noDataFound;

  /// No description provided for @stakeholderInfo.
  ///
  /// In en, this message translates to:
  /// **'Stakeholder Information'**
  String get stakeholderInfo;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternet;

  /// No description provided for @url404.
  ///
  /// In en, this message translates to:
  /// **'URL 404 not found.'**
  String get url404;

  /// No description provided for @badRequest.
  ///
  /// In en, this message translates to:
  /// **'Bad Request! Please check your input.'**
  String get badRequest;

  /// No description provided for @unAuthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized! Please login again.'**
  String get unAuthorized;

  /// No description provided for @forbidden.
  ///
  /// In en, this message translates to:
  /// **'Access Denied! You don\'t have permission.'**
  String get forbidden;

  /// No description provided for @internalServerError.
  ///
  /// In en, this message translates to:
  /// **'Server Error! Please try again later.'**
  String get internalServerError;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service Unavailable! Please try later.'**
  String get serviceUnavailable;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error:'**
  String get serverError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network Error! Please check your connection.'**
  String get networkError;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @dob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dob;

  /// No description provided for @cellNumber.
  ///
  /// In en, this message translates to:
  /// **'Cell Phone'**
  String get cellNumber;

  /// No description provided for @province.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get province;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @isMilling.
  ///
  /// In en, this message translates to:
  /// **'Is your mailing address same as your address?'**
  String get isMilling;

  /// No description provided for @zipCode.
  ///
  /// In en, this message translates to:
  /// **'Zip code'**
  String get zipCode;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Accounts Information'**
  String get accountInformation;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @accNameOrNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Name or Number'**
  String get accNameOrNumber;

  /// No description provided for @usrId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get usrId;

  /// No description provided for @branch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branch;

  /// No description provided for @usrRole.
  ///
  /// In en, this message translates to:
  /// **'User Role'**
  String get usrRole;

  /// No description provided for @profileOverview.
  ///
  /// In en, this message translates to:
  /// **'Profile Overview'**
  String get profileOverview;

  /// No description provided for @currencyName.
  ///
  /// In en, this message translates to:
  /// **'Currency Name'**
  String get currencyName;

  /// No description provided for @symbol.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get symbol;

  /// No description provided for @accountLimit.
  ///
  /// In en, this message translates to:
  /// **'Account Limit'**
  String get accountLimit;

  /// No description provided for @asset.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get asset;

  /// No description provided for @liability.
  ///
  /// In en, this message translates to:
  /// **'Liability'**
  String get liability;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @ignore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get ignore;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @currencyActivationMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you wanna activate this currency?'**
  String get currencyActivationMessage;

  /// No description provided for @entities.
  ///
  /// In en, this message translates to:
  /// **'Entities'**
  String get entities;

  /// No description provided for @individuals.
  ///
  /// In en, this message translates to:
  /// **'Individuals'**
  String get individuals;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @socialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social Profile'**
  String get socialMedia;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @userLog.
  ///
  /// In en, this message translates to:
  /// **'User Log'**
  String get userLog;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @deniedPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Access Denied! You don’t have permission to view this section.'**
  String get deniedPermissionMessage;

  /// No description provided for @deniedPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Restricted Section'**
  String get deniedPermissionTitle;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @manageUser.
  ///
  /// In en, this message translates to:
  /// **'Review user activities and permissions.'**
  String get manageUser;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get createdAt;

  /// No description provided for @cashOperations.
  ///
  /// In en, this message translates to:
  /// **'Cash Operations'**
  String get cashOperations;

  /// No description provided for @usersAndAuthorizations.
  ///
  /// In en, this message translates to:
  /// **'Users & Authorizations'**
  String get usersAndAuthorizations;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is incorrect.'**
  String get incorrectPassword;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access Denied!'**
  String get accessDenied;

  /// No description provided for @unverified.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t verified your email yet.'**
  String get unverified;

  /// No description provided for @blockedMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re blocked, contact your administrator please?'**
  String get blockedMessage;

  /// No description provided for @ceo.
  ///
  /// In en, this message translates to:
  /// **'CEO'**
  String get ceo;

  /// No description provided for @deputy.
  ///
  /// In en, this message translates to:
  /// **'Deputy'**
  String get deputy;

  /// No description provided for @authoriser.
  ///
  /// In en, this message translates to:
  /// **'Authoriser'**
  String get authoriser;

  /// No description provided for @officer.
  ///
  /// In en, this message translates to:
  /// **'Officer'**
  String get officer;

  /// No description provided for @customerService.
  ///
  /// In en, this message translates to:
  /// **'Customer Service'**
  String get customerService;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get selectRole;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get confirmPassword;

  /// No description provided for @password8Char.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get password8Char;

  /// No description provided for @passwordUpperCase.
  ///
  /// In en, this message translates to:
  /// **'Password must include an uppercase letter'**
  String get passwordUpperCase;

  /// No description provided for @passwordLowerCase.
  ///
  /// In en, this message translates to:
  /// **'Password must include a lowercase letter'**
  String get passwordLowerCase;

  /// No description provided for @passwordWithDigit.
  ///
  /// In en, this message translates to:
  /// **'Password must include a number'**
  String get passwordWithDigit;

  /// No description provided for @passwordWithSpecialChar.
  ///
  /// In en, this message translates to:
  /// **'Password must include a special character'**
  String get passwordWithSpecialChar;

  /// No description provided for @passwordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordNotMatch;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 4 characters'**
  String get usernameMinLength;

  /// No description provided for @usernameNoStartDigit.
  ///
  /// In en, this message translates to:
  /// **'Username cannot start with a number'**
  String get usernameNoStartDigit;

  /// No description provided for @usernameInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Username can only contain letters, numbers.'**
  String get usernameInvalidChars;

  /// No description provided for @usernameNoSpaces.
  ///
  /// In en, this message translates to:
  /// **'Username cannot contain spaces'**
  String get usernameNoSpaces;

  /// No description provided for @addUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUserTitle;

  /// No description provided for @cashier.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get cashier;

  /// No description provided for @emailExists.
  ///
  /// In en, this message translates to:
  /// **'Email already exists, please choose another.'**
  String get emailExists;

  /// No description provided for @usernameExists.
  ///
  /// In en, this message translates to:
  /// **'Username already exists. Please choose another.'**
  String get usernameExists;

  /// No description provided for @backTitle.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backTitle;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordTitle;

  /// No description provided for @forceChangePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'For your security, please set a new password.'**
  String get forceChangePasswordHint;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
