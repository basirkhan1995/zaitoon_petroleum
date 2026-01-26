import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';

import '../../../../../../../Features/Generic/zaitoon_drop.dart';
import '../../../../Settings/Ui/Company/Branches/bloc/branch_bloc.dart';
import '../../../../Settings/Ui/Company/Branches/model/branch_model.dart';

class BranchDropdown extends StatefulWidget {
  final Function(BranchModel?) onBranchSelected;
  final String title;
  final double? radius;
  final double? height;
  final int? currentBranchId;
  final bool disableAction;
  final BranchModel? initiallySelected;
  final int? selectedId;
  final bool showAllOption; // New parameter to control "All" option

  const BranchDropdown({
    super.key,
    required this.onBranchSelected,
    this.title = "Branch",
    this.radius,
    this.height,
    this.currentBranchId,
    this.disableAction = false,
    this.initiallySelected,
    this.selectedId,
    this.showAllOption = false, // Default to false
  });

  @override
  State<BranchDropdown> createState() => _BranchDropdownState();
}

class _BranchDropdownState extends State<BranchDropdown> {
  BranchModel? _selectedItem;

  @override
  void initState() {
    super.initState();
    context.read<BranchBloc>().add(LoadBranchesEvent());
    _selectedItem = widget.initiallySelected;
  }

  @override
  void didUpdateWidget(BranchDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    // When external selectedId becomes null (on clear)
    if (widget.selectedId == null && oldWidget.selectedId != null) {
      // If showAllOption is true, reset to "All", otherwise reset to null
      if (widget.showAllOption) {
        _selectedItem = null;
      } else if (widget.initiallySelected != null) {
        _selectedItem = widget.initiallySelected;
      } else {
        final state = context.read<BranchBloc>().state;
        if (state is BranchLoadedState && state.branches.isNotEmpty) {
          _selectedItem = state.branches.first;
        }
      }
    }
    // When external selectedId changes to a new value, find and select it
    else if (widget.selectedId != null && widget.selectedId != oldWidget.selectedId) {
      final state = context.read<BranchBloc>().state;
      if (state is BranchLoadedState) {
        final found = state.branches.firstWhere(
              (b) => b.brcId == widget.selectedId,
          orElse: () => BranchModel(brcId: -1, brcName: 'Not Found'),
        );
        if (found.brcId != -1) {
          _selectedItem = found;
        }
      }
    }
  }

  Widget buildTitle(BuildContext context, bool isLoading) {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontSize: 12),
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      );
    }
    return Text(
      widget.title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BranchBloc, BranchState>(
      builder: (context, state) {
        final bool isLoading = state is BranchLoadingState;

        if (state is BranchErrorState) {
          return Text('Error: ${state.message}');
        }

        // Prepare items list
        List<BranchModel> items = [];

        // Add "All" option only if showAllOption is true
        if (widget.showAllOption) {
          final allOption = BranchModel(
            brcId: null,
            brcName: AppLocalizations.of(context)!.all,
          );
          items.add(allOption);
        }

        // Add actual branch items
        if (state is BranchLoadedState) {
          items.addAll(state.branches);
        }

        // Determine selected item
        BranchModel? selectedItem = _selectedItem;

        if (selectedItem == null && items.isNotEmpty) {
          // If showAllOption is true, default to "All", otherwise to first branch
          if (widget.showAllOption) {
            selectedItem = items.firstWhere(
                  (item) => item.brcId == null,
              orElse: () => items[0],
            );
          } else {
            selectedItem = items.isNotEmpty ? items[0] : null;
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ZDropdown<BranchModel>(
              disableAction: widget.disableAction || isLoading,
              title: '',
              height: widget.height ?? 40,
              items: items,
              multiSelect: false,
              selectedItem: selectedItem,
              itemLabel: (branch) => branch.brcName ?? '',
              initialValue: widget.title,
              onItemSelected: (branch) {
                setState(() => _selectedItem = branch);
                // Pass null when "All" is selected and showAllOption is true
                if (widget.showAllOption && branch.brcId == null) {
                  widget.onBranchSelected(null);
                } else {
                  widget.onBranchSelected(branch);
                }
              },
              isLoading: isLoading,
              customTitle: buildTitle(context, isLoading),
              radius: widget.radius,
            ),
          ],
        );
      },
    );
  }
}