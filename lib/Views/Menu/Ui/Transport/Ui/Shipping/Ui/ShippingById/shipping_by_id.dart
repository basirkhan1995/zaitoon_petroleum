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
import '../../../../../../../../Features/Date/zdate_picker.dart';
import '../../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../../../Features/Other/thousand_separator.dart';
import '../../../../../../../../Features/Widgets/stepper.dart';
import '../../../../../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../../Finance/Ui/GlAccounts/bloc/gl_accounts_bloc.dart';
import '../../../../../Finance/Ui/GlAccounts/model/gl_model.dart';
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
        context.read<ShippingBloc>().add(
          LoadShippingDetailEvent(widget.shippingId!),
        );
        currentLocale = context.read<LocalizationBloc>().state.languageCode;
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
  final accountController = TextEditingController();
  final expenseAmount = TextEditingController();
  final expenseNarration = TextEditingController();
  int? expenseAccNumber;

  ShippingDetailsModel? loadedShippingDetails;
  String shpFromGregorian = DateTime.now().toFormattedDate();
  Jalali shpFromShamsi = DateTime.now().toAfghanShamsi;

  String? usrName;
  String shpToGregorian = DateTime.now().toFormattedDate();
  Jalali shpToShamsi = DateTime.now().toAfghanShamsi;

  final formKey = GlobalKey<FormState>();
  String? currentLocale;

  int? customerId;
  int? vehicleId;
  String? unit;

  // Add these for expense management
  ShippingExpenseModel? _selectedExpenseForEdit;
  bool _isExpenseFormLoading = false;

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          _clearExpenseForm();
        }
        if (state is ShippingErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ShippingDetailLoadingState) {
          loadedShippingDetails = state.currentShipping;
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
          const SizedBox(height: 10),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Loading shipping details'),
          const SizedBox(height: 10),
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
        width: MediaQuery.sizeOf(context).width * .7,
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
            onFinish: onSubmit
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
                content: _buildFinishShipping(),
                icon: Icons.check_circle,
              ),
            ],
            onFinish: onSubmit,
          ),
        ),
      ),
    );
  }

  Widget _buildFinishShipping() {
    final tr = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green,
          ),
          SizedBox(height: 20),
          Text(
            "ready to submit",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 10),
          Text(
            "Review",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void onSubmit() {
   // if (!formKey.currentState!.validate()) return;
    final data = ShippingModel(
      shpLoadSize: loadingSize.text,
      shpUnloadSize: unloadingSize.text,
      shpTo: shpTo.text,
      shpFrom: shpFrom.text,
      shpRent: shippingRent.text.cleanAmount,
      productId: int.tryParse(productId.text),
      vehicleId: vehicleId,
      customerId: customerId,
      shpArriveDate: DateTime.tryParse(shpToGregorian),
      shpMovingDate: DateTime.tryParse(shpFromGregorian),
      usrName: usrName ?? "",
      advanceAmount: advanceAmount.text.cleanAmount,
      remark: remark.text,
      shpId: loadedShippingDetails?.shpId,
      shpUnit: unit ?? "TN",
    );

    final bloc = context.read<ShippingBloc>();
    if (widget.shippingId == null) {
      bloc.add(AddShippingEvent(data));
    } else {
      bloc.add(UpdateShippingEvent(data));
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
            const Text('No income yet'),
        ],
      ),
    );
  }

  Widget _buildExpensesView(ShippingDetailsModel shipping) {
    final tr = AppLocalizations.of(context)!;
    final expenses = shipping.expenses ?? [];
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<ShippingBloc, ShippingState>(
      builder: (context, state) {
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
                              label: state is ShippingLoadingState
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              )
                                  : Text(_selectedExpenseForEdit != null ? tr.update : tr.create),
                              onPressed: () {
                                _handleExpenseAction();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: GenericTextfield<GlAccountsModel, GlAccountsBloc, GlAccountsState>(
                            showAllOnFocus: true,
                            controller: accountController,
                            title: tr.accounts,
                            hintText: tr.accNameOrNumber,
                            isRequired: true,
                            bloc: context.read<GlAccountsBloc>(),
                            fetchAllFunction: (bloc) => bloc.add(
                              LoadGlAccountEvent(
                                local: currentLocale ?? "en",
                                categories: [4],
                              ),
                            ),
                            searchFunction: (bloc, query) => bloc.add(
                              LoadGlAccountEvent(
                                local: currentLocale ?? "en",
                                categories: [4],
                                search: query,
                              ),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
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
                            stateToLoading: (state) => state is GlAccountsLoadingState,
                            loadingBuilder: (context) => const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                            stateToItems: (state) {
                              if (state is GlAccountLoadedState) {
                                return state.gl;
                              }
                              return [];
                            },
                            onSelected: (value) {
                              setState(() {
                                expenseAccNumber = value.accNumber;
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
                        padding: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 180,
                                child: Text(tr.referenceNumber,style: textTheme.titleSmall)),
                            SizedBox(
                                width: 100,
                                child: Text(tr.accountNumber,style: textTheme.titleSmall)),
                            SizedBox(
                                width: 150,
                                child: Text(tr.accountName,style: textTheme.titleSmall)),
                            Expanded(
                                child: Text(tr.narration,style: textTheme.titleSmall)),
                            SizedBox(
                              width: 100,
                                child: Text(tr.amount,style: textTheme.titleSmall)),
                            SizedBox(
                              width: 50,
                            )
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
                            return SingleChildScrollView(
                              child: InkWell(
                                onTap: ()=> _loadExpenseForEdit(expense),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedExpenseForEdit?.trdReference == expense.trdReference
                                        ? color.primary.withValues(alpha: .1)
                                        : index.isEven
                                        ? color.primary.withValues(alpha: .05)
                                        : Colors.transparent,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: 180,
                                          child: Text(expense.trdReference??"")),
                                      SizedBox(
                                          width: 100,
                                          child: Text(expense.accNumber.toString())),
                                      SizedBox(
                                          width: 150,
                                          child: Text(expense.accName??"")),
                                      Expanded(child: Text(expense.narration??"")),
                                      SizedBox(
                                        width: 100,
                                        child: Text("${expense.amount?.toAmount()} ${expense.currency}",
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(),
                                        ),
                                      ),

                                      SizedBox(
                                        width: 50,
                                        child: InkWell(
                                            onTap: ()=> _showDeleteConfirmationDialog(expense),
                                            child: Icon(Icons.delete,color: color.error)),
                                      )


                                    ],
                                  )
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

  void _clearExpenseForm() {
    expenseAmount.clear();
    expenseNarration.clear();
    accountController.clear();
    expenseAccNumber = null;
    _selectedExpenseForEdit = null;
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
    if (expenseAccNumber == null || expenseAmount.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.required("Fields")),
        ),
      );
      return;
    }

    if (_selectedExpenseForEdit != null) {
      // Update existing expense
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
      // Add new expense
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
            onYes: (){
              context.read<ShippingBloc>().add(
                DeleteShippingExpenseEvent(
                  shpId: widget.shippingId!,
                  trnReference: expense.trdReference!,
                  usrName: usrName ?? "",
                ),
              );
            });
      },
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