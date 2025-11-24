import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/model/transaction_model.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final Repositories _repo;
  TransactionsBloc(this._repo) : super(TransactionsInitial()) {

    on<OnCashTransactionEvent>((event, emit) async{
      try{
       final response = await _repo.onChashTransaction(newTransaction: event.transaction);
       if(response['msg'] == "success"){
         emit(TransactionSuccessState());
       }
      }catch(e){
       emit(TransactionErrorState(e.toString()));
      }
    });

  }
}
