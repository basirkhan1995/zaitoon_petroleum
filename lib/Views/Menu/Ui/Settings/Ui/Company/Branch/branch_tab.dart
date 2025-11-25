import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Branch/BranchLimits/Ui/limits.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Branch/Branches/Ui/add_edit_branch.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Branch/Branches/model/branch_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Branch/bloc/brc_tab_bloc.dart';
import '../../../../../../../Features/Generic/tab_bar.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';

class BranchTabsView extends StatelessWidget {
  final BranchModel selectedBranch;
  const BranchTabsView({super.key, required this.selectedBranch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: BlocBuilder<BranchTabBloc, BranchTabState>(
          builder: (context, state) {
            final tabs = <ZTabItem<BranchTabName>>[
              ZTabItem(
                value: BranchTabName.overview,
                label: AppLocalizations.of(context)!.overview,
                screen: BranchAddEditView(selectedBranch: selectedBranch),
              ),
              ZTabItem(
                value: BranchTabName.limits,
                label: AppLocalizations.of(context)!.accountLimit,
                screen: const BranchLimitsView(),
              ),
            ];

            final available = tabs.map((t) => t.value).toList();
            final selected = available.contains(state.tab)
                ? state.tab
                : available.first;

            return ZTabContainer<BranchTabName>(
              title: AppLocalizations.of(context)!.stakeholders,

              /// Tab data
              tabs: tabs,
              selectedValue: selected,

              /// Bloc update
              onChanged: (val) => context
                  .read<BranchTabBloc>()
                  .add(BrcOnChangedEvent(val)),

              /// Colors for underline style
              style: ZTabStyle.underline,
              selectedColor: Theme.of(context).colorScheme.primary,
              unselectedTextColor: Theme.of(context).colorScheme.secondary,
              selectedTextColor: Theme.of(context).colorScheme.surface,
              tabContainerColor: Theme.of(context).colorScheme.surface,
            );
          },
        ),
      ),
    );
  }
}
