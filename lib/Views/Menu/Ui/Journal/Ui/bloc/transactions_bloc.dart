import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/localization_services.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/model/transaction_model.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final Repositories _repo;
  TransactionsBloc(this._repo) : super(TransactionsInitial()) {

    on<OnCashTransactionEvent>((event, emit) async{
      emit(TransactionLoadingState());
      try{
        final response = await _repo.cashFlowOperations(newTransaction: event.transaction);
        if(response['msg'] == "success"){
          emit(TransactionSuccessState());
        }
      }catch(e){
       emit(TransactionErrorState(e.toString()));
      }
    });

    on<LoadAllTransactionsEvent>((event, emit) async{
      emit(TransactionLoadingState());
      try{
        final txn = await _repo.getTransactionsByStatus(status: event.status);
        emit(TransactionLoadedState(txn));
      }catch(e){
        emit(TransactionErrorState(e.toString()));
      }
    });

    on<AuthorizeTxnEvent>((event, emit) async{
      final locale = localizationService.loc;
      emit(TransactionLoadingState());
      try{
        final response = await _repo.authorizeTxn(reference: event.reference,usrName: event.usrName);
        if(response['msg'] == "authorized"){
          emit(TransactionSuccessState());
        }if(response['msg'] == "invalid"){
          emit(TransactionErrorState(locale.authorizeDeniedMessage));
        }
      }catch(e){
        emit(TransactionErrorState(e.toString()));
      }
    });

  }
}
