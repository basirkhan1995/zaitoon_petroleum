import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/add_edit_vehicle.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/bloc/vehicle_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../Features/Widgets/search_field.dart';

class VehiclesView extends StatelessWidget {
  const VehiclesView({super.key});

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
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    context.read<VehicleBloc>().add(LoadVehicleEvent());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final tr = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    TextStyle? titleStyle = textTheme.titleSmall;
    return Scaffold(
       backgroundColor: color.surface,
        body: Column(
          children: [
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 8),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: ZSearchField(
                      icon: FontAwesomeIcons.magnifyingGlass,
                      controller: searchController,
                      hint: tr.search,
                      onChanged: (e) {
                        setState(() {

                        });
                      },
                      title: "",
                    ),
                  ),
                  ZOutlineButton(
                      width: 120,
                      icon: Icons.refresh,
                      onPressed: (){
                        context.read<VehicleBloc>().add(LoadVehicleEvent());
                      },
                      label: Text(tr.refresh)),
                  ZOutlineButton(
                      isActive: true,
                      width: 120,
                      icon: Icons.add,
                      onPressed: (){
                       showDialog(context: context, builder: (context){
                         return AddEditVehicleView();
                       });
                      },
                      label: Text(tr.newKeyword)),

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 1),
              child: Row(
                spacing: 5,
                children: [
                  Expanded(
                      child: Text(tr.vehicleModel,style: titleStyle)),
                  SizedBox(
                      width: 100,
                      child: Text(tr.vehiclePlate,style: titleStyle)),
                  SizedBox(
                      width: 100,
                      child: Text(tr.fuelType,style: titleStyle)),
                  SizedBox(
                      width: 100,
                      child: Text(tr.manufacturedYear,style: titleStyle)),
                  SizedBox(
                      width: 120,
                      child: Text(tr.vehicleType,style: titleStyle)),
                  SizedBox(
                      width: 100,
                      child: Text(tr.drivers,style: titleStyle)),
                  SizedBox(
                      width: 80,
                      child: Text(tr.status,style: titleStyle)),
                ],
              ),
            ),
            Divider(endIndent: 15,indent: 15,color: color.primary),
            Expanded(
              child: BlocBuilder<VehicleBloc, VehicleState>(
                builder: (context, state) {
                  if(state is VehicleLoadingState){
                    return Center(child: CircularProgressIndicator());
                  }
                  if(state is VehicleErrorState){
                    return NoDataWidget(
                      message: state.message,
                      onRefresh: (){
                        context.read<VehicleBloc>().add(LoadVehicleEvent());
                      },
                    );
                  }
                  if(state is VehicleLoadedState){
                    final query = searchController.text.toLowerCase().trim();
                    final filteredList = state.vehicles.where((item) {
                      final name = item.vclModel?.toLowerCase() ?? '';
                      return name.contains(query);
                    }).toList();

                    if(filteredList.isEmpty){
                      return NoDataWidget(
                        title: tr.noData,
                        message: tr.noDataFound,
                      );
                    }
                    return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context,index){
                          final vehicle = filteredList[index];
                        return InkWell(
                          onTap: (){
                            showDialog(context: context, builder: (context){
                              return AddEditVehicleView(model: vehicle);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 8),
                            decoration: BoxDecoration(
                              color: index.isEven? color.primary.withValues(alpha: .05) : Colors.transparent
                            ),
                            child: Row(
                              spacing: 5,
                              children: [
                               Expanded(child: Text(vehicle.vclModel??"")),
                                SizedBox(
                                    width: 100,
                                    child: Text(vehicle.vclOwnership??"")),
                                SizedBox(
                                    width: 100,
                                    child: Text(vehicle.vclPlateNo??"")),
                                SizedBox(
                                    width: 100,
                                    child: Text(vehicle.vclFuelType??"")),
                                SizedBox(
                                    width: 100,
                                    child: Text(vehicle.vclYear??"")),
                                SizedBox(
                                    width: 120,
                                    child: Text(vehicle.vclBodyType??"")),
                                SizedBox(
                                    width: 100,
                                    child: Text(vehicle.driver??"")),
                                SizedBox(
                                    width: 80,
                                    child: Text(vehicle.vclStatus == 1? tr.active : tr.inactive)),
                              ],
                            ),
                          ),
                        );
                    });
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        )
    );
  }
}
