import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/Bloc/localizations_bloc.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/ProjectServices/bloc/project_services_bloc.dart';

class ProjectServicesView extends StatelessWidget {
  final int? projectId;
  const ProjectServicesView({super.key, this.projectId});
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(projectId),
      tablet: _Tablet(projectId),
      desktop: _Desktop(projectId),
    );
  }
}

class _Mobile extends StatelessWidget {
  final int? projectId;
  const _Mobile(this.projectId);
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Tablet extends StatelessWidget {
  final int? projectId;
  const _Tablet(this.projectId);
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Desktop extends StatefulWidget {
  final int? projectId;
  const _Desktop(this.projectId);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  final formKey = GlobalKey<FormState>();
  final servicesController = TextEditingController();
  final qty = TextEditingController();
  final amount = TextEditingController();
  final remark = TextEditingController();
  String? myLocale;
  @override
  void initState() {
    myLocale = context.read<LocalizationBloc>().state.languageCode;
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(widget.projectId !=null) {
        context.read<ProjectServicesBloc>().add(LoadProjectServiceEvent(widget.projectId!));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    remark.dispose();
    servicesController.dispose();
    amount.dispose();
    qty.dispose();
    amount.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    TextStyle? titleStyle = Theme.of(context).textTheme.titleSmall;
    TextStyle? subtitleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(color: color.outline.withValues(alpha: .8));
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8,vertical: 7),
            decoration: BoxDecoration(
                color: color.primary.withValues(alpha: .05)
            ),
            child: Row(
              children: [
                Expanded(child: Text("Project Services",style: titleStyle)),

                SizedBox(
                    width: 50,
                    child: Text(
                        tr.qty,style: titleStyle)),
                SizedBox(
                    width: 120,
                    child: Text(
                        textAlign: myLocale == "en"? TextAlign.right : TextAlign.left,
                        tr.amount,style: titleStyle)),

                SizedBox(
                    width: 120,
                    child: Text(
                        textAlign: myLocale == "en"? TextAlign.right : TextAlign.left,
                        tr.totalTitle,style: titleStyle)),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ProjectServicesBloc, ProjectServicesState>(
              builder: (context, state) {
                if(state is ProjectServicesLoadingState){
                  return Center(child: CircularProgressIndicator());
                }
                if(state is ProjectServicesErrorState){
                  return NoDataWidget(
                    title: tr.errorTitle,
                    message: state.message,
                    onRefresh: (){
                      context.read<ProjectServicesBloc>().add(LoadProjectServiceEvent(widget.projectId!));
                    },
                  );
                }
                if(state is ProjectServicesLoadedState){
                  return ListView.builder(
                      itemCount: state.projectServices.length,
                      itemBuilder: (context,index){
                      final prjServices = state.projectServices[index];
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                        decoration: BoxDecoration(
                          color: index.isOdd? color.primary.withValues(alpha: .05) : Colors.transparent
                        ),
                        child: Row(
                          children: [
                           Expanded(
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.start,
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(prjServices.srvName??"",style: titleStyle),
                                 Text(prjServices.prpTrnRef??"",style: subtitleStyle),
                                 if(prjServices.pjdRemark !=null)
                                 Text(prjServices.pjdRemark??"",style: subtitleStyle),
                               ],
                             ),
                           ),

                           SizedBox(
                               width: 50,
                               child: Text(prjServices.pjdQuantity.toString())),

                            SizedBox(
                                width: 120,
                                child: Text(prjServices.pjdPricePerQty.toAmount(),
                                textAlign: myLocale == "en"? TextAlign.right : TextAlign.left,
                                )),

                            SizedBox(
                                width: 120,
                                child: Text(prjServices.total.toAmount(),
                                  textAlign: myLocale == "en"? TextAlign.right : TextAlign.left,
                                )),
                          ],
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
