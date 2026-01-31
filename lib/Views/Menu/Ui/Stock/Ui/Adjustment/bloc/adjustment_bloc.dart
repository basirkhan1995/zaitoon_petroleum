import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';

import '../model/adj_items.dart';
import '../model/adjustment_model.dart';

part 'adjustment_event.dart';
part 'adjustment_state.dart';

class AdjustmentBloc extends Bloc<AdjustmentEvent, AdjustmentState> {
  final Repositories repo;

  // Keep track of loaded adjustments
  List<AdjustmentModel> _adjustments = [];

  AdjustmentBloc(this.repo) : super(AdjustmentInitial()) {
    on<InitializeAdjustmentEvent>(_onInitialize);
    on<LoadAdjustmentsEvent>(_onLoadAdjustments);
    on<SelectExpenseAccountEvent>(_onSelectExpenseAccount);
    on<ClearExpenseAccountEvent>(_onClearExpenseAccount);
    on<AddNewAdjustmentItemEvent>(_onAddNewItem);
    on<RemoveAdjustmentItemEvent>(_onRemoveItem);
    on<UpdateAdjustmentItemEvent>(_onUpdateItem);
    on<ResetAdjustmentEvent>(_onReset);
    on<SaveAdjustmentEvent>(_onSaveAdjustment);
  }

  void _onInitialize(InitializeAdjustmentEvent event, Emitter<AdjustmentState> emit) {
    emit(AdjustmentFormLoaded(
      items: [AdjustmentItem(
        productId: '',
        productName: '',
        quantity: 1,
        purPrice: 0,
        storageName: '',
        storageId: 0,
      )],
    ));
  }

  Future<void> _onLoadAdjustments(LoadAdjustmentsEvent event, Emitter<AdjustmentState> emit) async {
    emit(AdjustmentLoading());
    try {
      _adjustments = await repo.allAdjustments();
      emit(AdjustmentListLoaded(_adjustments));
    } catch (e) {
      emit(AdjustmentError(e.toString()));
    }
  }

  void _onSelectExpenseAccount(SelectExpenseAccountEvent event, Emitter<AdjustmentState> emit) {
    if (state is AdjustmentFormLoaded) {
      final current = state as AdjustmentFormLoaded;
      emit(current.copyWith(expenseAccount: event.account));
    }
  }

  void _onClearExpenseAccount(ClearExpenseAccountEvent event, Emitter<AdjustmentState> emit) {
    if (state is AdjustmentFormLoaded) {
      final current = state as AdjustmentFormLoaded;
      emit(current.copyWith(expenseAccount: null));
    }
  }

  void _onAddNewItem(AddNewAdjustmentItemEvent event, Emitter<AdjustmentState> emit) {
    if (state is! AdjustmentFormLoaded) return;
    final current = state as AdjustmentFormLoaded;

    final newItem = AdjustmentItem(
      productId: '',
      productName: '',
      quantity: 1,
      purPrice: 0,
      storageName: '',
      storageId: 0,
    );

    final updatedItems = List<AdjustmentItem>.from(current.items)..add(newItem);
    emit(current.copyWith(items: updatedItems));
  }

  void _onRemoveItem(RemoveAdjustmentItemEvent event, Emitter<AdjustmentState> emit) {
    if (state is AdjustmentFormLoaded) {
      final current = state as AdjustmentFormLoaded;
      final updatedItems = current.items.where((item) => item.rowId != event.rowId).toList();

      if (updatedItems.isEmpty) {
        updatedItems.add(AdjustmentItem(
          productId: '',
          productName: '',
          quantity: 1,
          purPrice: 0,
          storageName: '',
          storageId: 0,
        ));
      }

      emit(current.copyWith(items: updatedItems));
    }
  }

  void _onUpdateItem(UpdateAdjustmentItemEvent event, Emitter<AdjustmentState> emit) {
    if (state is AdjustmentFormLoaded) {
      final current = state as AdjustmentFormLoaded;
      final updatedItems = current.items.map((item) {
        if (item.rowId == event.rowId) {
          return AdjustmentItem(
            itemId: item.rowId,
            productId: event.productId ?? item.productId,
            productName: event.productName ?? item.productName,
            quantity: event.quantity ?? item.quantity,
            purPrice: event.purPrice ?? item.purPrice,
            storageName: event.storageName ?? item.storageName,
            storageId: event.storageId ?? item.storageId,
          );
        }
        return item;
      }).toList();

      emit(current.copyWith(items: updatedItems));
    }
  }

  void _onReset(ResetAdjustmentEvent event, Emitter<AdjustmentState> emit) {
    emit(AdjustmentFormLoaded(
      items: [AdjustmentItem(
        productId: '',
        productName: '',
        quantity: 1,
        purPrice: 0,
        storageName: '',
        storageId: 0,
      )],
    ));
  }

  Future<void> _onSaveAdjustment(SaveAdjustmentEvent event, Emitter<AdjustmentState> emit) async {
    if (state is! AdjustmentFormLoaded) {
      event.completer.complete('');
      return;
    }

    final current = state as AdjustmentFormLoaded;
    final savedState = current.copyWith();

    // Validate form
    if (event.expenseAccount == 0) {
      emit(AdjustmentError('Please select an expense account'));
      emit(savedState);
      event.completer.complete('');
      return;
    }

    if (event.items.isEmpty) {
      emit(AdjustmentError('Please add at least one item'));
      emit(savedState);
      event.completer.complete('');
      return;
    }

    for (var i = 0; i < event.items.length; i++) {
      final item = event.items[i];
      if (item.productId.isEmpty) {
        emit(AdjustmentError('Please select a product for item ${i + 1}'));
        emit(savedState);
        event.completer.complete('');
        return;
      }
      if (item.storageId == 0) {
        emit(AdjustmentError('Please select a storage for item ${i + 1}'));
        emit(savedState);
        event.completer.complete('');
        return;
      }
      if (item.purPrice == null || item.purPrice! <= 0) {
        emit(AdjustmentError('Please enter a valid purchase price for item ${i + 1}'));
        emit(savedState);
        event.completer.complete('');
        return;
      }
      if (item.quantity <= 0) {
        emit(AdjustmentError('Please enter a valid quantity for item ${i + 1}'));
        emit(savedState);
        event.completer.complete('');
        return;
      }
    }

    emit(AdjustmentSaving(
      items: event.items,
      expenseAccount: event.expenseAccount,
      xRef: event.xRef,
    ));

    try {
      final records = event.items.map((item) {
        return {
          'stkProduct': int.tryParse(item.productId) ?? 0,
          'stkStorage': item.storageId,
          'stkQuantity': item.quantity,
          'stkPurPrice': item.purPrice,
        };
      }).toList();

      final response = await repo.addAdjustment(
        usrName: event.usrName,
        xReference: event.xRef,
        xAccount: event.expenseAccount,
        records: records,
      );

      final message = response['msg']?.toString() ?? 'No response message';

      if (message.toLowerCase().contains('success') ||
          message.toLowerCase().contains('authorized')) {
        String adjustmentNumber = response['ordxRef']?.toString() ?? 'Generated';

        // Add the new adjustment to the list
        final newAdjustment = AdjustmentModel(
          ordId: int.tryParse(response['ordID']?.toString() ?? '0'),
          ordName: response['ordName']?.toString(),
          ordxRef: adjustmentNumber,
          account: event.expenseAccount,
          amount: event.items.fold(0.0, (sum, item) => sum + item.totalCost).toString(),
          trnStateText: 'Authorized',
          ordEntryDate: DateTime.now(),
        );

        _adjustments.insert(0, newAdjustment);

        emit(AdjustmentSaved(true, adjustmentNumber: adjustmentNumber));
        emit(AdjustmentListLoaded(_adjustments));
        add(ResetAdjustmentEvent());
        event.completer.complete(adjustmentNumber);
      } else {
        String errorMessage;
        final msgLower = message.toLowerCase();

        if (msgLower.contains('not enough')) {
          errorMessage = 'Insufficient stock for adjustment';
        } else if (msgLower.contains('large')) {
          errorMessage = 'Adjustment quantity exceeds available stock';
        } else if (msgLower.contains('failed')) {
          errorMessage = 'Adjustment creation failed. Please try again.';
        } else {
          errorMessage = message;
        }

        emit(AdjustmentError(errorMessage));
        emit(savedState);
        event.completer.complete('');
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('DioException')) {
        errorMessage = 'Network error: Please check your connection';
      }

      emit(AdjustmentError(errorMessage));
      emit(savedState);
      event.completer.complete('');
    }
  }
}