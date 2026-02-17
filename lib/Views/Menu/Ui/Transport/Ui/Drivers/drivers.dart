import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/bloc/employee_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../Features/Other/image_helper.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../Features/Widgets/zcard_mobile.dart';
import '../../../HR/Ui/Employees/Ui/add_edit_employee.dart';
import '../../../HR/Ui/Employees/features/emp_card.dart';

class DriversView extends StatelessWidget {
  const DriversView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
        mobile: _Mobile(), tablet: _Desktop(), desktop: _Desktop());
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    return const _MobileDriversView();
  }
}

class _MobileDriversView extends StatefulWidget {
  const _MobileDriversView();

  @override
  State<_MobileDriversView> createState() => _MobileDriversViewState();
}

class _MobileDriversViewState extends State<_MobileDriversView> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeBloc>().add(LoadEmployeeEvent(cat: "driver"));
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: color.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: color.outline.withValues(alpha: 0.1),
                ),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search drivers',
                  prefixIcon: Icon(Icons.search, color: color.primary),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: color.outline),
                    onPressed: () {
                      searchController.clear();
                      setState(() {});
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),

          // Drivers List
          Expanded(
            child: BlocBuilder<EmployeeBloc, EmployeeState>(
              builder: (context, state) {
                if (state is EmployeeLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is EmployeeErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: color.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (state is EmployeeLoadedState) {
                  final query = searchController.text.toLowerCase().trim();
                  final filteredList = state.employees.where((item) {
                    final fullName = '${item.perName ?? ""} ${item.perLastName ?? ""}'.toLowerCase();
                    final position = item.empPosition?.toLowerCase() ?? '';
                    return fullName.contains(query) || position.contains(query);
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            size: 64,
                            color: color.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Drivers Found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            searchController.text.isEmpty
                                ? 'No drivers registered yet'
                                : 'No results for "${searchController.text}"',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final driver = filteredList[index];
                      final fullName = '${driver.perName ?? ""} ${driver.perLastName ?? ""}'.trim();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: MobileInfoCard(
                          imageUrl: driver.empImage,
                          title: fullName.isNotEmpty ? fullName : 'Unnamed Driver',
                          subtitle: driver.empPosition ?? 'No Position',
                          status: MobileStatus(
                            label: driver.empStatus == 1 ? 'Active' : 'Inactive',
                            color: driver.empStatus == 1 ? Colors.green : Colors.red,
                            backgroundColor: driver.empStatus == 1
                                ? Colors.green.withValues(alpha: 0.12)
                                : Colors.red.withValues(alpha: 0.12),
                          ),
                          infoItems: [
                            if (driver.empDepartment != null)
                              MobileInfoItem(
                                icon: Icons.business_center,
                                text: driver.empDepartment!,
                                iconColor: color.primary,
                              ),
                            if (driver.empSalary != null)
                              MobileInfoItem(
                                icon: Icons.payments,
                                text: driver.empSalary!.toAmount(),
                                iconColor: Colors.green,
                              ),
                            if (driver.empHireDate != null)
                              MobileInfoItem(
                                icon: Icons.calendar_today,
                                text: driver.empHireDate!.toFormattedDate(),
                                iconColor: color.secondary,
                              ),
                          ],
                          onTap: () {
                            _showDriverDetails(context, driver);
                          },
                          accentColor: color.primary,
                          showActions: true,
                        ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddEditEmployeeView(
              isDriver: true,
              employeeType: 'driver',
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Driver'),
        backgroundColor: color.primary,
        foregroundColor: color.surface,
      ),
    );
  }

  void _showDriverDetails(BuildContext context, dynamic driver) {
    final color = Theme.of(context).colorScheme;
    final fullName = '${driver.perName ?? ""} ${driver.perLastName ?? ""}'.trim();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: color.surface,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Driver Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Driver Info
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        // Profile Image and Basic Info
                        Center(
                          child: Column(
                            children: [
                              ImageHelper.stakeholderProfile(
                                imageName: driver.empImage,
                                size: 100,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                fullName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (driver.empPosition != null)
                                Text(
                                  driver.empPosition!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: color.secondary,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: driver.empStatus == 1
                                      ? Colors.green.withValues(alpha: 0.12)
                                      : Colors.red.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  driver.empStatus == 1 ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: driver.empStatus == 1
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Details
                        _buildDetailItem(
                          context,
                          icon: Icons.badge,
                          label: 'Employee ID',
                          value: driver.empCode ?? '-',
                        ),
                        _buildDetailItem(
                          context,
                          icon: Icons.person,
                          label: 'First Name',
                          value: driver.perName ?? '-',
                        ),
                        _buildDetailItem(
                          context,
                          icon: Icons.person_outline,
                          label: 'Last Name',
                          value: driver.perLastName ?? '-',
                        ),
                        _buildDetailItem(
                          context,
                          icon: Icons.phone,
                          label: 'Phone',
                          value: driver.perPhone ?? '-',
                        ),
                        _buildDetailItem(
                          context,
                          icon: Icons.email,
                          label: 'Email',
                          value: driver.perEmail ?? '-',
                        ),
                        _buildDetailItem(
                          context,
                          icon: Icons.business_center,
                          label: 'Department',
                          value: driver.empDepartment ?? '-',
                        ),
                        _buildDetailItem(
                          context,
                          icon: Icons.work,
                          label: 'Position',
                          value: driver.empPosition ?? '-',
                        ),
                        _buildDetailItem(
                          context,
                          icon: Icons.payments,
                          label: 'Salary',
                          value: driver.empSalary?.toAmount() ?? '-',
                        ),
                        _buildDetailItem(
                          context,
                          icon: Icons.calendar_today,
                          label: 'Hire Date',
                          value: driver.empHireDate?.toFormattedDate() ?? '-',
                        ),
                        if (driver.empLicenseNumber != null)
                          _buildDetailItem(
                            context,
                            icon: Icons.drive_eta,
                            label: 'License Number',
                            value: driver.empLicenseNumber!,
                          ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (_) => AddEditEmployeeView(
                                  model: driver,
                                  isDriver: true,
                                  employeeType: 'driver',
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Add view trips functionality here
                            },
                            icon: const Icon(Icons.route),
                            label: const Text('View Trips'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    final color = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.secondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      context.read<EmployeeBloc>().add(LoadEmployeeEvent(cat: "driver"));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
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
    );
  }

  void onAdd() {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditEmployeeView(
          isDriver: true,
          employeeType: 'driver',
        );
      },
    );
  }

  void onRefresh() {
    context.read<EmployeeBloc>().add(LoadEmployeeEvent(cat: "driver"));
  }
}

