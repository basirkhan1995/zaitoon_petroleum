import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import '../../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../../../Features/Other/thousand_separator.dart';
import '../../../../../../../../Features/Other/utils.dart';
import '../../../../../../../../Features/Widgets/button.dart';
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
    // Remove controllers for deleted entries
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bulk Transfer"),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, auth) {
          if (auth is AuthenticatedState) {
            userName = auth.loginData.usrName;
          }

          return BlocConsumer<TransferBloc, TransferState>(
            listener: (context, state) {
              if (state is TransferSavedState) {
                if (state.success) {
                  Utils.showOverlayMessage(context,
                    message: 'Transfer completed successfully',
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
    // Validate currency mismatch
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
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Currency Selection
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _currencyController,
                      decoration: InputDecoration(
                        labelText: 'Transaction Currency',
                        hintText: 'USD',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            setState(() {
                              _selectedCurrency = _currencyController.text.trim().toUpperCase();
                            });
                            // Update all entries with selected currency
                            for (final entry in state.entries) {
                              context.read<TransferBloc>().add(
                                UpdateTransferEntryEvent(
                                  id: entry.rowId,
                                  accountNumber: entry.accountNumber,
                                  accountName: entry.accountName,
                                  currency: _selectedCurrency,
                                  debit: entry.debit,
                                  credit: entry.credit,
                                  narration: entry.narration,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrency = value.trim().toUpperCase();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ZOutlineButton(
                    height: 48,
                    icon: Icons.add,
                    onPressed: () {
                      context.read<TransferBloc>().add(AddTransferEntryEvent());
                    },
                    width: 130,
                    label: const Text('Add Entry'),
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
                        'Some accounts have different currency. Click check icon to update all.',
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
                        'Debit and Credit totals are not equal!',
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

        const SizedBox(height: 16),

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

    return ZButton(
      height: 46,
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
          // Success is handled in listener
        } catch (e) {
          // Error is handled in listener via TransferApiErrorState
        }
      },
      width: 130,
      label: const Text('Save Transfer'),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.primary,
          borderRadius: BorderRadius.circular(4),
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
                'Account',
                style: TextStyle(
                  color: color.surface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 95,
              child: Text(
                textAlign: TextAlign.center,
                'Currency',
                style: TextStyle(
                  color: color.surface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                'Debit ($currencySymbol)',
                style: TextStyle(
                  color: color.surface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                'Credit ($currencySymbol)',
                style: TextStyle(
                  color: color.surface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Narration',
                style: TextStyle(
                  color: color.surface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                'Action',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color.surface,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
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
              hintText: 'Account',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.accName ?? '',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Row(
                      children: [
                        Text(
                          account.accNumber.toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
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
                                  ? Colors.green
                                  : Colors.orange,
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
                child: CircularProgressIndicator(strokeWidth: 2),
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
                  currency: widget.selectedCurrency ?? account.actCurrency,
                ));
              },
              noResultsText: 'No account found',
              showClearButton: true,
            ),
          ),

          // Currency
          SizedBox(
            width: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: hasCurrencyMismatch ? Colors.orange.shade50 : null,
                border: Border.all(
                  color: hasCurrencyMismatch ? Colors.orange : Colors.grey.shade400,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                entryCurrency,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: hasCurrencyMismatch ? Colors.orange : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Debit
          SizedBox(
            width: 120,
            child: TextField(
              key: ValueKey('debit_${widget.entry.rowId}'),
              controller: widget.debitController,
              focusNode: widget.focusNode,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]*')),
                SmartThousandsDecimalFormatter(),
              ],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                hintText: '0.00',
                suffixText: entryCurrency,
                suffixStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
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
            width: 120,
            child: TextField(
              key: ValueKey('credit_${widget.entry.rowId}'),
              controller: widget.creditController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]*')),
                SmartThousandsDecimalFormatter(),
              ],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                hintText: '0.00',
                suffixText: entryCurrency,
                suffixStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
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
            child: TextField(
              key: ValueKey('narration_${widget.entry.rowId}'),
              controller: widget.narrationController,
              textInputAction: TextInputAction.done,
              maxLines: 1,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                hintText: 'Description',
              ),
              onChanged: (value) {
                widget.onChanged(widget.entry.copyWith(
                  narration: value,
                ));
              },
            ),
          ),

          // Delete
          SizedBox(
            width: 80,
            child: Center(
              child: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => widget.onRemove(widget.entry.rowId),
              ),
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
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
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
                      'Total Debit:',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      '$currencySymbol ${totalDebit.toAmount()}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Credit:',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      '$currencySymbol ${totalCredit.toAmount()}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Difference:',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      '$currencySymbol ${difference.abs().toAmount()}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: isBalanced ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!isBalanced)
              Row(
                children: [
                  Icon(Icons.error, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Debit and Credit totals are not equal. Please adjust amounts to balance.',
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