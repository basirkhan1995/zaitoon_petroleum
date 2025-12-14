part of 'shipping_expense_bloc.dart';

sealed class ShippingExpenseState extends Equatable {
  const ShippingExpenseState();
}

final class ShippingExpenseInitial extends ShippingExpenseState {
  @override
  List<Object> get props => [];
}
