import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/EndOfYear/bloc/eoy_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EndOfYearView extends StatelessWidget {
  const EndOfYearView({super.key});

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

class _Desktop extends StatelessWidget {
  const _Desktop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("P&L"),
      ),

      body: BlocBuilder<EoyBloc, EoyState>(
    builder: (context, state) {
      if (state is EoyErrorState) {
        return NoDataWidget(message: state.error);
      }

      if (state is EoyLoadingState) {
        return const Center(child: CircularProgressIndicator());
      }

      if (state is EoyLoadedState) {
        return ListView.builder(
          itemCount: state.eoy.length,
          itemBuilder: (context, index) {
            final eoy = state.eoy[index];
            return Container(
              decoration: BoxDecoration(
                color: index.isEven ? Theme.of(context).colorScheme.primary.withValues(alpha: .05) : Colors.transparent
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        eoy.accountNumber.toString(),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        eoy.accountName ?? "",
                      ),
                    ),

                    SizedBox(
                      width: 100,
                      child: Text(
                        eoy.trdBranch.toString(),
                      ),
                    ),

                    SizedBox(
                      width: 100,
                      child: Text(
                        eoy.category.toString(),
                      ),
                    ),

                    SizedBox(
                      width: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            eoy.debit.toAmount(),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            eoy.currency ?? "",
                            style: TextStyle(
                              color: Utils.currencyColors(eoy.currency ?? ""),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            eoy.credit.toAmount(),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            eoy.currency ?? "",
                            style: TextStyle(
                              color: Utils.currencyColors(eoy.currency ?? ""),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            );
          },
        );
      }

      return const SizedBox();
    },
    ),

    );
  }
}

