import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Finance/ArApReport/bloc/ar_ap_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PayablesView extends StatelessWidget {
  const PayablesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
        mobile: _Mobile(), tablet: _Tablet(), desktop: _Desktop());
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
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<ArApBloc>().add(LoadArApEvent());
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    TextStyle? title = Theme.of(context).textTheme.titleMedium;
    TextStyle? subTitle = Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline);
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(tr.creditors),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              children: [
                SizedBox(
                    width: 280,
                    child: Text(tr.accounts,style: title,)),
                Expanded(child: Text("Signatory",style: title,)),
                Text(tr.balance,style: title,),
              ],
            ),
          ),
          Divider(
            indent: 15,endIndent: 15,
          ),
          Expanded(
            child: BlocBuilder<ArApBloc, ArApState>(
              builder: (context, state) {
                if(state is ArApErrorState){
                  return NoDataWidget(
                    message: state.error,
                  );
                }
                if(state is ArApLoadingState){
                  return Center(
                      child: CircularProgressIndicator());
                }
                if(state is ArApLoadedState){
                  return ListView.builder(
                      itemCount: state.apAccounts.length,
                      itemBuilder: (context,index){
                        final ap = state.apAccounts[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 8),
                      decoration: BoxDecoration(
                        color: index.isOdd? Theme.of(context).colorScheme.primary.withValues(alpha: .05) : Colors.transparent
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 280,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ap.accName??"",style: title),
                                Text(ap.accNumber.toString(),style: subTitle),
                              ],
                            ),
                          ),

                          Expanded(child: Text(ap.fullName??"",style: Theme.of(context).textTheme.titleMedium)),
                          Text("${ap.accBalance.toAmount()} ${ap.accCurrency}",style: Theme.of(context).textTheme.titleMedium),

                        ],
                      ),
                    );
                  });
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

