import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/Currencies/model/ccy_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/features/currency_drop.dart';
import '../../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../../../Features/Other/utils.dart';
import '../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../../Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import '../../../../../Stakeholders/Ui/Accounts/model/acc_model.dart';
import '../bloc/transfer_bloc.dart';
import '../model/transfer_model.dart';

class BulkTransferScreen extends StatefulWidget {
  const BulkTransferScreen({super.key});

  @override
  State<BulkTransferScreen> createState() => _BulkTransferScreenState();
}

class _BulkTransferScreenState extends State<BulkTransferScreen> {
  // Store controllers by rowId: index -> TextEditingController
  final Map<int, List<TextEditingController>> _rowControllers = {};
  final Map<int, FocusNode> _rowFocusNodes = {};
  final TextEditingController _currencyController = TextEditingController(text: 'USD');
  String? userName;
  String? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    context.read<TransferBloc>().add(InitializeTransferEvent());
    _selectedCurrency = 'USD';
  }

  @override
  void dispose() {
    for (final node in _rowFocusNodes.values) {
      node.dispose();
    }
    for (final controllers in _rowControllers.values) {
      for (final controller in controllers) {
        controller.dispose();
      }
    }
    _currencyController.dispose();
    super.dispose();
  }

  void _ensureControllerForEntry(TransferEntry entry) {
    if (!_rowControllers.containsKey(entry.rowId)) {
      _rowControllers[entry.rowId] = [
        TextEditingController(text: entry.accountName ?? ''), // Account
        TextEditingController(text: entry.debit > 0 ? entry.debit.toAmount() : ''), // Debit
        TextEditingController(text: entry.credit > 0 ? entry.credit.toAmount() : ''), // Credit
        TextEditingController(text: entry.narration), // Narration
      ];

      if (!_rowFocusNodes.containsKey(entry.rowId)) {
        _rowFocusNodes[entry.rowId] = FocusNode();
      }
    }
  }

  void _removeControllerForEntry(int rowId) {
    final controllers = _rowControllers.remove(rowId);
    if (controllers != null) {
      for (final controller in controllers) {
        controller.dispose();
      }
    }

    final focusNode = _rowFocusNodes.remove(rowId);
    focusNode?.dispose();
  }

  void _syncControllersWithState(TransferLoadedState state) {
    final currentRowIds = state.entries.map((e) => e.rowId).toSet();
    final existingRowIds = _rowControllers.keys.toSet();
    final deletedRowIds = existingRowIds.difference(currentRowIds);

    for (final rowId in deletedRowIds) {
      _removeControllerForEntry(rowId);
    }

    // Create/update controllers for current entries
    for (final entry in state.entries) {
      _ensureControllerForEntry(entry);

      final controllers = _rowControllers[entry.rowId]!;

      // Update account name if changed
      if (controllers[0].text != (entry.accountName ?? '')) {
        controllers[0].text = entry.accountName ?? '';
      }

      // Update debit if changed
      if (entry.debit > 0) {
        final formatted = entry.debit.toAmount();
        if (controllers[1].text != formatted) {
          controllers[1].text = formatted;
        }
        // Clear credit if debit is set
        if (entry.credit == 0 && controllers[2].text.isNotEmpty) {
          controllers[2].text = '';
        }
      } else if (controllers[1].text.isNotEmpty) {
        controllers[1].text = '';
      }

      // Update credit if changed
      if (entry.credit > 0) {
        final formatted = entry.credit.toAmount();
        if (controllers[2].text != formatted) {
          controllers[2].text = formatted;
        }
        // Clear debit if credit is set
        if (entry.debit == 0 && controllers[1].text.isNotEmpty) {
          controllers[1].text = '';
        }
      } else if (controllers[2].text.isNotEmpty) {
        controllers[2].text = '';
      }

      // Update narration if changed
      if (controllers[3].text != entry.narration) {
        controllers[3].text = entry.narration;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZFormDialog(
      width: MediaQuery.of(context).size.width *.8,
      icon: Icons.bubble_chart_outlined,
      isActionTrue: false,
      onAction: null,
      title: AppLocalizations.of(context)!.bulkTransfer,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, auth) {
          if (auth is AuthenticatedState) {
            userName = auth.loginData.usrName;
          }

          return BlocConsumer<TransferBloc, TransferState>(
            listener: (context, state) {
              if (state is TransferSavedState) {
                if (state.success) {
                  Utils.showOverlayMessage(context,
                    message: AppLocalizations.of(context)!.successTransactionMessage,
                    isError: false,
                  );
                }
              } else if (state is TransferApiErrorState) {
                // Show error message
                Utils.showOverlayMessage(context,
                  message: state.error,
                  isError: true,
                );
              }
            },
            builder: (context, state) {
              if (state is TransferLoadedState) {
                _syncControllersWithState(state);

                return _buildLoadedState(context, state);
              } else if (state is TransferSavingState) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              } else if (state is TransferApiErrorState) {
                // Show error state but preserve entries
                return _buildErrorState(context, state);
              } else if (state is TransferErrorState) {
                return Center(
                  child: Text(
                    state.error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, TransferLoadedState state) {
    bool hasCurrencyMismatch = false;
    if (_selectedCurrency != null) {
      for (final entry in state.entries) {
        if (entry.currency != null &&
            entry.currency!.isNotEmpty &&
            entry.currency != _selectedCurrency) {
          hasCurrencyMismatch = true;
          break;
        }
      }
    }

    return Column(
      children: [
        // Header Section
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 3),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Row(

                children: [
                  Expanded(
                    child: CurrencyDropdown(
                      height: 40,
                        title: '',
                        initiallySelectedSingle: CurrenciesModel(ccyCode: _selectedCurrency),
                        isMulti: false,
                        onMultiChanged: (_){},
                        onSingleChanged: (e){
                          setState(() {
                            _selectedCurrency = e?.ccyCode??"";
                          });
                        },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ZOutlineButton(
                    height: 40,
                    icon: Icons.add,
                    onPressed: () {
                      context.read<TransferBloc>().add(AddTransferEntryEvent());
                    },
                    width: 120,
                    label: Text(AppLocalizations.of(context)!.addEntry),
                  ),
                  const SizedBox(width: 8),
                  _buildSaveButton(context, state, hasCurrencyMismatch),
                ],
              ),

              // Warnings
              if (hasCurrencyMismatch)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.transactionMismatchCcyAlert,
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              if ((state.totalDebit - state.totalCredit).abs() > 0.01)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.debitNoEqualCredit,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Entries Header
        _TransferHeaderRow(currencySymbol: _selectedCurrency ?? 'USD'),

        const SizedBox(height: 8),

        // Entries List
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.entries.length,
            itemBuilder: (context, index) {
              final entry = state.entries[index];
              final controllers = _rowControllers[entry.rowId]!;
              final focusNode = _rowFocusNodes[entry.rowId]!;

              return _TransferEntryRow(
                key: ValueKey(entry.rowId),
                entry: entry,
                index: index,
                focusNode: focusNode,
                accountController: controllers[0],
                debitController: controllers[1],
                creditController: controllers[2],
                narrationController: controllers[3],
                selectedCurrency: _selectedCurrency,
                onChanged: (updatedEntry) {
                  context.read<TransferBloc>().add(
                    UpdateTransferEntryEvent(
                      id: updatedEntry.rowId,
                      accountNumber: updatedEntry.accountNumber,
                      accountName: updatedEntry.accountName,
                      currency: updatedEntry.currency,
                      debit: updatedEntry.debit,
                      credit: updatedEntry.credit,
                      narration: updatedEntry.narration,
                    ),
                  );
                },
                onRemove: (id) {
                  context.read<TransferBloc>().add(
                    RemoveTransferEntryEvent(id),
                  );
                },
              );
            },
          ),
        ),

        // Summary Section
        _TransferSummary(
          totalDebit: state.totalDebit,
          totalCredit: state.totalCredit,
          currencySymbol: _selectedCurrency ?? 'USD',
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, TransferApiErrorState state) {
    // Show error but keep entries for editing
    return Column(
      children: [
        // Error Banner
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Failed',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.error,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  context.read<TransferBloc>().add(ClearApiErrorEvent());
                },
              ),
            ],
          ),
        ),

        // Show the entries (reuse the loaded state builder with error state entries)
        Expanded(
          child: _buildLoadedState(
            context,
            TransferLoadedState(
              entries: state.entries,
              totalDebit: state.entries.fold(0.0, (sum, entry) => sum + entry.debit),
              totalCredit: state.entries.fold(0.0, (sum, entry) => sum + entry.credit),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, TransferLoadedState state, bool hasCurrencyMismatch) {
    final isBalanced = (state.totalDebit - state.totalCredit).abs() < 0.01;
    final hasEntries = state.entries.isNotEmpty;
    final allAccountsValid = state.entries.every((entry) => entry.accountNumber != null);
    final isValid = isBalanced && hasEntries && allAccountsValid && !hasCurrencyMismatch;

    return ZOutlineButton(
      height: 40,
      icon: Icons.cached_rounded,
      onPressed: !isValid || userName == null
          ? null
          : () async {
        final completer = Completer<String>();
        context.read<TransferBloc>().add(
          SaveTransferEvent(
            userName: userName!,
            completer: completer,
          ),
        );
        try {
          await completer.future;
        } catch (e) {
          // Error is handled in listener via TransferApiErrorState
        }
      },
      width: 120,
      label: Text(AppLocalizations.of(context)!.create),
    );
  }
}

class _TransferHeaderRow extends StatelessWidget {
  final String currencySymbol;

  const _TransferHeaderRow({
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.primary,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                '#',
                style: TextStyle(
                  color: color.surface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                AppLocalizations.of(context)!.accounts,
                style: TextStyle(
                  color: color.surface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                AppLocalizations.of(context)!.ccyCode,
                style: TextStyle(
                  color: color.surface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 150,
              child: Text(
                '${AppLocalizations.of(context)!.debitTitle} ($currencySymbol)',
                style: TextStyle(
                  color: color.surface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 150,
              child: Text(
                '${AppLocalizations.of(context)!.creditTitle} ($currencySymbol)',
                style: TextStyle(
                  color: color.surface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                AppLocalizations.of(context)!.narration,
                style: TextStyle(
                  color: color.surface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              child: Icon(Icons.delete_outline_rounded,color: Theme.of(context).colorScheme.surface,size: 20)
            ),
          ],
        ));
    }
}


class _TransferEntryRow extends StatefulWidget {
  final TransferEntry entry;
  final int index;
  final FocusNode focusNode;
  final TextEditingController accountController;
  final TextEditingController debitController;
  final TextEditingController creditController;
  final TextEditingController narrationController;
  final String? selectedCurrency;
  final Function(TransferEntry) onChanged;
  final Function(int) onRemove;

  const _TransferEntryRow({
    super.key,
    required this.entry,
    required this.index,
    required this.focusNode,
    required this.accountController,
    required this.debitController,
    required this.creditController,
    required this.narrationController,
    this.selectedCurrency,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_TransferEntryRow> createState() => __TransferEntryRowState();
}

class __TransferEntryRowState extends State<_TransferEntryRow> {
  @override
  Widget build(BuildContext context) {
    final entryCurrency = widget.entry.currency ?? widget.selectedCurrency ?? 'USD';
    final hasCurrencyMismatch = widget.selectedCurrency != null &&
        entryCurrency != widget.selectedCurrency;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        spacing: 5,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${widget.index + 1}',
              textAlign: TextAlign.center,
            ),
          ),

          // Account Selection
          Expanded(
            flex: 2,
            child: GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
              key: ValueKey('account_${widget.entry.rowId}'),
              showAllOnFocus: true,
              controller: widget.accountController,
              title: '',
              hintText: AppLocalizations.of(context)!.accounts,
              isRequired: true,
              bloc: context.read<AccountsBloc>(),
              fetchAllFunction: (bloc) => bloc.add(
                LoadAccountsEvent(),
              ),
              searchFunction: (bloc, query) => bloc.add(
                LoadAccountsEvent(),
              ),
              itemBuilder: (context, account) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        account.accName ?? '',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),

                    Row(
                      children: [
                        Text(
                          account.accNumber.toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: account.actCurrency == widget.selectedCurrency
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            account.actCurrency ?? 'USD',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: account.actCurrency == widget.selectedCurrency
                                  ? Colors.black
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              itemToString: (account) => account.accName ?? "",
              stateToLoading: (state) => state is AccountLoadingState,
              loadingBuilder: (context) => const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 1),
              ),
              stateToItems: (state) {
                if (state is AccountLoadedState) return state.accounts;
                return [];
              },
              onSelected: (account) {
                widget.accountController.text = account.accName ?? '';
                widget.onChanged(widget.entry.copyWith(
                  accountNumber: account.accNumber,
                  accountName: account.accName,
                  currency: account.actCurrency,
                ));
              },
              noResultsText: 'No account found',
              showClearButton: true,
            ),
          ),

          // Currency
          SizedBox(
            width: 50,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
              decoration: BoxDecoration(
                color: hasCurrencyMismatch ? Colors.orange.shade50 : null,
                border: Border.all(
                  color: hasCurrencyMismatch ? Colors.orange : Colors.grey.shade400,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                entryCurrency,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: hasCurrencyMismatch ? Colors.orange : Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          //Debit
          SizedBox(
            width: 150,
            height: 40,
            child: TextField(
              key: ValueKey('debit_${widget.entry.rowId}'),
              controller: widget.debitController,
              focusNode: widget.focusNode,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0.00',
                suffixText: entryCurrency,
                suffixStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400, // default unfocused color
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                ),
              ),
              onChanged: (value) {
                final debit = value.cleanAmount.toDoubleAmount();
                if (debit > 0) {
                  widget.creditController.text = '';
                }
                widget.onChanged(widget.entry.copyWith(
                  debit: debit,
                  credit: 0.0,
                ));
              },
              onEditingComplete: () {
                final debit = widget.debitController.text.cleanAmount.toDoubleAmount();
                if (debit > 0) {
                  widget.debitController.text = debit.toAmount();
                }
              },
            ),
          ),

         // Credit
          SizedBox(
            width: 150,
            height: 40,
            child: TextField(
              key: ValueKey('credit_${widget.entry.rowId}'),
              controller: widget.creditController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0.00',
                suffixText: entryCurrency,
                suffixStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400, // default unfocused color
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                ),
              ),
              onChanged: (value) {
                final credit = value.cleanAmount.toDoubleAmount();
                if (credit > 0) {
                  widget.debitController.text = '';
                }
                widget.onChanged(widget.entry.copyWith(
                  credit: credit,
                  debit: 0.0,
                ));
              },
              onEditingComplete: () {
                final credit = widget.creditController.text.cleanAmount.toDoubleAmount();
                if (credit > 0) {
                  widget.creditController.text = credit.toAmount();
                }
              },
            ),
          ),

          // Narration
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 40,
              child: TextField(
                key: ValueKey('narration_${widget.entry.rowId}'),
                controller: widget.narrationController,
                textInputAction: TextInputAction.done,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.narration,
                  suffixStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400, // default unfocused color
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1,
                    ),
                  ),
                ),
                onChanged: (value) {
                  widget.onChanged(widget.entry.copyWith(
                    narration: value,
                  ));
                },
              ),
            ),
          ),

          // Delete
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => widget.onRemove(widget.entry.rowId),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferSummary extends StatelessWidget {
  final double totalDebit;
  final double totalCredit;
  final String currencySymbol;

  const _TransferSummary({
    required this.totalDebit,
    required this.totalCredit,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final difference = totalDebit - totalCredit;
    final isBalanced = difference.abs() < 0.01;

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isBalanced ? Colors.green : Colors.red,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.totalDebit,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.outline.withValues(alpha: .6)),
                    ),
                    Text(
                      '$currencySymbol ${totalDebit.toAmount()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.totalCredit,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.outline.withValues(alpha: .6)),
                    ),
                    Text(
                      '$currencySymbol ${totalCredit.toAmount()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.difference,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.outline.withValues(alpha: .6)),
                    ),
                    Text(
                      '$currencySymbol ${difference.abs().toAmount()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isBalanced ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (!isBalanced)
            const SizedBox(height: 8),
            if (!isBalanced)
              Row(
                children: [
                  Icon(Icons.error, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.debitNoEqualCredit,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        )
    );
  }
}
