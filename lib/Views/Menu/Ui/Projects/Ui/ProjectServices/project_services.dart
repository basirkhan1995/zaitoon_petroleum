import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/Bloc/localizations_bloc.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/ProjectServices/bloc/project_services_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/ProjectServices/model/project_services_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Services/Ui/add_edit_services.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Services/bloc/services_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Services/model/services_model.dart';

import '../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../../Auth/models/login_model.dart';

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
  final qty = TextEditingController(text: "1");
  final amount = TextEditingController();
  final remark = TextEditingController();
  int? serviceId;
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
  LoginData? loginData;
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

    final state = context.watch<AuthBloc>().state;
    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    loginData = state.loginData;

    return Scaffold(
      body: Column(
        children: [
          ZCover(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [

               Row(
                 spacing: 8,
                 children: [
                   Expanded(
                     flex: 3,
                     child: GenericTextfield<ServicesModel, ServicesBloc, ServicesState>(
                       controller: servicesController,
                       title: tr.services,
                       hintText: tr.services,
                       trailing: IconButton(
                         onPressed: () {
                           showDialog(
                             context: context,
                             builder: (context) {
                               return AddEditServiceView();
                             },
                           );
                         },
                         icon: Icon(Icons.add),
                       ),
                       isRequired: true,
                       bloc: context.read<ServicesBloc>(),
                       fetchAllFunction: (bloc) => bloc.add(LoadServicesEvent()),
                       searchFunction: (bloc, query) => bloc.add(LoadServicesEvent(search: query)),
                       validator: (value) {
                         if (value.isEmpty) {
                           return tr.required(tr.individuals);
                         }
                         return null;
                       },
                       itemBuilder: (context, ser) => Padding(
                         padding: const EdgeInsets.symmetric(
                           horizontal: 5,
                           vertical: 8,
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Expanded(
                                   child: Text(
                                     "${ser.srvName}",
                                     style: Theme.of(context).textTheme.bodyLarge,
                                   ),
                                 ),
                               ],
                             ),
                           ],
                         ),
                       ),
                       itemToString: (ser) => "${ser.srvName}",
                       stateToLoading: (state) => state is ServicesLoadingState,
                       loadingBuilder: (context) => const SizedBox(
                         width: 16,
                         height: 16,
                         child: CircularProgressIndicator(strokeWidth: 2),
                       ),
                       stateToItems: (state) {
                         if (state is ServicesLoadedState) {
                           return state.services;
                         }
                         return [];
                       },
                       onSelected: (value) {
                         setState(() {
                          serviceId = value.srvId;
                         });
                       },
                       noResultsText: tr.noDataFound,
                       showClearButton: true,
                     ),
                   ),
                   Expanded(
                     child: ZTextFieldEntitled(
                         isRequired: true,
                         validator: (value){
                           if(value.isEmpty){
                             return tr.required(tr.qty);
                           }
                           return null;
                         },
                         controller: qty,
                         title: tr.qty),
                   ),
                   Expanded(
                     child: ZTextFieldEntitled(
                         isRequired: true,
                         validator: (value){
                           if(value.isEmpty){
                             return tr.required(tr.qty);
                           }
                           return null;
                         },
                         controller: amount,
                         title: tr.amount),
                   ),
                 ],
               ),

               SizedBox(height: 12),
               Row(
                 children: [
                   ZOutlineButton(
                       onPressed: (){
                         Navigator.of(context).pop();
                       },
                       label: Text(tr.cancel.toUpperCase())),
                   SizedBox(width: 8),

                   ZOutlineButton(
                       onPressed: (){

                       },
                       isActive: true,
                       label: Text(tr.create.toUpperCase())),

                 ],
               )
              ],
            ),
          ),
          SizedBox(height: 8),
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
                  if(state.projectServices.isEmpty){
                    return NoDataWidget(
                      title: "No Services",
                      message: "Click Add Services to add a new",
                      enableAction: false,
                    );
                  }
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


  void onServicesSubmit(){
    if (!formKey.currentState!.validate()) return;
    final bloc = context.read<ProjectServicesBloc>();

    final data = ProjectServicesModel(
      prjId: widget.projectId, // Project ID
      pjdId: widget.projectId, // Project Services ID, the one supposed to be updated when it's clicked
      srvId: serviceId, // Service Id
      srvName: servicesController.text,
      pjdQuantity: double.tryParse(qty.text),
      pjdPricePerQty: double.tryParse(amount.text),
      usrName: loginData?.usrName
    );

    //To Add A new Service
    bloc.add(AddProjectServiceEvent(data));

    //To Update selected Service
    bloc.add(UpdateProjectServiceEvent(data));

  }
}
