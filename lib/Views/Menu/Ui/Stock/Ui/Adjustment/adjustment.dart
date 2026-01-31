import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/search_field.dart';
import 'package:zaitoon_petroleum/Features/Widgets/txn_status_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../Features/Date/shamsi_converter.dart';
import '../../../../../../Features/Other/extensions.dart';
import '../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import 'add_adjustment.dart';
import 'bloc/adjustment_bloc.dart';
import 'model/adjustment_model.dart';

class AdjustmentView extends StatelessWidget {
  const AdjustmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const _Mobile(),
      desktop: const _Desktop(),
      tablet: const _Tablet(),
    );
  }
}

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  String? baseCurrency;
  final TextEditingController searchController = TextEditingController();
  List<AdjustmentModel> _filteredAdjustments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load adjustments when the view initializes
      context.read<AdjustmentBloc>().add(LoadAdjustmentsEvent());
    });

    final companyState = context.read<CompanyProfileBloc>().state;
    if (companyState is CompanyProfileLoadedState) {
      baseCurrency = companyState.company.comLocalCcy ?? "";
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterAdjustments(String query, List<AdjustmentModel> adjustments) {
    setState(() {
      if (query.isEmpty) {
        _filteredAdjustments = adjustments;
      } else {
        _filteredAdjustments = adjustments.where((adj) {
          return (adj.ordxRef?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              (adj.trnStateText?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              (adj.account?.toString().contains(query) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    TextStyle? titleStyle = textTheme.titleSmall?.copyWith(color: color.surface);
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  flex: 5,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      tr.adjustment,
                      style: textTheme.titleMedium?.copyWith(fontSize: 20),
                    ),
                    subtitle: Text(
                      'Adjust inventory shortage to expense account',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ZSearchField(
                    icon: FontAwesomeIcons.magnifyingGlass,
                    controller: searchController,
                    hint: tr.search,
                    onChanged: (query) {
                      final state = context.read<AdjustmentBloc>().state;
                      if (state is AdjustmentListLoaded) {
                        _filterAdjustments(query, state.adjustments);
                      }
                    },
                    title: "",
                  ),
                ),
                ZOutlineButton(
                  toolTip: "F5",
                  width: 120,
                  icon: Icons.refresh,
                  onPressed: () => context.read<AdjustmentBloc>().add(LoadAdjustmentsEvent()),
                  label: Text(tr.refresh),
                ),
                ZOutlineButton(
                  toolTip: "Ctrl+N",
                  isActive: true,
                  width: 120,
                  icon: Icons.add,
                  onPressed: () => _showNewAdjustmentDialog(context),
                  label: Text(tr.newKeyword),
                ),
              ],
            ),
          ),

          // Adjustments List Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
            decoration: BoxDecoration(color: color.primary.withAlpha(230)),
            child: Row(
              children: [
                SizedBox(width: 30, child: Text("#", style: titleStyle)),
                SizedBox(width: 100, child: Text("Date", style: titleStyle)),
                SizedBox(width: 215, child: Text(tr.referenceNumber, style: titleStyle)),
                Expanded(child: Text("Expense Account", style: titleStyle)),
                SizedBox(width: 150, child: Text(tr.totalInvoice, style: titleStyle)),
                SizedBox(width: 120, child: Text("Status", style: titleStyle)),
              ],
            ),
          ),

          // Adjustments List
          Expanded(
            child: BlocConsumer<AdjustmentBloc, AdjustmentState>(
              listener: (context, state) {
                if (state is AdjustmentListLoaded) {
                  _filterAdjustments(searchController.text, state.adjustments);
                }
              },
              builder: (context, state) {
                if (state is AdjustmentLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AdjustmentListLoaded) {
                  // Initialize filtered list if empty
                  if (_filteredAdjustments.isEmpty && searchController.text.isEmpty) {
                    _filteredAdjustments = state.adjustments;
                  }

                  if (_filteredAdjustments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            searchController.text.isEmpty
                                ? 'No adjustments found'
                                : 'No matching adjustments',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          if (searchController.text.isEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Click the "New" button to create your first adjustment',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            ),
                          ]
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: _filteredAdjustments.length,
                    itemBuilder: (context, index) {
                      final adjustment = _filteredAdjustments[index];
                      return _buildAdjustmentRow(adjustment, index, context);
                    },
                  );
                } else if (state is AdjustmentError) {
                  return NoDataWidget(
                    imageName: "error.png",
                    message: state.message,
                    enableAction: false,
                  );
                } else if (state is AdjustmentSaved) {
                  // After saving, reload adjustments
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<AdjustmentBloc>().add(LoadAdjustmentsEvent());
                  });
                  return const Center(child: CircularProgressIndicator());
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentRow(
      AdjustmentModel adjustment,
      int index,
      BuildContext context,
      ) {
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        color: index.isEven ? Colors.transparent : Colors.grey.shade50,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              "${index + 1}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color.primary,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              adjustment.ordEntryDate?.toFormattedDate() ?? "N/A",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          SizedBox(
            width: 215,
            child: Text(
              adjustment.ordxRef ?? "N/A",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              "${adjustment.account ?? ""}",
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              "${adjustment.amount?.toAmount()} $baseCurrency",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 120,
            child: TransactionStatusBadge(status: adjustment.trnStateText??"")
          ),
        ],
      ),
    );
  }

  void _showNewAdjustmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 700),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: AdjustmentFormView(),
          ),
        ),
      ),
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