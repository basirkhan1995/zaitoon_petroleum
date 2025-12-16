import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../../../Features/Date/zdate_picker.dart';
import '../../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../../../Features/Other/thousand_separator.dart';
import '../../../../../../../../Features/Widgets/stepper.dart';
import '../../../../../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../../Stakeholders/Ui/Individuals/bloc/individuals_bloc.dart';
import '../../../../../Stakeholders/Ui/Individuals/individual_model.dart';
import '../../../Vehicles/bloc/vehicle_bloc.dart';
import '../../../Vehicles/model/vehicle_model.dart';
import '../../feature/unit_drop.dart';
import '../ShippingView/bloc/shipping_bloc.dart';
import '../ShippingView/model/shipping_model.dart';
import '../ShippingView/model/shp_details_model.dart';
import 'package:shamsi_date/shamsi_date.dart';

class ShippingScreen extends StatelessWidget {
  final int? shippingId;

  const ShippingScreen({super.key, this.shippingId});

  @override
  Widget build(BuildContext context) {
    // Use the existing bloc from parent context
    return ResponsiveLayout(
      mobile: _Mobile(shippingId: shippingId),
      desktop: _Desktop(shippingId: shippingId),
      tablet: _Tablet(shippingId: shippingId),
    );
  }
}

class _Desktop extends StatefulWidget {
  final int? shippingId;
  const _Desktop({this.shippingId});

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  @override
  void initState() {
    super.initState();
    if (widget.shippingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Use context.read directly since bloc is already available from parent
        context.read<ShippingBloc>().add(
          LoadShippingDetailEvent(widget.shippingId!),
        );
      });
    }
  }

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
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = state.loginData;
    usrName = login.usrName??"";

    return BlocConsumer<ShippingBloc, ShippingState>(
      listener: (context, state) {
        if (state is ShippingSuccessState) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        if (state is ShippingDetailLoadingState) {
          return _buildLoadingDialog();
        }

        if (state is ShippingErrorState) {
          return _buildErrorDialog(state.error, context);
        }

        if (state is ShippingDetailLoadedState) {
          return _buildStepperWithData(state, tr, context);
        }

        // Default: new shipping
        return _buildNewShippingStepper(tr, context);
      },
    );
  }

  Widget _advancePayment(){
    final tr = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ZTextFieldEntitled(
            keyboardInputType: TextInputType.numberWithOptions(
              decimal: true,
            ),
            inputFormat: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[0-9.,]*'),
              ),
              SmartThousandsDecimalFormatter(),
            ],
            controller: advanceAmount,
            title: tr.advanceAmount,
          ),
        ],
      ),
    );
  }
  Widget _order(){
    final tr = AppLocalizations.of(context)!;
    return SingleChildScrollView(
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
                title: tr.customer,
                hintText: tr.customer,
                isRequired: true,
                bloc: context.read<IndividualsBloc>(),
                fetchAllFunction: (bloc) => bloc.add(LoadIndividualsEvent()),
                searchFunction: (bloc, query) => bloc.add(LoadIndividualsEvent()),
                validator: (value) {
                  if (value.isEmpty) {
                    return tr.required(tr.customer);
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
                itemToString: (acc) =>
                "${acc.perName} ${acc.perLastName}",
                stateToLoading: (state) =>
                state is IndividualLoadingState,
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

              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: ZTextFieldEntitled(
                      controller: productId,
                      title: tr.products,
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
  Widget _shipping(){
    final tr = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(
            spacing: 13,
            children: [
              GenericTextfield<VehicleModel, VehicleBloc, VehicleState>(
                showAllOnFocus: true,
                controller: vehicleCtrl,
                title: tr.vehicles,
                hintText: tr.vehicles,
                isRequired: true,
                bloc: context.read<VehicleBloc>(),
                fetchAllFunction: (bloc) => bloc.add(LoadVehicleEvent()),
                searchFunction: (bloc, query) =>
                    bloc.add(LoadVehicleEvent()),
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
                itemToString: (veh) =>
                "${veh.vclModel} | ${veh.vclPlateNo}",
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
                spacing: 5,
                children: [
                  Expanded(
                    child: ZTextFieldEntitled(
                      controller: shpFrom,
                      title: tr.shpFrom,
                      validator: (value) {
                        if (value.isEmpty) {
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
                      validator: (value) {
                        if (value.isEmpty) {
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
                  Expanded(
                    child: UnitDropdown(
                      onUnitSelected: (e) {
                        setState(() {
                          unit = e.name;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 5,
                children: [
                  Expanded(
                    child: ZTextFieldEntitled(
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
                          return tr.required(tr.shippingRent);
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
                      controller: shippingRent,
                      title: tr.shippingRent,
                    ),
                  ),

                ],
              ),
              ZTextFieldEntitled(controller: remark, title: tr.remark,keyboardInputType: TextInputType.multiline,),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildLoadingDialog() {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Loading shipping details'),
        ],
      ),
    );
  }
  Widget _buildErrorDialog(String error, BuildContext context) {
    return AlertDialog(
      content: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStepperWithData(ShippingDetailLoadedState state, AppLocalizations tr, BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width * .6,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: CustomStepper(
            steps: [
              StepItem(
                title: tr.order,
                content: _order(),
                icon: Icons.shopping_cart,
              ),
              StepItem(
                title: tr.shipping,
                content: _shipping(),
                icon: Icons.local_shipping,
              ),
              StepItem(
                title: tr.expense,
                content: _buildExpensesView(state.currentShipping!),
                icon: Icons.data_exploration,
              ),
              StepItem(
                title: tr.income,
                content: _buildIncomeView(state.currentShipping!),
                icon: Icons.data_exploration,
              ),
              StepItem(
                title: 'Delivered',
                content: _buildDeliveryView(state.currentShipping!),
                icon: Icons.check_circle,
              ),
            ],
            onFinish: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
  Widget _buildNewShippingStepper(AppLocalizations tr, BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8)
      ),
      contentPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width * .6,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: CustomStepper(
            steps: [
              StepItem(
                title: tr.order,
                content: _order(),
                icon: Icons.shopping_cart,
              ),
              StepItem(
                title: tr.shipping,
                content: _shipping(),
                icon: Icons.local_shipping,
              ),
              StepItem(
                title: tr.advancePayment,
                content: _advancePayment(),
                icon: Icons.attach_money_outlined,
              ),
              StepItem(
                title: 'Delivered',
                content: const Text('Delivered confirmation'),
                icon: Icons.check_circle,
              ),
            ],
            onFinish: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
  Widget _buildIncomeView(ShippingDetailsModel shipping) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.income,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (shipping.income != null && shipping.income!.isNotEmpty)
            ...shipping.income!.map((income) => Cover(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                leading: const Icon(Icons.attach_money, color: Colors.green),
                title: Text(income.accName ?? ''),
                subtitle: Text(income.narration ?? ''),
                trailing: Text(
                  '${income.amount?.toAmount()} ${income.currency}',
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ))
          else
            const Text('No income yet'),
        ],
      ),
    );
  }
  Widget _buildExpensesView(ShippingDetailsModel shipping) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.expense,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            if (shipping.expenses != null && shipping.expenses!.isNotEmpty)
              ...shipping.expenses!.map((expense) => Cover(
                child: ListTile(
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  title: Text(expense.accName ?? ''),
                  subtitle: Text(expense.narration ?? ''),
                  trailing: Text(
                    '${expense.amount?.toAmount()} ${expense.currency}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ))
            else
              Text(AppLocalizations.of(context)!.noExpenseRecorded),
          ],
        ),
      ),
    );
  }
  Widget _buildDeliveryView(ShippingDetailsModel shipping) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            shipping.shpStatus == 1 ? Icons.check_circle : Icons.schedule,
            size: 60,
            color: shipping.shpStatus == 1 ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            shipping.shpStatus == 1 ? 'Delivered' : 'Pending',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Shipping Status: ${shipping.shpStatus == 1 ? "Completed" : "In Progress"}'),
        ],
      ),
    );
  }
  ShippingModel _convertToShippingModel(ShippingDetailsModel details) {
    return ShippingModel(
      shpId: details.shpId,
      vehicle: details.vehicle,
      vehicleId: details.vclId,
      proName: details.proName,
      productId: details.proId,
      customer: details.customer,
      shpFrom: details.shpFrom,
      shpMovingDate: details.shpMovingDate,
      shpLoadSize: details.shpLoadSize,
      shpUnit: details.shpUnit,
      shpTo: details.shpTo,
      shpArriveDate: details.shpArriveDate,
      shpUnloadSize: details.shpUnloadSize,
      shpRent: details.shpRent,
      total: details.total,
      shpStatus: details.shpStatus,
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
}

// Mobile and Tablet remain as Placeholder
class _Mobile extends StatelessWidget {
  final int? shippingId;
  const _Mobile({this.shippingId});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Tablet extends StatelessWidget {
  final int? shippingId;
  const _Tablet({this.shippingId});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}