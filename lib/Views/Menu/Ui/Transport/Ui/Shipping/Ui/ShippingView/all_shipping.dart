import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon_petroleum/Features/Other/shortcut.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Shipping/Ui/ShippingById/shipping_by_id.dart';
import '../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import 'bloc/shipping_bloc.dart';
import 'model/shipping_model.dart';

class ShippingView extends StatelessWidget {
  const ShippingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(),
      tablet: _Tablet(),
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

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  final TextEditingController searchController = TextEditingController();
  String? _baseCurrency;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShippingBloc>().add(LoadShippingEvent());

      final comState = context.read<CompanyProfileBloc>().state;
      if (comState is CompanyProfileLoadedState) {
        _baseCurrency = comState.company.comLocalCcy;
      }
    });
  }

  void _handleShippingTap(ShippingModel shp) {
    if (shp.shpId == null) return;

    // Dispatch event to load shipping details
    context.read<ShippingBloc>().add(LoadShippingDetailEvent(shp.shpId!));
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final shortcuts = {
      const SingleActivator(LogicalKeyboardKey.f1): onAdd,
      const SingleActivator(LogicalKeyboardKey.f5): onRefresh,
    };

    return MultiBlocListener(
      listeners: [
        BlocListener<ShippingBloc, ShippingState>(
          listener: (context, state) {
            // Handle detail loaded - show dialog
            if (state is ShippingDetailLoadedState && state.currentShipping != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => ShippingScreen(
                    shippingId: state.currentShipping!.shpId,
                  ),
                ).then((_) {
                  // Clear the detail loading state when dialog is closed
                  context.read<ShippingBloc>().add(ClearDetailLoadingEvent());
                });
              });
            }

            // Handle success states
            if (state is ShippingSuccessState) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
      child: GlobalShortcuts(
        shortcuts: shortcuts,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 8,
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: ZSearchField(
                        icon: FontAwesomeIcons.magnifyingGlass,
                        controller: searchController,
                        hint: tr.search,
                        onChanged: (e) => setState(() {}),
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
                    ZOutlineButton(
                      toolTip: "F1",
                      width: 120,
                      icon: Icons.add,
                      isActive: true,
                      onPressed: onAdd,
                      label: Text(tr.newKeyword),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              _buildColumnHeaders(context),
              Divider(endIndent: 15, indent: 15),
              Expanded(
                child: BlocBuilder<ShippingBloc, ShippingState>(
                  builder: (context, state) {
                    return _buildShippingList(context, state);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColumnHeaders(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final titleStyle = Theme.of(context).textTheme.titleSmall;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(tr.id)),
          SizedBox(width: 90, child: Text(tr.date, style: titleStyle)),
          Expanded(child: Text(tr.vehicles, style: titleStyle)),
          SizedBox(width: 130, child: Text(tr.products, style: titleStyle)),
          SizedBox(width: 130, child: Text(tr.customer, style: titleStyle)),
          SizedBox(width: 110, child: Text(tr.shippingRent, style: titleStyle)),
          SizedBox(width: 110, child: Text(tr.loadingSize, style: titleStyle)),
          SizedBox(width: 110, child: Text(tr.unloadingSize, style: titleStyle)),
          SizedBox(width: 120, child: Text(tr.totalTitle, style: titleStyle)),
          SizedBox(width: 70, child: Text(tr.status, style: titleStyle)),
        ],
      ),
    );
  }

  Widget _buildShippingList(BuildContext context, ShippingState state) {
    final tr = AppLocalizations.of(context)!;

    // Handle loading state for entire list
    if (state is ShippingListLoadingState && state.shippingList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle error state
    if (state is ShippingErrorState) {
      return NoDataWidget(
        message: state.error,
        onRefresh: onRefresh,
      );
    }

    // Get shipping list from state
    List<ShippingModel> shippingList = [];
    int? loadingShpId;

    if (state is ShippingListLoadingState) {
      shippingList = state.shippingList;
      loadingShpId = state.loadingShpId;
    } else if (state is ShippingDetailLoadingState) {
      shippingList = state.shippingList;
      loadingShpId = state.loadingShpId;
    } else if (state is ShippingDetailLoadedState) {
      shippingList = state.shippingList;
      loadingShpId = state.loadingShpId;
    } else if (state is ShippingListLoadedState) {
      shippingList = state.shippingList;
      loadingShpId = state.loadingShpId;
    } else if (state is ShippingInitial) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ShippingErrorState) {
      shippingList = state.shippingList;
      loadingShpId = state.loadingShpId;
    } else if (state is ShippingSuccessState) {
      shippingList = state.shippingList;
      loadingShpId = state.loadingShpId;
    }

    // Handle empty list
    if (shippingList.isEmpty && !(state is ShippingListLoadingState)) {
      return NoDataWidget(
        message: tr.noDataFound,
        onRefresh: onRefresh,
      );
    }

    // Filter based on search
    final query = searchController.text.toLowerCase().trim();
    final filteredList = shippingList.where((shp) {
      final id = shp.shpId?.toString() ?? '';
      final vehicle = shp.vehicle?.toLowerCase() ?? '';
      final product = shp.proName?.toLowerCase() ?? '';
      final customer = shp.customer?.toLowerCase() ?? '';
      final status = (shp.shpStatus == 1
          ? tr.completedTitle
          : tr.pendingTitle).toLowerCase();

      return id.contains(query) ||
          vehicle.contains(query) ||
          product.contains(query) ||
          customer.contains(query) ||
          status.contains(query);
    }).toList();

    // Show loading if filtering while loading
    if (filteredList.isEmpty && query.isNotEmpty && state is ShippingListLoadingState) {
      return const Center(child: CircularProgressIndicator());
    }

    // Build list view
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final shp = filteredList[index];
        final isLoadingThisItem = loadingShpId == shp.shpId;

        return InkWell(
          onTap: isLoadingThisItem ? null : () => _handleShippingTap(shp),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: index.isEven
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: .05)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                // ID with loading indicator
                SizedBox(
                  width: 40,
                  child: Row(
                    children: [
                      if (isLoadingThisItem)
                        Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.only(right: 4),
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                      Text(shp.shpId.toString()),
                    ],
                  ),
                ),

                // Other columns
                SizedBox(
                  width: 90,
                  child: Text(shp.shpMovingDate.toFormattedDate()),
                ),
                Expanded(child: Text(shp.vehicle ?? "")),
                SizedBox(width: 130, child: Text(shp.proName ?? "")),
                SizedBox(width: 130, child: Text(shp.customer ?? "")),
                SizedBox(
                  width: 110,
                  child: Text("${shp.shpRent?.toAmount()} $_baseCurrency"),
                ),
                SizedBox(
                  width: 110,
                  child: Text("${shp.shpLoadSize?.toAmount()} ${shp.shpUnit}"),
                ),
                SizedBox(
                  width: 110,
                  child: Text("${shp.shpUnloadSize?.toAmount()} ${shp.shpUnit}"),
                ),
                SizedBox(
                  width: 120,
                  child: Text("${shp.total?.toAmount()} $_baseCurrency"),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    shp.shpStatus == 1 ? tr.completedTitle : tr.pendingTitle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void onAdd() {
    context.read<ShippingBloc>().add(ClearShippingDetailEvent());
    showDialog(
      context: context,
      builder: (context) => const ShippingScreen(),
    );
  }

  void onRefresh() {
    context.read<ShippingBloc>().add(LoadShippingEvent());
  }
}