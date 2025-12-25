import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/status_badge.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../Features/Widgets/search_field.dart';
import 'add_edit_product.dart';
import 'bloc/products_bloc.dart';


class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
        mobile: _Mobile(), tablet: _Tablet(), desktop: _Desktop());
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
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<ProductsBloc>().add(LoadProductsEvent());
    });
    super.initState();
  }

  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;
    final tr = AppLocalizations.of(context)!;
    TextStyle? titleStyle = textTheme.titleSmall;
    return Scaffold(
      backgroundColor: color.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 10),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr.products,style: textTheme.titleLarge),
                        Text(tr.manageProductTitle,style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.outline)),

                      ],
                    )),
                Expanded(
                  flex: 2,
                  child: ZSearchField(
                    controller: searchController,
                    hint: tr.search,
                    title: '',
                    end: searchController.text.isNotEmpty? InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: (){
                          setState(() {
                            searchController.clear();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.clear,size: 15,),
                        )) : SizedBox(),
                    onChanged: (e){
                      setState(() {
                      });
                    },
                    icon: FontAwesomeIcons.magnifyingGlass,
                  ),
                ),
                ZOutlineButton(
                    width: 110,
                    icon: Icons.refresh,
                    onPressed: onRefresh,
                    label: Text(AppLocalizations.of(context)!.refresh)),
                ZOutlineButton(
                    width: 110,
                    isActive: true,
                    icon: Icons.add,
                    onPressed: (){
                      showDialog(context: context, builder: (context){
                        return AddEditProductView();
                      });
                    },
                    label: Text(AppLocalizations.of(context)!.newKeyword)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 0),
            child: Row(
              children: [
                SizedBox(
                    width: 200,
                    child: Text(tr.productName,style: titleStyle)),
                Expanded(
                    child: Text(tr.details,style: titleStyle)),
                SizedBox(
                    width: 150,
                    child: Text(tr.productCode,style: titleStyle)),
                SizedBox(
                    width: 150,
                    child: Text(tr.madeIn,style: titleStyle)),
                SizedBox(
                    width: 90,
                    child: Text(tr.status,style: titleStyle)),
              ],
            ),
          ),
          Divider(endIndent: 15,indent: 15),
          Expanded(
            child: BlocBuilder<ProductsBloc, ProductsState>(
              builder: (context, state) {
                if(state is ProductsLoadingState){
                  return Center(child: CircularProgressIndicator());
                }
                if(state is ProductsErrorState){
                  return NoDataWidget(
                    message: state.message,
                  );
                }
                if(state is ProductsLoadedState){
                  final query = searchController.text.toLowerCase().trim();

                  final filteredList = state.products.where((item) {
                    final code = item.proCode?.toLowerCase() ?? '';
                    final productName = item.proName?.toString() ?? '';

                    return code.contains(query.toLowerCase()) || productName.contains(query.toLowerCase());
                  }).toList();
                  return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context,index){
                        final product = filteredList[index];
                      return InkWell(
                        onTap: (){
                          showDialog(context: context, builder: (context){
                            return AddEditProductView(model: product);
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                          decoration: BoxDecoration(
                              color: index.isEven? color.primary.withValues(alpha: .05) : Colors.transparent
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 200,
                                  child: Text(product.proName??"")),
                              Expanded(
                                  child: Text(product.proDetails??"")),
                              SizedBox(
                                  width: 150,
                                  child: Text(product.proCode??"")),
                              SizedBox(
                                  width: 150,
                                  child: Text(product.proMadeIn??"")),
                              SizedBox(
                                  width: 90,
                                  child: StatusBadge( status: product.proStatus!,trueValue: tr.active, falseValue: tr.inactive,))
                            ],
                          ),
                        ),
                      );
                  });
                }
                return SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  void onRefresh(){
    context.read<ProductsBloc>().add(LoadProductsEvent());
  }
}

