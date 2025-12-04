import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Localizations/Bloc/localizations_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';

class AccountsReportView extends StatelessWidget {
  const AccountsReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(),
      tablet: _Tablet(),
    );
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

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  String? currentLocale;
  String? baseCurrency;

  @override
  void initState() {
    super.initState();

    // Read initial values without watching
    final compState = context.read<CompanyProfileBloc>().state;
    if (compState is CompanyProfileLoadedState) {
      baseCurrency = compState.company.comLocalCcy;
    }

    currentLocale = context.read<LocalizationBloc>().state.countryCode;

    // Try loading accounts only if both values are available
    _tryLoadAccounts();
  }

  /// Load only when both required values exist
  void _tryLoadAccounts() {
    if (currentLocale != null && baseCurrency != null) {
      context.read<AccountsBloc>().add(
        LoadAccountsFilterEvent(
          start: 1,
          end: 5,
          locale: currentLocale!,
          ccy: baseCurrency!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        /// Listen for company profile changes
        BlocListener<CompanyProfileBloc, CompanyProfileState>(
          listener: (context, state) {
            if (state is CompanyProfileLoadedState) {
              setState(() {
                baseCurrency = state.company.comLocalCcy;
              });
              _tryLoadAccounts();
            }
          },
        ),

        /// Listen for locale changes
        BlocListener<LocalizationBloc, Locale>(
          listener: (context, state) {
            setState(() {
              currentLocale = state.countryCode;
            });
            _tryLoadAccounts();
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Accounts Report"),
        ),

        body: BlocBuilder<AccountsBloc, AccountsState>(
          builder: (context, state) {
            if (state is AccountErrorState) {
              return Center(child: Text(state.message));
            }

            if (state is AccountLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AccountLoadedState) {
              if (state.accounts.isEmpty) {
                return const Center(child: Text("No accounts found"));
              }

              return ListView.builder(
                itemCount: state.accounts.length,
                itemBuilder: (context, index) {
                  final account = state.accounts[index];
                  return ListTile(
                    title: Row(
                      children: [
                        SizedBox(
                            width: 80,
                            child: Text(account.accNumber.toString())),
                        Text(account.accName.toString()),
                      ],
                    ),
                    trailing: Text(account.accBalance?.toAmount() ?? ""),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
