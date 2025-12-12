import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Shipping/bloc/shipping_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Shipping/feature/unit_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Shipping/model/shipping_model.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/bloc/vehicle_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Vehicles/model/vehicle_model.dart';
import '../../../../../../../Features/Date/zdate_picker.dart';
import '../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../../Features/Other/thousand_separator.dart';
import '../../../../Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import '../../../../Stakeholders/Ui/Individuals/individual_model.dart';

class AddEditShippingView extends StatelessWidget {
  final ShippingModel? model;
  const AddEditShippingView({super.key, this.model});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(model),
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
  final ShippingModel? model;
  const _Desktop(this.model);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  final productId = TextEditingController();
  final shpFrom = TextEditingController();
  final shpTo = TextEditingController();
  final shippingRent = TextEditingController();
  final loadingSize = TextEditingController();
  final unloadingSize = TextEditingController();
  final customerCtrl = TextEditingController();
  final vehicleCtrl = TextEditingController();
  final remark = TextEditingController();
  final advanceAmount = TextEditingController();

  String shpFromGregorian = DateTime.now().toFormattedDate();
  Jalali shpFromShamsi = DateTime.now().toAfghanShamsi;

  String? usrName;
  String shpToGregorian = DateTime.now().toFormattedDate();
  Jalali shpToShamsi = DateTime.now().toAfghanShamsi;

  final formKey = GlobalKey<FormState>();

  int? customerId;
  int? vehicleId;
  String? unit;
  @override
  void dispose() {
    shippingRent.dispose();
    loadingSize.dispose();
    unloadingSize.dispose();
    customerCtrl.dispose();
    shpFrom.dispose();
    shpTo.dispose();
    vehicleCtrl.dispose();
    productId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    return BlocBuilder<ShippingBloc, ShippingState>(
      builder: (context, state) {
        return ZFormDialog(
          onAction: onSubmit,
          title: tr.newKeyword,
          actionLabel: state is ShippingLoadingState
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(color: color.surface),
                )
              : Text(tr.create),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                child: Column(
                  spacing: 13,
                  children: [
                    GenericTextfield<IndividualsModel, IndividualsBloc, IndividualsState>(
                      showAllOnFocus: true,
                      controller: customerCtrl,
                      title: tr.individuals,
                      hintText: tr.individuals,
                      isRequired: true,
                      bloc: context.read<IndividualsBloc>(),
                      fetchAllFunction: (bloc) => bloc.add(LoadIndividualsEvent()),
                      searchFunction: (bloc, query) => bloc.add(LoadIndividualsEvent()),
                      validator: (value) {
                        if (value.isEmpty) {
                          return tr.required(tr.individuals);
                        }
                        return null;
                      },
                      itemBuilder: (context, account) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${account.perName} ${account.perLastName}",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      itemToString: (acc) => "${acc.perName} ${acc.perLastName}",
                      stateToLoading: (state) => state is IndividualLoadingState,
                      loadingBuilder: (context) => const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      stateToItems: (state) {
                        if (state is IndividualLoadedState) {
                          return state.individuals;
                        }
                        return [];
                      },
                      onSelected: (value) {
                        setState(() {
                          customerId = value.perId!;
                        });
                      },
                      noResultsText: tr.noDataFound,
                      showClearButton: true,
                    ),
                    GenericTextfield<VehicleModel, VehicleBloc, VehicleState>(
                      showAllOnFocus: true,
                      controller: vehicleCtrl,
                      title: tr.vehicles,
                      hintText: tr.vehicles,
                      isRequired: true,
                      bloc: context.read<VehicleBloc>(),
                      fetchAllFunction: (bloc) => bloc.add(LoadVehicleEvent()),
                      searchFunction: (bloc, query) => bloc.add(LoadVehicleEvent()),
                      validator: (value) {
                        if (value.isEmpty) {
                          return tr.required(tr.vehicle);
                        }
                        return null;
                      },
                      itemBuilder: (context, veh) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${veh.vclModel} | ${veh.vclPlateNo}",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      itemToString: (veh) => "${veh.vclModel} | ${veh.vclPlateNo}",
                      stateToLoading: (state) => state is VehicleLoadingState,
                      loadingBuilder: (context) => const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      stateToItems: (state) {
                        if (state is VehicleLoadedState) {
                          return state.vehicles;
                        }
                        return [];
                      },
                      onSelected: (value) {
                        setState(() {
                          vehicleId = value.vclId!;
                        });
                      },
                      noResultsText: tr.noDataFound,
                      showClearButton: true,
                    ),

                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: ZTextFieldEntitled(
                            controller: productId,
                            title: tr.products,
                          ),
                        ),

                        Expanded(child: UnitDropdown(
                            onUnitSelected: (e){
                              setState(() {
                                unit = e.name;
                              });
                            })),
                      ],
                    ),

                    Row(
                      spacing: 5,
                      children: [
                        Expanded(
                          child: ZTextFieldEntitled(
                            controller: shpFrom,
                            title: tr.shpFrom,
                            validator: (value){
                              if(value.isEmpty){
                                return tr.required(tr.shpFrom);
                              }
                              return null;
                            },
                          ),
                        ),
                        Expanded(
                          child: ZTextFieldEntitled(
                            controller: shpTo,
                            title: tr.shpTo,
                            validator: (value){
                              if(value.isEmpty){
                                return tr.required(tr.shpTo);
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: datePicker(
                            date: shpFromGregorian,
                            title: tr.loadingDate,
                          ),
                        ),
                        Expanded(
                          child: datePicker(
                            date: shpToGregorian,
                            title: tr.unloadingDate,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Expanded(
                          child: ZTextFieldEntitled(
                            controller: loadingSize,
                            title: tr.loadingSize,
                          ),
                        ),
                        Expanded(
                          child: ZTextFieldEntitled(
                            controller: unloadingSize,
                            title: tr.unloadingSize,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: ZTextFieldEntitled(
                            isRequired: true,
                            keyboardInputType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormat: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]*')),
                              SmartThousandsDecimalFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return tr.required(tr.shippingRent);
                              }

                              // Remove formatting (e.g. commas)
                              final clean = value.replaceAll(RegExp(r'[^\d.]'), '');
                              final amount = double.tryParse(clean);

                              if (amount == null || amount <= 0.0) {
                                return tr.amountGreaterZero;
                              }

                              return null;
                            },
                            controller: shippingRent,
                            title: tr.shippingRent,
                          ),
                        ),
                        Expanded(
                          child: ZTextFieldEntitled(
                            isRequired: true,
                            keyboardInputType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormat: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]*')),
                              SmartThousandsDecimalFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return tr.required(tr.advanceAmount);
                              }

                              // Remove formatting (e.g. commas)
                              final clean = value.replaceAll(RegExp(r'[^\d.]'), '');
                              final amount = double.tryParse(clean);

                              if (amount == null || amount <= 0.0) {
                                return tr.amountGreaterZero;
                              }

                              return null;
                            },
                            controller: advanceAmount,
                            title: tr.advanceAmount,
                          ),
                        ),
                      ],
                    ),
                    ZTextFieldEntitled(
                      controller: remark,
                      title: tr.remark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget datePicker({required String date, required String title}) {
    return GenericDatePicker(
      label: title,
      initialGregorianDate: date,
      onDateChanged: (newDate) {
        setState(() {
          date = newDate;
        });
      },
    );
  }

  void onSubmit() {
    if (!formKey.currentState!.validate()) return;
    final data = ShippingModel(
      shpLoadSize: loadingSize.text,
      shpUnloadSize: unloadingSize.text,
      shpTo: shpTo.text,
      shpFrom: shpFrom.text,
      shpRent: shippingRent.text.cleanAmount,
      productId: int.tryParse(productId.text),
      vehicleId: int.tryParse(vehicleCtrl.text),
      customerId: customerId,
      shpArriveDate: DateTime.tryParse(shpToGregorian),
      shpMovingDate: DateTime.tryParse(shpFromGregorian),
      usrName: usrName ?? "victus",
      advanceAmount: advanceAmount.text.cleanAmount,
      remark: remark.text,
      shpId: widget.model?.shpId,
      shpUnit: unit ?? "TN",
    );
    final bloc = context.read<ShippingBloc>();
    if (widget.model == null) {
      bloc.add(AddShippingEvent(data));
    } else {
      bloc.add(UpdateShippingEvent(data));
    }
  }
}
