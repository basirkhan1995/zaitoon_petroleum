import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Products/model/product_model.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final Repositories _repo;
  ProductsBloc(this._repo) : super(ProductsInitial()) {

    on<ProductsEvent>((event, emit) async{
      emit(ProductsLoadingState());
     try{
      final products = await _repo.getProduct();
      emit(ProductsLoadedState(products));
     }catch(e){
       emit(ProductsErrorState(e.toString()));
     }
    });


  }
}
