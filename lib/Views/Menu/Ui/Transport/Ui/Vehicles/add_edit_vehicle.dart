import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Auth/models/login_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Drivers/bloc/driver_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Drivers/model/driver_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/bloc/vehicle_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/features/fuel_type_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/features/ownership_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/features/vehicle_types_drop.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/model/vehicle_model.dart';
import '../../../../../../Features/Date/zdate_picker.dart';
import '../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../Features/Other/image_helper.dart';
import '../../../../../../Features/Other/thousand_separator.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';

class AddEditVehicleView extends StatelessWidget {
  final VehicleModel? model;
  const AddEditVehicleView({super.key, this.model});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(model),
      tablet: _Tablet(),
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
  final VehicleModel? model;
  const _Desktop(this.model);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  final vclModel = TextEditingController();
  final plateNo = TextEditingController();
  final vclYear = TextEditingController();
  final odometer = TextEditingController();
  final vclVinNo = TextEditingController();
  final vclEnginPower = TextEditingController();
  final vclRegNo = TextEditingController();
  final vclPurchaseAmount = TextEditingController();
  final driverCtrl = TextEditingController();
  final amount = TextEditingController();

  int? driverId;
  String? ownerShipValue;
  String? vehicleCategory;
  String? fuel;
  String vehicleExpireDateGregorian = DateTime.now().toFormattedDate();
  Jalali vehicleExpireDateShamsi = DateTime.now().toAfghanShamsi;

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    plateNo.dispose();
    vclYear.dispose();
    vclRegNo.dispose();
    vclEnginPower.dispose();
    vclModel.dispose();
    vclPurchaseAmount.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if(widget.model != null){
      final m = widget.model!;
      plateNo.text = m.vclPlateNo??"";
      driverCtrl.text = m.driver ??"";
      vclVinNo.text = m.vclVinNo ??"";
      vclPurchaseAmount.text = m.vclPurchaseAmount??"";
      driverId = m.driverId;
      vclYear.text = m.vclYear ??"";
      vclModel.text = m.vclModel??"";
      odometer.text = m.vclOdoMeter.toString();
      vclPurchaseAmount.text = m.vclPurchaseAmount?.toAmount()??"";
      vclEnginPower.text = m.vclEnginPower??"";
      vclRegNo.text = m.vclRegNo??"";
      fuel = m.vclFuelType ??"";
      vehicleCategory = m.vclBodyType ??"";
      ownerShipValue = m.vclOwnership;
    }
    super.initState();
  }

  LoginData? loginData;

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isEdit = widget.model != null;
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    loginData = state.loginData;

    return ZFormDialog(
      onAction: onSubmit,
      icon: Icons.fire_truck_rounded,
      title: isEdit ? tr.update : tr.newKeyword,
      actionLabel: (context.watch<VehicleBloc>().state is VehicleLoadingState)
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.surface,
              ),
            )
          : Text(isEdit ? tr.update : tr.create),

      child: BlocConsumer<VehicleBloc, VehicleState>(
        listener: (context, state) {
          if (state is VehicleSuccessState) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  spacing: 12,
                  children: [
                    ZTextFieldEntitled(
                      isRequired: true,
                      title: tr.vehicleModel,
                      controller: vclModel,
                      validator: (value) {
                        if (value.isEmpty) {
                          return tr.required(tr.vehicleModel);
                        }
                        return null;
                      },
                    ),

                    // Driver Selection
                    SizedBox(
                      width: double.infinity,
                      child:
                          GenericTextfield<DriverModel, DriverBloc, DriverState>(
                            controller: driverCtrl,
                            validator: (e){
                              return null;
                            },
                            title: tr.driver,
                            hintText: tr.driver,
                            bloc: context.read<DriverBloc>(),
                            fetchAllFunction: (bloc) =>
                                bloc.add(LoadDriverEvent()),
                            searchFunction: (bloc, query) =>
                                bloc.add(LoadDriverEvent()),
                            itemBuilder: (context, driver) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Row(
                                spacing: 8,
                                children: [
                                  ImageHelper.stakeholderProfile(
                                    imageName: driver.perPhoto,
                                    size: 35,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${driver.perfullName}",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            itemToString: (account) => "${account.perfullName}",
                            stateToLoading: (state) => state is DriverLoadingState,
                            loadingBuilder: (context) => const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 1),
                            ),
                            stateToItems: (state) {
                              if (state is DriverLoadedState) {
                                return state.drivers;
                              }
                              return [];
                            },
                            onSelected: (account) {
                              setState(() {
                                driverId = account.empId;
                              });
                            },
                            noResultsText: 'No driver found',
                            showClearButton: true,
                          ),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Expanded(
                          flex: 2,
                          child: ZTextFieldEntitled(
                            isRequired: true,
                            title: tr.vehiclePlate,
                            controller: plateNo,
                            validator: (value) {
                              if (value.isEmpty) {
                                return tr.required(tr.vehiclePlate);
                              }
                              return null;
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: ZTextFieldEntitled(
                            title: tr.meter,
                            controller: odometer,
                            inputFormat: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value.isEmpty) {
                                return tr.required(tr.meter);
                              }
                              return null;
                            },
                          ),
                        ),
                        Expanded(
                          child: ZTextFieldEntitled(
                            isRequired: true,
                            title: tr.manufacturedYear,
                            controller: vclYear,
                            inputFormat: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value.isEmpty) {
                                return tr.required(tr.manufacturedYear);
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    Row(
                      spacing: 5,
                      children: [
                        Expanded(
                          flex: 2,
                          child: ZTextFieldEntitled(
                            isRequired: true,
                            title: tr.vinNumber,
                            controller: vclVinNo,
                            validator: (value) {
                              if (value.isEmpty) {
                                return tr.required(tr.vehiclePlate);
                              }
                              return null;
                            },
                          ),
                        ),
                        Expanded(child: datePicker()),
                      ],
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        Expanded(child: FuelDropdown(onFuelSelected: (e) {
                          setState(() {
                            fuel = e.name;
                          });
                        })),
                        Expanded(
                          child: VehicleDropdown(onVehicleSelected: (e) {
                            setState(() {
                              vehicleCategory = e.name;
                            });
                          }),
                        ),
                        Expanded(
                          child: OwnershipDropdown(
                            selectedOwnership: VehicleOwnership.owned,
                            onOwnershipSelected: (e) {
                              setState(() {
                                ownerShipValue = e.name;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    ZTextFieldEntitled(
                      keyboardInputType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormat: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]*')),
                        SmartThousandsDecimalFormatter(),
                      ],

                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return tr.required(tr.amount);
                      //   }
                      //   return null;
                      // },

                      controller: amount,
                      title: tr.amount,
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Expanded(
                          child: ZTextFieldEntitled(
                            isRequired: true,
                            title: tr.enginePower,
                            controller: vclEnginPower,
                            validator: (value) {
                              if (value.isEmpty) {
                                return tr.required(tr.enginePower);
                              }
                              return null;
                            },
                          ),
                        ),
                        Expanded(
                          child: ZTextFieldEntitled(
                            isRequired: true,
                            title: tr.vclRegisteredNo,
                            controller: vclRegNo,
                            validator: (value) {
                              if (value.isEmpty) {
                                return tr.required(tr.vclRegisteredNo);
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        state is VehicleErrorState? Text(state.message,style: TextStyle(color: theme.colorScheme.error),) : SizedBox.shrink(),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget datePicker() {
    String vehicleExpireDateGregorian = DateTime.now().toFormattedDate();
    return GenericDatePicker(
      label: AppLocalizations.of(context)!.vclExpireDate,
      initialGregorianDate: vehicleExpireDateGregorian,
      onDateChanged: (newDate) {
        setState(() {
          vehicleExpireDateGregorian = newDate;
        });
      },
    );
  }

  void onSubmit() {
    if (!formKey.currentState!.validate()) return;
    final bloc = context.read<VehicleBloc>();
    final data = VehicleModel(
      usrName: loginData?.usrName,
      vclModel: vclModel.text,
      vclYear: vclYear.text,
      vclVinNo: vclVinNo.text,
      vclFuelType: fuel ?? AppLocalizations.of(context)!.petrol,
      vclEnginPower: vclEnginPower.text,
      vclBodyType: vehicleCategory ?? AppLocalizations.of(context)!.truck,
      vclRegNo: vclRegNo.text,
      vclExpireDate: DateTime.tryParse(vehicleExpireDateGregorian),
      vclPlateNo: plateNo.text,
      vclOdoMeter: int.tryParse(odometer.text),
      vclOwnership: ownerShipValue ?? AppLocalizations.of(context)!.owned,
      vclPurchaseAmount: amount.text.cleanAmount,
      driverId: driverId,
      vclStatus: 1,
      vclId: widget.model?.vclId,
    );

    if (widget.model == null) {
      bloc.add(AddVehicleEvent(data));
    } else {
      bloc.add(UpdateVehicleEvent(data));
    }
  }
}
