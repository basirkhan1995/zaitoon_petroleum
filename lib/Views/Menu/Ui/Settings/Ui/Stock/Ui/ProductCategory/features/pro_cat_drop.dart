import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../../../Features/Generic/zaitoon_drop.dart';
import '../../../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../bloc/pro_cat_bloc.dart';
import '../model/pro_cat_model.dart';

class ProductCategoryDropdown extends StatefulWidget {
  /// Category ID from Product (EDIT mode)
  final int? selectedCategoryId;

  /// Returns FULL model
  final ValueChanged<ProCategoryModel> onCategorySelected;

  const ProductCategoryDropdown({
    super.key,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  State<ProductCategoryDropdown> createState() =>
      _ProductCategoryDropdownState();
}

class _ProductCategoryDropdownState extends State<ProductCategoryDropdown> {
  ProCategoryModel? _selectedCategory;
  List<ProCategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProCatBloc>().add(LoadProCatEvent());
    });
  }

  void _setInitialSelection() {
    if (_categories.isEmpty) return;

    // 1️⃣ EDIT MODE → ID → Model
    if (widget.selectedCategoryId != null) {
      _selectedCategory = _categories.firstWhere(
            (c) => c.pcId == widget.selectedCategoryId,
        orElse: () => _categories.first,
      );
    }

    // 2️⃣ ADD MODE → default first
    _selectedCategory ??= _categories.first;

    widget.onCategorySelected(_selectedCategory!);
  }

  void _onSelect(ProCategoryModel cat) {
    setState(() => _selectedCategory = cat);
    widget.onCategorySelected(cat);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProCatBloc, ProCatState>(
      listener: (context, state) {
        if (state is ProCatLoadedState) {
          _categories = state.proCategory;

          if (_selectedCategory == null) {
            _setInitialSelection();
          }

          setState(() {});
        }
      },
      child: ZDropdown<ProCategoryModel>(
        title: AppLocalizations.of(context)!.categoryTitle,
        items: _categories,
        selectedItem: _selectedCategory,
        itemLabel: (cat) => cat.pcName ?? "",
        onItemSelected: _onSelect,
        leadingBuilder: (_) =>
        const Icon(Icons.category_rounded, size: 20),
      ),
    );
  }
}
