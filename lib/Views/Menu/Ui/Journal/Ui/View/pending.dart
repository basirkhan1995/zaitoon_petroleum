import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/bloc/transactions_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PendingTransactionsView extends StatelessWidget {
  const PendingTransactionsView({super.key});

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
  final Set<String> _selectedRefs = {}; // selecting by trnReference
  bool _selectionMode = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsBloc>().add(LoadAllTransactionsEvent('pending'));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          if(_selectionMode)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                ZOutlineButton(
                    width: 150,
                    icon: Icons.check_box_rounded,
                    label: Text("${locale.authorize} (${_selectedRefs.length})")),
                ZOutlineButton(
                    width: 100,
                    onPressed: (){
                      setState(() {
                        _selectionMode = false;
                        _selectedRefs.clear();
                      });
                    },
                    isActive: true,
                    icon: Icons.close,
                    label: Text(locale.cancel)),
              ],
            ),
          ),

          if(!_selectionMode)
          const SizedBox(height: 10),

          // HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [

                // SELECT-ALL CHECKBOX
                if(_selectionMode)
                SizedBox(
                  width: 40,
                  child: BlocBuilder<TransactionsBloc, TransactionsState>(
                    builder: (context, state) {
                      if (state is! TransactionLoadedState) {
                        return const SizedBox();
                      }

                      final allSelected = _selectedRefs.length == state.txn.length;

                      return Checkbox(
                        value: allSelected && _selectionMode,
                        onChanged: (v) => _toggleSelectAll(state.txn),
                      );
                    },
                  ),
                ),

                SizedBox(width: 90, child: Text(locale.txnDate, style: textTheme.titleMedium)),
                const SizedBox(width: 20),
                Expanded(child: Text(locale.referenceNumber, style: textTheme.titleMedium)),
                SizedBox(width: 110, child: Text(locale.txnType, style: textTheme.titleMedium)),
                const SizedBox(width: 20),
                SizedBox(width: 110, child: Text(locale.txnMaker, style: textTheme.titleMedium)),
              ],
            ),
          ),

          Divider(
            indent: 8,
            endIndent: 8,
            color: Theme.of(context).colorScheme.primary,
          ),

          // BODY
          Expanded(
            child: BlocBuilder<TransactionsBloc, TransactionsState>(
              builder: (context, state) {
                if (state is TransactionErrorState) {
                  return NoDataWidget(
                    message: state.message,
                    onRefresh: () {
                      context.read<TransactionsBloc>().add(LoadAllTransactionsEvent('pending'));
                    },
                  );
                }

                if (state is TransactionLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TransactionLoadedState) {
                  final txns = state.txn;

                  if (txns.isEmpty) {
                    return NoDataWidget(
                      message: locale.noDataFound,
                      onRefresh: () {
                        context.read<TransactionsBloc>().add(LoadAllTransactionsEvent('pending'));
                      },
                    );
                  }

                  return ListView.builder(
                    itemCount: txns.length,
                    itemBuilder: (context, index) {
                      final txn = txns[index];
                      final isSelected = _selectedRefs.contains(txn.trnReference);

                      return InkWell(
                        onTap: () {
                          if (_selectionMode) _toggleSelection(txn);
                        },
                        onLongPress: () {
                          _toggleSelection(txn); // long press to start selecting
                        },
                        hoverColor: Theme.of(context).primaryColor.withValues(alpha: .05),
                        child: Container(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary.withValues(alpha: .15)
                              : index.isOdd
                              ? Theme.of(context).colorScheme.primary.withValues(alpha: .06)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,vertical: 8),
                          child: Row(
                            children: [
                              if(_selectionMode)
                              // CHECKBOX
                              SizedBox(
                                width: 40,
                                child: Checkbox(
                                  visualDensity: VisualDensity(vertical: -4),
                                  value: isSelected,
                                  onChanged: (v) => _toggleSelection(txn),
                                ),
                              ),

                              SizedBox(
                                width: 90,
                                child: Text(txn.trnEntryDate!.toDateString),
                              ),
                              const SizedBox(width: 20),

                              Expanded(
                                child: Text(txn.trnReference.toString()),
                              ),

                              SizedBox(
                                width: 110,
                                child: Text(txn.trnType ?? ""),
                              ),

                              const SizedBox(width: 20),
                              SizedBox(
                                width: 110,
                                child: Text(txn.maker ?? ""),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Toggle a single item by trnReference
  void _toggleSelection(dynamic record) {
    setState(() {
      final ref = record.trnReference!;

      if (_selectedRefs.contains(ref)) {
        _selectedRefs.remove(ref);
        if (_selectedRefs.isEmpty) _selectionMode = false;
      } else {
        _selectionMode = true;
        _selectedRefs.add(ref);
      }
    });
  }

  /// Select all / Unselect all
  void _toggleSelectAll(List data) {
    setState(() {
      if (_selectedRefs.length == data.length) {
        _selectedRefs.clear();
        _selectionMode = false;
      } else {
        _selectionMode = true;
        _selectedRefs.clear();
        _selectedRefs.addAll(data.map((e) => e.trnReference!));
      }
    });
  }
}




