import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/bloc/employee_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Drivers/bloc/driver_bloc.dart';
import '../../../../../../../Features/Other/image_helper.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/search_field.dart';

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
    final textTheme = Theme.of(context).textTheme;
    TextStyle? titleStyle = textTheme.titleSmall?.copyWith(color: color.secondary);

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 1),
            child: Row(
              children: [
                Expanded(
                    child: Text(locale.employeeName,style: titleStyle)),
                SizedBox(
                    width: 170,
                    child: Text(locale.mobile1,style: titleStyle)),
                SizedBox(
                    width: 180,
                    child: Text(locale.address,style: titleStyle)),
                SizedBox(
                    width: 250,
                    child: Text(locale.vehicle,style: titleStyle)),
                SizedBox(
                    width: 100,
                    child: Text(locale.hireDate,style: titleStyle)),
                SizedBox(
                    width: 80,
                    child: Text(locale.status,style: titleStyle)),
              ],
            ),
          ),
          Divider(endIndent: 15,indent: 15,color: color.primary),
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
                  return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context,index){
                        final emp = filteredList[index];
                        final fullName = "${emp.perfullName}";
                        return InkWell(
                          hoverColor: color.primary.withValues(alpha: .05),
                          highlightColor: color.primary.withValues(alpha: .05),
                          onTap: (){},
                          child: Container(
                            decoration: BoxDecoration(
                                color: index.isOdd? color.primary.withValues(alpha: .05) : Colors.transparent
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 5),
                              child: Row(
                                children: [
                                  ImageHelper.stakeholderProfile(
                                    imageName: emp.perPhoto,
                                    size: 50,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                      child: Text(fullName,style: titleStyle?.copyWith(fontWeight: FontWeight.bold))),
                                  SizedBox(
                                      width: 170,
                                      child: Text(emp.perPhone??"")),
                                  SizedBox(
                                      width: 180,
                                      child: Text(emp.address??"")),
                                  SizedBox(
                                      width: 250,
                                      child: Text(emp.vehicle??"")),
                                  SizedBox(
                                      width: 100,
                                      child: Text(emp.empHireDate.toFormattedDate())),
                                  SizedBox(
                                      width: 80,
                                      child: Text(emp.empStatus == 1? locale.active : locale.inactive)),

                                ],
                              ),
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
      ),
    );
  }
  void onRefresh(){
    context.read<DriverBloc>().add(LoadDriverEvent());
  }
}

