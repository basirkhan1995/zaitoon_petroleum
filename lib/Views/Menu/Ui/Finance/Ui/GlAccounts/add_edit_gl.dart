import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/GlAccounts/GlCategories/bloc/gl_category_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/GlAccounts/GlCategories/category_view.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/GlAccounts/bloc/gl_accounts_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/GlAccounts/features/gl_category_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/GlAccounts/model/gl_model.dart';
import '../../../../../Auth/bloc/auth_bloc.dart';

class AddEditGl extends StatelessWidget {
  final GlAccountsModel? model;
  const AddEditGl({super.key, this.model});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(model),
    );
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Desktop extends StatefulWidget {
  final GlAccountsModel? model;
  const _Desktop(this.model);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  final formKey = GlobalKey<FormState>();
  final accName = TextEditingController();
  final accNumberCtrl = TextEditingController();

  int? accNumber;
  int? categoryId;
  int? subCategoryId;
  String? usrName;

  @override
  void initState() {
    if (widget.model != null) {
      accName.text = widget.model?.accName ?? "";
      accNumber = widget.model?.accNumber;
      accNumberCtrl.text = widget.model?.accNumber?.toString() ?? "";
      categoryId = widget.model?.accCategory;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final authState = context.watch<AuthBloc>().state;
    final glState = context.watch<GlAccountsBloc>().state;
    final color = Theme.of(context).colorScheme;

    if (authState is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = authState.loginData;
    usrName = login.usrName ?? "";
    bool isEdit = widget.model != null;
    return ZFormDialog(
      onAction: onSubmit,
      padding: EdgeInsets.symmetric(vertical: 15,horizontal: 15),
      actionLabel: glState is GlAccountsLoadingState? SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(
          color: color.surface,
          strokeWidth: 2,
        ),
      ) : Text(isEdit? tr.update : tr.create),
      title: isEdit? tr.edit : tr.newKeyword,
      child: Form(
        key: formKey,
        child: BlocBuilder<GlAccountsBloc, GlAccountsState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if(widget.model !=null)
                ZTextFieldEntitled(
                  title: tr.accountNumber,
                  controller: accNumberCtrl,
                  readOnly: true,
                  isEnabled: false,
                ),
                if(widget.model !=null)
                SizedBox(height: 12),
                ZTextFieldEntitled(
                  title: tr.accountName,
                  controller: accName,
                  validator: (value) {
                    if (value.isEmpty) {
                      return tr.required(tr.accountName);
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                GLCategoryDropdown(
                  disableAction: widget.model != null,
                  selectedDbValue: categoryId,
                  onChanged: (e) {
                    setState(() {
                      categoryId = e;
                    });
                    context.read<GlCategoryBloc>().add(LoadGlCategoriesEvent(categoryId ?? 1));
                  },
                ),
                SizedBox(height: 12),
                GlSubCategoriesDrop(
                    disableAction: widget.model != null,
                    title: tr.subCategory,
                    mainCategoryId: categoryId ?? 1,

                    onChanged: (e){
                       setState(() {
                         subCategoryId = e?.acgId;
                       });
                    }),

                if(state is GlAccountsErrorState)
                SizedBox(height: 15),
                if(state is GlAccountsErrorState)
                Row(
                  children: [
                    Text(state.message, style: TextStyle(color: Theme.of(context).colorScheme.error),)
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void onSubmit() {
    if (!formKey.currentState!.validate()) return;
    final bloc = context.read<GlAccountsBloc>();

    final data = GlAccountsModel(
      accName: accName.text,
      accCategory: subCategoryId,
      accNumber: accNumber,
      usrName: usrName ?? "",
    );

    if (widget.model != null) {
      bloc.add(UpdateGlEvent(data));
    } else {
      bloc.add(AddGlEvent(data));
    }

  }
}
