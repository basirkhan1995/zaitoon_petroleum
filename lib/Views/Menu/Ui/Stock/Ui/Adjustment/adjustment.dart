// adjustment_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/search_field.dart';
import 'package:zaitoon_petroleum/Features/Widgets/txn_status_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../Features/Other/extensions.dart';
import '../../../../../../Features/Other/utils.dart';
import '../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import 'adjustment_details.dart';
import 'bloc/adjustment_bloc.dart';

class AdjustmentView extends StatelessWidget {
  const AdjustmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const _Mobile(),
      desktop: const _Desktop(),
      tablet: const _Tablet(),
    );
  }
}

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  String? baseCurrency;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdjustmentBloc>().add(LoadAdjustmentsEvent());
    });

    final companyState = context.read<CompanyProfileBloc>().state;
    if (companyState is CompanyProfileLoadedState) {
      baseCurrency = companyState.company.comLocalCcy ?? "";
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onRefresh() {
    context.read<AdjustmentBloc>().add(LoadAdjustmentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    TextStyle? titleStyle = textTheme.titleSmall?.copyWith(color: color.surface);
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  flex: 5,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    tileColor: Colors.transparent,
                    title: Text(
                      tr.adjustment,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20),
                    ),
                    subtitle: Text(
                      'Adjust inventory shortage to expense account',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ZSearchField(
                    icon: FontAwesomeIcons.magnifyingGlass,
                    controller: searchController,
                    hint: tr.search,
                    onChanged: (e) {
                      setState(() {});
                    },
                    title: "",
                  ),
                ),
                ZOutlineButton(
                  toolTip: "F5",
                  width: 120,
                  icon: Icons.refresh,
                  onPressed: onRefresh,
                  label: Text(tr.refresh),
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: .9),
            ),
            child: Row(
              children: [
                SizedBox(width: 40, child: Text('#', style: titleStyle)),
                SizedBox(width: 100, child: Text(tr.date, style: titleStyle)),
                SizedBox(width: 215, child: Text(tr.referenceNumber, style: titleStyle)),
                Expanded(child: Text(tr.accountNumber, style: titleStyle)),
                SizedBox(width: 150, child: Text(tr.amount, style: titleStyle)),
                SizedBox(width: 120, child: Text(tr.status, style: titleStyle)),
              ],
            ),
          ),

          // Adjustments List
          Expanded(
            child: BlocConsumer<AdjustmentBloc, AdjustmentState>(
              listener: (context, state) {
                // When we get a deleted state, refresh the data
                if (state is AdjustmentDeletedState) {
                  Utils.showOverlayMessage(
                    context,
                    message: state.message,
                    isError: false,
                  );
                  context.read<AdjustmentBloc>().add(LoadAdjustmentsEvent());
                }
                // When we get a saved state, refresh the data
                if (state is AdjustmentSavedState) {
                  Utils.showOverlayMessage(
                    context,
                    message: state.message,
                    isError: false,
                  );
                  context.read<AdjustmentBloc>().add(LoadAdjustmentsEvent());
                }
                if (state is AdjustmentErrorState) {
                  Utils.showOverlayMessage(
                    context,
                    message: state.error,
                    isError: true,
                  );
                }
              },
              builder: (context, state) {
                // Loading states
                if (state is AdjustmentLoadingState ||
                    state is AdjustmentSavingState ||
                    state is AdjustmentDeletingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error state
                if (state is AdjustmentErrorState) {
                  return NoDataWidget(
                    imageName: 'error.png',
                    message: state.error,
                    onRefresh: onRefresh,
                  );
                }

                // Loaded state
                if (state is AdjustmentLoadedState) {
                  final query = searchController.text.toLowerCase().trim();
                  final filteredList = state.adjustments.where((item) {
                    final ref = item.ordxRef?.toLowerCase() ?? '';
                    final ordId = item.ordId?.toString() ?? '';
                    final account = item.account?.toString() ?? '';
                    final amount = item.amount?.toLowerCase() ?? '';
                    final status = item.trnStateText?.toLowerCase() ?? '';
                    return ref.contains(query) ||
                        ordId.contains(query) ||
                        account.contains(query) ||
                        amount.contains(query) ||
                        status.contains(query);
                  }).toList();

                  if (filteredList.isEmpty) {
                    return NoDataWidget(
                      message: tr.noDataFound,
                      onRefresh: onRefresh,
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final adjustment = filteredList[index];

                      return InkWell(
                        onTap: () {
                          Utils.goto(
                            context,
                            AdjustmentDetailView(orderId: adjustment.ordId!),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: index.isEven
                                ? color.primary.withValues(alpha: .05)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: Text(adjustment.ordId.toString()),
                              ),
                              SizedBox(
                                width: 100,
                                child: Text(
                                  adjustment.ordEntryDate != null
                                      ? adjustment.ordEntryDate!.toFormattedDate()
                                      : "",
                                ),
                              ),
                              SizedBox(
                                width: 215,
                                child: Text(
                                  adjustment.ordxRef ?? "-",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  adjustment.account?.toString() ?? "-",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  adjustment.amount != null
                                      ? "${adjustment.amount?.toAmount()} $baseCurrency"
                                      : "-",
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: TransactionStatusBadge(
                                  status: adjustment.trnStateText ?? "",
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                // Initial state
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
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