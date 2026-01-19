import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../Features/Generic/zaitoon_drop.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../bloc/vehicle_bloc.dart';
import '../model/vehicle_model.dart';

class VehicleDropdown extends StatefulWidget {
  final ValueChanged<VehicleModel?>? onSingleChanged;
  final ValueChanged<List<VehicleModel>>? onMultiChanged;
  final String? initialValue;
  final bool isMulti;
  final int? initialVehicleId;

  const VehicleDropdown({
    super.key,
    this.onSingleChanged,
    this.initialValue,
    this.onMultiChanged,
    this.isMulti = false,
    this.initialVehicleId,
  });

  @override
  State<VehicleDropdown> createState() => _VehicleDropdownState();
}

class _VehicleDropdownState extends State<VehicleDropdown> {
  VehicleModel? _selectedSingle;
  List<VehicleModel> _selectedMulti = [];

  @override
  void initState() {
    super.initState();

    context.read<VehicleBloc>().add(const LoadVehicleEvent());

    if (!widget.isMulti && widget.initialVehicleId != null) {
      final state = context.read<VehicleBloc>().state;
      if (state is VehicleLoadedState) {
        _selectedSingle = state.vehicles
            .where((v) => v.vclId == widget.initialVehicleId)
            .firstOrNull;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        if (state is VehicleErrorState) {
          return Text(state.message);
        }

        final vehicles =
        state is VehicleLoadedState ? state.vehicles : <VehicleModel>[];

        return ZDropdown<VehicleModel>(
          title: AppLocalizations.of(context)!.vehicle,
          items: vehicles,
          initialValue: widget.initialValue ?? AppLocalizations.of(context)!.all,
          multiSelect: widget.isMulti,
          isLoading:  state is VehicleLoadingState,
          selectedItem: widget.isMulti ? null : _selectedSingle,
          selectedItems: widget.isMulti ? _selectedMulti : [],

          itemLabel: _vehicleLabel,

          onItemSelected: widget.isMulti
              ? (_) {}
              : (v) {
            _selectedSingle = v;
            widget.onSingleChanged?.call(v);
            setState(() {});
          },

          onMultiSelectChanged: widget.isMulti
              ? (list) {
            _selectedMulti = list;
            widget.onMultiChanged?.call(list);
            setState(() {});
          }
              : null,
        );
      },
    );
  }
  String _vehicleLabel(VehicleModel v) {
    final model = v.vclModel ?? '';
    final plate = v.vclPlateNo ?? '';
    final year = v.vclYear ?? '';

    if (model.isEmpty && plate.isEmpty) {
      return 'Vehicle ${v.vclId}';
    }

    return [
      model,
      if (year.isNotEmpty) '($year)',
      if (plate.isNotEmpty) '- $plate',
    ].join(' ');
  }
}
