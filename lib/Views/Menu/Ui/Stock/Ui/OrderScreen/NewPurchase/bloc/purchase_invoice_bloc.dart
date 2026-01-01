import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stakeholders/Ui/Individuals/individual_model.dart';
import '../../../../../../../../Services/repositories.dart';
import '../../../../../Settings/Ui/Company/Storage/model/storage_model.dart';
import '../../../../../Stakeholders/Ui/Accounts/model/acc_model.dart';
import '../model/purchase_invoice_items.dart';

part 'purchase_invoice_event.dart';
part 'purchase_invoice_state.dart';

class PurchaseInvoiceBloc extends Bloc<PurchaseInvoiceEvent, PurchaseInvoiceState> {
  final Repositories repo;

  PurchaseInvoiceBloc(this.repo) : super(PurchaseInvoiceInitial()) {
    on<InitializePurchaseInvoiceEvent>(_onInitialize);
    on<SelectSupplierEvent>(_onSelectSupplier);
    on<SelectSupplierAccountEvent>(_onSelectSupplierAccount);
    on<ClearSupplierEvent>(_onClearSupplier);
    on<AddNewPurchaseItemEvent>(_onAddNewItem);
    on<RemovePurchaseItemEvent>(_onRemoveItem);
    on<UpdatePurchaseItemEvent>(_onUpdateItem);
    on<UpdatePurchasePaymentEvent>(_onUpdatePayment);
    on<ResetPurchaseInvoiceEvent>(_onReset);
    on<SavePurchaseInvoiceEvent>(_onSaveInvoice);
    on<LoadPurchaseStoragesEvent>(_onLoadStorages);
  }

  void _onInitialize(InitializePurchaseInvoiceEvent event, Emitter<PurchaseInvoiceState> emit) {
    emit(PurchaseInvoiceLoaded(
      items: [PurchaseInvoiceItem(
        productId: '',
        productName: '',
        qty: 1,
        purPrice: 0,
        storageName: '',
        storageId: 0,
      )],
      payment: 0.0,
      paymentMode: PaymentMode.cash,
    ));
  }

  void _onSelectSupplierAccount(SelectSupplierAccountEvent event, Emitter<PurchaseInvoiceState> emit) {
    if (state is PurchaseInvoiceLoaded) {
      final current = state as PurchaseInvoiceLoaded;

      // Determine payment mode based on current payment amount
      PaymentMode newPaymentMode;

      if (current.payment == 0) {
        // No cash payment = full credit
        newPaymentMode = PaymentMode.credit;
      } else if (current.payment >= current.grandTotal) {
        // Full cash payment
        newPaymentMode = PaymentMode.cash;
      } else if (current.payment > 0 && current.payment < current.grandTotal) {
        // Partial cash payment = mixed
        newPaymentMode = PaymentMode.mixed;
      } else {
        // Default to credit if payment is invalid
        newPaymentMode = PaymentMode.credit;
      }

      emit(current.copyWith(
        supplierAccount: event.supplier,
        paymentMode: newPaymentMode,
      ));
    }
  }

  void _onSelectSupplier(SelectSupplierEvent event, Emitter<PurchaseInvoiceState> emit) {
    if (state is PurchaseInvoiceLoaded) {
      final current = state as PurchaseInvoiceLoaded;
      emit(current.copyWith(supplier: event.supplier));
    }
  }

  void _onClearSupplier(ClearSupplierEvent event, Emitter<PurchaseInvoiceState> emit) {
    if (state is PurchaseInvoiceLoaded) {
      final current = state as PurchaseInvoiceLoaded;
      emit(current.copyWith(
        supplier: null,
        supplierAccount: null,
        paymentMode: PaymentMode.cash,
      ));
    }
  }

  void _onAddNewItem(AddNewPurchaseItemEvent event, Emitter<PurchaseInvoiceState> emit) {
    if (state is! PurchaseInvoiceLoaded) return;
    final current = state as PurchaseInvoiceLoaded;

    final newItem = PurchaseInvoiceItem(
      productId: '',
      productName: '',
      qty: 1,
      purPrice: 0,
      storageName: '',
      storageId: 0,
    );

    final updatedItems = List<PurchaseInvoiceItem>.from(current.items)..add(newItem);
    emit(current.copyWith(items: updatedItems));
  }

  void _onRemoveItem(RemovePurchaseItemEvent event, Emitter<PurchaseInvoiceState> emit) {
    if (state is PurchaseInvoiceLoaded) {
      final current = state as PurchaseInvoiceLoaded;
      final updatedItems = current.items.where((item) => item.rowId != event.rowId).toList();

      if (updatedItems.isEmpty) {
        updatedItems.add(PurchaseInvoiceItem(
          productId: '',
          productName: '',
          qty: 1,
          purPrice: 0,
          storageName: '',
          storageId: 0,
        ));
      }

      emit(current.copyWith(items: updatedItems));
    }
  }

  void _onUpdateItem(UpdatePurchaseItemEvent event, Emitter<PurchaseInvoiceState> emit) {
    if (state is PurchaseInvoiceLoaded) {
      final current = state as PurchaseInvoiceLoaded;
      final updatedItems = current.items.map((item) {
        if (item.rowId == event.rowId) {
          return PurchaseInvoiceItem(
            itemId: item.rowId,
            productId: event.productId ?? item.productId,
            productName: event.productName ?? item.productName,
            qty: event.qty ?? item.qty,
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

  void _onUpdatePayment(UpdatePurchasePaymentEvent event, Emitter<PurchaseInvoiceState> emit) {
    if (state is PurchaseInvoiceLoaded) {
      final current = state as PurchaseInvoiceLoaded;

      double cashPayment;
      double creditAmount;
      PaymentMode newPaymentMode;

      if (event.isCreditAmount) {
        // event.payment contains CREDIT amount
        creditAmount = event.payment;
        cashPayment = current.grandTotal - creditAmount;

        if (creditAmount <= 0) {
          // No credit = full cash
          newPaymentMode = PaymentMode.cash;
          cashPayment = current.grandTotal;
          creditAmount = 0;
        } else if (creditAmount >= current.grandTotal) {
          // Full credit
          newPaymentMode = PaymentMode.credit;
          cashPayment = 0;
          creditAmount = current.grandTotal;
        } else {
          // Mixed
          newPaymentMode = PaymentMode.mixed;
        }
      } else {
        // Original logic: event.payment contains CASH amount
        cashPayment = event.payment;
        creditAmount = current.grandTotal - cashPayment;

        if (cashPayment == 0) {
          newPaymentMode = PaymentMode.credit;
          creditAmount = current.grandTotal;
        } else if (cashPayment >= current.grandTotal) {
          newPaymentMode = PaymentMode.cash;
          cashPayment = current.grandTotal;
          creditAmount = 0;
        } else {
          newPaymentMode = PaymentMode.mixed;
        }
      }

      emit(current.copyWith(
        payment: cashPayment, // Store cash payment in state
        paymentMode: newPaymentMode,
      ));
    }
  }

  void _onReset(ResetPurchaseInvoiceEvent event, Emitter<PurchaseInvoiceState> emit) {
    emit(PurchaseInvoiceLoaded(
      items: [PurchaseInvoiceItem(
        productId: '',
        productName: '',
        qty: 1,
        purPrice: 0,
        storageName: '',
        storageId: 0,
      )],
      payment: 0.0,
      paymentMode: PaymentMode.cash,
    ));
  }

  Future<void> _onSaveInvoice(SavePurchaseInvoiceEvent event, Emitter<PurchaseInvoiceState> emit) async {
    if (state is! PurchaseInvoiceLoaded) {
      event.completer.complete('');
      return;
    }

    final current = state as PurchaseInvoiceLoaded;
    final savedState = current.copyWith();

    // Validate supplier
    if (current.supplier == null) {
      emit(PurchaseInvoiceError('Please select a supplier'));
      emit(savedState);
      event.completer.complete('');
      return;
    }

    // Validate items are not empty
    if (current.items.isEmpty) {
      emit(PurchaseInvoiceError('Please add at least one item'));
      emit(savedState);
      event.completer.complete('');
      return;
    }

    // Validate each item has all required fields
    for (var i = 0; i < current.items.length; i++) {
      final item = current.items[i];
      if (item.productId.isEmpty) {
        emit(PurchaseInvoiceError('Please select a product for item ${i + 1}'));
        emit(savedState);
        event.completer.complete('');
        return;
      }
      if (item.storageId == 0) {
        emit(PurchaseInvoiceError('Please select a storage for item ${i + 1}'));
        emit(savedState);
        event.completer.complete('');
        return;
      }
      if (item.purPrice == null || item.purPrice! <= 0) {
        emit(PurchaseInvoiceError('Please enter a valid price for item ${i + 1}'));
        emit(savedState);
        event.completer.complete('');
        return;
      }
      if (item.qty <= 0) {
        emit(PurchaseInvoiceError('Please enter a valid quantity for item ${i + 1}'));
        emit(savedState);
        event.completer.complete('');
        return;
      }
    }

    // Validate payment based on mode
    if (current.paymentMode == PaymentMode.credit || current.paymentMode == PaymentMode.mixed) {
      if (current.supplierAccount == null) {
        emit(PurchaseInvoiceError('Please select a supplier account for credit payment'));
        emit(savedState);
        event.completer.complete('');
        return;
      }
    }

    if (current.paymentMode == PaymentMode.mixed) {
      if (current.payment <= 0) {
        emit(PurchaseInvoiceError('For mixed payment, cash payment must be greater than 0'));
        emit(savedState);
        event.completer.complete('');
        return;
      }
      if (current.payment >= current.grandTotal) {
        emit(PurchaseInvoiceError('For mixed payment, cash payment must be less than total amount'));
        emit(savedState);
        event.completer.complete('');
        return;
      }
    }

    // Show saving state
    emit(PurchaseInvoiceSaving(
      items: current.items,
      supplier: current.supplier,
      supplierAccount: current.supplierAccount,
      payment: current.payment,
      paymentMode: current.paymentMode,
      storages: current.storages,
    ));

    try {
      // Calculate account and amount for API
      int? accountNumber;
      double amountToSend;

      switch (current.paymentMode) {
        case PaymentMode.cash:
        // Full cash payment - no account needed
          accountNumber = 0; // 0 means cash payment
          amountToSend = current.grandTotal; // Full amount as cash
          break;

        case PaymentMode.credit:
        // Full credit payment - all amount goes to account as credit
          accountNumber = current.supplierAccount!.accNumber;
          amountToSend = 0.0; // No cash payment now
          break;

        case PaymentMode.mixed:
        // Mixed payment: part cash now, rest as credit
          accountNumber = current.supplierAccount!.accNumber;
          amountToSend = current.payment; // Cash portion being paid now
          // The credit portion (current.creditAmount) will automatically go to account
          break;
      }

      // Convert items to records
      final records = current.items.map((item) {
        return PurchaseInvoiceRecord(
          proID: int.tryParse(item.productId) ?? 0,
          stgID: item.storageId,
          quantity: item.qty.toDouble(),
          pPrice: item.purPrice,
        );
      }).toList();

      final xRef = event.xRef ?? 'PUR-${DateTime.now().millisecondsSinceEpoch}';

      // Call API - returns Map<String, dynamic>
      final response = await repo.addInvoice(
        orderName: "Purchase",
        usrName: event.usrName,
        perID: event.ordPersonal,
        xRef: xRef,
        account: accountNumber,
        amount: amountToSend,
        records: records,
      );

      // Extract message from response
      final message = response['msg']?.toString() ?? 'No response message';

      // Handle different response messages
      if (message.toLowerCase().contains('success')) {
        // Success - extract invoice number if available
        String invoiceNumber = response['invoiceNo']?.toString() ?? 'Generated';

        emit(PurchaseInvoiceSaved(true, invoiceNumber: invoiceNumber));
        event.completer.complete(invoiceNumber);

        // Reset after successful save
        add(ResetPurchaseInvoiceEvent());
      }
      else if (message.toLowerCase().contains('authorized')) {
        // Transaction is authorized but not completed
        String invoiceNumber = response['invoiceNo']?.toString() ?? 'Authorized';

        emit(PurchaseInvoiceSaved(true, invoiceNumber: invoiceNumber));
        event.completer.complete(invoiceNumber);

        add(ResetPurchaseInvoiceEvent());
      }
      else {
        // Handle specific error messages
        String errorMessage;
        final msgLower = message.toLowerCase();

        if (msgLower.contains('over limit')) {
          errorMessage = 'Account credit limit exceeded';
        } else if (msgLower.contains('block')) {
          errorMessage = 'Account is blocked';
        } else if (msgLower.contains('invalid ccy')) {
          errorMessage = 'Account currency does not match system currency';
        } else if (msgLower.contains('not found')) {
          errorMessage = 'Invalid product or storage ID';
        } else if (msgLower.contains('unavailable')) {
          errorMessage = message; // Contains product name and available quantity
        } else if (msgLower.contains('large')) {
          errorMessage = 'Payment amount exceeds total bill amount';
        } else if (msgLower.contains('failed')) {
          errorMessage = 'Invoice creation failed. Please try again.';
        } else {
          errorMessage = message; // Return the original message
        }

        emit(PurchaseInvoiceError(errorMessage));
        emit(savedState);
        event.completer.complete('');
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('DioException')) {
        errorMessage = 'Network error: Please check your connection';
      }

      emit(PurchaseInvoiceError(errorMessage));
      emit(savedState);
      event.completer.complete('');
    }
  }

  Future<void> _onLoadStorages(LoadPurchaseStoragesEvent event, Emitter<PurchaseInvoiceState> emit) async {
    try {
      if (state is PurchaseInvoiceLoaded) {
        final current = state as PurchaseInvoiceLoaded;
        emit(current.copyWith(storages: []));
      }
    } catch (e) {
      // Handle error silently
    }
  }
}