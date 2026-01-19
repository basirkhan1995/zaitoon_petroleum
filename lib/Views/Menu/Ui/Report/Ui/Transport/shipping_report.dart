import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Transport/bloc/shipping_report_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/features/individuals_dropdown.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/features/vehicle_drop.dart';
import '../../../../../../../../../Features/PrintSettings/report_model.dart';
import '../../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../../Localizations/Bloc/localizations_bloc.dart';
import '../../../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../Features/Date/z_generic_date.dart';
import '../../../../../../Features/Other/utils.dart';
import '../../../../../../Features/PrintSettings/print_preview.dart';
import '../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../../../Transport/Ui/Shipping/Ui/ShippingView/View/add_edit_shipping.dart';
import '../../../Transport/Ui/Shipping/Ui/ShippingView/View/all_shipping.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'PDF/shp_report_print.dart';
import 'features/status_drop.dart';
import 'model/shp_report_model.dart';

class ShippingReportView extends StatelessWidget {
  const ShippingReportView({super.key});

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
  String fromDate = DateTime.now().subtract(Duration(days: 7)).toFormattedDate();
  String toDate = DateTime.now().toFormattedDate();
  Jalali shamsiFromDate = DateTime.now().subtract(Duration(days: 7)).toAfghanShamsi;
  Jalali shamsiToDate = DateTime.now().toAfghanShamsi;
  final TextEditingController searchController = TextEditingController();
  int? perId;
  int? vehicleId;
  int? status;
  String _baseCurrency = "";
  String? myLocale;

  Uint8List _companyLogo = Uint8List(0);
  final company = ReportModel();
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShippingReportBloc>().add(ResetShippingReportEvent());
      myLocale = context.read<LocalizationBloc>().state.languageCode;
      final comState = context.read<CompanyProfileBloc>().state;
      if (comState is CompanyProfileLoadedState) {
        _baseCurrency = comState.company.comLocalCcy ?? "";
        company.comName = comState.company.comName ?? "";
        company.statementDate = DateTime.now().toDateTime;
        company.comEmail = comState.company.comEmail ?? "";
        company.comAddress = comState.company.addName ?? "";
        company.compPhone = comState.company.comPhone ?? "";
        company.comLogo = _companyLogo;
        _baseCurrency = comState.company.comLocalCcy ?? "";
        final base64Logo = comState.company.comLogo;
        if (base64Logo != null && base64Logo.isNotEmpty) {
          try {
            _companyLogo = base64Decode(base64Logo);
            company.comLogo = _companyLogo;
          } catch (e) {
            _companyLogo = Uint8List(0);
          }
        }
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(   tr.allShipping,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),),
          titleSpacing: 0,
      ),
      body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 8,
                  children: [
                    SizedBox(
                      width: 150,
                      child: ZDatePicker(
                        label: tr.fromDate,
                        value: fromDate,
                        onDateChanged: (v) {
                          setState(() {
                            fromDate = v;
                            shamsiFromDate = v.toAfghanShamsi;
                          });
                        },
                      ),
                    ),

                    SizedBox(
                      width: 150,
                      child: ZDatePicker(
                        label: tr.toDate,
                        value: toDate,
                        onDateChanged: (v) {
                          setState(() {
                            toDate = v;
                            shamsiToDate = v.toAfghanShamsi;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: VehicleDropdown(
                        onSingleChanged: (vehicle) {
                          setState(() {
                            vehicleId = vehicle?.vclId;
                          });
                        },
                      ),

                    ),

                    Expanded(
                      flex: 2,
                      child: StakeholdersDropdown(
                          title: tr.customer,

                          height: 40,
                          isMulti: false,
                          onMultiChanged: (e){},
                          onSingleChanged: (e){
                            setState(() {
                              perId = e!.perId;
                            });
                          },
                      ),
                    ),
                    Expanded(
                      child: StatusDropdown(
                        value: status,
                        onChanged: (v) {
                          setState(() => status = v); // v is 1 or 0
                        },
                      ),
                    ),
                    if(perId !=null || vehicleId !=null)
                    ZOutlineButton(
                      toolTip: "F5",
                      width: 100,
                      icon: Icons.filter_alt_off_outlined,
                      onPressed: (){
                       setState(() {
                         perId = null;
                         vehicleId = null;
                       });
                      },
                      label: Text(tr.clear),
                    ),
                    ZOutlineButton(
                      toolTip: "F6",
                      width: 120,
                      icon: FontAwesomeIcons.solidFilePdf,
                      onPressed: onPdf,
                      label: Text("PDF"),
                    ),
                    ZOutlineButton(
                      toolTip: "F5",
                      width: 120,
                      isActive: true,
                      icon: Icons.filter_alt,
                      onPressed: onRefresh,
                      label: Text(tr.apply),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              _buildColumnHeaders(),
              const SizedBox(height: 5),
              const Divider(endIndent: 15, indent: 15),
              const SizedBox(height: 0),

              Expanded(
                child: BlocBuilder<ShippingReportBloc, ShippingReportState>(
                  builder: (context, state) {
                    if(state is ShippingReportLoadingState){
                      return Center(child: CircularProgressIndicator());
                    }
                    if(state is ShippingReportErrorState){
                      return NoDataWidget(
                        message: state.message,
                      );
                    }
                    if( state is ShippingReportInitial){
                      return NoDataWidget(
                        imageName: "shipment.png",
                        title: "Shipments Overview",
                        message: "Select filters and generate the report.",
                        enableAction: false,
                      );
                    }
                    if(state is ShippingReportLoadedState){
                      if(state.shp.isEmpty){
                        return NoDataWidget(
                          title: tr.noData,
                        );
                      }
                      return _buildReportListView(context, state.shp);
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildColumnHeaders() {
    final tr = AppLocalizations.of(context)!;
    final titleStyle = Theme.of(context).textTheme.titleSmall;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(tr.id, style: titleStyle)),
          SizedBox(width: 100, child: Text(tr.date, style: titleStyle)),
          Expanded(child: Text(tr.customer, style: titleStyle)),
          SizedBox(width: 200, child: Text(tr.products, style: titleStyle)),
          SizedBox(width: 200, child: Text(tr.vehicle, style: titleStyle)),
          SizedBox(width: 110, child: Text(tr.shippingRent, style: titleStyle)),
          SizedBox(width: 110, child: Text(tr.loadingSize, style: titleStyle)),
          SizedBox(width: 110, child: Text(tr.unloadingSize, style: titleStyle),),
          SizedBox(width: 120, child: Text(tr.totalTitle, style: titleStyle)),
          SizedBox(width: 100, child: Text(tr.status, style: titleStyle)),
        ],
      ),
    );
  }

  Widget _buildReportListView(BuildContext context, List<ShippingReportModel> list) {
    final tr = AppLocalizations.of(context)!;

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final shp = list[index];

        return InkWell(
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_) => ShippingByIdView(
                shippingId: shp.shpId,
                perId: perId,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: index.isEven
                  ? Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: .05)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                /// NO / ID
                SizedBox(
                  width: 40,
                  child: Text(shp.shpId.toString()),
                ),

                /// DATE
                SizedBox(
                  width: 100,
                  child: Text(
                    shp.shpMovingDate?.toFormattedDate() ?? "",
                  ),
                ),

                /// CUSTOMER
                Expanded(
                  child: Text(shp.customerName ?? ""),
                ),

                /// PRODUCT
                SizedBox(
                  width: 200,
                  child: Text(shp.proName ?? ""),
                ),

                /// VEHICLE
                SizedBox(
                  width: 200,
                  child: Text(shp.vehicle ?? ""),
                ),

                /// SHIPPING RENT
                SizedBox(
                  width: 110,
                  child: Text(
                    "${shp.shpRent?.toAmount()} $_baseCurrency",
                  ),
                ),

                /// LOADING SIZE
                SizedBox(
                  width: 110,
                  child: Text(
                    "${shp.shpLoadSize?.toDoubleAmount()} ${shp.shpUnit}",
                  ),
                ),

                /// UNLOADING SIZE
                SizedBox(
                  width: 110,
                  child: Text(
                    "${shp.shpUnloadSize?.toDoubleAmount()} ${shp.shpUnit}",
                  ),
                ),

                /// TOTAL
                SizedBox(
                  width: 120,
                  child: Text(
                    "${shp.total?.toAmount()} $_baseCurrency",
                  ),
                ),

                /// STATUS
                SizedBox(
                  width: 100,
                  child: ShippingStatusBadge(
                    status: shp.shpStatus ?? 0,
                    tr: tr,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void onRefresh() {
    context.read<ShippingReportBloc>().add(LoadShippingReportEvent(
      status: status,
      customerId: perId,
      fromDate: fromDate,
      toDate: toDate,
      vehicleId: vehicleId
    ));
  }

  // Add this PDF function
  void onPdf() {
    final tr = AppLocalizations.of(context)!;
    final state = context.read<ShippingReportBloc>().state;

    List<ShippingReportModel> shippingList = [];
    String? filterCustomer;
    String? filterVehicle;
    String? filterStatus;

    // Extract shipping list from state
    if (state is ShippingReportLoadedState) {
      shippingList = state.shp;
    } else if (state is ShippingReportLoadingState) {
      // Handle loading state if needed
    }

    if (shippingList.isEmpty) {
      Utils.showOverlayMessage(
        context,
        message: tr.noData,
        isError: true,
      );
      return;
    }

    // Prepare filter texts for display
    if (perId != null) {
      // You need to get the customer name from your dropdown selection
      // For now, using a placeholder - you should implement this based on your UI
      filterCustomer = "Customer ID: $perId";
    }

    if (vehicleId != null) {
      // Get vehicle name from your dropdown selection
      filterVehicle = "Vehicle ID: $vehicleId";
    }

    if (status != null) {
      filterStatus = status == 1 ? tr.delivered : tr.pendingTitle;
    }

    // Get customer and vehicle names from dropdowns if available
    // You might need to store these names in state when selecting dropdowns

    showDialog(
      context: context,
      builder: (_) => PrintPreviewDialog<List<ShippingReportModel>>(
        data: shippingList,
        company: company,
        buildPreview: ({
          required data,
          required language,
          required orientation,
          required pageFormat,
        }) {
          return ShippingReportPdfServices().printPreview(
            company: company,
            language: language,
            pageFormat: pageFormat,
            shippingList: data,
            filterFromDate: fromDate,
            filterToDate: toDate,
            filterCustomer: filterCustomer,
            filterVehicle: filterVehicle,
            filterStatus: filterStatus?.toString(),
          );
        },
        onPrint: ({
          required data,
          required language,
          required orientation,
          required pageFormat,
          required selectedPrinter,
          required copies,
          required pages,
        }) {
          return ShippingReportPdfServices().printDocument(
            company: company,
            language: language,
            pageFormat: pageFormat,
            selectedPrinter: selectedPrinter,
            shippingList: data,
            copies: copies,
            pages: pages,
            filterFromDate: fromDate,
            filterToDate: toDate,
            filterCustomer: filterCustomer,
            filterVehicle: filterVehicle,
            filterStatus: filterStatus?.toString(),
          );
        },
        onSave: ({
          required data,
          required language,
          required orientation,
          required pageFormat,
        }) {
          return ShippingReportPdfServices().createDocument(
            company: company,
            language: language,
            pageFormat: pageFormat,
            shippingList: data,
            filterFromDate: fromDate,
            filterToDate: toDate,
            filterCustomer: filterCustomer,
            filterVehicle: filterVehicle,
            filterStatus: filterStatus?.toString(),
          );
        },
      ),
    );
  }
}
