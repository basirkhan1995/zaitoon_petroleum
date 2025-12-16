import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Shipping/Ui/ShippingView/model/shp_details_model.dart';

import '../model/shipping_model.dart';

part 'shipping_event.dart';
part 'shipping_state.dart';


class ShippingBloc extends Bloc<ShippingEvent, ShippingState> {
  final Repositories _repo;

  ShippingBloc(this._repo) : super(ShippingInitial()) {
    // All operations in one BLoC
    on<LoadShippingEvent>(_onLoadShipping);
    on<AddShippingEvent>(_onAddShipping);
    on<UpdateShippingEvent>(_onUpdateShipping);


    // Detail operations
    on<LoadShippingDetailEvent>(_onLoadShippingDetail);
    on<UpdateStepperStepEvent>(_onUpdateStepperStep);
  }

  // Load all shipping - ALWAYS preserves list
  Future<void> _onLoadShipping(
      LoadShippingEvent event,
      Emitter<ShippingState> emit,
      ) async {
    emit(ShippingLoadingState(shippingList: state.shippingList));

    try {
      final shippingList = await _repo.getShipping();
      emit(ShippingListLoadedState(shippingList: shippingList));
    } catch (e) {
      emit(ShippingErrorState(
        shippingList: state.shippingList,
        error: 'Failed to load shipping: $e',
      ));
    }
  }

  // Load single shipping details - Preserves list
  Future<void> _onLoadShippingDetail(
      LoadShippingDetailEvent event,
      Emitter<ShippingState> emit,
      ) async {
    // Show loading state for details
    emit(ShippingDetailLoadingState(
      shippingList: state.shippingList,
      loadingShpId: event.shpId,
    ));

    try {
      final shippingDetail = await _repo.getShippingById(shpId: event.shpId);

      emit(ShippingDetailLoadedState(
        shippingList: state.shippingList,
        currentShipping: shippingDetail,
        currentStep: 0,
      ));
    } catch (e) {
      // Fallback: find in existing list
      final shippingFromList = state.shippingList.firstWhereOrNull((shp) => shp.shpId == event.shpId);

      if (shippingFromList != null) {
        final basicDetail = ShippingDetailsModel(
          shpId: shippingFromList.shpId,
          vehicle: shippingFromList.vehicle,
          vclId: shippingFromList.vehicleId ?? shippingFromList.vehicleId,
          proName: shippingFromList.proName,
          proId: shippingFromList.productId ?? shippingFromList.productId,
          customer: shippingFromList.customer,
          shpFrom: shippingFromList.shpFrom,
          shpMovingDate: shippingFromList.shpMovingDate,
          shpLoadSize: shippingFromList.shpLoadSize,
          shpUnit: shippingFromList.shpUnit,
          shpTo: shippingFromList.shpTo,
          shpArriveDate: shippingFromList.shpArriveDate,
          shpUnloadSize: shippingFromList.shpUnloadSize,
          shpRent: shippingFromList.shpRent,
          total: shippingFromList.total,
          shpStatus: shippingFromList.shpStatus,
          income: [],
          expenses: [],
        );

        emit(ShippingDetailLoadedState(
          shippingList: state.shippingList,
          currentShipping: basicDetail,
          currentStep: 0,
        ));
      } else {
        emit(ShippingErrorState(
          shippingList: state.shippingList,
          error: 'Shipping not found',
        ));
      }
    }
  }

  // Add new shipping
  Future<void> _onAddShipping(
      AddShippingEvent event,
      Emitter<ShippingState> emit,
      ) async {
    try {
      final res = await _repo.addShipping(newShipping: event.newShipping);

      if (res['msg'] == "success") {
        // Reload the list to include new item
        final updatedList = await _repo.getShipping();

        emit(ShippingSuccessState(
          shippingList: updatedList,
          message: 'Shipping added successfully',
        ));
      }
    } catch (e) {
      emit(ShippingErrorState(
        shippingList: state.shippingList,
        error: 'Failed to add shipping: $e',
      ));
    }
  }

  // Update shipping
  Future<void> _onUpdateShipping(
      UpdateShippingEvent event,
      Emitter<ShippingState> emit,
      ) async {
    try {
      final res = await _repo.updateShipping(newShipping: event.updatedShipping);

      if (res['msg'] == "success") {
        // Update in local list
        final updatedList = state.shippingList.map((shp) {
          if (shp.shpId == event.updatedShipping.shpId) {
            return event.updatedShipping;
          }
          return shp;
        }).toList();

        // Update current shipping if it's the same
        ShippingDetailsModel? updatedCurrentShipping;
        if (state.currentShipping?.shpId == event.updatedShipping.shpId) {
          updatedCurrentShipping = ShippingDetailsModel(
            shpId: event.updatedShipping.shpId,
            vehicle: event.updatedShipping.vehicle,
            vclId: event.updatedShipping.vehicleId,
            proName: event.updatedShipping.proName,
            proId: event.updatedShipping.productId,
            customer: event.updatedShipping.customer,
            shpFrom: event.updatedShipping.shpFrom,
            shpMovingDate: event.updatedShipping.shpMovingDate,
            shpLoadSize: event.updatedShipping.shpLoadSize,
            shpUnit: event.updatedShipping.shpUnit,
            shpTo: event.updatedShipping.shpTo,
            shpArriveDate: event.updatedShipping.shpArriveDate,
            shpUnloadSize: event.updatedShipping.shpUnloadSize,
            shpRent: event.updatedShipping.shpRent,
            total: event.updatedShipping.total,
            shpStatus: event.updatedShipping.shpStatus,
            income: state.currentShipping?.income ?? [],
            expenses: state.currentShipping?.expenses ?? [],
          );
        }

        emit(ShippingSuccessState(
          shippingList: updatedList,
          message: 'Shipping updated successfully',
        ));

        if (updatedCurrentShipping != null) {
          emit(ShippingDetailLoadedState(
            shippingList: updatedList,
            currentShipping: updatedCurrentShipping,
            currentStep: state is ShippingDetailLoadedState
                ? (state as ShippingDetailLoadedState).currentStep
                : 0,
          ));
        }
      }
    } catch (e) {
      emit(ShippingErrorState(
        shippingList: state.shippingList,
        error: 'Failed to update shipping: $e',
      ));
    }
  }

  // Update stepper step
  void _onUpdateStepperStep(
      UpdateStepperStepEvent event,
      Emitter<ShippingState> emit,
      ) {
    if (state is ShippingDetailLoadedState) {
      final currentState = state as ShippingDetailLoadedState;
      emit(currentState.copyWith(currentStep: event.step));
    }
  }
}
