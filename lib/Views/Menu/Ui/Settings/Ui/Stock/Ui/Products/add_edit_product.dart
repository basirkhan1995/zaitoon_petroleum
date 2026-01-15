import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../ProductCategory/features/pro_cat_drop.dart';
import '../ProductCategory/model/pro_cat_model.dart';
import 'bloc/products_bloc.dart';
import 'model/product_model.dart';
import 'dart:math';

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
  final madeIn = TextEditingController();
  final details = TextEditingController();
  int? catId;
  ProCategoryModel? _selectedCategory;

  @override
  void initState() {
    if(widget.model !=null){
      productName.text = widget.model?.proName??"";
      productCode.text = widget.model?.proCode??"";
      madeIn.text = widget.model?.proMadeIn??"";
      details.text = widget.model?.proDetails??"";
      catId = widget.model?.proCategory;
    }if(widget.model == null){
      productCode.text = generateProductCode();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
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
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  spacing: 15,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ZTextFieldEntitled(
                      title: tr.productCode,
                      controller: productCode,
                      maxLength: 13,
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
                    ProductCategoryDropdown(

                      selectedCategoryId: catId,
                      onCategorySelected: (cat) {
                        _selectedCategory = cat;
                      },
                    ),


                    ZTextFieldEntitled(
                      title: tr.madeIn,
                      controller: madeIn,
                    ),

                    ZTextFieldEntitled(
                      title: tr.details,
                      controller: details,
                      keyboardInputType: TextInputType.multiline,
                      maxLength: 100,
                    ),
                  ],
                ),
              ),
            ),
        );
      },
    );
  }




  String generateProductCode({String prefix = 'PRD'}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    final now = DateTime.now();

    final batch = List.generate(3, (_) => chars[rand.nextInt(chars.length)],).join();
    final date = '${now.year % 100}${now.month.toString().padLeft(2, '0')}';
    return '$prefix-$date-$batch';
  }




  void onSubmit(){
    if (!formKey.currentState!.validate()) return;
    final bloc = context.read<ProductsBloc>();
    final data = ProductsModel(
      proId: widget.model?.proId,
      proCode: productCode.text,
      proName: productName.text,
      proMadeIn: madeIn.text,
      proCategory: _selectedCategory?.pcId,
      proDetails: details.text,
      proStatus: 1
    );
    if(widget.model != null){
      bloc.add(UpdateProductEvent(data));
    }else{
      bloc.add(AddProductEvent(data));
    }
  }
}
