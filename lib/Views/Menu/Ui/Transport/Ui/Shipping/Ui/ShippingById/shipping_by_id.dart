import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../../../Features/Widgets/stepper.dart';
import '../ShippingView/View/ShippingExpense/shipping_expense.dart';
import '../ShippingView/View/add_edit_shipping.dart';
import '../ShippingView/bloc/shipping_bloc.dart';
import '../ShippingView/model/shipping_model.dart';
import '../ShippingView/model/shp_details_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width * .6,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: CustomStepper(
            steps: [
              StepItem(
                title: tr.order,
                content: Expanded(
                  child: AddEditShippingView(
                    model: _convertToShippingModel(state.currentShipping!),
                  ),
                ),
                icon: Icons.shopping_cart,
              ),
              StepItem(
                title: tr.shipping,
                content: Expanded(
                  child: ShippingExpenseView(),
                ),
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
                content: const Expanded(child: AddEditShippingView()),
                icon: Icons.shopping_cart,
              ),
              StepItem(
                title: tr.shipping,
                content: const Expanded(child: ShippingExpenseView()),
                icon: Icons.local_shipping,
              ),
              StepItem(
                title: tr.advancePayment,
                content: const Text('Advance Payment'),
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