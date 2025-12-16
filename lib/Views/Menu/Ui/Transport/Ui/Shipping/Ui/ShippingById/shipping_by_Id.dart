
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../../../Features/Widgets/stepper.dart';
import '../../../../../../../../Services/repositories.dart';
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
    return BlocProvider(
      create: (context) => ShippingBloc(RepositoryProvider.of<Repositories>(context)),
      child: ResponsiveLayout(
        mobile: _Mobile(shippingId: shippingId),
        desktop: _Desktop(shippingId: shippingId),
        tablet: _Tablet(shippingId: shippingId),
      ),
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
      content: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading shipping details...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDialog(String error, BuildContext context) {
    return AlertDialog(
      content: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
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
                content: Expanded(child: AddEditShippingView()),
                icon: Icons.shopping_cart,
              ),
              StepItem(
                title: tr.shipping,
                content: Expanded(child: ShippingExpenseView()),
                icon: Icons.local_shipping,
              ),
              StepItem(
                title: tr.expense,
                content: Text(tr.expense),
                icon: Icons.data_exploration,
              ),
              StepItem(
                title: tr.income,
                content: Text(tr.income),
                icon: Icons.data_exploration,
              ),
              StepItem(
                title: 'Delivered',
                content: Text('Delivered confirmation'),
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
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.income,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          if (shipping.income != null && shipping.income!.isNotEmpty)
            ...shipping.income!.map((income) => Cover(
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 5),
                leading: Icon(Icons.attach_money, color: Colors.green),
                title: Text(income.accName ?? ''),
                subtitle: Text(income.narration ?? ''),
                trailing: Text(
                  '${income.amount?.toAmount()} ${income.currency}',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            )).toList()
          else
            Text('No income yet'),
        ],
      ),
    );
  }

  Widget _buildExpensesView(ShippingDetailsModel shipping) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Your expense form...
            Text(
              AppLocalizations.of(context)!.expense,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            if (shipping.expenses != null && shipping.expenses!.isNotEmpty)
              ...shipping.expenses!.map((expense) => Cover(
                child: ListTile(
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  title: Text(expense.accName ?? ''),
                  subtitle: Text(expense.narration ?? ''),
                  trailing: Text(
                    '${expense.amount?.toAmount()} ${expense.currency}',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              )).toList()
            else
              Text(AppLocalizations.of(context)!.noExpenseRecorded),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryView(ShippingDetailsModel shipping) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            shipping.shpStatus == 1 ? Icons.check_circle : Icons.schedule,
            size: 60,
            color: shipping.shpStatus == 1 ? Colors.green : Colors.orange,
          ),
          SizedBox(height: 16),
          Text(
            shipping.shpStatus == 1 ? 'Delivered' : 'Pending',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
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