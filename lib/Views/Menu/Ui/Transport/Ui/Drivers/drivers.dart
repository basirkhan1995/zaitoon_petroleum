import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/bloc/employee_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Drivers/bloc/driver_bloc.dart';
import '../../../../../../../Features/Other/image_helper.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/search_field.dart';
import '../../../HR/Ui/Employees/features/emp_card.dart';

class DriversView extends StatelessWidget {
  const DriversView({super.key});

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

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<DriverBloc>().add(LoadDriverEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;

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
                    hint: locale.search,
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
                    onPressed: onRefresh,
                    label: Text(locale.refresh)),

              ],
            ),
          ),

          Divider(endIndent: 15,indent: 15,color: color.outline.withValues(alpha: .3)),
          Expanded(
            child: BlocConsumer<DriverBloc, DriverState>(
              listener: (context, state) {
                if(state is EmployeeSuccessState){
                  Navigator.of(context).pop();
                }
              },
              builder: (context, state) {
                if(state is DriverLoadingState){
                  return Center(child: CircularProgressIndicator());
                }
                if(state is DriverErrorState){
                  return NoDataWidget(
                    title: locale.accessDenied,
                    message: state.message,
                  );
                }
                if(state is DriverLoadedState){
                  final query = searchController.text.toLowerCase().trim();
                  final filteredList = state.drivers.where((item) {
                    final name = item.perfullName?.toLowerCase() ?? '';
                    return name.contains(query);
                  }).toList();

                  if(filteredList.isEmpty){
                    return NoDataWidget(
                      title: locale.noData,
                      message: locale.noDataFound,
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(15),
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.25, // Slightly taller for more info
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final driver = filteredList[index];

                      return InfoCard(
                        // Image
                        image: ImageHelper.stakeholderProfile(
                          imageName: driver.perPhoto,
                          size: 46,
                        ),

                        // Title and Subtitle
                        title: driver.perfullName ?? "Unnamed Driver",
                        subtitle: driver.vehicle ?? "No Vehicle",

                        // Status
                        status: InfoStatus(
                          label: driver.empStatus == 1 ? locale.active : locale.inactive,
                          color: driver.empStatus == 1 ? Colors.green : Colors.red,
                        ),

                        // Information items
                        infoItems: [
                          if (driver.perPhone != null && driver.perPhone!.isNotEmpty)
                            InfoItem(
                              icon: Icons.phone,
                              text: driver.perPhone!,
                            ),

                          if (driver.address != null && driver.address!.isNotEmpty)
                            InfoItem(
                              icon: Icons.location_on,
                              text: driver.address??"",
                              iconColor: Colors.blue,
                            ),

                          InfoItem(
                            icon: Icons.directions_car,
                            text: driver.vehicle ?? "No Vehicle",
                            iconColor: Colors.deepPurple,
                          ),
                        ],

                        // On tap action
                        // onTap: () {
                        //   // Open driver details dialog or navigate
                        //   showDialog(
                        //     context: context,
                        //     builder: (_) => AddEditEmployeeView(),
                        //   );
                        // },

                        // Optional customization
                        minHeight: 200,
                        maxHeight: 300,
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
  void onRefresh(){
    context.read<DriverBloc>().add(LoadDriverEvent());
  }
}

