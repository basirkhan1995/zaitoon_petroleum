
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
      mobile: const _Mobile(),
      desktop: const _Desktop(),
      tablet: const _Tablet(),
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
  bool _initialLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialLoaded) {
      final compState = context.read<CompanyProfileBloc>().state;
      if (compState is CompanyProfileLoadedState) {
        baseCurrency = compState.company.comLocalCcy;
      }

      currentLocale = context.read<LocalizationBloc>().state.countryCode;

      _loadAccounts();
      _initialLoaded = true;
    }
  }

  void _loadAccounts() {
    context.read<AccountsBloc>().add(
      LoadAccountsFilterEvent(
        start: 1,
        end: 5,
        ccy: baseCurrency,
        locale: "en",
        exclude: '',
        input: ''
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<CompanyProfileBloc, CompanyProfileState>(
          listener: (context, state) {
            if (state is CompanyProfileLoadedState) {
              setState(() {
                baseCurrency = state.company.comLocalCcy;
              });
              _loadAccounts();
            }
          },
        ),

        BlocListener<LocalizationBloc, Locale>(
          listener: (context, state) {
            setState(() {
              currentLocale = state.countryCode;
            });
            _loadAccounts();
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text("Accounts Report")),

        body: BlocBuilder<AccountsBloc, AccountsState>(
          builder: (context, state) {
            if (state is AccountLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AccountErrorState) {
              return Center(child: Text(state.message));
            }

            if (state is AccountLoadedState) {
              if (state.accounts.isEmpty) {
                return const Center(child: Text("No accounts found"));
              }

              return ListView.builder(
                itemCount: state.accounts.length,
                itemBuilder: (context, index) {
                  final account = state.accounts[index];

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: index.isEven
                          ? color.primary.withValues(alpha: .05)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 80, child: Text(account.accNumber.toString())),
                        Expanded(child: Text(account.accName.toString())),
                        Text("${account.accBalance?.toAmount()} ${account.actCurrency??baseCurrency}"),
                      ],
                    ),
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
