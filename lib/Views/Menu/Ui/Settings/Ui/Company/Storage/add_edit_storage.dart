import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/zform_dialog.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/bloc/storage_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/Storage/model/storage_model.dart';
import '../../../../../../../../../Features/Widgets/textfield_entitled.dart';
import '../../../../../../../../../Localizations/l10n/translations/app_localizations.dart';

class StorageAddEditView extends StatelessWidget {
  final StorageModel? selectedStorage;

  const StorageAddEditView({super.key, this.selectedStorage});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(model: selectedStorage),
      tablet: _Tablet(model: selectedStorage),
      desktop: _Desktop(model: selectedStorage),
    );
  }
}

class _Mobile extends StatelessWidget {
  final StorageModel? model;

  const _Mobile({this.model});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Tablet extends StatelessWidget {
  final StorageModel? model;

  const _Tablet({this.model});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Desktop extends StatefulWidget {
  final StorageModel? model;

  const _Desktop({this.model});

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  // Controllers
  final TextEditingController storageName = TextEditingController();
  final TextEditingController storageDetails = TextEditingController();
  final TextEditingController storageLocation = TextEditingController();

  int statusValue = 0;
  bool isActive = false;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Pre-fill for edit mode
    if (widget.model != null) {
      final m = widget.model!;
      storageName.text = m.stgName ?? "";
      storageDetails.text = m.stgDetails??"";
      storageLocation.text = m.stgLocation ??"";
      statusValue = m.stgStatus ?? 1;
      isActive = statusValue == 1;
    }
  }

  @override
  void dispose() {
    storageName.dispose();
    storageDetails.dispose();
    storageLocation.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    TextStyle? titleStyle = textTheme.titleSmall?.copyWith();
    final isEdit = widget.model != null;

    return ZFormDialog(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      width: 550,

      title: isEdit ? locale.update : locale.newKeyword,

      actionLabel:
      (context.watch<StorageBloc>().state is StorageLoadingState)
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: theme.surface,
        ),
      )
          : Text(isEdit ? locale.update : locale.create),

      onAction: onSubmit,

      child: Form(
        key: formKey,
        child: BlocConsumer<StorageBloc, StorageState>(
          listener: (context, state) {
            if (state is StorageSuccessState) {
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                ZTextFieldEntitled(
                  controller: storageName,
                  isRequired: true,
                  title: locale.storage,
                  onSubmit: (_) => onSubmit(),
                  validator: (value) {
                    if (value.isEmpty) {
                      return locale.required(locale.storage);
                    }
                    return null;
                  },
                ),
                ZTextFieldEntitled(
                  controller: storageLocation,
                  isRequired: true,
                  title: locale.location,
                  onSubmit: (_) => onSubmit(),
                  validator: (value) {
                    if (value.isEmpty) {
                      return locale.required(locale.location);
                    }
                    return null;
                  },
                ),



                ZTextFieldEntitled(
                  controller: storageDetails,
                  keyboardInputType: TextInputType.multiline,
                  maxLength: 100,
                  title: locale.details,
                  onSubmit: (_) => onSubmit(),
                ),

                Row(
                  spacing: 8,
                  children: [
                    Switch.adaptive(
                      value: statusValue == 1,
                      onChanged: (value) {
                        setState(() {
                          isActive = value;
                          statusValue = isActive ? 1 : 0;
                        });
                      },
                    ),
                    Text(isActive? locale.active: locale.inactive,style: titleStyle),
                  ],
                ),
                SizedBox(height: 10)
              ],
            );
          },
        ),
      ),
    );
  }

  void onSubmit() {
    if (!formKey.currentState!.validate()) return;

    final data = StorageModel(
      stgId: widget.model?.stgId,
      stgName: storageName.text,
      stgDetails: storageDetails.text,
      stgLocation: storageLocation.text,
      stgStatus: statusValue,
    );

    final bloc = context.read<StorageBloc>();

    if (widget.model == null) {
      bloc.add(AddStorageEvent(data));
    } else {
      bloc.add(UpdateStorageEvent(data));
    }
  }
}
