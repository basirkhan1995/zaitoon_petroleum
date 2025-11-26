import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Branch/branch_tab.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Branches/model/branch_model.dart';

class BranchDetailsView extends StatelessWidget {
  final BranchModel branch;
  const BranchDetailsView({super.key,required this.branch});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(),tablet: _Tablet(), desktop: _Desktop(branch));
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

class _Desktop extends StatelessWidget {
  final BranchModel branch;
  const _Desktop(this.branch);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            contentPadding: EdgeInsets.zero,
            insetPadding: const EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            titlePadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            content: Container(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              width: MediaQuery.sizeOf(context).width * .4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(child: BranchTabsView(selectedBranch: branch))
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
