import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/total_daily_bloc.dart';
import 'package:shamsi_date/shamsi_date.dart';

class TotalDailyTxnView extends StatelessWidget {
  final String? fromDate;
  final String? toDate;
  const TotalDailyTxnView({super.key,this.fromDate,this.toDate});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), desktop: _Desktop(fromDate, toDate),tablet: _Tablet(),);
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
  final String? fromDate;
  final String? toDate;
  const _Desktop(this.fromDate, this.toDate);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<TotalDailyBloc>().add(LoadTotalDailyEvent(widget.fromDate ?? fromDate, widget.toDate ?? toDate));
    });
    super.initState();
  }

  String fromDate = DateTime.now().toFormattedDate();
  String toDate = DateTime.now().toFormattedDate();
  Jalali shamsiFromDate = DateTime.now().toAfghanShamsi;
  Jalali shamsiToDate = DateTime.now().toAfghanShamsi;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TotalDailyBloc, TotalDailyState>(
      builder: (context, state) {
        if (state is TotalDailyError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is TotalDailyLoaded) {
          final data = state.data;

          return Stack(
            children: [
              Wrap(
                spacing: 1,
                runSpacing: 10,
                children: data.map((item) {
                  final color = theme.colorScheme.onSurface;

                  return Container(
                    width: 190,
                    padding: const EdgeInsets.all(10),
                    margin: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withValues(alpha: .15),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// 🔹 Transaction Name
                        Row(
                          spacing: 3,
                          children: [
                            Icon(Icons.line_axis_rounded,size: 15,color: theme.colorScheme.outline.withValues(alpha: .9)),
                            Text(
                              item.txnName ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w400,
                                color: theme.colorScheme.outline.withValues(alpha: .9)
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        /// 🔹 Amount
                        Text(
                          item.totalAmount?.toAmount()??"0.00",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),

                        const SizedBox(height: 4),

                        /// 🔹 Count
                        Text(
                          '${item.totalCount} transactions',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              /// 🔄 Refresh indicator (top-right)
              if (state.isRefreshing)
                const Positioned(
                  top: 6,
                  right: 6,
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          );
        }

        /// First load
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

}


