import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/bloc/vehicle_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VehiclesView extends StatelessWidget {
  const VehiclesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(), desktop: _Desktop(), tablet: _Tablet(),);
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


class _Mobile extends StatelessWidget {
  const _Mobile();

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
  @override
  void initState() {
    context.read<VehicleBloc>().add(LoadVehicleEvent());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, state) {
            if(state is VehicleLoadingState){
              return Center(child: CircularProgressIndicator());
            }
            if(state is VehicleErrorState){
              return NoDataWidget(
                message: state.message,
                onRefresh: (){
                  context.read<VehicleBloc>().add(LoadVehicleEvent());
                },
              );
            }
            if(state is VehicleLoadedState){
              return ListView.builder(
                  itemCount: state.vehicles.length,
                  itemBuilder: (context,index){
                  return Row(
                    children: [

                    ],
                  );
              });
            }
            return const SizedBox();
          },
        )
    );
  }
}
