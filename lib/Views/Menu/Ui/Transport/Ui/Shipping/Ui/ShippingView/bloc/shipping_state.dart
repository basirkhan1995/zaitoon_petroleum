part of 'shipping_bloc.dart';

abstract class ShippingState extends Equatable {
  final List<ShippingModel> shippingList;
  final ShippingDetailsModel? currentShipping;
  final int? loadingShpId;

  const ShippingState({
    this.shippingList = const [],
    this.currentShipping,
    this.loadingShpId,
  });

  @override
  List<Object?> get props => [shippingList, currentShipping, loadingShpId];

  ShippingState copyWith({
    List<ShippingModel>? shippingList,
    ShippingDetailsModel? currentShipping,
    int? loadingShpId,
  });
}

class ShippingInitial extends ShippingState {
  const ShippingInitial() : super(shippingList: const []);

  @override
  ShippingInitial copyWith({
    List<ShippingModel>? shippingList,
    ShippingDetailsModel? currentShipping,
    int? loadingShpId,
  }) {
    return ShippingInitial();
  }
}

class ShippingListLoadingState extends ShippingState {
  const ShippingListLoadingState({
    required super.shippingList,
    super.currentShipping,
    super.loadingShpId,
  });

  @override
  ShippingListLoadingState copyWith({
    List<ShippingModel>? shippingList,
    ShippingDetailsModel? currentShipping,
    int? loadingShpId,
  }) {
    return ShippingListLoadingState(
      shippingList: shippingList ?? this.shippingList,
      currentShipping: currentShipping ?? this.currentShipping,
      loadingShpId: loadingShpId ?? this.loadingShpId,
    );
  }
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
  });

  @override
  ShippingDetailLoadedState copyWith({
    List<ShippingModel>? shippingList,
    ShippingDetailsModel? currentShipping,
    int? loadingShpId,
  }) {
    return ShippingDetailLoadedState(
      shippingList: shippingList ?? this.shippingList,
      currentShipping: currentShipping ?? this.currentShipping,
      loadingShpId: loadingShpId ?? this.loadingShpId,
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