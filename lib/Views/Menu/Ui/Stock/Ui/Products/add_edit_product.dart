import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Products/bloc/products_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Products/model/product_model.dart';

class AddEditProductView extends StatelessWidget {
  final ProductsModel? model;
  const AddEditProductView({super.key,this.model});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(model),
      tablet: _Tablet(),
    );
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Desktop extends StatefulWidget {
  final ProductsModel? model;
  const _Desktop(this.model);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  final formKey = GlobalKey<FormState>();

  final productName = TextEditingController();
  final productCode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    TextStyle? titleStyle = Theme.of(context).textTheme.titleMedium;
    bool isEdit = widget.model != null;
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        return ZFormDialog(
            onAction: onSubmit,
            title: isEdit? tr.update : tr.newKeyword,
            actionLabel: state is ProductsLoadingState? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  color: color.surface,
                )) : Text(isEdit? tr.update : tr.create),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ZTextFieldEntitled(
                    title: tr.productCode,
                    controller: productCode,
                    isRequired: true,
                    validator: (value){
                      if(value.isEmpty){
                        return tr.required(tr.productCode);
                      }
                      return null;
                    },
                  ),
                  ZTextFieldEntitled(
                      title: tr.productName,
                      controller: productName,
                      isRequired: true,
                      validator: (value){
                        if(value.isEmpty){
                          return tr.required(tr.productName);
                        }
                        return null;
                      },
                  ),
                  ZTextFieldEntitled(
                    title: "Made in",
                    controller: productName,
                    isRequired: true,
                    validator: (value){
                      if(value.isEmpty){
                        return tr.required(tr.productName);
                      }
                      return null;
                    },
                  ),

                  ZTextFieldEntitled(
                    title: "Details",
                    controller: productName,
                    isRequired: true,
                    validator: (value){
                      if(value.isEmpty){
                        return tr.required(tr.productName);
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
        );
      },
    );
  }

  void onSubmit(){
    if (!formKey.currentState!.validate()) return;
    final bloc = context.read<ProductsBloc>();
    final data = ProductsModel(
      proId: widget.model?.proId,
    );
    if(widget.model != null){
      bloc.add(UpdateProductEvent(data));
    }else{
      bloc.add(AddProductEvent(data));
    }
  }
}
