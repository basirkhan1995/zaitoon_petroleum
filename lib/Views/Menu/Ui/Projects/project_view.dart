import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/Ui/AllProjects/model/pjr_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Projects/project_tabs.dart';

class ProjectView extends StatelessWidget {
  final ProjectsModel project;
  const ProjectView({super.key,required this.project});

  @override
  Widget build(BuildContext context) {
    return ZFormDialog(
        width: MediaQuery.of(context).size.width *.5,
        onAction: null,
        isActionTrue: false,
        title: project.prjName??"",
        child: ProjectTabsView(project: project)
    );
  }
}
