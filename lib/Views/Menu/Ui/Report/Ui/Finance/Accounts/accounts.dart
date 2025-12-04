import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';

class AccountsReportView extends StatelessWidget {
  const AccountsReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(), desktop: _Desktop(), tablet: _Tablet(),);
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
  @override
  void initState() {
    context.read<AccountsBloc>().add(LoadAccountsFilterEvent(start: 1,end: 5,locale: 'en',ccy: "USD"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Accounts Report"),
      ),

      body: BlocBuilder<AccountsBloc, AccountsState>(
        builder: (context, state) {
          if(state is AccountErrorState){
            return Center(child: Text(state.message));
          }
          if(state is AccountLoadingState){
            return Center(child: CircularProgressIndicator(),);
          }
           if(state is AccountLoadedState){
             return ListView.builder(
                 itemCount: state.accounts.length,
                 itemBuilder: (context,index){
                 return ListTile(
                   title: Text(state.accounts[index].accNumber.toString()),
                   trailing: Text(state.accounts[index].accBalance?.toAmount()??""),
                 );
             });
           }
          return const SizedBox();
        },
      ),
    );
  }
}

