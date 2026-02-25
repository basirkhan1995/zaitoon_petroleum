import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/toast.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/search_field.dart';
import 'package:zaitoon_petroleum/Features/Widgets/status_badge.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/AllProjects/model/pjr_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/project_view.dart';
import 'add_project.dart';
import 'bloc/projects_bloc.dart';

class AllProjectsView extends StatelessWidget {
  const AllProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(),
      tablet: _Tablet(),
    );
  }
}

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'All';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectsBloc>().add(LoadProjectsEvent());
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> onRefresh() async {
    context.read<ProjectsBloc>().add(LoadProjectsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: Column(
        children: [
          // Header with gradient background
          Container(
            padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and add button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr.projects,
                          style: textTheme.headlineSmall?.copyWith(
                            color: color.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage and track all your projects',
                          style: textTheme.bodyMedium?.copyWith(
                            color: color.onSurface.withValues(alpha: .8),
                          ),
                        ),
                      ],
                    ),
                    ZOutlineButton(
                      isActive: true,
                      icon: Icons.add,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddNewProjectView(),
                        );
                      },

                      label: Text(
                        tr.newProject,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search and filter bar
                Row(
                  children: [
                    // Search field
                    Expanded(
                      flex: 3,
                      child: ZSearchField(
                        title: "",
                        hint: "Search",
                        icon: Icons.search,
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'All',
                            isSelected: _filterStatus == 'All',
                            onSelected: () {
                              setState(() {
                                _filterStatus = 'All';
                              });
                            },
                            surfaceColor: color.primary,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: tr.completedTitle,
                            isSelected: _filterStatus == 'Completed',
                            onSelected: () {
                              setState(() {
                                _filterStatus = 'Completed';
                              });
                            },
                            surfaceColor: color.primary,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: tr.pendingTitle,
                            isSelected: _filterStatus == 'Pending',
                            onSelected: () {
                              setState(() {
                                _filterStatus = 'Pending';
                              });
                            },
                            surfaceColor: color.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 8),
            child: BlocBuilder<ProjectsBloc, ProjectsState>(
              builder: (context, state) {
                if (state is ProjectsLoadedState) {
                  final totalProjects = state.pjr.length;
                  final completed = state.pjr.where((p) => p.prjStatus == 1).length;
                  final pending = state.pjr.where((p) => p.prjStatus == 0).length;

                  return Row(
                    children: [
                      _buildStatCard(
                        title: 'Total Projects',
                        value: totalProjects.toString(),
                        icon: Icons.folder_copy,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        title: tr.completedTitle,
                        value: completed.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        title: tr.pendingTitle,
                        value: pending.toString(),
                        icon: Icons.pending,
                        color: Colors.orange,
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ),


          // Projects list
          Expanded(
            child: BlocConsumer<ProjectsBloc, ProjectsState>(
              listener: (context, state) {
                if (state is ProjectSuccessState) {
                  ToastManager.show(
                    context: context,
                    message: tr.successMessage,
                    type: ToastType.success,
                  );
                }
                if (state is ProjectsErrorState) {
                  ToastManager.show(
                    context: context,
                    message: state.message,
                    type: ToastType.error,
                  );
                }
              },
              builder: (context, state) {
                if (state is ProjectsLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is ProjectsErrorState) {
                  return NoDataWidget(
                    title: "Error",
                    message: state.message,
                    onRefresh: onRefresh,
                  );
                }
                if (state is ProjectsLoadedState) {
                  // Filter projects based on search and status
                  var filteredProjects = state.pjr.where((project) {
                    final matchesSearch = _searchQuery.isEmpty ||
                        (project.prjName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                        (project.prjDetails?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

                    final matchesStatus = _filterStatus == 'All' ||
                        (_filterStatus == tr.completedTitle && project.prjStatus == 1) ||
                        (_filterStatus == tr.pendingTitle && project.prjStatus == 0);

                    return matchesSearch && matchesStatus;
                  }).toList();

                  if (filteredProjects.isEmpty) {
                    return NoDataWidget(
                      title: "No Projects Found",
                      message: _searchQuery.isNotEmpty || _filterStatus != 'All'
                          ? "Try adjusting your search or filters"
                          : "Click the button above to create your first project",
                      enableAction: false,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: onRefresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      itemCount: filteredProjects.length,
                      itemBuilder: (context, index) {
                        final pjr = filteredProjects[index];
                        return _buildProjectCard(pjr, index, color, textTheme, tr);
                      },
                    ),
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

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required Color surfaceColor,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: surfaceColor.withValues(alpha: .15),
      selectedColor: surfaceColor,
      checkmarkColor: Theme.of(context).colorScheme.surface,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).colorScheme.surface : surfaceColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : surfaceColor.withValues(alpha: .3),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color.withValues(alpha: .2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildProjectCard(
      ProjectsModel pjr,
      int index,
      ColorScheme color,
      TextTheme textTheme,
      AppLocalizations tr,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: index.isOdd
            ? color.primary.withValues(alpha: .02)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.grey.withValues(alpha: .1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => ProjectView(project: pjr),
            );
          },
          borderRadius: BorderRadius.circular(5),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color.primary.withValues(alpha: .1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${pjr.prjId}',
                        style: TextStyle(
                          color: color.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pjr.prjName ?? '',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (pjr.prjDetails != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            pjr.prjDetails??"",
                            style: textTheme.bodySmall?.copyWith(
                              color: color.outline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: color.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pjr.prjDateLine.toFormattedDate(),
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDeadlineColor(pjr.prjDateLine).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getDeadlineIcon(pjr.prjDateLine),
                          size: 14,
                          color: _getDeadlineColor(pjr.prjDateLine),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pjr.prjDateLine?.daysLeftText ?? '',
                          style: textTheme.bodySmall?.copyWith(
                            color: _getDeadlineColor(pjr.prjDateLine),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: StatusBadge(
                    status: pjr.prjStatus!,
                    trueValue: tr.completedTitle,
                    falseValue: tr.pendingTitle,
                  ),
                ),

                Expanded(
                  flex: 0,
                  child: IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    onPressed: () {
                      _showProjectMenu(context, pjr);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDeadlineColor(DateTime? deadline) {
    if (deadline == null) return Colors.grey;
    final days = deadline.daysLeft ?? 0;
    if (days > 7) return Colors.green;
    if (days > 3) return Colors.orange;
    if (days >= 0) return Colors.deepOrange;
    return Colors.red;
  }

  IconData _getDeadlineIcon(DateTime? deadline) {
    if (deadline == null) return Icons.help_outline;
    final days = deadline.daysLeft ?? 0;
    if (days > 7) return Icons.check_circle_outline;
    if (days > 3) return Icons.access_time;
    if (days >= 0) return Icons.warning_amber;
    return Icons.error_outline;
  }

  void _showProjectMenu(BuildContext context, dynamic project) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => ProjectView(project: project),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, project);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, ProjectsModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.prjName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
             // context.read<ProjectsBloc>().add(DeleteProjectEvent(project.prjId!, "basir.h"));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _Mobile extends StatefulWidget {
  const _Mobile();

  @override
  State<_Mobile> createState() => _MobileState();
}

class _MobileState extends State<_Mobile> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'All';
  bool _showFilters = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectsBloc>().add(LoadProjectsEvent());
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> onRefresh() async {
    context.read<ProjectsBloc>().add(LoadProjectsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        title: Text(
          tr.projects,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddNewProjectView(),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_showFilters ? 120 : 70),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ZSearchField(
                  title: "",
                  hint: "Search projects...",
                  icon: Icons.search,
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              if (_showFilters)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'All',
                          isSelected: _filterStatus == 'All',
                          onSelected: () {
                            setState(() {
                              _filterStatus = 'All';
                            });
                          },
                          surfaceColor: color.primary,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: tr.completedTitle,
                          isSelected: _filterStatus == 'Completed',
                          onSelected: () {
                            setState(() {
                              _filterStatus = 'Completed';
                            });
                          },
                          surfaceColor: color.primary,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: tr.pendingTitle,
                          isSelected: _filterStatus == 'Pending',
                          onSelected: () {
                            setState(() {
                              _filterStatus = 'Pending';
                            });
                          },
                          surfaceColor: color.primary,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Stats cards
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<ProjectsBloc, ProjectsState>(
              builder: (context, state) {
                if (state is ProjectsLoadedState) {
                  final totalProjects = state.pjr.length;
                  final completed = state.pjr.where((p) => p.prjStatus == 1).length;
                  final pending = state.pjr.where((p) => p.prjStatus == 0).length;

                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total',
                          value: totalProjects.toString(),
                          icon: Icons.folder_copy,
                          color: color.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          title: tr.completedTitle,
                          value: completed.toString(),
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          title: tr.pendingTitle,
                          value: pending.toString(),
                          icon: Icons.pending,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ),

          // Projects list
          Expanded(
            child: BlocConsumer<ProjectsBloc, ProjectsState>(
              listener: (context, state) {
                if (state is ProjectSuccessState) {
                  ToastManager.show(
                    context: context,
                    message: tr.successMessage,
                    type: ToastType.success,
                  );
                }
                if (state is ProjectsErrorState) {
                  ToastManager.show(
                    context: context,
                    message: state.message,
                    type: ToastType.error,
                  );
                }
              },
              builder: (context, state) {
                if (state is ProjectsLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is ProjectsErrorState) {
                  return NoDataWidget(
                    title: "Error",
                    message: state.message,
                    onRefresh: onRefresh,
                  );
                }
                if (state is ProjectsLoadedState) {
                  // Filter projects based on search and status
                  var filteredProjects = state.pjr.where((project) {
                    final matchesSearch = _searchQuery.isEmpty ||
                        (project.prjName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                        (project.prjDetails?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

                    final matchesStatus = _filterStatus == 'All' ||
                        (_filterStatus == tr.completedTitle && project.prjStatus == 1) ||
                        (_filterStatus == tr.pendingTitle && project.prjStatus == 0);

                    return matchesSearch && matchesStatus;
                  }).toList();

                  if (filteredProjects.isEmpty) {
                    return NoDataWidget(
                      title: "No Projects Found",
                      message: _searchQuery.isNotEmpty || _filterStatus != 'All'
                          ? "Try adjusting your search or filters"
                          : "Tap the + button to create your first project",
                      enableAction: false,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: onRefresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredProjects.length,
                      itemBuilder: (context, index) {
                        final pjr = filteredProjects[index];
                        return _buildMobileProjectCard(pjr, context, tr);
                      },
                    ),
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

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required Color surfaceColor,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: surfaceColor.withValues(alpha: .15),
      selectedColor: surfaceColor,
      checkmarkColor: Theme.of(context).colorScheme.surface,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).colorScheme.surface : surfaceColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : surfaceColor.withValues(alpha: .3),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileProjectCard(ProjectsModel pjr, BuildContext context, AppLocalizations tr) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => ProjectView(project: pjr),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with ID and name
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color.primary.withValues(alpha: .1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${pjr.prjId}',
                        style: TextStyle(
                          color: color.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pjr.prjName ?? '',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  StatusBadge(
                    status: pjr.prjStatus!,
                    trueValue: tr.completedTitle,
                    falseValue: tr.pendingTitle,
                  ),
                ],
              ),

              // Details if available
              if (pjr.prjDetails != null && pjr.prjDetails!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  pjr.prjDetails!,
                  style: textTheme.bodySmall?.copyWith(
                    color: color.outline,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Deadline and days left
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: color.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pjr.prjDateLine.toFormattedDate(),
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDeadlineColor(pjr.prjDateLine).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getDeadlineIcon(pjr.prjDateLine),
                          size: 14,
                          color: _getDeadlineColor(pjr.prjDateLine),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pjr.prjDateLine?.daysLeftText ?? '',
                          style: textTheme.bodySmall?.copyWith(
                            color: _getDeadlineColor(pjr.prjDateLine),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Action buttons
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.visibility,
                      size: 18,
                      color: color.primary,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ProjectView(project: pjr),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 18,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _showDeleteConfirmation(context, pjr);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDeadlineColor(DateTime? deadline) {
    if (deadline == null) return Colors.grey;
    final days = deadline.daysLeft ?? 0;
    if (days > 7) return Colors.green;
    if (days > 3) return Colors.orange;
    if (days >= 0) return Colors.deepOrange;
    return Colors.red;
  }

  IconData _getDeadlineIcon(DateTime? deadline) {
    if (deadline == null) return Icons.help_outline;
    final days = deadline.daysLeft ?? 0;
    if (days > 7) return Icons.check_circle_outline;
    if (days > 3) return Icons.access_time;
    if (days >= 0) return Icons.warning_amber;
    return Icons.error_outline;
  }

  void _showDeleteConfirmation(BuildContext context, ProjectsModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.prjName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Uncomment when delete event is implemented
              // context.read<ProjectsBloc>().add(DeleteProjectEvent(project.prjId!, "basir.h"));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _Tablet extends StatefulWidget {
  const _Tablet();

  @override
  State<_Tablet> createState() => _TabletState();
}

class _TabletState extends State<_Tablet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'All';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectsBloc>().add(LoadProjectsEvent());
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> onRefresh() async {
    context.read<ProjectsBloc>().add(LoadProjectsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.projects,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage and track all your projects',
                      style: textTheme.bodyMedium?.copyWith(
                        color: color.onSurface.withValues(alpha: .8),
                      ),
                    ),
                  ],
                ),
                ZOutlineButton(
                  isActive: true,
                  icon: Icons.add,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AddNewProjectView(),
                    );
                  },
                  label: Text(tr.newProject),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search and filter
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ZSearchField(
                    title: "",
                    hint: "Search projects...",
                    icon: Icons.search,
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'All',
                          isSelected: _filterStatus == 'All',
                          onSelected: () {
                            setState(() {
                              _filterStatus = 'All';
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: tr.completedTitle,
                          isSelected: _filterStatus == 'Completed',
                          onSelected: () {
                            setState(() {
                              _filterStatus = 'Completed';
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: tr.pendingTitle,
                          isSelected: _filterStatus == 'Pending',
                          onSelected: () {
                            setState(() {
                              _filterStatus = 'Pending';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats cards
            BlocBuilder<ProjectsBloc, ProjectsState>(
              builder: (context, state) {
                if (state is ProjectsLoadedState) {
                  final totalProjects = state.pjr.length;
                  final completed = state.pjr.where((p) => p.prjStatus == 1).length;
                  final pending = state.pjr.where((p) => p.prjStatus == 0).length;

                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Projects',
                          value: totalProjects.toString(),
                          icon: Icons.folder_copy,
                          color: color.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: tr.completedTitle,
                          value: completed.toString(),
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: tr.pendingTitle,
                          value: pending.toString(),
                          icon: Icons.pending,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
            const SizedBox(height: 20),

            // Projects list
            Expanded(
              child: BlocConsumer<ProjectsBloc, ProjectsState>(
                listener: (context, state) {
                  if (state is ProjectSuccessState) {
                    ToastManager.show(
                      context: context,
                      message: tr.successMessage,
                      type: ToastType.success,
                    );
                  }
                  if (state is ProjectsErrorState) {
                    ToastManager.show(
                      context: context,
                      message: state.message,
                      type: ToastType.error,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ProjectsLoadingState) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (state is ProjectsErrorState) {
                    return NoDataWidget(
                      title: "Error",
                      message: state.message,
                      onRefresh: onRefresh,
                    );
                  }
                  if (state is ProjectsLoadedState) {
                    var filteredProjects = state.pjr.where((project) {
                      final matchesSearch = _searchQuery.isEmpty ||
                          (project.prjName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                          (project.prjDetails?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

                      final matchesStatus = _filterStatus == 'All' ||
                          (_filterStatus == tr.completedTitle && project.prjStatus == 1) ||
                          (_filterStatus == tr.pendingTitle && project.prjStatus == 0);

                      return matchesSearch && matchesStatus;
                    }).toList();

                    if (filteredProjects.isEmpty) {
                      return NoDataWidget(
                        title: "No Projects Found",
                        message: _searchQuery.isNotEmpty || _filterStatus != 'All'
                            ? "Try adjusting your search or filters"
                            : "Click the button above to create your first project",
                        enableAction: false,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: onRefresh,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredProjects.length,
                        itemBuilder: (context, index) {
                          final pjr = filteredProjects[index];
                          return _buildTabletProjectCard(pjr, context, tr);
                        },
                      ),
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

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final color = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: color.primary.withValues(alpha: .15),
      selectedColor: color.primary,
      checkmarkColor: color.surface,
      labelStyle: TextStyle(
        color: isSelected ? color.surface : color.primary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? color.primary : color.primary.withValues(alpha: .3),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabletProjectCard(ProjectsModel pjr, BuildContext context, AppLocalizations tr) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => ProjectView(project: pjr),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.primary.withValues(alpha: .1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${pjr.prjId}',
                        style: TextStyle(
                          color: color.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pjr.prjName ?? '',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(
                    status: pjr.prjStatus!,
                    trueValue: tr.completedTitle,
                    falseValue: tr.pendingTitle,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Details
              if (pjr.prjDetails != null && pjr.prjDetails!.isNotEmpty)
                Text(
                  pjr.prjDetails!,
                  style: textTheme.bodySmall?.copyWith(
                    color: color.outline,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const Spacer(),

              // Deadline info
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: color.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pjr.prjDateLine.toFormattedDate(),
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDeadlineColor(pjr.prjDateLine).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getDeadlineIcon(pjr.prjDateLine),
                          size: 14,
                          color: _getDeadlineColor(pjr.prjDateLine),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pjr.prjDateLine?.daysLeftText ?? '',
                          style: textTheme.bodySmall?.copyWith(
                            color: _getDeadlineColor(pjr.prjDateLine),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.visibility,
                      size: 18,
                      color: color.primary,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ProjectView(project: pjr),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 18,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _showDeleteConfirmation(context, pjr);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDeadlineColor(DateTime? deadline) {
    if (deadline == null) return Colors.grey;
    final days = deadline.daysLeft ?? 0;
    if (days > 7) return Colors.green;
    if (days > 3) return Colors.orange;
    if (days >= 0) return Colors.deepOrange;
    return Colors.red;
  }

  IconData _getDeadlineIcon(DateTime? deadline) {
    if (deadline == null) return Icons.help_outline;
    final days = deadline.daysLeft ?? 0;
    if (days > 7) return Icons.check_circle_outline;
    if (days > 3) return Icons.access_time;
    if (days >= 0) return Icons.warning_amber;
    return Icons.error_outline;
  }

  void _showDeleteConfirmation(BuildContext context, ProjectsModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.prjName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Uncomment when delete event is implemented
              // context.read<ProjectsBloc>().add(DeleteProjectEvent(project.prjId!, "basir.h"));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}