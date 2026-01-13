import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'bloc/trial_balance_bloc.dart';

class TrialBalanceView extends StatelessWidget {
  const TrialBalanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(), desktop: _Desktop(), tablet: _Tablet(),);
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


class _Mobile extends StatelessWidget {
  const _Mobile();

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
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<TrialBalanceBloc>().add(LoadTrialBalanceEvent(currency: "USD", date: "2026-01-12"));
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text("Trial balance"),
      ),

      body: BlocBuilder<TrialBalanceBloc, TrialBalanceState>(
        builder: (context, state) {
          if(state is TrialBalanceErrorState){
            return NoDataWidget(
              message: state.message,
            );
          }
          if(state is TrialBalanceLoadingState){
            return Center(child: CircularProgressIndicator());
          }
          if(state is TrialBalanceLoadedState){
            return ListView.builder(
                itemCount: state.balance.length,
                itemBuilder: (context,index){
                 final tb = state.balance[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tb.accountName??""),
                              Text(tb.accountNumber??"",style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),),
                            ],
                          ),
                        ),
                        SizedBox(
                            width: 150,
                            child: Text(tb.debit.toAmount())),
                        SizedBox(
                            width: 150,
                            child: Text(tb.credit.toAmount())),

                      ],
                    ),
                  );
            });
          }
          return const SizedBox();
        },
      ),
    );
  }
}

