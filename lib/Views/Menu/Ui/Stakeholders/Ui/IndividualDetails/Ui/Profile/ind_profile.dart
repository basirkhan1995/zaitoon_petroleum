import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/blur_loading.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/IndividualByID/bloc/stakeholder_by_id_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/IndividualDetails/profile.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/Ui/add_edit.dart';
import '../../../../../../../../Features/Other/image_helper.dart';
import '../../../Individuals/individual_model.dart';

class IndividualProfileView extends StatelessWidget {
  final IndividualsModel ind;
  const IndividualProfileView({super.key, required this.ind});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(ind),
    );
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

class _Desktop extends StatefulWidget {
  final IndividualsModel ind;
  const _Desktop(this.ind);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  IndividualsModel? individual;
  String? fullName;
  @override
  void initState() {
    context.read<StakeholderByIdBloc>().add(LoadStakeholderByIdEvent(stkId: widget.ind.perId!));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final locale = AppLocalizations.of(context)!;


    return Scaffold(
      appBar: AppBar(titleSpacing: 0, title: Text(locale.profileOverview)),
      body: BlocBuilder<StakeholderByIdBloc, StakeholderByIdState>(
        builder: (context, state) {

          if(state is StakeholderByIdLoadedState){
            individual = state.stk;
            fullName = "${state.stk.perName} ${state.stk.perLastName}";
          }
          return Column(
            children: [
              BlurLoader(
                isLoading: state is StakeholderByIdLoadingState,
                child: Cover(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  color: color.surface,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ImageHelper.stakeholderProfile(
                              shapeStyle: ShapeStyle.roundedRectangle,
                              imageName:  individual?.imageProfile,
                              borderRadius: 8,
                              size: 100),
                          SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${individual?.perName} ${individual?.perLastName}",
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Row(
                                  spacing: 5,
                                  children: [
                                    Cover(child: Text(individual?.perPhone ?? "")),
                                    Cover(child: Text(individual?.perEnidNo ?? "")),
                                    Cover(child: Text(Utils.genderType(gender: individual?.perGender ?? "",locale: locale))),
                                    Cover(child: Text(individual?.addCity ?? "")),
                                    Cover(child: Text(individual?.addProvince ?? "")),
                                    Cover(child: Text(individual?.addCountry ?? "")),
                                    Cover(child: Text(individual?.addName ?? "")),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              spacing: 8,
                              children: [
                                ZOutlineButton(
                                  icon: Icons.refresh,
                                  width: 120,
                                  onPressed: (){
                                    showDialog(context: context, builder: (context){
                                      return IndividualAddEditView(model: individual);
                                    });
                                  },
                                  label: Text(locale.edit),
                                ),
                                ZOutlineButton(
                                  isActive: true,
                                  icon: Icons.delete,
                                  width: 120,
                                  label: Text(locale.delete),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IndividualsDetailsTabView(ind: widget.ind),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
