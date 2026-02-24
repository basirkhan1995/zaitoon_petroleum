import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/toast.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Features/Widgets/status_badge.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/project_view.dart';
import 'add_project.dart';
import 'bloc/projects_bloc.dart';

class AllProjectsView extends StatelessWidget {
  const AllProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(), desktop: _Desktop(), tablet: _Tablet(),);
  }
}

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectsBloc>().add(LoadProjectsEvent());
    });
    super.initState();
  }

  Future<void> onRefresh()async{
    context.read<ProjectsBloc>().add(LoadProjectsEvent());
  }
  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    TextStyle? titleStyle = Theme.of(context).textTheme.titleMedium;
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(tr.projects),
        actionsPadding: EdgeInsets.symmetric(horizontal: 8),
        actions: [
          ZOutlineButton(
              isActive: true,
              icon: Icons.add,
              onPressed: (){
                showDialog(context: context, builder: (context){
                  return AddNewProjectView();
                });
              },
              label: Text(tr.newProject))
        ],
      ),
      body: BlocConsumer<ProjectsBloc, ProjectsState>(
        listener: (context,state){
         if(state is ProjectSuccessState){
           ToastManager.show(context: context, message: tr.successMessage, type: ToastType.success);
           Navigator.of(context);
         }if(state is ProjectsErrorState){
           ToastManager.show(context: context, message: state.message, type: ToastType.error);
         }
        },
        builder: (context, state) {
          if(state is ProjectsLoadingState){
            return Center(child: CircularProgressIndicator());
          }
          if(state is ProjectsErrorState){
            return NoDataWidget(
              title: "Error",
              message: state.message,
              onRefresh: onRefresh,
            );
          }if(state is ProjectsLoadedState){
            return ListView.builder(
                itemCount: state.pjr.length,
                itemBuilder: (context,index){
                final pjr = state.pjr[index];
                  return InkWell(
                    onTap: (){
                      showDialog(context: context, builder: (context){
                        return ProjectView(project: pjr);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        color: index.isOdd? color.primary.withValues(alpha: .05) : Colors.transparent
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
                              Text(pjr.prjName??"",style: titleStyle),
                              Text(pjr.prjDetails??"")
                            ],
                          ),
                        ),

                        SizedBox(
                            width: 100,
                            child: Text(pjr.prjDateLine.toFormattedDate())),
                        StatusBadge(status: pjr.prjStatus!, trueValue: tr.completedTitle, falseValue: tr.pendingTitle),
                      ],
                                      ),
                    ),
                  );
            });
          }
          return const SizedBox();
        },
      ),
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
