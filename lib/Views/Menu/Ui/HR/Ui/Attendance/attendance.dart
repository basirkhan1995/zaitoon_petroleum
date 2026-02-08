import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Attendance/bloc/attendance_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Attendance/model/attendance_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/bloc/employee_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/model/emp_model.dart';
import '../../../../../../Features/Date/shamsi_converter.dart';
import '../../../../../../Features/Date/z_generic_date.dart';
import '../../../../../../Features/Generic/rounded_searchable_textfield.dart';

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

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
    return _AttendanceContent();
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return _AttendanceContent();
  }
}

class _Desktop extends StatelessWidget {
  const _Desktop();

  @override
  Widget build(BuildContext context) {
    return const _AttendanceContent();
  }
}

class _AttendanceContent extends StatefulWidget {
  const _AttendanceContent();

  @override
  State<_AttendanceContent> createState() => __AttendanceContentState();
}

class __AttendanceContentState extends State<_AttendanceContent> {
  final TextEditingController _dateController = TextEditingController();
  List<AttendanceRecord> _tempRecords = [];
  bool _isEditing = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedDate = DateTime.now().toFormattedDate();

  // Store controllers for each row
  final Map<int, TextEditingController> _employeeControllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAttendance();
      // Load employees for dropdown
      context.read<EmployeeBloc>().add(LoadEmployeeEvent());
    });
  }

  void _loadAttendance() {
    context.read<AttendanceBloc>().add(
      LoadAllAttendanceEvent(date: _selectedDate),
    );
  }

  Future<void> _selectTime(BuildContext context,
      {required Function(String) onTimeSelected,
        String? initialTime}) async {

    TimeOfDay initialTimeOfDay;
    if (initialTime != null && initialTime.isNotEmpty) {
      try {
        final parts = initialTime.split(':');
        initialTimeOfDay = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (e) {
        initialTimeOfDay = TimeOfDay.now();
      }
    } else {
      initialTimeOfDay = TimeOfDay.now();
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTimeOfDay,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      onTimeSelected(formattedTime);
    }
  }

  void _startEditing(List<AttendanceRecord> records) {
    // Clear existing controllers
    _employeeControllers.clear();

    // Create controllers for each record
    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      _employeeControllers[i] = TextEditingController(
        text: record.usrName ?? '',
      );
    }

    setState(() {
      _isEditing = true;
      _tempRecords = List.from(records);
    });
  }

  void _cancelEditing() {
    _employeeControllers.clear();
    setState(() {
      _isEditing = false;
      _tempRecords.clear();
    });
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      final model = AttendanceModel(
        usrName: "radveen", // This should come from user session
        records: _tempRecords,
      );

      if (_tempRecords.any((record) => record.emaId == null)) {
        // Add new attendance
        context.read<AttendanceBloc>().add(AddAttendanceEvent(model));
      } else {
        // Update existing attendance
        context.read<AttendanceBloc>().add(UpdateAttendanceEvent(model));
      }

      _employeeControllers.clear();
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _updateRecord(int index, String field, String value) {
    setState(() {
      final record = _tempRecords[index];
      _tempRecords[index] = record.copyWith(
        emaCheckedIn: field == 'checkIn' ? value : record.emaCheckedIn,
        emaCheckedOut: field == 'checkOut' ? value : record.emaCheckedOut,
        emaStatus: field == 'status' ? value : record.emaStatus,
      );
    });
  }

  void _updateEmployee(int index, EmployeeModel employee) {
    setState(() {
      final record = _tempRecords[index];
      _tempRecords[index] = record.copyWith(
        emaEmployee: employee.empId, // Save employee ID
        usrName: "${employee.perName} ${employee.perLastName}", // Save employee name
      );
      // Update the controller text
      _employeeControllers[index]?.text = "${employee.perName} ${employee.perLastName}";
    });
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          Expanded(
            child: ZDatePicker(
              label: "Date",
              value: _selectedDate,
              onDateChanged: (v) {
                setState(() {
                  _selectedDate = v;
                });
                _loadAttendance();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerField({
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value.isNotEmpty ? value : label,
              style: TextStyle(
                color: value.isNotEmpty ? Colors.black : Colors.grey,
                fontSize: 14,
              ),
            ),
            const Icon(Icons.access_time, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCell(int index, AttendanceRecord record) {
    final tr = AppLocalizations.of(context)!;

    // Get or create controller for this row
    if (!_employeeControllers.containsKey(index)) {
      _employeeControllers[index] = TextEditingController(
        text: record.usrName ?? '',
      );
    }

    return _isEditing
        ? SizedBox(
      width: 200,
      child: GenericTextfield<EmployeeModel, EmployeeBloc, EmployeeState>(
        controller: _employeeControllers[index]!,
        title: "",
        hintText: tr.employees,
        isRequired: true,
        bloc: context.read<EmployeeBloc>(),
        fetchAllFunction: (bloc) => bloc.add(LoadEmployeeEvent()),
        searchFunction: (bloc, query) => bloc.add(LoadEmployeeEvent()),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return tr.required(tr.employees);
          }
          return null;
        },
        itemBuilder: (context, emp) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${emp.perName} ${emp.perLastName}",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (emp.empId != null)
                Text(
                  "ID: ${emp.empId}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
        itemToString: (emp) => "${emp.perName} ${emp.perLastName}",
        stateToLoading: (state) => state is EmployeeLoadingState,
        loadingBuilder: (context) => const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        stateToItems: (state) {
          if (state is EmployeeLoadedState) {
            return state.employees;
          }
          return [];
        },
        onSelected: (employee) {
          _updateEmployee(index, employee);
        },
        noResultsText: tr.noDataFound,
        showClearButton: true,
      ),
    )
        : Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        record.usrName ?? 'Unknown Employee',
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildAttendanceTable(List<AttendanceRecord> records) {
    final data = _isEditing ? _tempRecords : records;
    final theme = Theme.of(context);
   // final tr = AppLocalizations.of(context)!;

    return Expanded(
      child: Form(
        key: _formKey,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attendance Records',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!_isEditing && records.isNotEmpty)
                      ZOutlineButton(
                        onPressed: () => _startEditing(records),
                        icon: Icons.edit,
                        label: const Text('Edit'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 24,
                        horizontalMargin: 16,
                        headingRowHeight: 50,
                        dataRowHeight: 70, // Increased for dropdown
                        columns: [
                          DataColumn(
                            label: Text(
                              'Employee',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Check In',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Check Out',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Status',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (_isEditing)
                            const DataColumn(
                              label: Text(
                                'Action',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                        rows: data.asMap().entries.map((entry) {
                          final index = entry.key;
                          final record = entry.value;

                          return DataRow(
                            cells: [
                              DataCell(_buildEmployeeCell(index, record)),
                              DataCell(
                                _isEditing
                                    ? SizedBox(
                                  width: 130,
                                  child: _buildTimePickerField(
                                    value: record.emaCheckedIn ?? '',
                                    label: 'Select Time',
                                    onTap: () => _selectTime(
                                      context,
                                      initialTime: record.emaCheckedIn,
                                      onTimeSelected: (time) =>
                                          _updateRecord(index, 'checkIn', time),
                                    ),
                                  ),
                                )
                                    : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    record.emaCheckedIn ?? '--:--:--',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                              DataCell(
                                _isEditing
                                    ? SizedBox(
                                  width: 130,
                                  child: _buildTimePickerField(
                                    value: record.emaCheckedOut ?? '',
                                    label: 'Select Time',
                                    onTap: () => _selectTime(
                                      context,
                                      initialTime: record.emaCheckedOut,
                                      onTimeSelected: (time) =>
                                          _updateRecord(index, 'checkOut', time),
                                    ),
                                  ),
                                )
                                    : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    record.emaCheckedOut ?? '--:--:--',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                              DataCell(
                                _isEditing
                                    ? SizedBox(
                                  width: 120,
                                  child: DropdownButtonFormField<String>(
                                    initialValue: record.emaStatus ?? 'Present',
                                    items: ['Present', 'Absent', 'Late', 'Leave']
                                        .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ))
                                        .toList(),
                                    onChanged: (value) =>
                                        _updateRecord(index, 'status', value!),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                    ),
                                  ),
                                )
                                    : Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(record.emaStatus),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    record.emaStatus ?? 'Unknown',
                                    style: TextStyle(
                                      color: _getStatusTextColor(record.emaStatus),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              if (_isEditing)
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20),
                                    color: Colors.red.shade600,
                                    onPressed: () {
                                      // Remove the controller
                                      _employeeControllers.remove(index);

                                      // Shift all controllers after this index
                                      final newControllers = <int, TextEditingController>{};
                                      _employeeControllers.forEach((key, controller) {
                                        if (key > index) {
                                          newControllers[key - 1] = controller;
                                        } else if (key < index) {
                                          newControllers[key] = controller;
                                        }
                                      });

                                      setState(() {
                                        _employeeControllers
                                          ..clear()
                                          ..addAll(newControllers);
                                        _tempRecords.removeAt(index);
                                      });
                                    },
                                    tooltip: 'Delete record',
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_tempRecords.length} records',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: _cancelEditing,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                side: BorderSide(color: Colors.grey.shade400),
                              ),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _saveChanges,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: const Text('Save Changes'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 24),
                Text(
                  'No Attendance Records',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No attendance found for $_selectedDate',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                      _tempRecords = [];
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Attendance for Today'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading attendance...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Unable to load attendance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAttendance,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'present':
        return Colors.green.shade50;
      case 'absent':
        return Colors.red.shade50;
      case 'late':
        return Colors.orange.shade50;
      case 'leave':
        return Colors.blue.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'present':
        return Colors.green.shade800;
      case 'absent':
        return Colors.red.shade800;
      case 'late':
        return Colors.orange.shade800;
      case 'leave':
        return Colors.blue.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Attendance'),
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AttendanceLoadedState) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
          }
        },
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateSelector(),
                const SizedBox(height: 8),
                Text(
                  'Showing attendance for $_selectedDate',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                if (state is AttendanceLoadingState) _buildLoadingState(),
                if (state is AttendanceSilentLoadingState &&
                    state is! AttendanceLoadedState) _buildLoadingState(),
                if (state is AttendanceLoadedState)
                  state.attendance.isEmpty
                      ? _buildEmptyState()
                      : _buildAttendanceTable(state.attendance),
                if (state is AttendanceErrorState &&
                    state is! AttendanceSilentLoadingState)
                  _buildErrorState(state.message),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    // Dispose all employee controllers
    _employeeControllers.values.forEach((controller) => controller.dispose());
    _employeeControllers.clear();
    super.dispose();
  }
}