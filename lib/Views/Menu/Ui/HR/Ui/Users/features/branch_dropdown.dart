import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../Features/Generic/zaitoon_drop.dart';
import '../../../../Settings/Ui/Company/Branches/bloc/branch_bloc.dart';
import '../../../../Settings/Ui/Company/Branches/model/branch_model.dart';


class BranchDropdown extends StatelessWidget {
  final Function(BranchModel) onBranchSelected;
  final String title;
  final double? radius;
  final double? height;
  final int? currentBranchId; // ✅ the brcId of the current user

  const BranchDropdown({
    super.key,
    required this.onBranchSelected,
    this.title = "Branch",
    this.radius,
    this.height,
    this.currentBranchId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BranchBloc, BranchState>(
      builder: (context, state) {
        if (state is BranchLoadingState) {
          return ZDropdown<BranchModel>(
            title: title,
            items: const [],
            isLoading: true,
            onItemSelected: (_) {},
            itemLabel: (e) => "",
          );
        }

        if (state is BranchLoadedState) {
          final branches = state.branches;

          if (branches.isEmpty) {
            return const Text("No branches found");
          }

          // Find the branch that matches currentBranchId
          BranchModel? initialBranch;
          if (currentBranchId != null) {
            initialBranch =
                branches.firstWhere((b) => b.brcId == currentBranchId, orElse: () => branches.first);
          } else {
            initialBranch = branches.first;
          }

          return ZDropdown<BranchModel>(
            title: title,
            items: branches,
            selectedItem: initialBranch, // ✅ show branchName instead of code
            height: height,
            radius: radius,
            itemLabel: (b) => b.brcName ?? "",
            onItemSelected: (selected) {
              onBranchSelected(selected);
            },
          );
        }

        if (state is BranchErrorState) {
          return Text("Error: ${state.message}");
        }

        return const SizedBox.shrink();
      },
    );
  }
}
