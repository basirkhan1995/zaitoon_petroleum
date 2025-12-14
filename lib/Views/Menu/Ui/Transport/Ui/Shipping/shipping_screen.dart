import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../Features/Widgets/stepper.dart';
import 'Ui/ShippingView/View/ShippingExpense/shipping_expense.dart';
import 'Ui/ShippingView/View/add_edit_shipping.dart';

class ShippingScreen extends StatelessWidget {

  const ShippingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(),
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

class _Desktop extends StatelessWidget {

  const _Desktop();

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: SizedBox(
          width: MediaQuery.sizeOf(context).width * .5,
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(5)
            ),
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
                  title: tr.advancePayment,
                  content: Text(tr.payment),
                  icon: Icons.data_exploration,
                ),
                StepItem(
                  title: tr.expense,
                  content: Text(tr.expense),
                  icon: Icons.data_exploration,
                ),
                StepItem(
                  title: 'Delivered',
                  content: Text('Delivered confirmation'),
                  icon: Icons.check_circle,
                ),
              ],
              onFinish: (){

              },
            ),
          )
        ),
      ),
    );
  }
}
