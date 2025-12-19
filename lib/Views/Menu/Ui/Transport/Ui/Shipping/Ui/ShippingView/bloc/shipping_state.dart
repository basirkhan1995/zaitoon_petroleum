part of 'shipping_bloc.dart';

abstract class ShippingState extends Equatable {
  final List<ShippingModel> shippingList;
  final ShippingDetailsModel? currentShipping;
  final int? loadingShpId;
  final bool shouldOpenDialog;

  const ShippingState({
    this.shippingList = const [],
    this.currentShipping,
    this.loadingShpId,
    this.shouldOpenDialog = false,
  });

  @override
  List<Object?> get props => [shippingList, currentShipping, loadingShpId, shouldOpenDialog];

  ShippingState copyWith({
    List<ShippingModel>? shippingList,
    ShippingDetailsModel? currentShipping,
    int? loadingShpId,
    bool? shouldOpenDialog,
  });
}

class ShippingInitial extends ShippingState {
  const ShippingInitial() : super(shippingList: const []);

  @override
  ShippingInitial copyWith({
    List<ShippingModel>? shippingList,
    ShippingDetailsModel? currentShipping,
    int? loadingShpId,
    bool? shouldOpenDialog,
  }) {
    return ShippingInitial();
  }
}

class ShippingListLoadingState extends ShippingState {
  final bool isLoading;

  const ShippingListLoadingState({
    required super.shippingList,
    super.currentShipping,
    super.loadingShpId,
    this.isLoading = false,
  });

  @override
  ShippingListLoadingState copyWith({
    List<ShippingModel>? shippingList,
    ShippingDetailsModel? currentShipping,
    int? loadingShpId,
    bool? isLoading,
    bool? shouldOpenDialog,
  }) {
    return ShippingListLoadingState(
      shippingList: shippingList ?? this.shippingList,
      currentShipping: currentShipping ?? this.currentShipping,
      loadingShpId: loadingShpId ?? this.loadingShpId,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [...super.props, isLoading];
}

class ShippingDetailLoadingState extends ShippingState {
  const ShippingDetailLoadingState({
    required super.shippingList,
    super.currentShipping,
    required super.loadingShpId,
  });

  @override
  ShippingDetailLoadingState copyWith({
    List<ShippingModel>? shippingList,
    ShippingDetailsModel? currentShipping,
    int? loadingShpId,
    bool? shouldOpenDialog,
  }) {
    return ShippingDetailLoadingState(
      shippingList: shippingList ?? this.shippingList,
      currentShipping: currentShipping ?? this.currentShipping,
      loadingShpId: loadingShpId ?? this.loadingShpId,
    );
  }
}

class ShippingListLoadedState extends ShippingState {
  const ShippingListLoadedState({
    required super.shippingList,
    super.currentShipping,
    super.loadingShpId,
  });

  @override
  ShippingListLoadedState copyWith({
    List<ShippingModel>? shippingList,
    ShippingDetailsModel? currentShipping,
    int? loadingShpId,
    bool? shouldOpenDialog,
  }) {
    return ShippingListLoadedState(
      shippingList: shippingList ?? this.shippingList,
      currentShipping: currentShipping ?? this.currentShipping,
      loadingShpId: loadingShpId ?? this.loadingShpId,
    );
  }
}

class ShippingDetailLoadedState extends ShippingState {
  const ShippingDetailLoadedState({
    required super.shippingList,
    required super.currentShipping,
    super.loadingShpId,
    super.shouldOpenDialog = true,
  });

  @override
  ShippingDetailLoadedState copyWith({
    List<ShippingModel>? shippingList,
    ShippingDetailsModel? currentShipping,
    int? loadingShpId,
    bool? shouldOpenDialog,
  }) {
    return ShippingDetailLoadedState(
      shippingList: shippingList ?? this.shippingList,
      currentShipping: currentShipping ?? this.currentShipping,
      loadingShpId: loadingShpId ?? this.loadingShpId,
      shouldOpenDialog: shouldOpenDialog ?? this.shouldOpenDialog,
    );
  }
}

class ShippingErrorState extends ShippingState {
  final String error;

  const ShippingErrorState({
    required super.shippingList,
    super.currentShipping,
    super.loadingShpId,
    required this.error,
  });

  @override
  ShippingErrorState copyWith({
    List<ShippingModel>? shippingList,
    ShippingDetailsModel? currentShipping,
    int? loadingShpId,
    String? error,
    bool? shouldOpenDialog,
  }) {
    return ShippingErrorState(
      shippingList: shippingList ?? this.shippingList,
      currentShipping: currentShipping ?? this.currentShipping,
      loadingShpId: loadingShpId ?? this.loadingShpId,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [...super.props, error];
}

class ShippingSuccessState extends ShippingState {
  final String message;

  const ShippingSuccessState({
    required super.shippingList,
    super.currentShipping,
    super.loadingShpId,
    required this.message,
  });

  @override
  ShippingSuccessState copyWith({
    List<ShippingModel>? shippingList,
    ShippingDetailsModel? currentShipping,
    int? loadingShpId,
    String? message,
    bool? shouldOpenDialog,
  }) {
    return ShippingSuccessState(
      shippingList: shippingList ?? this.shippingList,
      currentShipping: currentShipping ?? this.currentShipping,
      loadingShpId: loadingShpId ?? this.loadingShpId,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [...super.props, message];
}