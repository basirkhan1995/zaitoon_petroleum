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
  /// **'Empowering Ideas, Building Trust'**
  String get zaitoonSlogan;

  /// No description provided for @zaitoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Zaitoon System'**
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
  /// **'Zaitoon System'**
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
  /// **'Fund Transfer'**
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
  /// **'Individuals'**
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
  /// **'Activity'**
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
  /// **'You\'re blocked, contact your administrator please.'**
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

  /// No description provided for @errorHint.
  ///
  /// In en, this message translates to:
  /// **'Check your services or refresh to try again.'**
  String get errorHint;

  /// No description provided for @oldPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'The old password you entered is incorrect.'**
  String get oldPasswordIncorrect;

  /// No description provided for @forceChangePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Require Password Change'**
  String get forceChangePasswordTitle;

  /// No description provided for @forceEmailVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Require Email Verification'**
  String get forceEmailVerificationTitle;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate'**
  String get rate;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From Currency'**
  String get from;

  /// No description provided for @toCurrency.
  ///
  /// In en, this message translates to:
  /// **'To Currency'**
  String get toCurrency;

  /// No description provided for @amountGreaterZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than zero.'**
  String get amountGreaterZero;

  /// No description provided for @newExchangeRateTitle.
  ///
  /// In en, this message translates to:
  /// **'New Exchange Rate'**
  String get newExchangeRateTitle;

  /// No description provided for @drivers.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get drivers;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @vehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicles;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @whatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsApp;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @narration.
  ///
  /// In en, this message translates to:
  /// **'Narration'**
  String get narration;

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get referenceNumber;

  /// No description provided for @txnMaker.
  ///
  /// In en, this message translates to:
  /// **'Maker'**
  String get txnMaker;

  /// No description provided for @txnDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get txnDate;

  /// No description provided for @authorizer.
  ///
  /// In en, this message translates to:
  /// **'Authorizer'**
  String get authorizer;

  /// No description provided for @txnType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get txnType;

  /// No description provided for @branchName.
  ///
  /// In en, this message translates to:
  /// **'Branch name'**
  String get branchName;

  /// No description provided for @branchId.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get branchId;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @authorize.
  ///
  /// In en, this message translates to:
  /// **'Authorize'**
  String get authorize;

  /// No description provided for @checker.
  ///
  /// In en, this message translates to:
  /// **'Authorized By'**
  String get checker;

  /// No description provided for @maker.
  ///
  /// In en, this message translates to:
  /// **'Created By'**
  String get maker;

  /// No description provided for @branchLimits.
  ///
  /// In en, this message translates to:
  /// **'Branch Limit'**
  String get branchLimits;

  /// No description provided for @branchInformation.
  ///
  /// In en, this message translates to:
  /// **'Branch Information'**
  String get branchInformation;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// No description provided for @txnDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get txnDetails;

  /// No description provided for @transactionRef.
  ///
  /// In en, this message translates to:
  /// **'Transaction Ref'**
  String get transactionRef;

  /// No description provided for @transactionDate.
  ///
  /// In en, this message translates to:
  /// **'Transaction Date'**
  String get transactionDate;

  /// No description provided for @recipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get recipient;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @authorizeDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to authorize this transaction.'**
  String get authorizeDeniedMessage;

  /// No description provided for @reversed.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get reversed;

  /// No description provided for @txnReprint.
  ///
  /// In en, this message translates to:
  /// **'TXN Reprint'**
  String get txnReprint;

  /// No description provided for @overLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'Insuffiecent account balance.'**
  String get overLimitMessage;

  /// No description provided for @deleteAuthorizedMessage.
  ///
  /// In en, this message translates to:
  /// **'This transaction is auhtorized and cannot be deleted.'**
  String get deleteAuthorizedMessage;

  /// No description provided for @deleteInvalidMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re not allowed to delete this transaction.'**
  String get deleteInvalidMessage;

  /// No description provided for @editInvalidMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re not allowed to update this transaction.'**
  String get editInvalidMessage;

  /// No description provided for @editInvalidAction.
  ///
  /// In en, this message translates to:
  /// **'Authorized & reversed transactions are not edited.'**
  String get editInvalidAction;

  /// No description provided for @editFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated failed, try again later'**
  String get editFailedMessage;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @reverseTitle.
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get reverseTitle;

  /// No description provided for @reverseInvalidMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re not allowed to revese this transaction.'**
  String get reverseInvalidMessage;

  /// No description provided for @reversePendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Pending transaction is not allowed to reverse.'**
  String get reversePendingMessage;

  /// No description provided for @reverseAlreadyMessage.
  ///
  /// In en, this message translates to:
  /// **'This transaction has already reversed once.'**
  String get reverseAlreadyMessage;

  /// No description provided for @authorizeInvalidMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re not allowed to authorize this transaction.'**
  String get authorizeInvalidMessage;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @selectKeyword.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectKeyword;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @selectYear.
  ///
  /// In en, this message translates to:
  /// **'Select Year'**
  String get selectYear;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @printers.
  ///
  /// In en, this message translates to:
  /// **'Printers'**
  String get printers;

  /// No description provided for @portrait.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get portrait;

  /// No description provided for @landscape.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get landscape;

  /// No description provided for @orientation.
  ///
  /// In en, this message translates to:
  /// **'Orientation'**
  String get orientation;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @paper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get paper;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get toDate;

  /// No description provided for @debitTitle.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get debitTitle;

  /// No description provided for @creditTitle.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get creditTitle;

  /// No description provided for @copies.
  ///
  /// In en, this message translates to:
  /// **'Copies'**
  String get copies;

  /// No description provided for @pages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pages;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @eg.
  ///
  /// In en, this message translates to:
  /// **'e.g, 1,3,5 or 1-3 or 1,3-5,7'**
  String get eg;

  /// No description provided for @accountStatementMessage.
  ///
  /// In en, this message translates to:
  /// **'Select an account and date range to view statement.'**
  String get accountStatementMessage;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @executiveManagement.
  ///
  /// In en, this message translates to:
  /// **'Executive management'**
  String get executiveManagement;

  /// No description provided for @operation.
  ///
  /// In en, this message translates to:
  /// **'Operation'**
  String get operation;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @marketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get marketing;

  /// No description provided for @it.
  ///
  /// In en, this message translates to:
  /// **'Information Technology (IT)'**
  String get it;

  /// No description provided for @procurement.
  ///
  /// In en, this message translates to:
  /// **'Procurement'**
  String get procurement;

  /// No description provided for @audit.
  ///
  /// In en, this message translates to:
  /// **'Audit'**
  String get audit;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @hourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get hourly;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @salaryBase.
  ///
  /// In en, this message translates to:
  /// **'Salary base'**
  String get salaryBase;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @employeeRegistration.
  ///
  /// In en, this message translates to:
  /// **'Employee Registration'**
  String get employeeRegistration;

  /// No description provided for @taxInfo.
  ///
  /// In en, this message translates to:
  /// **'TIN number'**
  String get taxInfo;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get jobTitle;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @employeeName.
  ///
  /// In en, this message translates to:
  /// **'Employee name'**
  String get employeeName;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @employed.
  ///
  /// In en, this message translates to:
  /// **'Employed'**
  String get employed;

  /// No description provided for @terminated.
  ///
  /// In en, this message translates to:
  /// **'Terminated'**
  String get terminated;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @sameAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'You cannot transfer between the same account.'**
  String get sameAccountMessage;

  /// No description provided for @operationFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to process your request at this time.'**
  String get operationFailedMessage;

  /// No description provided for @sameCurrencyNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Currency mismatch detected. Please choose accounts with identical currency.'**
  String get sameCurrencyNotAllowed;

  /// No description provided for @sameCurrencyOnlyAllowed.
  ///
  /// In en, this message translates to:
  /// **'Currency mismatch detected. Please choose accounts with identical currency.'**
  String get sameCurrencyOnlyAllowed;

  /// No description provided for @accountLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance or account limit reached.'**
  String get accountLimitMessage;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @authorizedTransaction.
  ///
  /// In en, this message translates to:
  /// **'Authorized'**
  String get authorizedTransaction;

  /// No description provided for @comLicense.
  ///
  /// In en, this message translates to:
  /// **'License No.'**
  String get comLicense;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @bulkTransfer.
  ///
  /// In en, this message translates to:
  /// **'Fund Transfer - Multi Accounts'**
  String get bulkTransfer;

  /// No description provided for @crop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get crop;

  /// No description provided for @totalDebit.
  ///
  /// In en, this message translates to:
  /// **'Total Debit'**
  String get totalDebit;

  /// No description provided for @totalCredit.
  ///
  /// In en, this message translates to:
  /// **'Total Credit'**
  String get totalCredit;

  /// No description provided for @difference.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get difference;

  /// No description provided for @debitNoEqualCredit.
  ///
  /// In en, this message translates to:
  /// **'Total debit and credit is not equal, please adjust amounts to balance.'**
  String get debitNoEqualCredit;

  /// No description provided for @successTransactionMessage.
  ///
  /// In en, this message translates to:
  /// **'Transfer has been successfully completed.'**
  String get successTransactionMessage;

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get addEntry;

  /// No description provided for @blockedAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Account is blocked.'**
  String get blockedAccountMessage;

  /// No description provided for @currencyMismatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Currency mismatch in transaction'**
  String get currencyMismatchMessage;

  /// No description provided for @transactionMismatchCcyAlert.
  ///
  /// In en, this message translates to:
  /// **'Your accounts currencies are not matching with your transaction main currency.'**
  String get transactionMismatchCcyAlert;

  /// No description provided for @ccyCode.
  ///
  /// In en, this message translates to:
  /// **'CCY'**
  String get ccyCode;

  /// No description provided for @actionBrief.
  ///
  /// In en, this message translates to:
  /// **'Act'**
  String get actionBrief;

  /// No description provided for @transactionFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Failed'**
  String get transactionFailedTitle;

  /// No description provided for @fundTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Fund Transfer SA'**
  String get fundTransferTitle;

  /// No description provided for @fundTransferMultiTitle.
  ///
  /// In en, this message translates to:
  /// **'Fund Transfer MA'**
  String get fundTransferMultiTitle;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @storages.
  ///
  /// In en, this message translates to:
  /// **'Storages'**
  String get storages;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @fxTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'FX Transaction - Multi Accounts'**
  String get fxTransactionTitle;

  /// No description provided for @debitAccCcy.
  ///
  /// In en, this message translates to:
  /// **'Debit Account Currency'**
  String get debitAccCcy;

  /// No description provided for @creditAccCcy.
  ///
  /// In en, this message translates to:
  /// **'Credit Account Currency'**
  String get creditAccCcy;

  /// No description provided for @convertedAmount.
  ///
  /// In en, this message translates to:
  /// **'Converted Amount'**
  String get convertedAmount;

  /// No description provided for @convertedAmountNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Credit amount does not match converted amount.'**
  String get convertedAmountNotMatch;

  /// No description provided for @amountIn.
  ///
  /// In en, this message translates to:
  /// **'Amount In'**
  String get amountIn;

  /// No description provided for @baseTitle.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get baseTitle;

  /// No description provided for @creditSide.
  ///
  /// In en, this message translates to:
  /// **'Credit side'**
  String get creditSide;

  /// No description provided for @debitSide.
  ///
  /// In en, this message translates to:
  /// **'Debit side'**
  String get debitSide;

  /// No description provided for @sameCurrency.
  ///
  /// In en, this message translates to:
  /// **'Same Currency'**
  String get sameCurrency;

  /// No description provided for @exchangeRatePercentage.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate can only be adjusted within ±5% of the system rate.'**
  String get exchangeRatePercentage;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'BALANCED'**
  String get balanced;

  /// No description provided for @unbalanced.
  ///
  /// In en, this message translates to:
  /// **'UNBALANCED'**
  String get unbalanced;

  /// No description provided for @various.
  ///
  /// In en, this message translates to:
  /// **'Various'**
  String get various;

  /// No description provided for @totalTitle.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalTitle;

  /// No description provided for @debitNotEqualBaseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Debit and credit amounts must balance.'**
  String get debitNotEqualBaseCurrency;

  /// No description provided for @adjusted.
  ///
  /// In en, this message translates to:
  /// **'Adjusted'**
  String get adjusted;

  /// No description provided for @enterRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get enterRate;

  /// No description provided for @driverName.
  ///
  /// In en, this message translates to:
  /// **'Driver Information'**
  String get driverName;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// No description provided for @hireDate.
  ///
  /// In en, this message translates to:
  /// **'Hired date'**
  String get hireDate;

  /// No description provided for @vehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Model'**
  String get vehicleModel;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @manufacturedYear.
  ///
  /// In en, this message translates to:
  /// **'Manufactured'**
  String get manufacturedYear;

  /// No description provided for @vehiclePlate.
  ///
  /// In en, this message translates to:
  /// **'Plate No'**
  String get vehiclePlate;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get vehicleType;

  /// No description provided for @fuelType.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get fuelType;

  /// No description provided for @vinNumber.
  ///
  /// In en, this message translates to:
  /// **'VIN Number'**
  String get vinNumber;

  /// No description provided for @enginePower.
  ///
  /// In en, this message translates to:
  /// **'Engine Power'**
  String get enginePower;

  /// No description provided for @vclRegisteredNo.
  ///
  /// In en, this message translates to:
  /// **'Registered License'**
  String get vclRegisteredNo;

  /// No description provided for @ownership.
  ///
  /// In en, this message translates to:
  /// **'Onwership'**
  String get ownership;

  /// No description provided for @rental.
  ///
  /// In en, this message translates to:
  /// **'Rental'**
  String get rental;

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get owned;

  /// No description provided for @lease.
  ///
  /// In en, this message translates to:
  /// **'Lease'**
  String get lease;

  /// No description provided for @petrol.
  ///
  /// In en, this message translates to:
  /// **'Petrol'**
  String get petrol;

  /// No description provided for @diesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get diesel;

  /// No description provided for @cngGas.
  ///
  /// In en, this message translates to:
  /// **'CNG'**
  String get cngGas;

  /// No description provided for @lpgGass.
  ///
  /// In en, this message translates to:
  /// **'LPG'**
  String get lpgGass;

  /// No description provided for @electric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get electric;

  /// No description provided for @hydrogen.
  ///
  /// In en, this message translates to:
  /// **'Hydrogen'**
  String get hydrogen;

  /// No description provided for @hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get hybrid;

  /// No description provided for @truck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get truck;

  /// No description provided for @tanker.
  ///
  /// In en, this message translates to:
  /// **'Tanker'**
  String get tanker;

  /// No description provided for @trailer.
  ///
  /// In en, this message translates to:
  /// **'Trailer'**
  String get trailer;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @van.
  ///
  /// In en, this message translates to:
  /// **'Van'**
  String get van;

  /// No description provided for @bus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get bus;

  /// No description provided for @miniVan.
  ///
  /// In en, this message translates to:
  /// **'Mini Van'**
  String get miniVan;

  /// No description provided for @sedan.
  ///
  /// In en, this message translates to:
  /// **'Sedan'**
  String get sedan;

  /// No description provided for @suv.
  ///
  /// In en, this message translates to:
  /// **'SUV'**
  String get suv;

  /// No description provided for @motorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get motorcycle;

  /// No description provided for @rickshaw.
  ///
  /// In en, this message translates to:
  /// **'Rickshaw'**
  String get rickshaw;

  /// No description provided for @ambulance.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get ambulance;

  /// No description provided for @fireTruck.
  ///
  /// In en, this message translates to:
  /// **'Fire Truck'**
  String get fireTruck;

  /// No description provided for @tractor.
  ///
  /// In en, this message translates to:
  /// **'Tractor'**
  String get tractor;

  /// No description provided for @refrigeratedTruck.
  ///
  /// In en, this message translates to:
  /// **'Refrigerated Truck'**
  String get refrigeratedTruck;

  /// No description provided for @meter.
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get meter;

  /// No description provided for @vclExpireDate.
  ///
  /// In en, this message translates to:
  /// **'Expire date'**
  String get vclExpireDate;

  /// No description provided for @remark.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get remark;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @debitAccount.
  ///
  /// In en, this message translates to:
  /// **'Debit Account'**
  String get debitAccount;

  /// No description provided for @creditAccount.
  ///
  /// In en, this message translates to:
  /// **'Credit Account'**
  String get creditAccount;

  /// No description provided for @vehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get vehicleDetails;

  /// No description provided for @authorizedTitle.
  ///
  /// In en, this message translates to:
  /// **'Authorized'**
  String get authorizedTitle;

  /// No description provided for @pendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingTitle;

  /// No description provided for @shpFrom.
  ///
  /// In en, this message translates to:
  /// **'Shipping from'**
  String get shpFrom;

  /// No description provided for @shpTo.
  ///
  /// In en, this message translates to:
  /// **'Shipping to'**
  String get shpTo;

  /// No description provided for @loadingDate.
  ///
  /// In en, this message translates to:
  /// **'Loading date'**
  String get loadingDate;

  /// No description provided for @unloadingDate.
  ///
  /// In en, this message translates to:
  /// **'ULD Date'**
  String get unloadingDate;

  /// No description provided for @shippingRent.
  ///
  /// In en, this message translates to:
  /// **'L/U Cost'**
  String get shippingRent;

  /// No description provided for @loadingSize.
  ///
  /// In en, this message translates to:
  /// **'LD Weight'**
  String get loadingSize;

  /// No description provided for @unloadingSize.
  ///
  /// In en, this message translates to:
  /// **'ULD Weight'**
  String get unloadingSize;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @advanceAmount.
  ///
  /// In en, this message translates to:
  /// **'Advance amount'**
  String get advanceAmount;

  /// No description provided for @tonTitle.
  ///
  /// In en, this message translates to:
  /// **'Ton'**
  String get tonTitle;

  /// No description provided for @kgTitle.
  ///
  /// In en, this message translates to:
  /// **'Kg'**
  String get kgTitle;

  /// No description provided for @completedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get completedTitle;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @todayTransaction.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Transactions'**
  String get todayTransaction;

  /// No description provided for @pendingTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending Transactions'**
  String get pendingTransactionTitle;

  /// No description provided for @pendingTransactionHint.
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval or completion'**
  String get pendingTransactionHint;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @advancePayment.
  ///
  /// In en, this message translates to:
  /// **'Advance Payment'**
  String get advancePayment;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @noExpenseRecorded.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded'**
  String get noExpenseRecorded;
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
