import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import '../../../Users/model/user_model.dart';
import 'bloc/permissions_bloc.dart';

class PermissionsView extends StatelessWidget {
  final UsersModel user;
  const PermissionsView({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(user),
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
  final UsersModel user;
  const _Desktop(this.user);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  @override
  void initState() {
    context.read<PermissionsBloc>().add(LoadPermissionsEvent(widget.user.usrName??""));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.user.usrName??"")),
      body: BlocBuilder<PermissionsBloc, PermissionsState>(
        builder: (context, state) {
          if(state is PermissionsErrorState){
            return Center(child: Text(state.message));
          }
          if(state is PermissionsLoadingState){
            return Center(
              child: CircularProgressIndicator(
                color: color.primary,
              ),
            );
          }
          if(state is PermissionsLoadedState){
            return ListView.builder(
                itemCount: state.permissions.length,
                itemBuilder: (context,index){
                  final per = state.permissions[index];
               return ListTile(
                 leading: Checkbox(
                     value: per.uprStatus == 1,
                     onChanged: (value){
                       context.read<PermissionsBloc>().add(UpdatePermissionsStatusEvent(
                           uprStatus: value ?? false,
                           usrId: widget.user.usrId!,
                           uprRole: per.uprRole!,
                           usrName: widget.user.usrName!));
                     }),
                 title: Text(per.rsgName??""),
               );
            });
          }
          return const SizedBox();
        },
      ),
    );
  }
}
