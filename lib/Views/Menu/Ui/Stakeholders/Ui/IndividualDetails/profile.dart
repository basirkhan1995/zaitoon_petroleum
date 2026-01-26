import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/IndividualDetails/Ui/Accounts/stk_accounts.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/IndividualDetails/Ui/Users/stk_users.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/IndividualDetails/bloc/ind_detail_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/model/individual_model.dart';
import '../../../../../../Features/Generic/tab_bar.dart';
import '../../../../../../Localizations/l10n/translations/app_localizations.dart';

class IndividualsDetailsTabView extends StatelessWidget {
  final IndividualsModel ind;
  const IndividualsDetailsTabView({super.key,required this.ind});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: BlocBuilder<IndividualDetailTabBloc, IndividualDetailTabState>(
        builder: (context, state) {
          final tabs = <ZTabItem<IndividualDetailTabName>>[
            ZTabItem(
              value: IndividualDetailTabName.accounts,
              label: AppLocalizations.of(context)!.accounts,
              screen: AccountsByPerIdView(ind: ind),
            ),
            ZTabItem(
              value: IndividualDetailTabName.users,
              label: AppLocalizations.of(context)!.users,
              screen: UsersByPerIdView(perId: ind.perId!),
            ),
          ];

          final available = tabs.map((t) => t.value).toList();
          final selected = available.contains(state.tab)
              ? state.tab
              : available.first;

          return ZTabContainer<IndividualDetailTabName>(
            /// Tab data
            tabs: tabs,
            selectedValue: selected,

            /// Bloc update
            onChanged: (val) => context.read<IndividualDetailTabBloc>().add(IndOnChangedEvent(val)),

            /// Colors for underline style
            style: ZTabStyle.rounded,
            tabBarPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
            borderRadius: 0,
            title: AppLocalizations.of(context)!.details,
            selectedColor: Theme.of(context).colorScheme.primary,
            description: AppLocalizations.of(context)!.accountsAndUsers,
            unselectedTextColor: Theme.of(context).colorScheme.secondary,
            selectedTextColor: Theme.of(context).colorScheme.surface,
            tabContainerColor: Theme.of(context).colorScheme.surface,
          );
        },
      ),
    );
  }
}
