// shipping_state.dart
part of 'shipping_bloc.dart';

abstract class ShippingState extends Equatable {
  final List<ShippingModel> shippingList; // Always keep the list
  final ShippingDetailsModel? currentShipping;

  const ShippingState({
    this.shippingList = const [],
    this.currentShipping,
  });

  @override
  List<Object?> get props => [shippingList, currentShipping];
}

// Initial state
class ShippingInitial extends ShippingState {
  const ShippingInitial() : super(shippingList: const []);
}

// Loading all shipping
class ShippingLoadingState extends ShippingState {
  const ShippingLoadingState({super.shippingList});
}

// List loaded successfully
class ShippingListLoadedState extends ShippingState {
  const ShippingListLoadedState({required super.shippingList});
}

// Loading single shipping details
class ShippingDetailLoadingState extends ShippingState {
  final int loadingShpId;

  const ShippingDetailLoadingState({
    required super.shippingList,
    required this.loadingShpId,
  });

  @override
  List<Object?> get props => [super.props, loadingShpId];
}

// Single shipping loaded with details (for stepper)
class ShippingDetailLoadedState extends ShippingState {
  final int currentStep;

  const ShippingDetailLoadedState({
    required super.shippingList,
    required super.currentShipping,
    this.currentStep = 0,
  });

  // CopyWith for stepper navigation
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
  List<Object?> get props => [super.props, currentStep];
}

// Error state
class ShippingErrorState extends ShippingState {
  final String error;

  const ShippingErrorState({
    required super.shippingList,
    required this.error,
  });

  @override
  List<Object?> get props => [super.props, error];
}

// Success state (for CRUD operations)
class ShippingSuccessState extends ShippingState {
  final String message;

  const ShippingSuccessState({
    required super.shippingList,
    required this.message,
  });

  @override
  List<Object?> get props => [super.props, message];
}