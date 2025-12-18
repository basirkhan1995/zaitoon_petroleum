import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/ProductCategory/bloc/pro_cat_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Stock/Ui/ProductCategory/model/pro_cat_model.dart';
import '../../../../../../../Auth/bloc/auth_bloc.dart';

class AddEditProCategoryView extends StatelessWidget {
  final ProCategoryModel? model;
  const AddEditProCategoryView({super.key, this.model});

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
  final ProCategoryModel? model;
  const _Desktop(this.model);

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  final formKey = GlobalKey<FormState>();
  final catName = TextEditingController();
  final description = TextEditingController();
  int status = 0;
  String? usrName;

  @override
  void initState() {
    if (widget.model != null) {
      catName.text = widget.model?.pcName ?? "";
      description.text = widget.model?.pcDescription ?? "";
      status = widget.model?.pcStatus ?? 0;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final state = context.watch<AuthBloc>().state;
    final color = Theme.of(context).colorScheme;

    if (state is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = state.loginData;
    usrName = login.usrName ?? "";

    bool isEdit = widget.model != null;

    return BlocBuilder<ProCatBloc, ProCatState>(
      builder: (context, catState) {
        return ZFormDialog(
          onAction: onSubmit,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          actionLabel: catState is ProCatLoadingState
              ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    color: color.surface,
                    strokeWidth: 2,
                  ),
                )
              : Text(isEdit ? tr.update : tr.create),
          title: isEdit ? tr.edit : tr.newKeyword,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ZTextFieldEntitled(
                  title: tr.categoryTitle,
                  controller: catName,
                  validator: (value) {
                    if (value.isEmpty) {
                      return tr.required(tr.accountName);
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                ZTextFieldEntitled(
                  title: tr.details,
                  controller: description,
                  validator: (value) {
                    if (value.isEmpty) {
                      return tr.required(tr.details);
                    }
                    return null;
                  },
                ),
                if (widget.model != null) SizedBox(height: 12),
                if (widget.model != null)
                  Row(
                    children: [
                      Switch(
                        value: status == 1,
                        onChanged: (e) {
                          setState(() {
                            status = e == true ? 1 : 0;
                          });
                        },
                      ),
                    ],
                  ),
                if (catState is ProCatErrorState) SizedBox(height: 15),
                if (catState is ProCatErrorState)
                  Row(
                    children: [
                      Text(
                        catState.message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void onSubmit() {
    if (!formKey.currentState!.validate()) return;
    final bloc = context.read<ProCatBloc>();

    final data = ProCategoryModel(
      pcId: widget.model?.pcId,
      pcName: catName.text,
      pcDescription: description.text,
      pcStatus: status,
    );

    if (widget.model != null) {
      bloc.add(UpdateProCatEvent(data));
    } else {
      bloc.add(AddProCatEvent(data));
    }
  }
}
