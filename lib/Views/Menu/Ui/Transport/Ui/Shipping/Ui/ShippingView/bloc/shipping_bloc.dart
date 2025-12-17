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
    on<LoadShippingEvent>(_onLoadShipping);
    on<LoadShippingDetailEvent>(_onLoadShippingDetail);
    on<UpdateStepperStepEvent>(_onUpdateStepperStep);
    on<AddShippingEvent>(_onAddShipping);
    on<UpdateShippingEvent>(_onUpdateShipping);
    on<ClearShippingDetailEvent>(_onClearShippingDetail);
    on<AddShippingExpenseEvent>(_onAddShippingExpense);
    on<UpdateShippingExpenseEvent>(_onUpdateShippingExpense);
    on<DeleteShippingExpenseEvent>(_onDeleteShippingExpense);
  }

  Future<void> _onLoadShipping(
      LoadShippingEvent event,
      Emitter<ShippingState> emit,
      ) async {
    // Preserve current shipping details while loading new list
    emit(ShippingLoadingState(
      shippingList: state.shippingList,
      currentShipping: state.currentShipping,
    ));

    try {
      final shippingList = await _repo.getAllShipping();
      emit(ShippingListLoadedState(
        shippingList: shippingList,
        currentShipping: state.currentShipping,
      ));
    } catch (e) {
      emit(ShippingErrorState(
        shippingList: state.shippingList,
        currentShipping: state.currentShipping,
        error: 'Failed to load shipping: $e',
      ));
    }
  }

  Future<void> _onLoadShippingDetail(
      LoadShippingDetailEvent event,
      Emitter<ShippingState> emit,
      ) async {
    // Show loading state while preserving the list
    emit(ShippingDetailLoadingState(
      shippingList: state.shippingList,
      currentShipping: state.currentShipping,
      loadingShpId: event.shpId,
    ));

    try {
      final shippingDetail = await _repo.getShippingById(shpId: event.shpId);

      // Update the list item if it exists
      final updatedList = state.shippingList.map((shp) {
        if (shp.shpId == event.shpId) {
          // Update basic info from details
          return shp.copyWith(
            shpUnloadSize: shippingDetail.shpUnloadSize,
            total: shippingDetail.total,
            shpStatus: shippingDetail.shpStatus,
          );
        }
        return shp;
      }).toList();

      emit(ShippingDetailLoadedState(
        shippingList: updatedList,
        currentShipping: shippingDetail,
        currentStep: 0,
      ));
    } catch (e) {
      // Fallback: try to find in existing list
      final shippingFromList = state.shippingList.firstWhereOrNull(
            (shp) => shp.shpId == event.shpId,
      );

      if (shippingFromList != null) {
        // Convert basic model to details model
        final basicDetail = ShippingDetailsModel(
          shpId: shippingFromList.shpId ?? 0,
          vehicle: shippingFromList.vehicle ?? '',
          vclId: shippingFromList.vehicleId ?? 0,
          proName: shippingFromList.proName ?? '',
          proId: shippingFromList.productId ?? 0,
          customer: shippingFromList.customer ?? '',
          shpFrom: shippingFromList.shpFrom ?? '',
         // shpMovingDate: shippingFromList.shpMovingDate ?? '',
          shpLoadSize: shippingFromList.shpLoadSize ?? '',
          shpUnit: shippingFromList.shpUnit ?? '',
          shpTo: shippingFromList.shpTo ?? '',
        //  shpArriveDate: shippingFromList.shpArriveDate ?? '',
          shpUnloadSize: shippingFromList.shpUnloadSize ?? '',
          shpRent: shippingFromList.shpRent ?? '',
          total: shippingFromList.total ?? '',
          shpStatus: shippingFromList.shpStatus ?? 0,
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
          currentShipping: state.currentShipping,
          error: 'Shipping not found: $e',
        ));
      }
    }
  }

  void _onClearShippingDetail(
      ClearShippingDetailEvent event,
      Emitter<ShippingState> emit,
      ) {
    // Clear details but keep the list
    emit(ShippingListLoadedState(
      shippingList: state.shippingList,
      currentShipping: null,
    ));
  }

  void _onUpdateStepperStep(
      UpdateStepperStepEvent event,
      Emitter<ShippingState> emit,
      ) {
    if (state is ShippingDetailLoadedState) {
      final currentState = state as ShippingDetailLoadedState;
      emit(currentState.copyWith(currentStep: event.step));
    }
  }

  Future<void> _onAddShipping(
      AddShippingEvent event,
      Emitter<ShippingState> emit,
      ) async {
    try {
      final res = await _repo.addShipping(newShipping: event.newShipping);

      if (res['msg'] == "success") {
        // Reload the list to include new item
        final updatedList = await _repo.getAllShipping();

        // Check if we need to update current shipping
        ShippingDetailsModel? updatedCurrentShipping = state.currentShipping;

        emit(ShippingSuccessState(
          shippingList: updatedList,
          currentShipping: updatedCurrentShipping,
          message: 'Shipping added successfully',
        ));

        // Auto-select the newly added shipping if ID is known
        if (res.containsKey('shpID') && res['shpID'] != null) {
          add(LoadShippingDetailEvent(res['shpID']));
        }
      } else {
        throw Exception(res['msg'] ?? 'Failed to add shipping');
      }
    } catch (e) {
      emit(ShippingErrorState(
        shippingList: state.shippingList,
        currentShipping: state.currentShipping,
        error: 'Failed to add shipping: $e',
      ));
    }
  }

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
        ShippingDetailsModel? updatedCurrentShipping = state.currentShipping;
        if (state.currentShipping?.shpId == event.updatedShipping.shpId) {
          updatedCurrentShipping = ShippingDetailsModel(
            shpId: event.updatedShipping.shpId ?? 0,
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
          currentShipping: updatedCurrentShipping,
          message: 'Shipping updated successfully',
        ));
      } else {
        throw Exception(res['msg'] ?? 'Failed to update shipping');
      }
    } catch (e) {
      emit(ShippingErrorState(
        shippingList: state.shippingList,
        currentShipping: state.currentShipping,
        error: 'Failed to update shipping: $e',
      ));
    }
  }

  Future<void> _onAddShippingExpense(AddShippingExpenseEvent event, Emitter<ShippingState> emit) async {
    if (state.currentShipping == null) return;
    try {
      final res = await _repo.addShippingExpense(
        shpId: event.shpId,
        accNumber: event.accNumber,
        amount: event.amount,
        narration: event.narration,
        usrName: event.usrName,
      );

      if (res['msg'] == "success") {
        // Reload the shipping details to get updated expenses
        add(LoadShippingDetailEvent(event.shpId));
      } else if (res['msg'] == "delivered") {
        // Shipping is already delivered, can't add expenses
        emit(ShippingErrorState(
          shippingList: state.shippingList,
          currentShipping: state.currentShipping,
          error: 'Cannot add expense to delivered shipping',
        ));
      } else {
        throw Exception(res['msg'] ?? 'Failed to add expense');
      }
    } catch (e) {
      emit(ShippingErrorState(
        shippingList: state.shippingList,
        currentShipping: state.currentShipping,
        error: 'Failed to add expense: $e',
      ));
    }
  }

  Future<void> _onUpdateShippingExpense(
      UpdateShippingExpenseEvent event,
      Emitter<ShippingState> emit,
      ) async {
    if (state.currentShipping == null) return;

    try {
      final res = await _repo.updateShippingExpense(
        shpId: event.shpId,
        reference: event.trnReference,
        amount: event.amount,
        narration: event.narration,
        usrName: event.usrName,
      );

      if (res['msg'] == "success") {
        // Reload the shipping details
        add(LoadShippingDetailEvent(event.shpId));

        emit(ShippingSuccessState(
          shippingList: state.shippingList,
          currentShipping: state.currentShipping,
          message: 'Expense updated successfully',
        ));
      } else if (res['msg'] == "delivered") {
        emit(ShippingErrorState(
          shippingList: state.shippingList,
          currentShipping: state.currentShipping,
          error: 'Cannot update expense of delivered shipping',
        ));
      } else {
        throw Exception(res['msg'] ?? 'Failed to update expense');
      }
    } catch (e) {
      emit(ShippingErrorState(
        shippingList: state.shippingList,
        currentShipping: state.currentShipping,
        error: 'Failed to update expense: $e',
      ));
    }
  }

  Future<void> _onDeleteShippingExpense(
      DeleteShippingExpenseEvent event,
      Emitter<ShippingState> emit,
      ) async {
    if (state.currentShipping == null) return;

    try {
      final res = await _repo.deleteShippingExpense(
        shpId: event.shpId,
        trnReference: event.trnReference,
        usrName: event.usrName,
      );

      if (res['msg'] == "success") {
        // Reload the shipping details
        add(LoadShippingDetailEvent(event.shpId));

        emit(ShippingSuccessState(
          shippingList: state.shippingList,
          currentShipping: state.currentShipping,
          message: 'Expense deleted successfully',
        ));
      } else if (res['msg'] == "delivered") {
        emit(ShippingErrorState(
          shippingList: state.shippingList,
          currentShipping: state.currentShipping,
          error: 'Cannot delete expense from delivered shipping',
        ));
      } else {
        throw Exception(res['msg'] ?? 'Failed to delete expense');
      }
    } catch (e) {
      emit(ShippingErrorState(
        shippingList: state.shippingList,
        currentShipping: state.currentShipping,
        error: 'Failed to delete expense: $e',
      ));
    }
  }
}