import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/shortcut.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/Ui/add_edit_employee.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/bloc/employee_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../Features/Other/image_helper.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/search_field.dart';
import '../features/emp_card.dart';
import 'package:flutter/services.dart';

class EmployeesView extends StatelessWidget {
  const EmployeesView({super.key});

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
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<EmployeeBloc>().add(LoadEmployeeEvent());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final shortcuts = {
      const SingleActivator(LogicalKeyboardKey.f1): onAdd,
      const SingleActivator(LogicalKeyboardKey.f5): onRefresh,
    };
    return Scaffold(
      body: GlobalShortcuts(
        shortcuts: shortcuts,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 8,
                children: [

                  Expanded(
                    flex: 5,
                    child: Text(
                      tr.employees, style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),

                  Expanded(
                    flex: 3,
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
                      toolTip: 'F5',
                      width: 120,
                      icon: Icons.refresh,
                      onPressed: onRefresh,
                      label: Text(tr.refresh)),
                  ZOutlineButton(
                      toolTip: 'F1',
                      width: 120,
                      icon: Icons.add,
                      isActive: true,
                      onPressed: onAdd,
                      label: Text(tr.newKeyword)),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<EmployeeBloc, EmployeeState>(
                listener: (context, state) {
                  if(state is EmployeeErrorState){
                    Utils.showOverlayMessage(context, title: tr.accessDenied, message: state.message, isError: true);
                  }
                  if(state is EmployeeSuccessState){
                    Navigator.of(context).pop();
                  }
                },
                builder: (context, state) {
                  if(state is EmployeeLoadingState){
                    return Center(child: CircularProgressIndicator());
                  }
                  if(state is EmployeeErrorState){
                    return NoDataWidget(
                      imageName: "error.png",
                      title: tr.accessDenied,
                      message: state.message,
                      onRefresh: (){
                        context.read<EmployeeBloc>().add(LoadEmployeeEvent());
                      },
                    );
                  }
                  if(state is EmployeeLoadedState){
                    final query = searchController.text.toLowerCase().trim();
                    final filteredList = state.employees.where((item) {
                      final name = item.perName?.toLowerCase() ?? '';
                      return name.contains(query);
                    }).toList();

                    if(filteredList.isEmpty){
                      return NoDataWidget(
                        title: tr.noData,
                        message: tr.noDataFound,
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final emp = filteredList[index];
                        return ZCard(
                          image: ImageHelper.stakeholderProfile(
                            imageName: emp.empImage,
                            size: 46,
                          ),

                          title: "${emp.perName} ${emp.perLastName}",
                          subtitle: emp.empPosition,
                          status: InfoStatus(
                            label: emp.empStatus == 1 ? tr.active : tr.inactive,
                            color: emp.empStatus == 1 ? Colors.green : Colors.red,
                          ),
                          infoItems: [
                            InfoItem(
                              icon: Icons.apartment,
                              text: emp.empDepartment ?? "-",
                            ),
                            InfoItem(
                              icon: Icons.payments,
                              text: emp.empSalary?.toAmount() ?? "-",
                            ),
                            InfoItem(
                              icon: Icons.date_range,
                              text: emp.empHireDate?.toFormattedDate() ?? "",
                            ),
                          ],
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AddEditEmployeeView(model: emp),
                            );
                          },
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
      ),
    );
  }
  void onAdd(){
    showDialog(context: context, builder: (context){
      return AddEditEmployeeView();
    });
  }
  void onRefresh(){
    context.read<EmployeeBloc>().add(LoadEmployeeEvent());
  }
}

