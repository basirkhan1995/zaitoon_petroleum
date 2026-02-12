import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Estimate/bloc/estimate_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/search_field.dart';
import '../../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../View/EstimateById/estimate_details.dart';

class EstimateView extends StatelessWidget {
  const EstimateView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(),
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
  String? baseCurrency;
  EstimatesLoaded? _cachedEstimates;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EstimateBloc>().add(LoadEstimatesEvent());
    });

    final companyState = context.read<CompanyProfileBloc>().state;
    if (companyState is CompanyProfileLoadedState) {
      baseCurrency = companyState.company.comLocalCcy ?? "";
    }
  }

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    TextStyle? titleStyle = textTheme.titleSmall?.copyWith(color: color.surface);
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  flex: 5,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    tileColor: Colors.transparent,
                    title: Text(
                      tr.estimateTitle,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontSize: 20),
                    ),
                    subtitle: Text(
                      tr.ordersSubtitle,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ZSearchField(
                    icon: FontAwesomeIcons.magnifyingGlass,
                    controller: searchController,
                    hint: AppLocalizations.of(context)!.search,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 5),
            decoration: BoxDecoration(
                color: color.primary.withValues(alpha: .9)
            ),
            child: Row(
              children: [
                SizedBox(width: 30, child: Text("#", style: titleStyle)),
                SizedBox(
                  width: 215,
                  child: Text(tr.referenceNumber, style: titleStyle),
                ),
                Expanded(child: Text(tr.party, style: titleStyle)),
                SizedBox(
                  width: 150,
                  child: Text(tr.totalInvoice, style: titleStyle),
                ),
              ],
            ),
          ),

          Expanded(
            child: BlocConsumer<EstimateBloc, EstimateState>(
              listener: (context, state) {
                if (state is EstimateDeleted || state is EstimateConverted) {
                  // Store the updated estimates
                  if (state is EstimatesLoaded) {
                    _cachedEstimates = state;
                  }
                }
                if (state is EstimateError) {
                  Utils.showOverlayMessage(context, message: state.message, isError: true);
                }
                if (state is EstimateSaved) {
                  context.read<EstimateBloc>().add(LoadEstimatesEvent());
                }
              },
              builder: (context, state) {
                // Cache the estimates when loaded
                if (state is EstimatesLoaded) {
                  _cachedEstimates = state;
                }

                // Determine which state to display
                final shouldUseCached = state is EstimateDetailLoading ||
                    state is EstimateDetailLoaded ||
                    state is EstimateSaving ||
                    state is EstimateDeleting ||
                    state is EstimateConverting;

                final displayState = shouldUseCached ? _cachedEstimates : state;

                // Handle null case for cached estimates
                if (shouldUseCached && _cachedEstimates == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (displayState is EstimateError) {
                  return NoDataWidget(
                    imageName: 'error.png',
                    message: displayState.message, onRefresh: (){
                    context.read<EstimateBloc>().add(LoadEstimatesEvent());
                  },);
                }

                if (displayState is EstimateLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (displayState is EstimatesLoaded) {
                  final query = searchController.text.toLowerCase().trim();
                  final filteredList = displayState.estimates.where((item) {
                    final ref = item.ordxRef?.toLowerCase() ?? '';
                    final ordId = item.ordId?.toString() ?? '';
                    final customerName = item.ordPersonalName?.toLowerCase() ?? '';
                    final reference = item.ordTrnRef?.toLowerCase() ?? '';
                    return ref.contains(query) ||
                        ordId.contains(query) ||
                        customerName.contains(query) ||
                        reference.contains(query);
                  }).toList();

                  if (filteredList.isEmpty) {
                    return NoDataWidget(message: tr.noDataFound,onRefresh: (){
                      context.read<EstimateBloc>().add(LoadEstimatesEvent());
                    },);
                  }

                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final estimate = filteredList[index];

                      return InkWell(
                        onTap: () {
                          Utils.goto(
                            context,
                            EstimateDetailView(estimateId: estimate.ordId!),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: index.isEven
                                ? color.primary.withValues(alpha: .05)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 30,
                                child: Text(estimate.ordId.toString()),
                              ),
                              SizedBox(
                                width: 215,
                                child: Text(
                                  estimate.ordxRef ?? "",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  estimate.ordPersonalName ?? "",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  "${estimate.total?.toAmount()} $baseCurrency",
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                // If we reach here, show loading indicator
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  void onRefresh() {
    context.read<EstimateBloc>().add(LoadEstimatesEvent());
  }
}