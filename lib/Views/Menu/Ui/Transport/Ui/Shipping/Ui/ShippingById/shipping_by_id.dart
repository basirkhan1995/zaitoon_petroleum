import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/alert_dialog.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/Bloc/localizations_bloc.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Accounts/model/acc_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Products/bloc/products_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Products/model/product_model.dart';
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

class ShippingByIdView extends StatelessWidget {
  final int? shippingId;

  const ShippingByIdView({super.key, this.shippingId});
  @override
  Widget build(BuildContext context) {
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
  // Form controllers
  final shpFrom = TextEditingController();
  final shpTo = TextEditingController();
  final shippingRent = TextEditingController();
  final loadingSize = TextEditingController();
  final unloadingSize = TextEditingController();
  final customerCtrl = TextEditingController();
  final vehicleCtrl = TextEditingController();
  final productCtrl = TextEditingController();
  final remark = TextEditingController();
  final advanceAmount = TextEditingController();
  final accountController = TextEditingController();
  final expenseAmount = TextEditingController();
  final expenseNarration = TextEditingController();

  int? expenseAccNumber;
  String? currentLocale;
  int? customerId;
  int? productId;
  int? vehicleId;
  String? unit;

  // Date variables
  String shpFromGregorian = DateTime.now().toFormattedDate();
  String shpToGregorian = DateTime.now().toFormattedDate();

  String? usrName;

  // Form keys for each step
  final GlobalKey<FormState> orderFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> shippingFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> advanceFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> expenseFormKey = GlobalKey<FormState>();

  ShippingExpenseModel? _selectedExpenseForEdit;

  // Add current step tracking
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentLocale = context.read<LocalizationBloc>().state.languageCode;
      if (widget.shippingId != null) {
        context.read<ShippingBloc>().add(LoadShippingDetailEvent(widget.shippingId!));
      }
    });
  }

  // Method to prefill form with shipping data
  void _prefillForm(ShippingDetailsModel shipping) {
    // Clear all controllers first
    _clearAllControllers();

    // Customer information
    if (shipping.customer != null && shipping.customer!.isNotEmpty) {
      customerCtrl.text = shipping.customer!;
    }

    // Product information
    if (shipping.proName != null && shipping.proName!.isNotEmpty) {
      productCtrl.text = shipping.proName!;
    }

    // Vehicle information
    if (shipping.vehicle != null && shipping.vehicle!.isNotEmpty) {
      vehicleCtrl.text = shipping.vehicle!;
    }

    // Location information
    if (shipping.shpFrom != null && shipping.shpFrom!.isNotEmpty) {
      shpFrom.text = shipping.shpFrom!;
    }

    if (shipping.shpTo != null && shipping.shpTo!.isNotEmpty) {
      shpTo.text = shipping.shpTo!;
    }

    // Date information
    if (shipping.shpMovingDate != null) {
      shpFromGregorian = shipping.shpMovingDate!.toFormattedDate();
    }

    if (shipping.shpArriveDate != null) {
      shpToGregorian = shipping.shpArriveDate!.toFormattedDate();
    }

    // Size information
    if (shipping.shpLoadSize != null && shipping.shpLoadSize!.isNotEmpty) {
      loadingSize.text = shipping.shpLoadSize!;
    }

    if (shipping.shpUnloadSize != null && shipping.shpUnloadSize!.isNotEmpty) {
      unloadingSize.text = shipping.shpUnloadSize!;
    }

    // Unit
    if (shipping.shpUnit != null && shipping.shpUnit!.isNotEmpty) {
      unit = shipping.shpUnit;
    }

    // Rent
    if (shipping.shpRent != null && shipping.shpRent!.isNotEmpty) {
      shippingRent.text = shipping.shpRent!;
    }

    // Set IDs from the response
    if (shipping.vclId != null) {
      vehicleId = shipping.vclId;
    }

    if (shipping.proId != null) {
      productId = shipping.proId;
    }

    // Update state to reflect changes
    if (mounted) {
      setState(() {});
    }
  }

  // Method to clear all controllers
  void _clearAllControllers() {
    productCtrl.clear();
    shpFrom.clear();
    shpTo.clear();
    shippingRent.clear();
    loadingSize.clear();
    unloadingSize.clear();
    customerCtrl.clear();
    vehicleCtrl.clear();
    remark.clear();
    advanceAmount.clear();
    accountController.clear();
    expenseAmount.clear();
    expenseNarration.clear();

    customerId = null;
    vehicleId = null;
    productId = null;
    unit = null;
    expenseAccNumber = null;
    _selectedExpenseForEdit = null;
  }

  @override
  void dispose() {
    // Dispose all controllers
    productCtrl.dispose();
    shpFrom.dispose();
    shpTo.dispose();
    shippingRent.dispose();
    loadingSize.dispose();
    unloadingSize.dispose();
    customerCtrl.dispose();
    vehicleCtrl.dispose();
    remark.dispose();
    advanceAmount.dispose();
    accountController.dispose();
    expenseAmount.dispose();
    expenseNarration.dispose();
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
    usrName = login.usrName ?? "";

    return BlocConsumer<ShippingBloc, ShippingState>(
      listener: (context, state) {
        if (state is ShippingSuccessState) {
          if (state.message.contains('Shipping')) {
            // Shipping added/updated successfully
            // Close the dialog after successful submission
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
            });
          }
          // Clear expense form after success
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _clearExpenseForm();
            setState(() {
              _selectedExpenseForEdit = null;
            });
          });
        }

        // Prefill form when shipping details are loaded
        if (state is ShippingDetailLoadedState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _prefillForm(state.currentShipping!);
          });
        }

        if (state is ShippingErrorState) {
          Utils.showOverlayMessage(context, message: state.error, isError: true);
        }
      },
      builder: (context, blocState) {
        // Get current shipping from any state
        ShippingDetailsModel? currentShipping;

        if (blocState is ShippingDetailLoadingState) {
          return _buildLoadingContent();
        }

        if (blocState is ShippingErrorState) {
          return _buildErrorContent(blocState.error, context);
        }

        // Extract shipping from various states
        if (blocState is ShippingDetailLoadedState) {
          currentShipping = blocState.currentShipping;
        } else if (blocState is ShippingSuccessState && blocState.currentShipping != null) {
          currentShipping = blocState.currentShipping;
        } else if (blocState is ShippingListLoadedState && blocState.currentShipping != null) {
          currentShipping = blocState.currentShipping;
        }

        // If we have shipping details, show the stepper with data
        if (currentShipping != null) {
          return _buildStepperWithData(currentShipping, tr, context);
        }

        // Default: new shipping
        return _buildNewShippingStepper(tr, context);
      },
    );
  }

  Widget _advancePayment() {
    final tr = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: advanceFormKey,
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
        ),
      ),
    );
  }

  Widget _order() {
    final tr = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: orderFormKey,
          child: Column(
            children: [
              const SizedBox(height: 13),
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
                  if (value == null || value.isEmpty) {
                    return tr.required(tr.customer);
                  }
                  if (customerId == null) {
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
                    customerCtrl.text = "${value.perName} ${value.perLastName}";
                  });
                  // Trigger validation
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    orderFormKey.currentState?.validate();
                  });
                },
                noResultsText: tr.noDataFound,
                showClearButton: true,
              ),
              const SizedBox(height: 13),
              GenericTextfield<ProductsModel, ProductsBloc, ProductsState>(
                showAllOnFocus: true,
                controller: productCtrl,
                title: tr.products,
                hintText: tr.products,
                isRequired: true,
                bloc: context.read<ProductsBloc>(),
                fetchAllFunction: (bloc) => bloc.add(LoadProductsEvent()),
                searchFunction: (bloc, query) => bloc.add(LoadProductsEvent()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr.required(tr.products);
                  }
                  if (productId == null) {
                    return tr.required(tr.products);
                  }
                  return null;
                },
                itemBuilder: (context, product) => Padding(
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
                            product.proName??"",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                itemToString: (product) => product.proName??"",
                stateToLoading: (state) => state is ProductsLoadingState,
                loadingBuilder: (context) => const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                stateToItems: (state) {
                  if (state is ProductsLoadedState) {
                    return state.products;
                  }
                  return [];
                },
                onSelected: (value) {
                  setState(() {
                    productId = value.proId!;
                    productCtrl.text = value.proName??"";
                  });
                  // Trigger validation
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    orderFormKey.currentState?.validate();
                  });
                },
                noResultsText: tr.noDataFound,
                showClearButton: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shipping() {
    final tr = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: shippingFormKey,
          child: Column(
            children: [
              const SizedBox(height: 13),
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
                  if (value == null || value.isEmpty) {
                    return tr.required(tr.vehicle);
                  }
                  if (vehicleId == null) {
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
                    vehicleCtrl.text = "${value.vclModel} | ${value.vclPlateNo}";
                  });
                  // Trigger validation
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    shippingFormKey.currentState?.validate();
                  });
                },
                noResultsText: tr.noDataFound,
                showClearButton: true,
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: ZTextFieldEntitled(
                      controller: shpFrom,
                      title: tr.shpFrom,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return tr.required(tr.shpFrom);
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: ZTextFieldEntitled(
                      controller: shpTo,
                      title: tr.shpTo,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return tr.required(tr.shpTo);
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: _datePicker(
                      date: shpFromGregorian,
                      title: tr.loadingDate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _datePicker(
                      date: shpToGregorian,
                      title: tr.unloadingDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: ZTextFieldEntitled(
                      controller: loadingSize,
                      title: tr.loadingSize,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return tr.required(tr.loadingSize);
                        }

                        // Convert to number and check if valid
                        final clean = value.replaceAll(RegExp(r'[^\d.]'), '');
                        final amount = double.tryParse(clean);

                        if (amount == null || amount <= 0) {
                          return tr.amountGreaterZero;
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: ZTextFieldEntitled(
                      controller: unloadingSize,
                      title: tr.unloadingSize,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return tr.required(tr.unloadingSize);
                        }

                        // Convert to number and check if valid
                        final clean = value.replaceAll(RegExp(r'[^\d.]'), '');
                        final amount = double.tryParse(clean);

                        if (amount == null || amount <= 0) {
                          return tr.amountGreaterZero;
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
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
              const SizedBox(height: 13),
              Row(
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
              const SizedBox(height: 13),
              ZTextFieldEntitled(
                controller: remark,
                title: tr.remark,
                keyboardInputType: TextInputType.multiline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text('Loading shipping details...'),
        ],
      ),
    );
  }

  Widget _buildErrorContent(String error, BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperWithData(ShippingDetailsModel shipping, AppLocalizations tr, BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
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
                content: _buildExpensesView(shipping),
                icon: Icons.data_exploration,
              ),
              StepItem(
                title: tr.income,
                content: _buildIncomeView(shipping),
                icon: Icons.data_exploration,
              ),
              StepItem(
                title: 'Summary',
                content: _buildSummaryView(shipping),
                icon: Icons.summarize,
              ),
            ],
            onFinish: onSubmit,
            // Add this callback for step change validation
            onStepChanged: (newStep) {
              // Validate BEFORE moving forward
              if (newStep > _currentStep) {
                if (_currentStep == 0 && !_validateOrderStep()) {
                  return false;
                }
                if (_currentStep == 1 && !_validateShippingStep()) {
                  return false;
                }
              }

              setState(() {
                _currentStep = newStep;
              });

              return true;
            },

          ),
        ),
      ),
    );
  }

  Widget _buildNewShippingStepper(AppLocalizations tr, BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
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
                title: 'Summary',
                content: _buildSummaryView(null),
                icon: Icons.summarize,
              ),
            ],
            onFinish: onSubmit,
            // Add this callback for step change validation
            onStepChanged: (newStep) {
              // Validate BEFORE moving forward
              if (newStep > _currentStep) {
                if (_currentStep == 0 && !_validateOrderStep()) {
                  return false;
                }
                if (_currentStep == 1 && !_validateShippingStep()) {
                  return false;
                }
              }

              setState(() {
                _currentStep = newStep;
              });

              return true;
            },

          ),
        ),
      ),
    );
  }

  bool _validateOrderStep() {
    if (orderFormKey.currentState == null) return false;

    final isValid = orderFormKey.currentState!.validate();
    if (!isValid) {
      Utils.showOverlayMessage(
          context,
          message: "Please fill all required fields in Order step",
          isError: true
      );
    }
    return isValid;
  }

  bool _validateShippingStep() {
    if (shippingFormKey.currentState == null) return false;

    final isValid = shippingFormKey.currentState!.validate();
    if (!isValid) {
      Utils.showOverlayMessage(
          context,
          message: "Please fill all required fields in Shipping step",
          isError: true
      );
    }
    return isValid;
  }

  void onSubmit() {
    print('onSubmit called!');
    print('Current step: $_currentStep');

    // Skip form validation in onSubmit since we already validated when moving steps
    // Just check required IDs and fields
    if (customerId == null) {
      Utils.showOverlayMessage(
          context,
          message: "Please select a customer",
          isError: true
      );
      setState(() {
        _currentStep = 0;
      });
      return;
    }

    if (productId == null) {
      Utils.showOverlayMessage(
          context,
          message: "Please select a product",
          isError: true
      );
      setState(() {
        _currentStep = 0;
      });
      return;
    }

    if (vehicleId == null) {
      Utils.showOverlayMessage(
          context,
          message: "Please select a vehicle",
          isError: true
      );
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    // Validate required fields from shipping step
    if (shpFrom.text.isEmpty || shpTo.text.isEmpty) {
      Utils.showOverlayMessage(
          context,
          message: "Please fill in shipping locations",
          isError: true
      );
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    if (loadingSize.text.isEmpty || unloadingSize.text.isEmpty) {
      Utils.showOverlayMessage(
          context,
          message: "Please fill in loading/unloading sizes",
          isError: true
      );
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    if (shippingRent.text.isEmpty) {
      Utils.showOverlayMessage(
          context,
          message: "Please enter shipping rent",
          isError: true
      );
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    // Validate shipping rent amount
    final cleanRent = shippingRent.text.cleanAmount;
    final rentValue = double.tryParse(cleanRent);
    if (rentValue == null || rentValue <= 0) {
      Utils.showOverlayMessage(
          context,
          message: "Invalid shipping rent amount",
          isError: true
      );
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    // Validate advance amount if provided
    if (advanceAmount.text.isNotEmpty) {
      final cleanAdvance = advanceAmount.text.cleanAmount;
      final advanceValue = double.tryParse(cleanAdvance);
      if (advanceValue == null || advanceValue <= 0) {
        Utils.showOverlayMessage(
            context,
            message: "Invalid advance amount",
            isError: true
        );
        setState(() {
          _currentStep = 2;
        });
        return;
      }
    }

    print('All validations passed! Submitting...');

    final bloc = context.read<ShippingBloc>();
    final data = ShippingModel(
      shpId: widget.shippingId,
      shpLoadSize: loadingSize.text,
      shpUnloadSize: unloadingSize.text,
      shpTo: shpTo.text,
      shpFrom: shpFrom.text,
      shpRent: shippingRent.text.cleanAmount,
      productId: productId!,
      vehicleId: vehicleId!,
      customerId: customerId!,
      shpArriveDate: DateTime.tryParse(shpToGregorian),
      shpMovingDate: DateTime.tryParse(shpFromGregorian),
      usrName: usrName ?? "",
      advanceAmount: advanceAmount.text.cleanAmount,
      remark: remark.text,
      shpStatus: 1,
      shpUnit: unit ?? "TN",
    );

    print('Dispatching AddShippingEvent...');

    if(widget.shippingId !=null){
      bloc.add(UpdateShippingEvent(data));
    }else{
      bloc.add(AddShippingEvent(data));
    }
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
            const Text('No income recorded'),
        ],
      ),
    );
  }

  Widget _buildExpensesView(ShippingDetailsModel shipping) {
    final tr = AppLocalizations.of(context)!;
    final expenses = shipping.expenses ?? [];
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocSelector<ShippingBloc, ShippingState, int?>(
      selector: (state) => state.loadingShpId,
      builder: (context, loadingShpId) {
        final isLoading = loadingShpId == widget.shippingId;

        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expense Form
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedExpenseForEdit != null ? tr.edit : tr.newKeyword,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        // Expense Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (_selectedExpenseForEdit != null)
                              ZOutlineButton(
                                width: 100,
                                height: 30,
                                label: Text(tr.cancel),
                                onPressed: () {
                                  setState(() {
                                    _selectedExpenseForEdit = null;
                                    _clearExpenseForm();
                                  });
                                },
                              ),
                            const SizedBox(width: 10),
                            ZOutlineButton(
                              width: 100,
                              height: 30,
                              isActive: true,
                              label: isLoading
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              )
                                  : Text(_selectedExpenseForEdit != null ? tr.update : tr.create),
                              onPressed: isLoading
                                  ? null // Disable button when loading
                                  : () {
                                _handleExpenseAction();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    Form(
                      key: expenseFormKey,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
                                  showAllOnFocus: true,
                                  controller: accountController,
                                  title: tr.accounts,
                                  hintText: tr.accNameOrNumber,
                                  isRequired: true,
                                  bloc: context.read<AccountsBloc>(),
                                  fetchAllFunction: (bloc) => bloc.add(
                                    LoadAccountsFilterEvent(start: 4, end: 4),
                                  ),
                                  searchFunction: (bloc, query) => bloc.add(
                                    LoadAccountsFilterEvent(start: 4, end: 4, input: query),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return tr.required(tr.accounts);
                                    }
                                    if (expenseAccNumber == null) {
                                      return tr.required(tr.accounts);
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
                                              "${account.accNumber} | ${account.accName}",
                                              style: Theme.of(context).textTheme.bodyLarge,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  itemToString: (acc) => "${acc.accNumber} | ${acc.accName}",
                                  stateToLoading: (state) => state is AccountLoadingState,
                                  loadingBuilder: (context) => const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 3),
                                  ),
                                  stateToItems: (state) {
                                    if (state is AccountLoadedState) {
                                      return state.accounts;
                                    }
                                    return [];
                                  },
                                  onSelected: (value) {
                                    setState(() {
                                      expenseAccNumber = value.accNumber;
                                      accountController.text = "${value.accNumber} | ${value.accName}";
                                    });
                                    // Trigger validation
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      expenseFormKey.currentState?.validate();
                                    });
                                  },
                                  noResultsText: tr.noDataFound,
                                  showClearButton: true,
                                ),
                              ),
                              const SizedBox(width: 8),
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
                                      return tr.required(tr.amount);
                                    }

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
                                  controller: expenseAmount,
                                  title: tr.amount,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ZTextFieldEntitled(
                            keyboardInputType: TextInputType.multiline,
                            controller: expenseNarration,
                            title: tr.narration,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),

                // Expenses List
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${tr.expense} (${expenses.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),

                if (expenses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context)!.noExpenseRecorded,
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 300,
                              child: Text(
                                tr.referenceNumber,
                                style: textTheme.titleSmall,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                tr.narration,
                                style: textTheme.titleSmall,
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                tr.amount,
                                style: textTheme.titleSmall,
                              ),
                            ),
                            const SizedBox(width: 50),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: color.outline.withValues(alpha: .3)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];

                            return Material(
                              child: InkWell(
                                hoverColor: color.primary.withValues(alpha: .06),
                                highlightColor: color.primary.withValues(alpha: .06),
                                onTap: isLoading ? null : () => _loadExpenseForEdit(expense),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedExpenseForEdit?.trdReference == expense.trdReference
                                        ? color.primary.withValues(alpha: .1)
                                        : index.isEven
                                        ? color.outline.withValues(alpha: .05)
                                        : Colors.transparent,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 300,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              expense.trdReference ?? "",
                                              style: textTheme.titleSmall,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 70,
                                                  child: Text(
                                                    expense.accNumber?.toString() ?? "",
                                                    style: TextStyle(color: color.primary),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 150,
                                                  child: Text(expense.accName ?? ""),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(child: Text(expense.narration ?? "")),
                                      SizedBox(
                                        width: 100,
                                        child: Text(
                                          "${expense.amount?.toAmount()} ${expense.currency}",
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 50,
                                        child: isLoading
                                            ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                            : InkWell(
                                          onTap: () => _showDeleteConfirmationDialog(expense),
                                          child: Icon(Icons.delete, color: color.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add this helper method to your _DesktopState class
  Map<String, String> _getSummaryData(ShippingDetailsModel? shipping) {
    if (shipping != null) {
      // Return data from ShippingDetailsModel
      return {
        'customer': shipping.customer ?? customerCtrl.text,
        'product': shipping.proName ?? productCtrl.text,
        'vehicle': shipping.vehicle ?? vehicleCtrl.text,
        'from': shipping.shpFrom ?? shpFrom.text,
        'to': shipping.shpTo ?? shpTo.text,
        'loadingSize': "${shipping.shpLoadSize ?? loadingSize.text} ${shipping.shpUnit ?? unit ?? 'TN'}",
        'unloadingSize': "${shipping.shpUnloadSize ?? unloadingSize.text} ${shipping.shpUnit ?? unit ?? 'TN'}",
        'rent': "${shipping.shpRent ?? shippingRent.text} USD",
        'total': shipping.total ?? "",
        'status': shipping.shpStatus?.toString() ?? "",
      };
    } else {
      // Return data from form
      final formData = _getFormDataAsShippingModel();
      return {
        'customer': formData.customer ?? customerCtrl.text,
        'product': formData.proName ?? productCtrl.text,
        'vehicle': formData.vehicle ?? vehicleCtrl.text,
        'from': formData.shpFrom ?? shpFrom.text,
        'to': formData.shpTo ?? shpTo.text,
        'loadingSize': "${formData.shpLoadSize ?? loadingSize.text} ${formData.shpUnit ?? unit ?? 'TN'}",
        'unloadingSize': "${formData.shpUnloadSize ?? unloadingSize.text} ${formData.shpUnit ?? unit ?? 'TN'}",
        'rent': "${formData.shpRent ?? shippingRent.text} USD",
        'total': formData.total ?? "",
        'status': formData.shpStatus?.toString() ?? "",
      };
    }
  }

  // Then update _buildSummaryView to use this helper
  Widget _buildSummaryView(ShippingDetailsModel? shipping) {
    final summaryData = _getSummaryData(shipping);
    final hasShippingDetails = shipping != null;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),

            // Customer Information
            _buildSummaryItem('Customer', summaryData['customer'] ?? ''),
            _buildSummaryItem('Product', summaryData['product'] ?? ''),

            const SizedBox(height: 5),
            Text(
              'Shipping Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Shipping Details
            _buildSummaryItem('Vehicle', summaryData['vehicle'] ?? ''),
            _buildSummaryItem('From', summaryData['from'] ?? ''),
            _buildSummaryItem('To', summaryData['to'] ?? ''),
            _buildSummaryItem('Loading Date', shpFromGregorian),
            _buildSummaryItem('Unloading Date', shpToGregorian),
            _buildSummaryItem('Loading Size', summaryData['loadingSize'] ?? ''),
            _buildSummaryItem('Unloading Size', summaryData['unloadingSize'] ?? ''),
            _buildSummaryItem('Shipping Rent', summaryData['rent'] ?? ''),

            // Financial Summary
            if (summaryData['total'] != null && summaryData['total']!.isNotEmpty)
              _buildSummaryItem('Total', "${summaryData['total']} USD", isHighlighted: true),

            // Expenses Summary - Only for ShippingDetailsModel
            if (hasShippingDetails && shipping.expenses != null && shipping.expenses!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Expenses',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...shipping.expenses!.map(
                        (expense) => _buildSummaryItem(
                      "${expense.accName} (${expense.accNumber})",
                      "${expense.amount} ${expense.currency}",
                      isSubItem: true,
                    ),
                  ),
                ],
              ),

            // Income Summary - Only for ShippingDetailsModel
            if (hasShippingDetails && shipping.income != null && shipping.income!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Income',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...shipping.income!.map(
                        (income) => _buildSummaryItem(
                      "${income.accName} (${income.accNumber})",
                      "${income.amount} ${income.currency}",
                      isSubItem: true,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 30),
            // Status
            if (summaryData['status'] != null && summaryData['status']!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: summaryData['status'] == "1" ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: summaryData['status'] == "1" ? Colors.green : Colors.orange,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      summaryData['status'] == "1" ? Icons.check_circle : Icons.schedule,
                      color: summaryData['status'] == "1" ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      summaryData['status'] == "1" ? 'Delivered' : 'Pending',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: summaryData['status'] == "1" ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, {bool isHighlighted = false, bool isSubItem = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSubItem ? 4.0 : 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              title,
              style: isSubItem
                  ? Theme.of(context).textTheme.bodySmall
                  : Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: isSubItem
                  ? Theme.of(context).textTheme.bodySmall
                  : Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isHighlighted ? Theme.of(context).colorScheme.primary : null,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get form data as ShippingModel
  ShippingModel _getFormDataAsShippingModel() {
    return ShippingModel(
      shpLoadSize: loadingSize.text,
      shpUnloadSize: unloadingSize.text,
      shpTo: shpTo.text,
      shpFrom: shpFrom.text,
      shpRent: shippingRent.text.cleanAmount,
      productId: productId,
      vehicleId: vehicleId,
      customerId: customerId,
      shpArriveDate: DateTime.tryParse(shpToGregorian),
      shpMovingDate: DateTime.tryParse(shpFromGregorian),
      usrName: usrName ?? "",
      advanceAmount: advanceAmount.text.cleanAmount,
      remark: remark.text,
      shpId: widget.shippingId,
      shpUnit: unit ?? "TN",
    );
  }

  void _clearExpenseForm() {
    expenseAmount.clear();
    expenseNarration.clear();
    accountController.clear();
    expenseAccNumber = null;
    _selectedExpenseForEdit = null;
    if (expenseFormKey.currentState != null) {
      expenseFormKey.currentState!.reset();
    }
  }

  void _loadExpenseForEdit(ShippingExpenseModel expense) {
    setState(() {
      _selectedExpenseForEdit = expense;
      expenseAmount.text = expense.amount ?? '';
      expenseNarration.text = expense.narration ?? '';

      if (expense.accNumber != null && expense.accName != null) {
        accountController.text = '${expense.accNumber} | ${expense.accName}';
        expenseAccNumber = expense.accNumber;
      }
    });
  }

  void _handleExpenseAction() {
    if (expenseFormKey.currentState == null || !expenseFormKey.currentState!.validate()) {
      Utils.showOverlayMessage(context, message: "Please fill all required fields", isError: true);
      return;
    }

    if (_selectedExpenseForEdit != null) {
      context.read<ShippingBloc>().add(
        UpdateShippingExpenseEvent(
          shpId: widget.shippingId!,
          trnReference: _selectedExpenseForEdit!.trdReference!,
          amount: expenseAmount.text,
          narration: expenseNarration.text,
          usrName: usrName ?? "",
        ),
      );
    } else {
      context.read<ShippingBloc>().add(
        AddShippingExpenseEvent(
          shpId: widget.shippingId!,
          accNumber: expenseAccNumber!,
          amount: expenseAmount.text,
          narration: expenseNarration.text,
          usrName: usrName ?? "",
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(ShippingExpenseModel expense) async {
    final tr = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ZAlertDialog(
          title: tr.areYouSure,
          content: "${tr.delete}? ${expense.amount?.toAmount()} ${expense.currency}",
          onYes: () {
            context.read<ShippingBloc>().add(
              DeleteShippingExpenseEvent(
                shpId: widget.shippingId!,
                trnReference: expense.trdReference!,
                usrName: usrName ?? "",
              ),
            );
          },
        );
      },
    );
  }

  Widget _datePicker({required String date, required String title}) {
    return GenericDatePicker(
      label: title,
      initialGregorianDate: date,
      onDateChanged: (newDate) {
        setState(() {
          if (title == 'Loading Date') {
            shpFromGregorian = newDate;
          } else {
            shpToGregorian = newDate;
          }
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