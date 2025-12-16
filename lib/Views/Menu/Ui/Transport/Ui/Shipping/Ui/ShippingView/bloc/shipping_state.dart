// shipping_state.dart
part of 'shipping_bloc.dart';

abstract class ShippingState extends Equatable {
  final List<ShippingModel> shippingList;
  final ShippingDetailsModel? currentShipping;

  const ShippingState({
    this.shippingList = const [],
    this.currentShipping,
  });

  @override
  List<Object?> get props => [shippingList, currentShipping];
}

class ShippingInitial extends ShippingState {
  const ShippingInitial() : super(shippingList: const []);
}

class ShippingLoadingState extends ShippingState {
  const ShippingLoadingState({
    required super.shippingList,
    super.currentShipping,
  });
}

class ShippingListLoadedState extends ShippingState {
  const ShippingListLoadedState({
    required super.shippingList,
    super.currentShipping,
  });
}

class ShippingDetailLoadingState extends ShippingState {
  final int loadingShpId;

  const ShippingDetailLoadingState({
    required super.shippingList,
    super.currentShipping,
    required this.loadingShpId,
  });

  @override
  List<Object?> get props => [...super.props, loadingShpId];
}

class ShippingDetailLoadedState extends ShippingState {
  final int currentStep;

  const ShippingDetailLoadedState({
    required super.shippingList,
    required super.currentShipping,
    this.currentStep = 0,
  });

  ShippingDetailLoadedState copyWith({
    List<ShippingModel>? shippingList,
    ShippingDetailsModel? currentShipping,
    int? currentStep,
  }) {
    return ShippingDetailLoadedState(
      shippingList: shippingList ?? this.shippingList,
      currentShipping: currentShipping ?? this.currentShipping,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  @override
  List<Object?> get props => [...super.props, currentStep];
}

class ShippingErrorState extends ShippingState {
  final String error;

  const ShippingErrorState({
    required super.shippingList,
    super.currentShipping,
    required this.error,
  });

  @override
  List<Object?> get props => [...super.props, error];
}

class ShippingSuccessState extends ShippingState {
  final String message;

  const ShippingSuccessState({
    required super.shippingList,
    super.currentShipping,
    required this.message,
  });

  @override
  List<Object?> get props => [...super.props, message];
}