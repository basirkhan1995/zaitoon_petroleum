import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/Ui/add_edit_employee.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/bloc/employee_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/search_field.dart';
import '../features/emp_card.dart';

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
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
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
                    onPressed: onRefresh,
                    label: Text(tr.refresh)),
                ZOutlineButton(
                    width: 120,
                    icon: Icons.add,
                    isActive: true,

                    onPressed: (){
                      showDialog(context: context, builder: (context){
                        return AddEditEmployeeView();
                      });
                    },
                    label: Text(tr.newKeyword)),
              ],
            ),
          ),
          SizedBox(height: 5),
          Divider(endIndent: 15,indent: 15,height: 1, color: color.outline.withValues(alpha: .2)),
          Expanded(
            child: BlocConsumer<EmployeeBloc, EmployeeState>(
              listener: (context, state) {
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
                    title: tr.accessDenied,
                    message: state.message,
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
                    padding: const EdgeInsets.all(15),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.25,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final emp = filteredList[index];
                      return EmployeeCard(
                        emp: emp,
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
    );
  }
  void onRefresh(){
    context.read<EmployeeBloc>().add(LoadEmployeeEvent());
  }
}

