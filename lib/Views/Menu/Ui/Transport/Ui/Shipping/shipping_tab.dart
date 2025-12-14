import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Shipping/Ui/ShippingExpense/shipping_expense.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Shipping/Ui/ShippingView/add_edit_shipping.dart';
import '../../../../../../Features/Widgets/stepper.dart';

class ShippingTabView extends StatefulWidget {
  const ShippingTabView({super.key});

  @override
  State<ShippingTabView> createState() => _ShippingTabViewState();
}

class _ShippingTabViewState extends State<ShippingTabView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomStepper(
        steps: [
          StepItem(
            title: 'Order',
            content: Expanded(child: AddEditShippingView()),
            icon: Icons.shopping_cart,
          ),
          StepItem(
            title: 'Shipping',
            content: Expanded(child: ShippingExpenseView()),
            icon: Icons.local_shipping,
          ),
          StepItem(
            title: "Advance Payment",
            content: Text("Payment"),
            icon: Icons.data_exploration,
          ),
          StepItem(
            title: 'Expenses',
            content: Text("Expenses"),
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
    );
  }

}
