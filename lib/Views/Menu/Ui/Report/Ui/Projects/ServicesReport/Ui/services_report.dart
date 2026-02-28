import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/AllProjects/bloc/projects_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/AllProjects/model/pjr_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Services/bloc/services_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Services/model/services_model.dart';
import '../../../../../../../../Features/Date/shamsi_converter.dart';
import '../../../../../../../../Features/Date/z_generic_date.dart';
import '../../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../bloc/services_report_bloc.dart';

class ServicesReportView extends StatelessWidget {
  const ServicesReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
        mobile: _Mobile(), tablet: _Tablet(), desktop: _Desktop());
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
  String fromDate = DateTime.now().subtract(const Duration(days: 7)).toFormattedDate();
  String toDate = DateTime.now().toFormattedDate();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<ServicesReportBloc>().add(ResetServicesReportEvent());
    });
    super.initState();
  }

  final servicesController = TextEditingController();
  final projectsController = TextEditingController();

  int? projectId;
  int? serviceId;

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    TextStyle? titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(color: color.surface);
    TextStyle? subtitleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(color: color.outline);
    return Scaffold(
      appBar: AppBar(
        title: Text("Services Report"),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: GenericTextfield<ServicesModel, ServicesBloc, ServicesState>(
                    title: tr.services,
                    controller: servicesController,
                    hintText: tr.services,
                    bloc: context.read<ServicesBloc>(),
                    fetchAllFunction: (bloc) => bloc.add(LoadServicesEvent()),
                    searchFunction: (bloc, query) => bloc.add(LoadServicesEvent(search: query)),
                    showAllOption: true,
                    allOption: ServicesModel(
                      srvName: tr.all,
                    ),
                    itemBuilder: (context, services) {
                      if (services.srvId == null) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            tr.all,
                            style: TextStyle(
                              color: color.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(services.srvName ?? ''),
                      );
                    },
                    itemToString: (ser) =>
                    ser.srvName ?? (ser.srvId == null ? tr.all : ''),
                    stateToLoading: (state) =>
                    state is ServicesLoadingState,
                    stateToItems: (state) {
                      if (state is ServicesLoadedState) {
                        return state.services;
                      }
                      return [];
                    },
                    onSelected: (ser) {
                      setState(() {
                        serviceId = ser.srvId;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: GenericTextfield<ProjectsModel, ProjectsBloc, ProjectsState>(
                    title: tr.projects,
                    controller: projectsController,
                    hintText: tr.projects,
                    bloc: context.read<ProjectsBloc>(),
                    fetchAllFunction: (bloc) => bloc.add(LoadProjectsEvent()),
                    searchFunction: (bloc, query) => bloc.add(LoadProjectsEvent()),
                    showAllOption: true,
                    allOption: ProjectsModel(
                      prjName: tr.all,
                    ),
                    itemBuilder: (context, prj) {
                      if (prj.prjId == null) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            tr.all,
                            style: TextStyle(
                              color: color.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(prj.prjName ?? ''),
                      );
                    },
                    itemToString: (prj) =>
                    prj.prjName ?? (prj.prjId == null ? tr.all : ''),
                    stateToLoading: (state) =>
                    state is ProjectsLoadingState,
                    stateToItems: (state) {
                      if (state is ProjectsLoadedState) {
                        return state.pjr;
                      }
                      return [];
                    },
                    onSelected: (prj) {
                      setState(() {
                        projectId = prj.prjId;
                      });
                    },
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
                ZOutlineButton(
                    isActive: true,
                    height: 47,
                    icon: Icons.filter_alt_outlined,
                    onPressed: (){
                      context.read<ServicesReportBloc>().add(LoadServicesReportEvent(
                        fromDate: fromDate,
                        toDate: toDate,
                        serviceId: serviceId,
                        projectId: projectId
                      ));
                    },
                    label: Text(tr.applyFilter)),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: color.primary,

            ),
            child: Row(
              children: [
                SizedBox(
                    width: 100,
                    child: Text(tr.date,style: titleStyle)),

                Expanded(
                    child: Text("Service & Project name",style: titleStyle)),

                SizedBox(
                    width: 100,
                    child: Text("Charges",style: titleStyle)),

                SizedBox(
                    width: 100,
                    child: Text("QTY",style: titleStyle)),

                SizedBox(
                    width: 100,
                    child: Text("Total Value",style: titleStyle)),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ServicesReportBloc, ServicesReportState>(
              builder: (context, state) {
                if(state is ServicesReportLoadingState){
                  return Center(child: CircularProgressIndicator());
                }if(state is ServicesReportErrorState){
                  return NoDataWidget(
                    title: tr.errorTitle,
                    message: state.message,
                  );
                }if(state is ServicesReportLoadedState){
                 return ListView.builder(
                     itemCount: state.services.length,
                     itemBuilder: (context,index){
                       final service = state.services[index];
                     return Container(
                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                       decoration: BoxDecoration(
                        color: index.isOdd? Theme.of(context).colorScheme.primary.withValues(alpha: .05) : Colors.transparent
                       ),
                       child: Row(
                         children: [
                           SizedBox(
                               width: 100,
                               child: Text(service.entryDate.toFormattedDate())),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(service.serviceName??"",style: titleStyle?.copyWith(color: color.onSurface),),
                                Text(service.projectName??"",style: subtitleStyle),
                              ],
                            ),
                          ),
                           SizedBox(
                               width: 100,
                               child: Text(service.pjdPricePerQty.toAmount())),
                           SizedBox(
                               width: 100,
                               child: Text(service.pjdQuantity.toString())),
                           SizedBox(
                               width: 100,
                               child: Text(service.totalAmount.toAmount())),

                         ],
                       ),
                     );
                 });
                }
                return const SizedBox();
              },
            ),
          )

        ],
      ),
    );
  }
}
