import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
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
import '../../../../../Stakeholders/Ui/Accounts/model/stk_acc_model.dart';
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
  final paymentAccountCtrl = TextEditingController();
  final cashCtrl = TextEditingController();

  int? expenseAccNumber;
  String? currentLocale;
  int? customerId;
  int? productId;
  int? vehicleId;
  String? unit;
  int? shpStatus;
  int? paymentAccNumber;

  // Date variables
  String shpFromGregorian = DateTime.now().toFormattedDate();
  String shpToGregorian = DateTime.now().toFormattedDate();

  String? usrName;
// State variables
  bool _isCashPaymentEnabled = false;
  bool _isAccountPaymentEnabled = false;
  double _remainingBalance = 0.0;
  // Form keys for each step
  final GlobalKey<FormState> orderFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> shippingFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> advanceFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> expenseFormKey = GlobalKey<FormState>();

  Expense? _selectedExpenseForEdit;

  // Add current step tracking
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentLocale = context.read<LocalizationBloc>().state.languageCode;
      if (widget.shippingId != null) {
        // Reset to first step when loading existing shipping
        _currentStep = 0;
        context.read<ShippingBloc>().add(LoadShippingDetailEvent(widget.shippingId!));
      }
    });
  }

  @override
  void didUpdateWidget(covariant _Desktop oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset current step when shippingId changes
    if (widget.shippingId != oldWidget.shippingId) {
      _currentStep = 0;
    }
  }

  void _prefillForm(ShippingDetailsModel shipping) {
    if (!mounted) return;
    setState(() {
      _currentStep = 0;
    });

      _clearAllControllers();

      customerId = shipping.perId;
      productId  = shipping.proId;
      vehicleId  = shipping.vclId;

      customerCtrl.text = shipping.customer ?? '';
      productCtrl.text  = shipping.proName ?? '';
      vehicleCtrl.text  = shipping.vehicle ?? '';

      shpFrom.text = shipping.shpFrom ?? '';
      shpTo.text   = shipping.shpTo ?? '';

      shpFromGregorian = shipping.shpMovingDate?.toFormattedDate()??"";
      shpToGregorian = shipping.shpArriveDate?.toFormattedDate()??"";

      loadingSize.text   = shipping.shpLoadSize ?? '';
      unloadingSize.text = shipping.shpUnloadSize ?? '';

      unit = shipping.shpUnit;
      shippingRent.text = shipping.shpRent ?? '';
      remark.text       = shipping.shpRemark ?? '';
      shpStatus         = shipping.shpStatus ?? 0;

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

  // Updated validation method that knows about current step
  bool _validateStepChange(int currentStep, int requestedStep) {
    // Only validate when moving forward
    if (requestedStep > currentStep) {
      if (requestedStep == 1) {
        // Validate order step - check if fields are actually filled
        if (customerCtrl.text.isEmpty || productCtrl.text.isEmpty) {
          Utils.showOverlayMessage(
              context,
              message: "Please fill all required fields in Order step",
              isError: true
          );
          return false;
        }
      }

      if (requestedStep == 2) {
        // Validate shipping step - check if fields are actually filled
        if (vehicleCtrl.text.isEmpty ||
            shpFrom.text.isEmpty ||
            shpTo.text.isEmpty ||
            shippingRent.text.isEmpty) {
          Utils.showOverlayMessage(
              context,
              message: "Please fill all required fields in Shipping step",
              isError: true
          );
          return false;
        }
      }
    }
    return true;
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

  Widget _buildStepperWithData(ShippingDetailsModel shipping, AppLocalizations tr, BuildContext context) {
    // Get loading state from bloc
    final blocState = context.watch<ShippingBloc>().state;
    final isLoading = blocState is ShippingListLoadingState && blocState.isLoading;
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;
    final tr = AppLocalizations.of(context)!;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    visualDensity: VisualDensity(vertical: -4),
                    minVerticalPadding: 0,
                    title: Text(tr.updateShipping,style: textTheme.titleMedium?.copyWith(
                      color: color.primary,
                    )),
                    subtitle: Text(tr.updateShippingHint,style: textTheme.bodySmall?.copyWith(
                        color: color.outline
                    ),),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(onPressed: popUp, icon: Icon(Icons.clear)),
                )
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: CustomStepper(
                  key: ValueKey('existing-shipping-${shipping.shpId}'),
                  currentStep: _currentStep,
                  onStepTapped: (step) {
                    // Don't allow step change during loading
                    if (!isLoading) {
                      setState(() {
                        _currentStep = step;
                      });
                    }
                  },
                  onStepChanged: (currentStep, requestedStep) {
                    // Don't allow validation during loading
                    if (isLoading) return false;
                    return _validateStepChange(currentStep, requestedStep);
                  },
                  steps: [
                    StepItem(
                      title: tr.order,
                      content: _order(shipping: shipping),
                      icon: Icons.shopping_cart,
                    ),
                    StepItem(
                      title: tr.shipping,
                      content: _shipping(shipping: shipping),
                      icon: Icons.local_shipping,
                    ),
                    StepItem(
                      title: tr.expense,
                      content: _buildExpensesView(shipping),
                      icon: Icons.data_exploration,
                    ),
                    StepItem(
                      title: tr.payment,
                      content: _buildPaymentView(shipping),
                      icon: Icons.payment_rounded,
                    ),
                    StepItem(
                      title: tr.summary,
                      content: _buildSummaryView(shipping),
                      icon: Icons.summarize,
                    ),
                  ],
                  onFinish: onFinish,
                  isLoading: isLoading,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewShippingStepper(AppLocalizations tr, BuildContext context) {
    // Get loading state from bloc
    final blocState = context.watch<ShippingBloc>().state;
    final isLoading = blocState is ShippingListLoadingState && blocState.isLoading;
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;
    final tr = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    visualDensity: VisualDensity(vertical: -4),
                    minVerticalPadding: 0,
                    title: Text(tr.createNewShipping,style: textTheme.titleMedium?.copyWith(
                      color: color.primary,
                    )),
                    subtitle: Text(tr.newShippingHint,style: textTheme.bodySmall?.copyWith(
                        color: color.outline
                    ),),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(onPressed: popUp, icon: Icon(Icons.clear)),
                )
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: CustomStepper(
                  key: const ValueKey('new-shipping'),
                  currentStep: _currentStep,
                  onStepTapped: (step) {
                    // Don't allow step change during loading
                    if (!isLoading) {
                      setState(() {
                        _currentStep = step;
                      });
                    }
                  },
                  onStepChanged: (currentStep, requestedStep) {
                    // Don't allow validation during loading
                    if (isLoading) return false;
                    return _validateStepChange(currentStep, requestedStep);
                  },
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
                  onFinish: onFinish,
                  isLoading: isLoading, // Pass loading state to stepper
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _order({ShippingDetailsModel? shipping}) {
    final tr = AppLocalizations.of(context)!;
    bool isDelivered = shipping?.shpStatus == 1;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: orderFormKey,
          child: Column(
            children: [
              const SizedBox(height: 13),
              GenericTextfield<IndividualsModel, IndividualsBloc, IndividualsState>(
                readOnly: isDelivered,
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
                readOnly: isDelivered,
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

  Widget _shipping({ShippingDetailsModel? shipping}) {
    final tr = AppLocalizations.of(context)!;
    bool isDelivered = shipping?.shpStatus == 1;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: shippingFormKey,
          child: Column(
            children: [
              GenericTextfield<VehicleModel, VehicleBloc, VehicleState>(
                showAllOnFocus: true,
                readOnly: isDelivered,
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
                      readOnly: isDelivered,
                      isRequired: true,
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
                  const SizedBox(width: 6),
                  Expanded(
                    child: ZTextFieldEntitled(
                      isRequired: true,
                      readOnly: isDelivered,
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
                      isActive: isDelivered,
                      date: shpFromGregorian,
                      title: tr.loadingDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _datePicker(
                      isActive: isDelivered,
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
                      readOnly: isDelivered,
                      isRequired: true,
                      controller: loadingSize,
                      title: tr.loadingSize,
                      inputFormat: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.,]*'),
                        ),
                        SmartThousandsDecimalFormatter(),
                      ],
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
                      readOnly: isDelivered,
                      isRequired: true,
                      controller: unloadingSize,
                      title: tr.unloadingSize,
                      inputFormat: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.,]*'),
                        ),
                        SmartThousandsDecimalFormatter(),
                      ],
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
                  const SizedBox(width: 7),
                  Expanded(
                    child: UnitDropdown(
                      isActive: isDelivered,
                      selectedUnit: UnitType.fromDatabaseValue(shipping?.shpUnit??""),
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
                      readOnly: isDelivered,
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
                readOnly: isDelivered,
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

  Widget _buildPaymentView(ShippingDetailsModel shipping) {
    final tr = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.payment, color: color.primary),
              title: Text(
                tr.payment,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                tr.paymentDescription,
                style: textTheme.bodyMedium?.copyWith(color: color.outline),
              ),
            ),

            const SizedBox(height: 5),

            // Total Amount Card
            Cover(
              radius: 6,
              color: color.surfaceContainerHighest.withValues(alpha: .3),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr.totalAmount, style: textTheme.titleMedium),
                        Text(
                          "${shipping.total?.toAmount()} USD",
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color.primary,
                          ),
                        ),
                      ],
                    ),
                    // Add remaining balance display here
                    if (_remainingBalance > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tr.remainingBalance, style: textTheme.bodyMedium),
                            Text(
                              "${_remainingBalance.toAmount()} USD",
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Payment Options Section
            Text(
              tr.paymentOptions,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              tr.selectPaymentMethod,
              style: textTheme.bodySmall?.copyWith(color: color.outline),
            ),

            const SizedBox(height: 15),

            // Cash Payment Section
            Cover(
              radius: 6,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.money, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tr.cashTitle,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _isCashPaymentEnabled,
                            onChanged: (value) {
                              setState(() {
                                _isCashPaymentEnabled = value;
                                if (!value) {
                                  cashCtrl.clear();
                                }
                                // Recalculate remaining balance
                                _calculateRemainingBalance(shipping);
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    if (_isCashPaymentEnabled) ...[
                      const SizedBox(height: 10),
                      ZTextFieldEntitled(
                        controller: cashCtrl,
                        title: tr.cashTitle,
                        hint: tr.enterCashAmount,
                        keyboardInputType: TextInputType.numberWithOptions(decimal: true),
                        inputFormat: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]*')),
                          SmartThousandsDecimalFormatter(),
                        ],
                        validator: (value) {
                          if (_isCashPaymentEnabled && value.isNotEmpty) {
                            final clean = value.replaceAll(RegExp(r'[^\d.]'), '');
                            final cashAmount = double.tryParse(clean) ?? 0;
                            final totalAmount = double.tryParse(shipping.total?.toAmount() ?? '0') ?? 0;

                            if (cashAmount <= 0) {
                              return tr.amountGreaterZero;
                            }
                            if (cashAmount > totalAmount) {
                              return tr.cashExceedsTotal;
                            }
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _calculateRemainingBalance(shipping);
                        },
                      ),

                      const SizedBox(height: 8),
                      if (cashCtrl.text.isNotEmpty)
                        Text(
                          '${tr.cashPaidNow}: ${cashCtrl.text} USD',
                          style: textTheme.bodySmall?.copyWith(color: Colors.green),
                        ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 5),

            // Account Payment Section (for remaining balance)
            Cover(
              radius: 6,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.buildingColumns, size: 18, color: color.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tr.accountPayment,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _isAccountPaymentEnabled,
                            onChanged: (value) {
                              setState(() {
                                _isAccountPaymentEnabled = value;
                                if (!value) {
                                  accountController.clear();
                                  paymentAccNumber = null;
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    if (_isAccountPaymentEnabled) ...[
                      const SizedBox(height: 10),

                      // Show remaining balance explicitly
                      if (_remainingBalance > 0)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.surfaceContainerHighest.withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: color.primary.withValues(alpha: .3)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(tr.remainingBalance, style: textTheme.titleSmall),
                                  Text(
                                    "${_remainingBalance.toAmount()} USD",
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: color.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tr.remainingWillBeAddedToAccount,
                                style: textTheme.bodySmall?.copyWith(color: color.outline),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 10),

                      // Account Selection
                      GenericTextfield<StakeholdersAccountsModel, AccountsBloc, AccountsState>(
                        showAllOnFocus: true,
                        controller: accountController,
                        title: tr.selectAccount,
                        hintText: tr.selectReceivableAccount,
                        isRequired: _isAccountPaymentEnabled && _remainingBalance > 0,
                        bloc: context.read<AccountsBloc>(),
                        fetchAllFunction: (bloc) => bloc.add(LoadStkAccountsEvent()),
                        searchFunction: (bloc, query) => bloc.add(
                            LoadStkAccountsEvent(search: query)
                        ),
                        validator: (value) {
                          if (_isAccountPaymentEnabled && _remainingBalance > 0) {
                            if (value.isEmpty) {
                              return tr.selectAccountRequired;
                            }
                            if (paymentAccNumber == null) {
                              return tr.selectValidAccount;
                            }
                          }
                          return null;
                        },
                        itemBuilder: (context, account) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          account.accName ?? "",
                                          style: textTheme.bodyLarge,
                                        ),
                                        Text(
                                          account.accnumber?.toString() ?? "",
                                          style: textTheme.bodySmall?.copyWith(color: color.outline),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${account.avilBalance?.toAmount()} ${account.ccySymbol}",
                                        style: textTheme.bodyLarge,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        itemToString: (acc) => "${acc.accnumber} | ${acc.accName}",
                        stateToLoading: (state) => state is AccountLoadingState,
                        loadingBuilder: (context) => const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                        stateToItems: (state) {
                          if (state is StkAccountLoadedState) {
                            return state.accounts;
                          }
                          return [];
                        },
                        onSelected: (value) {
                          setState(() {
                            paymentAccNumber = value.accnumber;
                            accountController.text = "${value.accnumber} | ${value.accName}";
                          });
                        },
                        noResultsText: tr.noAccountsFound,
                        showClearButton: true,
                      ),

                      const SizedBox(height: 8),
                      Text(
                        tr.remainingWillBeAddedToAccount,
                        style: textTheme.bodySmall?.copyWith(color: color.outline),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 5),

            // Payment Summary
            if (cashCtrl.text.isNotEmpty || _isAccountPaymentEnabled)
              Cover(
                radius: 6,
                color: color.surfaceContainerHighest.withValues(alpha: .2),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.paymentSummary,
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tr.totalAmount, style: textTheme.bodyMedium),
                          Text(
                            "${shipping.total?.toAmount()} USD",
                            style: textTheme.bodyLarge,
                          ),
                        ],
                      ),

                      const Divider(height: 24),

                      if (cashCtrl.text.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.money, size: 16, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(tr.cashPaid, style: textTheme.bodyMedium),
                              ],
                            ),
                            Text(
                              "${cashCtrl.text} USD",
                              style: textTheme.bodyLarge?.copyWith(color: Colors.green),
                            ),
                          ],
                        ),

                      if (_isAccountPaymentEnabled && paymentAccNumber != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(FontAwesomeIcons.buildingColumns, size: 15, color: color.primary),
                                  const SizedBox(width: 8),
                                  Text(tr.toAccount, style: textTheme.bodyMedium),
                                ],
                              ),
                              Text(
                                "${_remainingBalance.toAmount()} USD",
                                style: textTheme.bodyLarge?.copyWith(color: color.primary),
                              ),
                            ],
                          ),
                        ),

                      const Divider(height: 24),

                      // Show remaining balance after payments
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tr.remainingBalance, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            "${_calculateBalanceAfterPayments(shipping).toAmount()} USD",
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _calculateBalanceAfterPayments(shipping) == 0 ? Colors.green : color.error,
                            ),
                          ),
                        ],
                      ),

                      if (_calculateBalanceAfterPayments(shipping) == 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                tr.fullyPaid,
                                style: textTheme.bodyMedium?.copyWith(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Calculate remaining balance
  void _calculateRemainingBalance(ShippingDetailsModel shipping) {
    final cashAmount = double.tryParse(cashCtrl.text.cleanAmount) ?? 0;
    final totalAmount = double.tryParse(shipping.total?.toAmount() ?? '0') ?? 0;

    setState(() {
      _remainingBalance = totalAmount - cashAmount;

      // Auto-enable account payment if there's remaining balance
      if (_remainingBalance > 0 && !_isAccountPaymentEnabled) {
        _isAccountPaymentEnabled = true;
      }

      // If cash covers everything, disable account payment
      if (_remainingBalance <= 0) {
        _isAccountPaymentEnabled = false;
        accountController.clear();
        paymentAccNumber = null;
      }
    });
  }

// Calculate final balance after both payments
  double _calculateBalanceAfterPayments(ShippingDetailsModel shipping) {
    final cashAmount = double.tryParse(cashCtrl.text.cleanAmount) ?? 0;
    final totalAmount = double.tryParse(shipping.total?.toAmount() ?? '0') ?? 0;

    // If account payment is enabled, assume it covers the remaining balance
    if (_isAccountPaymentEnabled && paymentAccNumber != null) {
      return 0.0;
    }

    // Otherwise, show remaining balance after cash payment
    return totalAmount - cashAmount;
  }
  // Submit payment method
  void onPaymentSubmit() async {
    final tr = AppLocalizations.of(context)!;
    final bloc = context.read<ShippingBloc>();

    // ================= PAYMENT SPECIFIC VALIDATION =================
    // Check if we're in payment step (step index 3 for existing shipping)
    if (widget.shippingId != null && _currentStep == 3) {
      return _handlePaymentSubmission(tr, bloc);
    }

    // ... rest of your existing validation and shipping submission ...
  }

// Separate method for handling payment submission
  void _handlePaymentSubmission(AppLocalizations tr, ShippingBloc bloc) {
    // Access shipping state from widget context
    final shippingState = bloc.state;
    ShippingDetailsModel? currentShipping;

    // Extract current shipping from different states
    if (shippingState is ShippingDetailLoadedState) {
      currentShipping = shippingState.currentShipping;
    } else if (shippingState is ShippingSuccessState) {
      currentShipping = shippingState.currentShipping;
    } else if (shippingState is ShippingListLoadedState) {
      currentShipping = shippingState.currentShipping;
    }

    if (currentShipping == null) {
      Utils.showOverlayMessage(
        context,
        message: "Shipping information not found",
        isError: true,
      );
      return;
    }

    // Validate payment form
    final cashAmount = double.tryParse(cashCtrl.text.cleanAmount) ?? 0;
    final totalAmount = double.tryParse(currentShipping.total?.toAmount() ?? '0') ?? 0;

    // Check if any payment method is selected
    if (!_isCashPaymentEnabled && !_isAccountPaymentEnabled) {
      Utils.showOverlayMessage(
        context,
        message: tr.selectPaymentMethod,
        isError: true,
      );
      return;
    }

    // Validate cash amount
    if (_isCashPaymentEnabled && cashAmount <= 0) {
      Utils.showOverlayMessage(
        context,
        message: tr.enterValidCashAmount,
        isError: true,
      );
      return;
    }

    // Validate account selection for account payment
    if (_isAccountPaymentEnabled && paymentAccNumber == null) {
      Utils.showOverlayMessage(
        context,
        message: tr.selectAccountRequired,
        isError: true,
      );
      return;
    }

    // Calculate payment amounts
    double cashPayment = 0;
    double accountPayment = 0;
    String paymentType = "";

    if (_isCashPaymentEnabled && _isAccountPaymentEnabled) {
      // Mixed payment
      cashPayment = cashAmount;
      accountPayment = _remainingBalance;
      paymentType = "dual";
    } else if (_isCashPaymentEnabled) {
      // Cash only payment
      cashPayment = cashAmount;
      paymentType = "cash";
    } else if (_isAccountPaymentEnabled) {
      // Account only payment
      accountPayment = totalAmount;
      paymentType = "card";
    }

    // Show confirmation dialog
    _showPaymentConfirmationDialog(
      tr,
      bloc,
      cashPayment,
      accountPayment,
      paymentType,
    );
  }

// Confirmation dialog for payment
  void _showPaymentConfirmationDialog(AppLocalizations tr, ShippingBloc bloc, double cashAmount, double accountAmount, String paymentType,) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(tr.confirmPayment),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr.paymentConfirmationMessage),
            const SizedBox(height: 16),

            if (cashAmount > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr.cash),
                  Text("${cashAmount.toAmount()} USD"),
                ],
              ),

            if (accountAmount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr.accountPayment),
                    Text("${accountAmount.toAmount()} USD"),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr.totalPaid),
                Text(
                  "${(cashAmount + accountAmount).toAmount()} USD",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ZOutlineButton(
            width: 100,
            onPressed: () => Navigator.of(context).pop(),
            label: Text(tr.cancel),
          ),
          ZOutlineButton(
            width: 100,
            isActive: true,
            onPressed: () {
              Navigator.of(context).pop();
              _submitPayment(
                bloc,
                cashAmount,
                accountAmount,
                paymentType,
              );
            },
            label: Text(tr.confirmPayment),
          ),
        ],
      ),
    );
  }

// Actual payment submission
  void _submitPayment(ShippingBloc bloc, double cashAmount, double accountAmount, String paymentType) {
    final event = AddShippingPaymentEvent(
      shpId: widget.shippingId!,
      cashAmount: cashAmount > 0 ? cashAmount.toAmount() : "",
      accNumber: paymentAccNumber,
      accountAmount: accountAmount > 0 ? accountAmount.toAmount() : "",
      paymentType: paymentType,
      usrName: usrName ?? "",
    );

    bloc.add(event);
  }

// Also update the onSubmit method to call _handlePaymentSubmission
  void onSubmit() async {
    final tr = AppLocalizations.of(context)!;
    final bloc = context.read<ShippingBloc>();

    // ================= PAYMENT SPECIFIC VALIDATION =================
    // Check if we're in payment step (step index 3 for existing shipping)
    if (widget.shippingId != null && _currentStep == 3) {
      return _handlePaymentSubmission(tr, bloc);
    }

    // ================= COMMON VALIDATION =================

    if (customerId == null) {
      Utils.showOverlayMessage(
        context,
        message: tr.selectCustomer,
        isError: true,
      );
      setState(() => _currentStep = 0);
      return;
    }

    if (productId == null) {
      Utils.showOverlayMessage(
        context,
        message: tr.selectProduct,
        isError: true,
      );
      setState(() => _currentStep = 0);
      return;
    }

    if (vehicleId == null) {
      Utils.showOverlayMessage(
        context,
        message: tr.selectVehicle,
        isError: true,
      );
      setState(() => _currentStep = 1);
      return;
    }

    if (shpFrom.text.isEmpty || shpTo.text.isEmpty) {
      Utils.showOverlayMessage(
        context,
        message: tr.fillShippingLocations,
        isError: true,
      );
      setState(() => _currentStep = 1);
      return;
    }

    if (loadingSize.text.isEmpty) {
      Utils.showOverlayMessage(
        context,
        message: tr.fillLoadingSize,
        isError: true,
      );
      setState(() => _currentStep = 1);
      return;
    }

    if (shippingRent.text.isEmpty) {
      Utils.showOverlayMessage(
        context,
        message: tr.fillShippingRent,
        isError: true,
      );
      setState(() => _currentStep = 1);
      return;
    }

    final rentValue = double.tryParse(shippingRent.text.cleanAmount);
    if (rentValue == null || rentValue <= 0) {
      Utils.showOverlayMessage(
        context,
        message: tr.invalidShippingRent,
        isError: true,
      );
      setState(() => _currentStep = 1);
      return;
    }

    if (advanceAmount.text.isNotEmpty) {
      final advanceValue =
      double.tryParse(advanceAmount.text.cleanAmount);
      if (advanceValue == null || advanceValue <= 0) {
        Utils.showOverlayMessage(
          context,
          message: tr.invalidAdvanceAmount,
          isError: true,
        );
        setState(() => _currentStep = 2);
        return;
      }
    }

    // ================= DELIVERY VALIDATION =================

    if (shpStatus == 1) {
      if (unloadingSize.text.isEmpty) {
        Utils.showOverlayMessage(
          context,
          message: tr.unloadingSizeRequired,
          isError: true,
        );
        setState(() => _currentStep = 1);
        return;
      }

      final unloadingValue =
      double.tryParse(unloadingSize.text.cleanAmount);
      if (unloadingValue == null || unloadingValue <= 0) {
        Utils.showOverlayMessage(
          context,
          message: tr.invalidUnloadingSize,
          isError: true,
        );
        setState(() => _currentStep = 1);
        return;
      }

      if (shpToGregorian.isEmpty ||
          shpToGregorian == DateTime.now().toFormattedDate()) {
        Utils.showOverlayMessage(
          context,
          message: tr.setUnloadingDate,
          isError: true,
        );
        setState(() => _currentStep = 1);
        return;
      }

      try {
        final loadingDate = DateTime.parse(shpFromGregorian);
        final unloadingDate = DateTime.parse(shpToGregorian);

        if (unloadingDate.isBefore(loadingDate)) {
          Utils.showOverlayMessage(
            context,
            message: tr.unloadingBeforeLoading,
            isError: true,
          );
          setState(() => _currentStep = 1);
          return;
        }
      } catch (_) {
        Utils.showOverlayMessage(
          context,
          message: tr.invalidDateFormat,
          isError: true,
        );
        setState(() => _currentStep = 1);
        return;
      }

      final missingFields = <String>[];
      if (shpFrom.text.isEmpty) missingFields.add(tr.shpFrom);
      if (shpTo.text.isEmpty) missingFields.add(tr.shpTo);
      if (loadingSize.text.isEmpty) missingFields.add(tr.loadingSize);
      if (unloadingSize.text.isEmpty) missingFields.add(tr.unloadingSize);
      if (shippingRent.text.isEmpty) missingFields.add(tr.shippingRent);
      if (unit == null || unit!.isEmpty) missingFields.add(tr.unit);

      if (missingFields.isNotEmpty) {
        Utils.showOverlayMessage(
          context,
          message:
          "${tr.deliveryRequiredFields}\n${missingFields.join(', ')}",
          isError: true,
        );
        setState(() => _currentStep = 1);
        return;
      }

      final loadingValue =
      double.tryParse(loadingSize.text.cleanAmount);
      if (loadingValue != null &&
          ((unloadingValue - loadingValue).abs() / loadingValue) * 100 >
              20) {
        final shouldContinue =
        await _showUnloadingSizeWarningDialog(
            context, loadingValue, unloadingValue);

        if (!shouldContinue) {
          setState(() => _currentStep = 1);
          return;
        }
      }
    }

    // ================= SUBMIT =================

    final data = ShippingModel(
      shpId: widget.shippingId,
      shpLoadSize: loadingSize.text.cleanAmount,
      shpUnloadSize: unloadingSize.text.cleanAmount,
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
      shpStatus: shpStatus ?? 0,
      shpUnit: unit ?? "TN",
    );

    widget.shippingId != null
        ? bloc.add(UpdateShippingEvent(data))
        : bloc.add(AddShippingEvent(data));
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

                    if(shipping.shpStatus != 1)
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
                                    LoadAccountsFilterEvent(
                                        start: 4,
                                        end: 4,
                                        ccy: "USD",
                                        exclude: ""
                                    ),
                                  ),
                                  searchFunction: (bloc, query) => bloc.add(
                                    LoadAccountsFilterEvent(
                                        start: 4,
                                        end: 4,
                                        ccy: "USD",
                                        exclude: "",
                                        input: query
                                    ),
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
                    if(shipping.shpStatus != 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0,vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (_selectedExpenseForEdit != null)
                            ZOutlineButton(
                              width: 100,
                              height: 35,
                              label: Text(tr.cancel),
                              onPressed: () {
                                setState(() {
                                  _selectedExpenseForEdit = null;
                                  _clearExpenseForm();
                                });
                              },
                            ),
                          if (_selectedExpenseForEdit != null)
                          const SizedBox(width: 10),
                          ZOutlineButton(
                            width: 100,
                            height: 35,
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
                                ? null
                                : () {
                              _handleExpenseAction();
                            },
                          ),
                        ],
                      ),
                    ),
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

  Map<String, String> _getSummaryData(ShippingDetailsModel? shipping) {
    if (shipping != null) {
      // Return data from ShippingDetailsModel
      return {
        'customer': shipping.customer ?? customerCtrl.text,
        'product': shipping.proName ?? productCtrl.text,
        'vehicle': shipping.vehicle ?? vehicleCtrl.text,
        'from': shipping.shpFrom ?? shpFrom.text,
        'to': shipping.shpTo ?? shpTo.text,
        'loadingSize': "${shipping.shpLoadSize ?? loadingSize.text} ${shipping.shpUnit ?? unit ?? ''}",
        'unloadingSize': "${shipping.shpUnloadSize ?? unloadingSize.text} ${shipping.shpUnit ?? unit ?? ''}",
        'rent': shipping.shpRent ?? shippingRent.text,
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
        'rent': formData.shpRent ?? shippingRent.text,
        'total': formData.total ?? "",
        'status': formData.shpStatus?.toString() ?? "",
      };
    }
  }

  Widget _buildSummaryView(ShippingDetailsModel? shipping) {
    final summaryData = _getSummaryData(shipping);
    final hasShippingDetails = shipping != null;
    final tr = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            if (summaryData['status'] != null && summaryData['status']!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: summaryData['status'] == "1" ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(5),
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
                    Expanded(
                      child: Text(
                        summaryData['status'] == "1" ? tr.delivered : tr.pendingTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: summaryData['status'] == "1" ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),

                    Switch(value: shpStatus == 1,
                        onChanged: (e){
                      setState(() {
                        shpStatus = e ? 1 : 0;
                      });
                    })
                  ],
                ),
              ),
            SizedBox(height: 8),
            Text(
              tr.shippingSummary,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),

            // Customer Information
            _buildSummaryItem(tr.customer, summaryData['customer'] ?? ''),
            _buildSummaryItem(tr.productName, summaryData['product'] ?? ''),

            const SizedBox(height: 5),
            Text(
              tr.shippingDetails,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Shipping Details
            _buildSummaryItem(tr.vehicle, summaryData['vehicle'] ?? ''),
            _buildSummaryItem(tr.fromTo, "${summaryData['from']} - ${summaryData['to']}"),
            _buildSummaryItem(tr.loadingDate, shpFromGregorian),
            _buildSummaryItem(tr.unloadingDate, shpToGregorian),
            _buildSummaryItem(tr.loadingSize, summaryData['loadingSize'] ?? ''),
            _buildSummaryItem(tr.unloadingSize, summaryData['unloadingSize'] ?? ''),
            _buildSummaryItem(tr.shippingRent, summaryData['rent']?.toAmount() ?? ''),

            // Financial Summary
            if (summaryData['total'] != null && summaryData['total']!.isNotEmpty)
              _buildSummaryItem(tr.totalTitle, "${summaryData['total']?.toAmount()}", isHighlighted: true),

            // Expenses Summary - Only for ShippingDetailsModel
            if (hasShippingDetails && shipping.expenses != null && shipping.expenses!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    tr.expense,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...shipping.expenses!.map(
                        (expense) => _buildSummaryItem(
                      "${expense.accName} (${expense.accNumber})",
                      "${expense.amount?.toAmount()} ${expense.currency}",
                      isSubItem: true,
                    ),
                  ),
                ],
              ),

            // payment Summary - Only for ShippingDetailsModel
            if (hasShippingDetails && shipping.pyment != null && shipping.pyment!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    tr.payment,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...shipping.pyment!.map(
                        (payment) => _buildSummaryItem(
                        tr.cashAmount,
                      "${payment.cashAmount?.toAmount()}",
                      isSubItem: true,
                    ),
                  ),
                  ...shipping.pyment!.map(
                        (payment) => _buildSummaryItem(
                      tr.accountPayment,
                      "${payment.cardAmount?.toAmount()}",
                      isSubItem: true,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 30),
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
                  ? Theme.of(context).textTheme.bodyMedium
                  : Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: isSubItem
                  ? Theme.of(context).textTheme.bodyMedium
                  : Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isHighlighted ? Theme.of(context).colorScheme.primary : null,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(35),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Loading please wait...'),
          ],
        ),
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
  void popUp(){
    Navigator.of(context).pop();
  }
  void onFinish() async {
    final tr = AppLocalizations.of(context)!;
    final bloc = context.read<ShippingBloc>();
    // ================= COMMON VALIDATION =================

    if (customerId == null) {
      Utils.showOverlayMessage(
        context,
        message: tr.selectCustomer,
        isError: true,
      );
      setState(() => _currentStep = 0);
      return;
    }

    if (productId == null) {
      Utils.showOverlayMessage(
        context,
        message: tr.selectProduct,
        isError: true,
      );
      setState(() => _currentStep = 0);
      return;
    }

    if (vehicleId == null) {
      Utils.showOverlayMessage(
        context,
        message: tr.selectVehicle,
        isError: true,
      );
      setState(() => _currentStep = 1);
      return;
    }

    if (shpFrom.text.isEmpty || shpTo.text.isEmpty) {
      Utils.showOverlayMessage(
        context,
        message: tr.fillShippingLocations,
        isError: true,
      );
      setState(() => _currentStep = 1);
      return;
    }

    if (loadingSize.text.isEmpty) {
      Utils.showOverlayMessage(
        context,
        message: tr.fillLoadingSize,
        isError: true,
      );
      setState(() => _currentStep = 1);
      return;
    }

    if (shippingRent.text.isEmpty) {
      Utils.showOverlayMessage(
        context,
        message: tr.fillShippingRent,
        isError: true,
      );
      setState(() => _currentStep = 1);
      return;
    }

    final rentValue = double.tryParse(shippingRent.text.cleanAmount);
    if (rentValue == null || rentValue <= 0) {
      Utils.showOverlayMessage(
        context,
        message: tr.invalidShippingRent,
        isError: true,
      );
      setState(() => _currentStep = 1);
      return;
    }

    if (advanceAmount.text.isNotEmpty) {
      final advanceValue =
      double.tryParse(advanceAmount.text.cleanAmount);
      if (advanceValue == null || advanceValue <= 0) {
        Utils.showOverlayMessage(
          context,
          message: tr.invalidAdvanceAmount,
          isError: true,
        );
        setState(() => _currentStep = 2);
        return;
      }
    }

    // ================= DELIVERY VALIDATION =================

    if (shpStatus == 1) {
      if (unloadingSize.text.isEmpty) {
        Utils.showOverlayMessage(
          context,
          message: tr.unloadingSizeRequired,
          isError: true,
        );
        setState(() => _currentStep = 1);
        return;
      }

      final unloadingValue =
      double.tryParse(unloadingSize.text.cleanAmount);
      if (unloadingValue == null || unloadingValue <= 0) {
        Utils.showOverlayMessage(
          context,
          message: tr.invalidUnloadingSize,
          isError: true,
        );
        setState(() => _currentStep = 1);
        return;
      }

      if (shpToGregorian.isEmpty ||
          shpToGregorian == DateTime.now().toFormattedDate()) {
        Utils.showOverlayMessage(
          context,
          message: tr.setUnloadingDate,
          isError: true,
        );
        setState(() => _currentStep = 1);
        return;
      }

      try {
        final loadingDate = DateTime.parse(shpFromGregorian);
        final unloadingDate = DateTime.parse(shpToGregorian);

        if (unloadingDate.isBefore(loadingDate)) {
          Utils.showOverlayMessage(
            context,
            message: tr.unloadingBeforeLoading,
            isError: true,
          );
          setState(() => _currentStep = 1);
          return;
        }
      } catch (_) {
        Utils.showOverlayMessage(
          context,
          message: tr.invalidDateFormat,
          isError: true,
        );
        setState(() => _currentStep = 1);
        return;
      }

      final missingFields = <String>[];
      if (shpFrom.text.isEmpty) missingFields.add(tr.shpFrom);
      if (shpTo.text.isEmpty) missingFields.add(tr.shpTo);
      if (loadingSize.text.isEmpty) missingFields.add(tr.loadingSize);
      if (unloadingSize.text.isEmpty) missingFields.add(tr.unloadingSize);
      if (shippingRent.text.isEmpty) missingFields.add(tr.shippingRent);
      if (unit == null || unit!.isEmpty) missingFields.add(tr.unit);

      if (missingFields.isNotEmpty) {
        Utils.showOverlayMessage(
          context,
          message:
          "${tr.deliveryRequiredFields}\n${missingFields.join(', ')}",
          isError: true,
        );
        setState(() => _currentStep = 1);
        return;
      }

      final loadingValue =
      double.tryParse(loadingSize.text.cleanAmount);
      if (loadingValue != null &&
          ((unloadingValue - loadingValue).abs() / loadingValue) * 100 >
              20) {
        final shouldContinue =
        await _showUnloadingSizeWarningDialog(
            context, loadingValue, unloadingValue);

        if (!shouldContinue) {
          setState(() => _currentStep = 1);
          return;
        }
      }
    }

    // ================= SUBMIT =================

    final data = ShippingModel(
      shpId: widget.shippingId,
      shpLoadSize: loadingSize.text.cleanAmount,
      shpUnloadSize: unloadingSize.text.cleanAmount,
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
      shpStatus: shpStatus ?? 0,
      shpUnit: unit ?? "TN",
    );

    widget.shippingId != null
        ? bloc.add(UpdateShippingEvent(data))
        : bloc.add(AddShippingEvent(data));
  }

// Helper method to show warning dialog for unloading size difference
  Future<bool> _showUnloadingSizeWarningDialog(BuildContext context, double loadingSize, double unloadingSize) async {
    final difference = unloadingSize - loadingSize;
    final percentage = ((difference.abs()) / loadingSize) * 100;
    final tr = AppLocalizations.of(context)!;
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)
          ),
          title: Text(tr.unloadingSizeWarning),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${tr.unloadingSize} (${unloadingSize.toStringAsFixed(2)}) ${tr.unloadingSizeWarningMessage} (${loadingSize.toStringAsFixed(2)})."),
              const SizedBox(height: 8),
              Text("${tr.difference}: ${difference > 0 ? '+' : ''}${difference.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
              Text(tr.unloadingSizeProceedMessage),
            ],
          ),
          actions: [
            ZOutlineButton(
              width: 100,
              onPressed: () => Navigator.of(context).pop(false),
              label: Text(tr.cancel),
            ),
            ZOutlineButton(
              width: 100,
              isActive: true,
              onPressed: () => Navigator.of(context).pop(true),
              label: Text(tr.proceed),
            ),
          ],
        );
      },
    ) ?? false;
  }
  void _loadExpenseForEdit(Expense expense) {
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
  Widget _datePicker({required String date, required String title, bool? isActive}) {
    return GenericDatePicker(
      isActive: isActive ?? false,
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