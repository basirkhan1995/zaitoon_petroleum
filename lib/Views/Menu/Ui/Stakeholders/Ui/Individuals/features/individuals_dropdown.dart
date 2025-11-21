import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../Features/Generic/custom_filter_drop.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../bloc/individuals_bloc.dart';
import '../individual_model.dart';

class StakeholdersDropdown extends StatefulWidget {
  final String? title;
  final bool isMulti;
  final double height;
  final bool disableAction;
  final ValueChanged<List<IndividualsModel>> onMultiChanged;
  final ValueChanged<IndividualsModel?>? onSingleChanged;
  final List<IndividualsModel>? initiallySelected;
  final IndividualsModel? initiallySelectedSingle;
  final String? indId; // Optional: to load specific individual

  const StakeholdersDropdown({
    super.key,
    required this.isMulti,
    required this.onMultiChanged,
    this.height = 45,
    this.disableAction = false,
    this.onSingleChanged,
    this.title,
    this.initiallySelected,
    this.initiallySelectedSingle,
    this.indId,
  });

  @override
  State<StakeholdersDropdown> createState() => _StakeholdersDropdownState();
}

class _StakeholdersDropdownState extends State<StakeholdersDropdown> {
  List<IndividualsModel> _selectedMulti = [];
  IndividualsModel? _selectedSingle;

  @override
  void initState() {
    super.initState();

    // Load stakeholders when the dropdown is initialized
    context.read<IndividualsBloc>().add(LoadIndividualsEvent());

    if (widget.isMulti) {
      _selectedMulti = widget.initiallySelected ?? [];
    } else {
      _selectedSingle = widget.initiallySelectedSingle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IndividualsBloc, IndividualsState>(
      builder: (context, state) {
        final bool isLoading = state is IndividualLoadingState;

        // Build the title widget with loading indicator
        Widget buildTitle() {
          if (isLoading) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title ?? AppLocalizations.of(context)!.stakeholders,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            );
          } else {
            return Text(
              widget.title ?? AppLocalizations.of(context)!.stakeholders,
              style: Theme.of(context).textTheme.titleSmall,
            );
          }
        }

        if (state is IndividualErrorState) {
          return Text('Error: ${state.message}');
        }

        List<IndividualsModel> stakeholders = [];
        if (state is IndividualLoadedState) {
          stakeholders = state.individuals;
        }

        return ZDropdown<IndividualsModel>(
          disableAction: widget.disableAction,
          title: '', // We'll handle title separately
          height: widget.height,
          leadingBuilder: (IndividualsModel stakeholder) {
            // You can customize the leading icon based on stakeholder type
            return Icon(
              Icons.lock_clock,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            );
          },
          items: stakeholders,
          multiSelect: widget.isMulti,
          selectedItems: widget.isMulti ? _selectedMulti : [],
          selectedItem: widget.isMulti ? null : _selectedSingle,
          itemLabel: (item) => _getStakeholderDisplayName(item),
          initialValue: AppLocalizations.of(context)!.individuals,

          // MULTI-SELECT HANDLER
          onMultiSelectChanged: widget.isMulti
              ? (selected) {
            setState(() => _selectedMulti = selected);
            widget.onMultiChanged(selected);
          }
              : null,

          // SINGLE-SELECT HANDLER
          onItemSelected: widget.isMulti
              ? (_) {}
              : (item) {
            setState(() => _selectedSingle = item);
            widget.onSingleChanged?.call(item);
          },
          isLoading: isLoading,
          itemStyle: Theme.of(context).textTheme.bodyMedium,
          // Custom title widget that includes loading indicator
          customTitle: buildTitle(),
        );
      },
    );
  }

  String _getStakeholderDisplayName(IndividualsModel stakeholder) {
    // Customize how you want to display the stakeholder name
    // You can combine first name, last name, company name, etc.
    if (stakeholder.perName != null && stakeholder.perLastName != null) {
      return '${stakeholder.perName} ${stakeholder.perLastName}';
    } else if (stakeholder.perName != null) {
      return stakeholder.perName!;
    } else {
      return 'Unknown Stakeholder';
    }
  }
}