import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Drivers/bloc/driver_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Drivers/model/driver_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/features/fuel_type_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/features/ownership_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/features/vehicle_types_drop.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../../../Features/Date/gregorian_date_picker.dart';
import '../../../../../../Features/Date/shamsi_date_picker.dart';
import '../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../Features/Other/image_helper.dart';
import '../../../../../../Features/Other/thousand_separator.dart';

class AddEditVehicleView extends StatelessWidget {
  const AddEditVehicleView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), desktop: _Desktop(),tablet: _Tablet(),);
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
  final vclModel = TextEditingController();
  final plateNo = TextEditingController();
  final vclYear = TextEditingController();
  final odometer = TextEditingController();
  final vclVinNo = TextEditingController();
  final vclEnginPower = TextEditingController();
  final vclRegNo = TextEditingController();
  final vclOdoMeter = TextEditingController();
  final vclPurchaseAmount = TextEditingController();
  final driverCtrl = TextEditingController();
  final amount = TextEditingController();

  String ownerShipValue = "Owned";

  String vehicleExpireDateGregorian = DateTime.now().toFormattedDate();
  Jalali vehicleExpireDateShamsi = DateTime.now().toAfghanShamsi;

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
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return ZFormDialog(
        onAction: null,
        icon: Icons.fire_truck_rounded,
        title: tr.newKeyword,
        actionLabel: Text(tr.create),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              spacing: 12,
              children: [
                ZTextFieldEntitled(
                  isRequired: true,
                  title: tr.vehicleModel,
                  controller: vclModel,
                  validator: (value){
                    if(value.isEmpty){
                      return tr.required(tr.vehicleModel);
                    }
                    return null;
                  },
                ),
                // Driver Selection
                SizedBox(
                  width: double.infinity,
                  child: GenericTextfield<DriverModel, DriverBloc, DriverState>(
                    controller: driverCtrl,
                    title: tr.driver,
                    hintText: AppLocalizations.of(context)!.accounts,
                    isRequired: true,
                    bloc: context.read<DriverBloc>(),
                    fetchAllFunction: (bloc) => bloc.add(
                      LoadDriverEvent(),
                    ),
                    searchFunction: (bloc, query) => bloc.add(
                      LoadDriverEvent(
                      ),
                    ),
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
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    itemToString: (account) =>
                    "${account.perfullName}",
                    stateToLoading: (state) => state is DriverLoadingState,
                    loadingBuilder: (context) => const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 1),
                    ),
                    stateToItems: (state) {
                      if (state is DriverLoadedState) return state.drivers;
                      return [];
                    },
                    onSelected: (account) {

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
                          validator: (value){
                            if(value.isEmpty){
                              return tr.required(tr.vehiclePlate);
                            }
                            return null;
                          },
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ZTextFieldEntitled(
                        isRequired: true,
                        title: tr.meter,
                        controller: odometer,
                        hint: '5448665648',
                        inputFormat: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value){
                          if(value.isEmpty){
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
                        hint: 'e.g, 2025',
                        inputFormat: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value){
                          if(value.isEmpty){
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
                        validator: (value){
                          if(value.isEmpty){
                            return tr.required(tr.vehiclePlate);
                          }
                          return null;
                        },
                      ),
                    ),
                    Expanded(child: datePicker())
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(child: FuelDropdown(onFuelSelected: (e){})),
                    Expanded(child: VehicleDropdown(onVehicleSelected: (e){})),
                    Expanded(child: OwnershipDropdown(onOwnershipSelected: (e){
                      setState(() {
                        ownerShipValue = e.name;
                      });
                    })),
                  ],
                ),
                ZTextFieldEntitled(
                  isRequired: true,
                  keyboardInputType: TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormat: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9.,]*'),
                    ),
                    SmartThousandsDecimalFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr.required(tr.amount);
                    }

                    // Remove formatting (e.g. commas)
                    final clean = value.replaceAll(
                      RegExp(r'[^\d.]'),
                      '',
                    );
                    final amount = double.tryParse(clean);

                    if (amount == null || amount <= 0.0) {
                      return tr.amountGreaterZero;
                    }

                    return null;
                  },
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
                        validator: (value){
                          if(value.isEmpty){
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
                        validator: (value){
                          if(value.isEmpty){
                            return tr.required(tr.vclRegisteredNo);
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    );
  }
  Widget datePicker() {
    final locale = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    return Column(
      spacing: 4,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(locale.vclExpireDate, style: TextStyle(color: color.outline,fontSize: 12)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: color.outline.withValues(alpha: .4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 8,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //From Gregorian
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return GregorianDatePicker(
                            onDateSelected: (value) {
                              setState(() {
                                vehicleExpireDateGregorian = value.toFormattedDate();
                              });
                            },
                          );
                        },
                      );
                    },
                    child: Text(vehicleExpireDateGregorian, style: TextStyle(fontSize: 12)),
                  ),

                  //From Shamsi
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AfghanDatePicker(
                            onDateSelected: (value) {
                              setState(() {
                                vehicleExpireDateGregorian = value.toGregorianString();
                              });
                            },
                          );
                        },
                      );
                    },
                    child: Text(
                      vehicleExpireDateGregorian.shamsiDateFormatted,
                      style: TextStyle(
                        fontSize: 10,
                        color: color.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Icon(Icons.calendar_today_rounded, color: color.secondary),
            ],
          ),
        ),
      ],
    );
  }
}

