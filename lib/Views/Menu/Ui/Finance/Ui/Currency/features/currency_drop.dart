import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/Currencies/model/ccy_model.dart';
import '../../../../../../../Features/Generic/custom_filter_drop.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../Ui/Currencies/bloc/currencies_bloc.dart';

//✔️ Single-select usage example
// CurrencyDropdown(
// isMulti: false,
// onMultiChanged: (_) {},
// onSingleChanged: (value) {
// print("Selected currency: ${value?.ccyCode}");
// },
// )

// CurrencyDropdown(
// isMulti: true,
// onMultiChanged: (values) {
// print("Selected currencies: $values");
// },
// onSingleChanged: null,
// )

class CurrencyDropdown extends StatefulWidget {
  final String? title;
  final bool isMulti; // <--- NEW FLAG
  final ValueChanged<List<CurrenciesModel>> onMultiChanged;
  final ValueChanged<CurrenciesModel?>? onSingleChanged;

  // For initial selected values
  final List<CurrenciesModel>? initiallySelected;
  final CurrenciesModel? initiallySelectedSingle;

  const CurrencyDropdown({
    super.key,
    required this.isMulti,
    required this.onMultiChanged,
    this.onSingleChanged,
    this.title,
    this.initiallySelected,
    this.initiallySelectedSingle,
  });

  @override
  State<CurrencyDropdown> createState() => _CurrencyDropdownState();
}

class _CurrencyDropdownState extends State<CurrencyDropdown> {
  List<CurrenciesModel> _selectedMulti = [];
  CurrenciesModel? _selectedSingle;

  @override
  void initState() {
    super.initState();

    context.read<CurrenciesBloc>().add(LoadCurrenciesEvent(status: 1));

    if (widget.isMulti) {
      _selectedMulti = widget.initiallySelected ?? [];
    } else {
      _selectedSingle = widget.initiallySelectedSingle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrenciesBloc, CurrenciesState>(
      builder: (context, state) {
        if (state is CurrenciesLoadedState) {
          return CustomFilterDropdown<CurrenciesModel>(
            title: widget.title ?? AppLocalizations.of(context)!.currencyTitle,
            height: 45,
            items: state.ccy,
            multiSelect: widget.isMulti,
            selectedItems: widget.isMulti ? _selectedMulti : [],
            selectedItem: widget.isMulti ? null : _selectedSingle,

            itemLabel: (item) => item.ccyCode ?? "",

            initialValue: AppLocalizations.of(context)!.currencyTitle,

            // MULTI-SELECT HANDLER
            onMultiSelectChanged: widget.isMulti
                ? (selected) {
              setState(() => _selectedMulti = selected);
              widget.onMultiChanged(selected);
            }
                : null,

            // SINGLE-SELECT HANDLER
            onItemSelected: widget.isMulti
                ? (_) {}
                : (item) {
              setState(() => _selectedSingle = item);
              widget.onSingleChanged?.call(item);
            },

            itemStyle: Theme.of(context).textTheme.titleMedium,
          );
        }

        if (state is CurrenciesErrorState) {
          return Text('Error: ${state.message}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
