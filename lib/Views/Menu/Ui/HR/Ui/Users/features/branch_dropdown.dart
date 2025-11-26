import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../Features/Generic/custom_filter_drop.dart';
import '../../../../Settings/Ui/Company/Branches/bloc/branch_bloc.dart';
import '../../../../Settings/Ui/Company/Branches/model/branch_model.dart';


class BranchDropdown extends StatelessWidget {
  final Function(BranchModel) onBranchSelected;
  final String title;
  final double? radius;
  final double? height;

  const BranchDropdown({
    super.key,
    required this.onBranchSelected,
    this.title = "Branch",
    this.radius,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BranchBloc, BranchState>(
      builder: (context, state) {
        // 1️⃣ Loading state
        if (state is BranchLoadingState) {
          return ZDropdown<BranchModel>(
            title: title,
            items: const [],
            isLoading: true,
            onItemSelected: (_) {},
            itemLabel: (e) => "",
          );
        }

        // 2️⃣ Loaded state
        if (state is BranchLoadedState) {
          final branches = state.branches;

          if (branches.isEmpty) {
            return const Text("No branches found");
          }

          // Automatically select first branch
          final initialBranch = branches.first;

          return ZDropdown<BranchModel>(
            title: title,
            items: branches,
            selectedItem: initialBranch,
            height: height,
            radius: radius,
            itemLabel: (b) => b.brcName ?? "",
            onItemSelected: (selected) {
              onBranchSelected(selected);
            },
          );
        }

        // 3️⃣ Error state
        if (state is BranchErrorState) {
          return Text("Error: ${state.message}");
        }

        return const SizedBox.shrink();
      },
    );
  }
}
