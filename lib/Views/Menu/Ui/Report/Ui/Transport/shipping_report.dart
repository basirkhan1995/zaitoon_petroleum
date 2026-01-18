import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Transport/bloc/shipping_report_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/features/individuals_dropdown.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/features/vehicle_types_drop.dart';
import '../../../../../../../../../Features/PrintSettings/report_model.dart';
import '../../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../../Localizations/Bloc/localizations_bloc.dart';
import '../../../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../../../Transport/Ui/Shipping/Ui/ShippingView/bloc/shipping_bloc.dart';

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
  final TextEditingController searchController = TextEditingController();
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
      context.read<ShippingBloc>().add(LoadShippingEvent());
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

    return MultiBlocListener(
      listeners: [
        BlocListener<ShippingBloc, ShippingState>(
          listener: (context, state) {},
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 8,
                children: [
                  BackButton(),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr.allShipping,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${tr.shipping} ${tr.report}",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: StakeholdersDropdown(
                        isMulti: false,
                        onMultiChanged: (e){},
                        onSingleChanged: (e){},
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: VehicleDropdown(
                        onVehicleSelected: (e){}),
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
                    icon: Icons.refresh,
                    onPressed: onRefresh,
                    label: Text(tr.refresh),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            _buildColumnHeaders(),
            const SizedBox(height: 5),
            const Divider(endIndent: 15, indent: 15),
            const SizedBox(height: 0),

            BlocBuilder<ShippingReportBloc, ShippingReportState>(
              builder: (context, state) {
                if(state is ShippingReportErrorState){
                  return NoDataWidget(
                    message: state.message,
                  );
                }
                if(state is ShippingReportLoadedState){
                  return ListView.builder(
                      itemCount: state.shp.length,
                      itemBuilder: (context,index){
                        final shp = state.shp[index];
                       return Row(
                          children: [
                           Text(shp.shpId.toString())
                          ],
                        );
                  });
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  void onPdf() {}

  Widget _buildColumnHeaders() {
    final tr = AppLocalizations.of(context)!;
    final titleStyle = Theme.of(context).textTheme.titleSmall;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(tr.id, style: titleStyle)),
          SizedBox(width: 100, child: Text(tr.date, style: titleStyle)),
          Expanded(child: Text(tr.vehicles, style: titleStyle)),
          SizedBox(width: 200, child: Text(tr.products, style: titleStyle)),
          SizedBox(width: 130, child: Text(tr.customer, style: titleStyle)),
          SizedBox(width: 110, child: Text(tr.shippingRent, style: titleStyle)),
          SizedBox(width: 110, child: Text(tr.loadingSize, style: titleStyle)),
          SizedBox(
            width: 110,
            child: Text(tr.unloadingSize, style: titleStyle),
          ),
          SizedBox(width: 120, child: Text(tr.totalTitle, style: titleStyle)),
          SizedBox(width: 100, child: Text(tr.status, style: titleStyle)),
        ],
      ),
    );
  }

  void onRefresh() {
    context.read<ShippingReportBloc>().add(LoadShippingReportEvent());
  }
}
