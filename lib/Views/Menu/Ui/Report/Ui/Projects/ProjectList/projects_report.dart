import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Projects/ProjectList/bloc/projects_report_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Report/Ui/Transport/Shipments/features/status_drop.dart';
import '../../../../../../../Features/Date/shamsi_converter.dart';
import '../../../../../../../Features/Date/z_generic_date.dart';
import '../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import '../../../../Stakeholders/Ui/Individuals/model/individual_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectsReportView extends StatelessWidget {
  const ProjectsReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(),
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
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  String fromDate = DateTime.now()
      .subtract(const Duration(days: 7))
      .toFormattedDate();
  String toDate = DateTime.now().toFormattedDate();
  final customerController = TextEditingController();
  int? customerId;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<ProjectsReportBloc>().add(ResetProjectReportEvent());
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text("Projects Report")),
      body: Column(
        children: [
          //Header
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child:
                      GenericTextfield<IndividualsModel, IndividualsBloc, IndividualsState>(
                        showAllOnFocus: true,
                        controller: customerController,
                        title: tr.individuals,
                        hintText: tr.userOwner,
                        bloc: context.read<IndividualsBloc>(),
                        fetchAllFunction: (bloc) =>
                            bloc.add(LoadIndividualsEvent()),
                        searchFunction: (bloc, query) =>
                            bloc.add(SearchIndividualsEvent(query)),
                        itemBuilder: (context, account) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 5,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${account.perName} ${account.perLastName}",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        itemToString: (ind) =>
                            "${ind.perName} ${ind.perLastName}",
                        stateToLoading: (state) =>
                            state is IndividualLoadingState,
                        loadingBuilder: (context) => const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        stateToItems: (state) {
                          if (state is IndividualLoadedState) {
                            return state.individuals;
                          }
                          return [];
                        },
                        onSelected: (value) {
                          setState(() {
                            customerId = value.perId!;
                          });
                        },
                        noResultsText: tr.noDataFound,
                        showClearButton: true,
                      ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ZDatePicker(
                    label: tr.fromDate,
                    value: fromDate,
                    onDateChanged: (v) {
                      setState(() {
                        fromDate = v;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ZDatePicker(
                    label: tr.toDate,
                    value: toDate,
                    onDateChanged: (v) {
                      setState(() {
                        toDate = v;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: StatusDropdown(onChanged: (e) {})),
                const SizedBox(width: 8),
                ZOutlineButton(
                  icon: FontAwesomeIcons.solidFilePdf,
                  height: 47,
                  onPressed: () {},
                  label: Text("PDF"),
                ),
                const SizedBox(width: 8),
                ZOutlineButton(
                  icon: Icons.filter_alt_outlined,
                  height: 47,
                  isActive: true,
                  onPressed: () {
                    context.read<ProjectsReportBloc>().add(LoadProjectReportEvent(
                      fromDate: fromDate,
                      toDate: toDate,
                      customerId: customerId,
                    ));
                  },
                  label: Text(tr.applyFilter),
                ),
              ],
            ),
          ),

          Expanded(
            child: BlocBuilder<ProjectsReportBloc, ProjectsReportState>(
              builder: (context, state) {
                if(state is ProjectsReportInitial){
                  return NoDataWidget(
                    title: "Projects Report",
                    message: "Apply filter to show project report",
                    enableAction: false,
                  );
                }
                if(state is ProjectsReportLoadingState){
                  return Center(child: CircularProgressIndicator());
                }if(state is ProjectsReportErrorState){
                  return NoDataWidget(
                    title: tr.errorTitle,
                    message: state.message,
                    enableAction: false,
                  );
                }if(state is ProjectsReportLoadedState){
                  if(state.prj.isEmpty){
                    return NoDataWidget(
                      title: tr.noData,
                      message: tr.noDataFound,
                      enableAction: false,
                    );
                  }
                  return ListView.builder(
                      itemCount: state.prj.length,
                      itemBuilder: (context,index){
                     final pjr = state.prj[index];
                     return InkWell(
                       onTap: (){},
                       child: Container(
                         padding: EdgeInsets.all(10),
                         decoration: BoxDecoration(
                           color: index.isOdd? Theme.of(context).colorScheme.primary.withValues(alpha: .05) : Colors.transparent
                         ),
                         child: Row(
                           children: [
                             SizedBox(
                                 width: 40,
                                 child: Text(pjr.prjId.toString())),
                             Expanded(
                               child: Column(
                                 mainAxisAlignment: MainAxisAlignment.start,
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text(pjr.prjName.toString()),
                                   Text(pjr.prjLocation.toString()),
                                 ],
                               ),
                             ),
                             SizedBox(
                                 width: 180,
                                 child: Text(pjr.customerName??"")),

                             SizedBox(
                                 width: 100,
                                 child: Text(pjr.totalAmount.toAmount())),

                             SizedBox(
                                 width: 100,
                                 child: Text(pjr.totalPayments.toAmount())),

                             SizedBox(
                                 width: 100,
                                 child: Text(pjr.totalAmount.toAmount())),

                             SizedBox(
                                 width: 150,
                                 child: Text(pjr.prjDateLine?.daysLeftText??"")),
                             SizedBox(
                                 width: 80,
                                 child: Text(pjr.prjStatus.toString())),
                           ],
                         ),
                       ),
                     );
                  });
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
