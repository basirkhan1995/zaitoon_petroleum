import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoon_petroleum/Localizations/Bloc/localizations_bloc.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/Currencies/model/ccy_model.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/Ui/ExchangeRate/bloc/exchange_rate_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Finance/Ui/Currency/features/currency_drop.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../../../../../../../../Features/Generic/rounded_searchable_textfield.dart';
import '../../../../../../../../Features/Other/thousand_separator.dart';
import '../../../../../../../../Features/Other/utils.dart';
import '../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../Auth/bloc/auth_bloc.dart';
import '../../../../Stakeholders/Ui/Accounts/bloc/accounts_bloc.dart';
import '../../../../Stakeholders/Ui/Accounts/model/acc_model.dart';
import '../bloc/fx_bloc.dart';
import '../model/fx_model.dart';

class FxTransactionScreen extends StatefulWidget {
  const FxTransactionScreen({super.key});

  @override
  State<FxTransactionScreen> createState() => _FxTransactionScreenState();
}

class _FxTransactionScreenState extends State<FxTransactionScreen> {
  final Map<int, List<TextEditingController>> _rowControllers = {};
  final Map<int, FocusNode> _rowFocusNodes = {};
  final TextEditingController _exchangeRateCtrl = TextEditingController();
  String? userName;
  String? _fromSelectedCurrency;
  String? _toSelectedCurrency;

  bool _isDisposed = false;
  double _exchangeRate = 1.0;
  double _totalConvertedAmount = 0.0;

  // Store entry errors for display
  final Map<int, String> _entryErrors = {};

  @override
  void initState() {
    super.initState();
    context.read<FxBloc>().add(InitializeFxEvent());
    _fromSelectedCurrency = 'USD';
    _toSelectedCurrency = 'AFN';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchExchangeRate();
    });
  }

  void _fetchExchangeRate() {
    if (_fromSelectedCurrency != null && _toSelectedCurrency != null) {
      final xBloc = context.read<ExchangeRateBloc>();
      xBloc.add(
        GetExchangeRateEvent(
          fromCcy: _fromSelectedCurrency!,
          toCcy: _toSelectedCurrency!,
        ),
      );
    }
  }

  void _clearAllControllersAndFocus() {
    for (final controllers in _rowControllers.values) {
      for (final controller in controllers) {
        controller.clear();
      }
    }
    for (final node in _rowFocusNodes.values) {
      node.unfocus();
    }
    _fromSelectedCurrency = 'USD';
    _toSelectedCurrency = "AFN";
    _exchangeRateCtrl.clear();
    _exchangeRate = 1.0;
    _totalConvertedAmount = 0.0;
    _entryErrors.clear();
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (final controllers in _rowControllers.values) {
      for (final controller in controllers) {
        controller.dispose();
      }
    }
    _rowControllers.clear();

    for (final node in _rowFocusNodes.values) {
      node.dispose();
    }
    _rowFocusNodes.clear();
    _exchangeRateCtrl.dispose();
    super.dispose();
  }

  void _ensureControllerForEntry(TransferEntry entry) {
    if (!_rowControllers.containsKey(entry.rowId)) {
      _rowControllers[entry.rowId] = [
        TextEditingController(text: entry.accountName ?? ''),
        TextEditingController(
          text: entry.debit > 0 ? entry.debit.toAmount() : '',
        ),
        TextEditingController(
          text: entry.credit > 0 ? entry.credit.toAmount() : '',
        ),
        TextEditingController(text: entry.narration),
      ];
      if (!_rowFocusNodes.containsKey(entry.rowId)) {
        _rowFocusNodes[entry.rowId] = FocusNode();
      }
    }
  }

  String? baseCurrency;

  @override
  Widget build(BuildContext context) {
    final comState = context.watch<CompanyProfileBloc>().state;
    if (comState is CompanyProfileLoadedState) {
      baseCurrency = comState.company.comLocalCcy;
    }

    return BlocListener<ExchangeRateBloc, ExchangeRateState>(
      listener: (context, state) {
        if (state is ExchangeRateLoadedState) {
          final rate = double.tryParse(state.rate ?? "1.0") ?? 1.0;

          // Update exchange rate without setState
          _exchangeRate = rate;
          _exchangeRateCtrl.text = state.rate ?? "";

          // Update narration with new rate for all entries that have amounts
          _updateAllNarrationWithRate();

          // Recalculate converted amount
          _recalculateConvertedAmount();
        }
      },
      child: ZFormDialog(
        width: MediaQuery.of(context).size.width * .7,
        icon: Icons.bubble_chart_outlined,
        isActionTrue: false,
        onAction: null,
        title: AppLocalizations.of(context)!.fxTransactionTitle,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, auth) {
            if (auth is AuthenticatedState) {
              userName = auth.loginData.usrName;
            }

            return BlocConsumer<FxBloc, FxState>(
              listener: (context, state) {
                if (state is FxSavedState && state.success) {
                  Utils.showOverlayMessage(
                    context,
                    message: state.reference,
                    isError: false,
                  );
                  _clearAllControllersAndFocus();
                  context.read<FxBloc>().add(InitializeFxEvent());
                } else if (state is FxApiErrorState) {
                  Utils.showOverlayMessage(
                    context,
                    message: state.error,
                    isError: true,
                  );
                }
              },
              builder: (context, state) {
                if (_isDisposed) return const SizedBox.shrink();

                if (state is FxLoadedState || state is FxSavingState) {
                  final entries = (state is FxLoadedState
                      ? state.entries
                      : (state as FxSavingState).entries);
                  for (final entry in entries) {
                    _ensureControllerForEntry(entry);
                  }

                  // Calculate converted amount whenever entries change
                  _recalculateConvertedAmount();

                  return _buildLoadedState(
                    context,
                    state is FxLoadedState
                        ? state
                        : FxLoadedState(
                      entries: (state as FxSavingState).entries,
                      totalDebit: state.entries.fold(
                        0.0,
                            (sum, e) => sum + e.debit,
                      ),
                      totalCredit: state.entries.fold(
                        0.0,
                            (sum, e) => sum + e.credit,
                      ),
                    ),
                  );
                } else if (state is FxApiErrorState) {
                  return _buildErrorState(context, state);
                } else if (state is FxErrorState) {
                  return Center(
                    child: Text(
                      state.error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
      ),
    );
  }

  void _recalculateConvertedAmount() {
    // Get total debit amount in from currency
    final fxState = context.read<FxBloc>().state;
    if (fxState is FxLoadedState) {
      final totalDebit = fxState.totalDebit;
      _totalConvertedAmount = totalDebit * _exchangeRate;
    }
  }

  void _updateAllNarrationWithRate() {
    final fxState = context.read<FxBloc>().state;
    if (fxState is! FxLoadedState) return;

    for (final entry in fxState.entries) {
      if (entry.debit > 0 || entry.credit > 0) {
        final controllers = _rowControllers[entry.rowId];
        if (controllers != null) {
          final narrationController = controllers[3];
          final currentNarration = narrationController.text;
          final ratePattern = RegExp(r'@\d+(\.\d+)?');

          String newNarration;
          if (ratePattern.hasMatch(currentNarration)) {
            newNarration = currentNarration.replaceAll(
              ratePattern,
              '@${_exchangeRate.toStringAsFixed(2)}',
            );
          } else if (currentNarration.trim().isNotEmpty) {
            newNarration = '${currentNarration.trim()} @${_exchangeRate.toStringAsFixed(2)}';
          } else {
            newNarration = '@${_exchangeRate.toStringAsFixed(2)}';
          }

          if (currentNarration != newNarration) {
            narrationController.text = newNarration;
            context.read<FxBloc>().add(
              UpdateFxEntryEvent(
                id: entry.rowId,
                narration: newNarration,
              ),
            );
          }
        }
      }
    }
  }

  Widget _buildLoadedState(BuildContext context, FxLoadedState state) {
    final isEmpty = state.entries.isEmpty;
    final isRateLoading = context.watch<ExchangeRateBloc>().state is ExchangeRateLoadingState;

    // Check for currency mismatches and other errors
    bool hasDebitCurrencyMismatch = false;
    bool hasCreditCurrencyMismatch = false;
    bool hasInvalidEntryType = false;
    bool hasValidationErrors = false;

    // Recalculate errors
    final newEntryErrors = <int, String>{};

    if (!isEmpty) {
      for (final entry in state.entries) {
        String? errorMessage;

        // Check if entry has both debit and credit (invalid)
        if (entry.debit > 0 && entry.credit > 0) {
          errorMessage = 'Entry cannot have both debit and credit amounts';
          hasInvalidEntryType = true;
        }
        // Check if entry has debit (should be fromCurrency)
        else if (entry.debit > 0) {
          if (entry.currency != null && entry.currency != _fromSelectedCurrency) {
            errorMessage = 'Debit account currency (${entry.currency}) must match From currency ($_fromSelectedCurrency)';
            hasDebitCurrencyMismatch = true;
          }
        }
        // Check if entry has credit (should be toCurrency)
        else if (entry.credit > 0) {
          if (entry.currency != null && entry.currency != _toSelectedCurrency) {
            errorMessage = 'Credit account currency (${entry.currency}) must match To currency ($_toSelectedCurrency)';
            hasCreditCurrencyMismatch = true;
          }
        }

        if (errorMessage != null) {
          newEntryErrors[entry.rowId] = errorMessage;
          hasValidationErrors = true;
        }
      }
    }

    // Update entry errors only if changed
    if (_mapsAreDifferent(_entryErrors, newEntryErrors)) {
      _entryErrors.clear();
      _entryErrors.addAll(newEntryErrors);
    }

    // Calculate if credit matches converted amount
    final creditMatchesConverted = (state.totalCredit - _totalConvertedAmount).abs() < 0.01;

    return Column(
      children: [
        // Header Section
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: CurrencyDropdown(
                      height: 40,
                      title: AppLocalizations.of(context)!.from,
                      initiallySelectedSingle: CurrenciesModel(
                        ccyCode: _fromSelectedCurrency,
                      ),
                      isMulti: false,
                      onMultiChanged: (_) {},
                      onSingleChanged: (e) {
                        final newCurrency = e?.ccyCode ?? baseCurrency;
                        if (newCurrency != _fromSelectedCurrency) {
                          _fromSelectedCurrency = newCurrency;
                          _fetchExchangeRate();

                          // Update debit entries currency
                          final fxBloc = context.read<FxBloc>();
                          for (final entry in state.entries) {
                            if (entry.debit > 0) {
                              fxBloc.add(
                                UpdateFxEntryEvent(
                                  id: entry.rowId,
                                  currency: _fromSelectedCurrency,
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CurrencyDropdown(
                      height: 40,
                      title: AppLocalizations.of(context)!.toCurrency,
                      initiallySelectedSingle: CurrenciesModel(
                        ccyCode: _toSelectedCurrency,
                      ),
                      isMulti: false,
                      onMultiChanged: (_) {},
                      onSingleChanged: (e) {
                        final newCurrency = e?.ccyCode ?? baseCurrency;
                        if (newCurrency != _toSelectedCurrency) {
                          _toSelectedCurrency = newCurrency;
                          _fetchExchangeRate();

                          // Update credit entries currency
                          final fxBloc = context.read<FxBloc>();
                          for (final entry in state.entries) {
                            if (entry.credit > 0) {
                              fxBloc.add(
                                UpdateFxEntryEvent(
                                  id: entry.rowId,
                                  currency: _toSelectedCurrency,
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ZTextFieldEntitled(
                      controller: _exchangeRateCtrl,
                      end: isRateLoading ? Container(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2)) : null,
                      title: AppLocalizations.of(context)!.exchangeRate,
                      onChanged: (value) {
                        final rate = double.tryParse(value) ?? 1.0;
                        _exchangeRate = rate;
                        _recalculateConvertedAmount();
                        _updateAllNarrationWithRate();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ZOutlineButton(
                    height: 40,
                    icon: Icons.add,
                    onPressed: () {
                      // Add entry with fromCurrency by default (for debit)
                      context.read<FxBloc>().add(AddFxEntryEvent(
                        initialCurrency: _fromSelectedCurrency,
                      ));
                    },
                    width: 120,
                    label: Text(AppLocalizations.of(context)!.addEntry),
                  ),
                  const SizedBox(width: 8),
                  _buildSaveButton(
                    context,
                    state,
                    hasDebitCurrencyMismatch,
                    hasCreditCurrencyMismatch,
                    hasInvalidEntryType,
                    creditMatchesConverted,
                  ),
                ],
              ),

              // Display general warnings
              if (isEmpty)
                _buildWarningMessage(
                  Icons.info_outline,
                  Colors.blue,
                  'Add entries to begin transaction',
                ),

              if (hasDebitCurrencyMismatch)
                _buildWarningMessage(
                  Icons.warning,
                  Colors.orange,
                  'Some debit entries have currency mismatch',
                ),

              if (hasCreditCurrencyMismatch)
                _buildWarningMessage(
                  Icons.warning,
                  Colors.orange,
                  'Some credit entries have currency mismatch',
                ),

              if (hasInvalidEntryType)
                _buildWarningMessage(
                  Icons.error,
                  Colors.red,
                  'Some entries have both debit and credit amounts',
                ),

              if (!isEmpty && !creditMatchesConverted)
                _buildWarningMessage(
                  Icons.warning,
                  Colors.red,
                  'Total credit does not match converted amount',
                ),
            ],
          ),
        ),
        if (!isEmpty) ...[
          const SizedBox(height: 8),
          _TransferHeaderRow(
            fromCurrencySymbol: _fromSelectedCurrency ?? baseCurrency ?? "",
            toCurrencySymbol: _toSelectedCurrency ?? baseCurrency ?? "",
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: state.entries.length,
              itemBuilder: (context, index) {
                final entry = state.entries[index];
                final controllers = _rowControllers[entry.rowId];
                final focusNode = _rowFocusNodes[entry.rowId];
                if (controllers == null || focusNode == null) {
                  return const SizedBox.shrink();
                }

                // Determine if this is a debit or credit entry based on amount
                final isDebitEntry = entry.debit > 0;
                final isCreditEntry = entry.credit > 0;
                final expectedCurrency = isDebitEntry
                    ? _fromSelectedCurrency
                    : (isCreditEntry ? _toSelectedCurrency : null);

                // Only show currency mismatch if there's an amount AND currency doesn't match
                final hasCurrencyMismatch = expectedCurrency != null &&
                    entry.currency != null &&
                    entry.currency != expectedCurrency;

                return Column(
                  key: ValueKey('entry_row_${entry.rowId}'),
                  children: [
                    if (_entryErrors.containsKey(entry.rowId))
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _entryErrors[entry.rowId]!,
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _TransferEntryRow(
                      key: ValueKey(entry.rowId),
                      entry: entry,
                      index: index,
                      focusNode: focusNode,
                      accountController: controllers[0],
                      debitController: controllers[1],
                      creditController: controllers[2],
                      narrationController: controllers[3],
                      fromCurrency: _fromSelectedCurrency,
                      toCurrency: _toSelectedCurrency,
                      expectedCurrency: expectedCurrency,
                      hasCurrencyMismatch: hasCurrencyMismatch,
                      exchangeRate: _exchangeRate,
                      errorMessage: _entryErrors[entry.rowId],
                      onChanged: (updatedEntry) {
                        if (_isDisposed) return;

                        // Add rate to narration if amount is entered
                        if ((updatedEntry.debit > 0 || updatedEntry.credit > 0) &&
                            !updatedEntry.narration.contains('@')) {
                          final newNarration = updatedEntry.narration.isNotEmpty
                              ? '${updatedEntry.narration} @${_exchangeRate.toStringAsFixed(2)}'
                              : '@${_exchangeRate.toStringAsFixed(2)}';

                          context.read<FxBloc>().add(
                            UpdateFxEntryEvent(
                              id: updatedEntry.rowId,
                              accountNumber: updatedEntry.accountNumber,
                              accountName: updatedEntry.accountName,
                              currency: updatedEntry.currency,
                              debit: updatedEntry.debit,
                              credit: updatedEntry.credit,
                              narration: newNarration,
                            ),
                          );
                        } else {
                          context.read<FxBloc>().add(
                            UpdateFxEntryEvent(
                              id: updatedEntry.rowId,
                              accountNumber: updatedEntry.accountNumber,
                              accountName: updatedEntry.accountName,
                              currency: updatedEntry.currency,
                              debit: updatedEntry.debit,
                              credit: updatedEntry.credit,
                              narration: updatedEntry.narration,
                            ),
                          );
                        }
                      },
                      onRemove: (id) {
                        if (_isDisposed) return;
                        context.read<FxBloc>().add(RemoveFxEntryEvent(id));
                        _entryErrors.remove(id);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          _TransferSummary(
            totalDebit: state.totalDebit,
            totalCredit: state.totalCredit,
            fromCurrencySymbol: _fromSelectedCurrency ?? baseCurrency ?? "",
            toCurrencySymbol: _toSelectedCurrency ?? baseCurrency ?? "",
            exchangeRate: _exchangeRate,
            totalConvertedAmount: _totalConvertedAmount,
          ),
        ] else ...[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: .5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No entries added',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: .7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click "+ Add Entry" to start',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: .5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool _mapsAreDifferent(Map<int, String> map1, Map<int, String> map2) {
    if (map1.length != map2.length) return true;
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) return true;
    }
    return false;
  }

  Widget _buildWarningMessage(IconData icon, Color color, String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, FxApiErrorState state) {
    return Column(
      children: [
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
                      AppLocalizations.of(context)!.transactionFailedTitle,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(state.error, style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  context.read<FxBloc>().add(ClearFxApiErrorEvent());
                },
              ),
            ],
          ),
        ),

        Expanded(
          child: _buildLoadedState(
            context,
            FxLoadedState(
              entries: state.entries,
              totalDebit: state.entries.fold(
                0.0,
                    (sum, entry) => sum + entry.debit,
              ),
              totalCredit: state.entries.fold(
                0.0,
                    (sum, entry) => sum + entry.credit,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(
      BuildContext context,
      FxLoadedState state,
      bool hasDebitCurrencyMismatch,
      bool hasCreditCurrencyMismatch,
      bool hasInvalidEntryType,
      bool creditMatchesConverted,
      ) {
    final hasEntries = state.entries.isNotEmpty;
    final allAccountsValid = state.entries.every(
          (entry) => entry.accountNumber != null,
    );

    // Check that at least one entry has non-zero amount (debit or credit > 0)
    final hasNonZeroAmount = state.entries.any(
          (entry) => entry.debit > 0 || entry.credit > 0,
    );

    // Check that debits and credits are not mixed in the same entry
    final hasValidAmounts = state.entries.every(
          (entry) =>
      (entry.debit > 0 && entry.credit == 0) ||
          (entry.credit > 0 && entry.debit == 0) ||
          (entry.debit == 0 && entry.credit == 0),
    );

    // Check that we have both debit and credit entries
    final hasDebitEntries = state.entries.any((entry) => entry.debit > 0);
    final hasCreditEntries = state.entries.any((entry) => entry.credit > 0);
    final hasBothTypes = hasDebitEntries && hasCreditEntries;

    // Validate that total debit > 0
    final hasValidDebit = state.totalDebit > 0;

    // Check if any entries have validation errors
    final hasEntryErrors = _entryErrors.isNotEmpty;

    final isValid =
        hasEntries &&
            allAccountsValid &&
            hasNonZeroAmount &&
            hasValidAmounts &&
            hasBothTypes &&
            hasValidDebit &&
            creditMatchesConverted &&
            !hasEntryErrors;

    return BlocBuilder<FxBloc, FxState>(
      builder: (context, blocState) {
        final isSaving = blocState is FxSavingState;

        return ZOutlineButton(
          height: 40,
          icon: isSaving ? null : Icons.cached_rounded,
          onPressed: !isValid || userName == null || isSaving
              ? null
              : () async {
            final completer = Completer<String>();
            context.read<FxBloc>().add(
              SaveFxEvent(
                userName: userName!,
                fromCurrency: _fromSelectedCurrency ?? "",
                toCurrency: _toSelectedCurrency ?? "",
                exchangeRate: _exchangeRate,
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
          label: isSaving
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
              : Text(AppLocalizations.of(context)!.create),
        );
      },
    );
  }
}

class _TransferHeaderRow extends StatelessWidget {
  final String fromCurrencySymbol;
  final String toCurrencySymbol;

  const _TransferHeaderRow({
    required this.fromCurrencySymbol,
    required this.toCurrencySymbol,
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
            width: 25,
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
              '${AppLocalizations.of(context)!.debitTitle} ($fromCurrencySymbol)',
              style: TextStyle(
                color: color.surface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              '${AppLocalizations.of(context)!.creditTitle} ($toCurrencySymbol)',
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
            child: Icon(
              Icons.delete_outline_rounded,
              color: Theme.of(context).colorScheme.surface,
              size: 20,
            ),
          ),
        ],
      ),
    );
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
  final String? fromCurrency;
  final String? toCurrency;
  final String? expectedCurrency;
  final bool hasCurrencyMismatch;
  final double exchangeRate;
  final String? errorMessage;
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
    this.fromCurrency,
    this.toCurrency,
    this.expectedCurrency,
    required this.hasCurrencyMismatch,
    required this.exchangeRate,
    this.errorMessage,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_TransferEntryRow> createState() => __TransferEntryRowState();
}

class __TransferEntryRowState extends State<_TransferEntryRow> {
  String? baseCurrency;
  String? currentLocale;
  bool _hasInitializedNarration = false;

  @override
  void initState() {
    super.initState();
    // Initialize narration with rate in next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNarrationWithRate();
    });
  }

  void _initializeNarrationWithRate() {
    if (!_hasInitializedNarration &&
        (widget.entry.debit > 0 || widget.entry.credit > 0) &&
        !widget.entry.narration.contains('@') &&
        widget.exchangeRate > 0) {
      _addRateToNarration();
      _hasInitializedNarration = true;
    }
  }

  void _addRateToNarration() {
    final currentNarration = widget.narrationController.text;
    final ratePattern = RegExp(r'@\d+(\.\d+)?');

    String newNarration;
    if (ratePattern.hasMatch(currentNarration)) {
      // Update existing rate
      newNarration = currentNarration.replaceAll(
        ratePattern,
        '@${widget.exchangeRate.toStringAsFixed(2)}',
      );
    } else if (currentNarration.trim().isNotEmpty) {
      // Add rate to existing narration
      newNarration = '${currentNarration.trim()} @${widget.exchangeRate.toStringAsFixed(2)}';
    } else {
      // Just add rate
      newNarration = '@${widget.exchangeRate.toStringAsFixed(2)}';
    }

    widget.narrationController.text = newNarration;
  }

  void _handleAmountChange(double newAmount, bool isDebit) {
    // Clear opposite field
    if (isDebit) {
      widget.creditController.clear();
    } else {
      widget.debitController.clear();
    }

    // Force currency based on debit/credit
    final forcedCurrency = isDebit ? widget.fromCurrency : widget.toCurrency;

    // Update entry
    final updatedEntry = widget.entry.copyWith(
      debit: isDebit ? newAmount : 0.0,
      credit: !isDebit ? newAmount : 0.0,
      currency: forcedCurrency,
    );

    widget.onChanged(updatedEntry);

    // Add rate to narration if amount > 0
    if (newAmount > 0 && !widget.entry.narration.contains('@')) {
      _addRateToNarration();
    }
  }

  @override
  Widget build(BuildContext context) {
    currentLocale = context.watch<LocalizationBloc>().state.countryCode;
    final comState = context.watch<CompanyProfileBloc>().state;
    if (comState is CompanyProfileLoadedState) {
      baseCurrency = comState.company.comLocalCcy;
    }

    // Determine if this is a debit or credit entry
    final isDebitEntry = widget.entry.debit > 0;
    final isCreditEntry = widget.entry.credit > 0;
    final expectedCurrency = isDebitEntry ? widget.fromCurrency : widget.toCurrency;

    // Check if we should show currency validation
    final shouldValidateCurrency = (isDebitEntry || isCreditEntry);
    final showCurrencyError = shouldValidateCurrency && widget.hasCurrencyMismatch;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: showCurrencyError
            ? Colors.orange[50]
            : Theme.of(context).colorScheme.surface,
        border: showCurrencyError
            ? Border.all(color: Colors.orange, width: 1)
            : null,
      ),
      child: Row(
        spacing: 5,
        children: [
          SizedBox(
            width: 37,
            child: Text('${widget.index + 1}', textAlign: TextAlign.center),
          ),

          // Account Selection
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 40,
              child: GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
                key: ValueKey('account_${widget.entry.rowId}'),
                showAllOnFocus: true,
                controller: widget.accountController,
                title: '',
                hintText: AppLocalizations.of(context)!.accounts,
                isRequired: true,
                bloc: context.read<AccountsBloc>(),
                fetchAllFunction: (bloc) => bloc.add(
                  LoadAccountsFilterEvent(
                    start: 1,
                    end: 5,
                    exclude: "10101011",
                    ccy: expectedCurrency ?? baseCurrency,
                    locale: currentLocale ?? 'en',
                  ),
                ),
                searchFunction: (bloc, query) => bloc.add(
                  LoadAccountsFilterEvent(
                    input: query,
                    start: 1,
                    end: 5,
                    exclude: "10101011",
                    ccy: expectedCurrency ?? baseCurrency,
                    locale: currentLocale ?? 'en',
                  ),
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
                          "${account.accNumber} | ${account.accName}",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: shouldValidateCurrency &&
                                  account.actCurrency == expectedCurrency
                                  ? Colors.green.shade100
                                  : shouldValidateCurrency
                                  ? Colors.orange.shade100
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              account.actCurrency ?? baseCurrency ?? "",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                color: shouldValidateCurrency &&
                                    account.actCurrency == expectedCurrency
                                    ? Colors.green[800]
                                    : shouldValidateCurrency
                                    ? Colors.orange[800]
                                    : Colors.grey[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                itemToString: (account) =>
                "${account.accNumber} | ${account.accName}",
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

                  final accountCurrency = account.actCurrency;

                  // Update entry with selected account
                  final updatedEntry = widget.entry.copyWith(
                    accountNumber: account.accNumber,
                    accountName: account.accName,
                    currency: accountCurrency,
                  );

                  // If amount exists, check currency match
                  if (shouldValidateCurrency) {
                    final isCurrencyValid = accountCurrency == expectedCurrency;

                    if (!isCurrencyValid) {
                      // Show warning but don't prevent selection
                      Utils.showOverlayMessage(
                        context,
                        message: isDebitEntry
                            ? 'Debit account should be in $expectedCurrency (selected: $accountCurrency)'
                            : 'Credit account should be in $expectedCurrency (selected: $accountCurrency)',
                        isError: true,
                        duration: Duration(seconds: 2),
                      );
                    }
                  }

                  widget.onChanged(updatedEntry);
                },
                noResultsText: 'No account found',
                showClearButton: true,
              ),
            ),
          ),

          // Currency Display - SIMPLIFIED VERSION
          SizedBox(
            width: 50,
            height: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: showCurrencyError
                    ? Colors.orange.shade50
                    : Colors.grey.shade100,
                border: Border.all(
                  color: showCurrencyError
                      ? Colors.orange
                      : Theme.of(context).colorScheme.outline.withValues(alpha: .5),
                  width: showCurrencyError ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Tooltip(
                message: shouldValidateCurrency && expectedCurrency != null
                    ? 'Selected: ${widget.entry.currency ?? "---"}\nExpected: $expectedCurrency'
                    : 'Currency: ${widget.entry.currency ?? "---"}',
                child: Center(
                  child: Text(
                    widget.entry.currency ?? baseCurrency ?? "",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: showCurrencyError
                          ? Colors.orange[800]
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),

          // Debit Field
          SizedBox(
            width: 150,
            height: 40,
            child: TextField(
              key: ValueKey('debit_${widget.entry.rowId}'),
              controller: widget.debitController,
              style: TextStyle(fontSize: 15),
              focusNode: widget.focusNode,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]*')),
                SmartThousandsDecimalFormatter(),
              ],
              decoration: InputDecoration(
                hintText: '0.00',
                suffixText: widget.entry.debit > 0 ? 'Dr' : null,
                suffixStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: showCurrencyError && isDebitEntry
                        ? Colors.orange
                        : Theme.of(context).colorScheme.outline.withValues(alpha: .5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: showCurrencyError && isDebitEntry
                        ? Colors.orange
                        : Theme.of(context).colorScheme.outline.withValues(alpha: .5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: showCurrencyError && isDebitEntry
                        ? Colors.orange
                        : Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                ),
              ),
              onChanged: (value) {
                final debit = value.cleanAmount.toDoubleAmount();
                _handleAmountChange(debit, true);
              },
            ),
          ),

          // Credit Field
          SizedBox(
            width: 150,
            height: 40,
            child: TextFormField(
              key: ValueKey('credit_${widget.entry.rowId}'),
              controller: widget.creditController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 15),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]*')),
                SmartThousandsDecimalFormatter(),
              ],
              decoration: InputDecoration(
                hintText: '0.00',
                suffixText: widget.entry.credit > 0 ? 'Cr' : null,
                suffixStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: showCurrencyError && isCreditEntry
                        ? Colors.orange
                        : Theme.of(context).colorScheme.outline.withValues(alpha: .5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: showCurrencyError && isCreditEntry
                        ? Colors.orange
                        : Theme.of(context).colorScheme.outline.withValues(alpha: .5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: showCurrencyError && isCreditEntry
                        ? Colors.orange
                        : Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                ),
              ),
              onChanged: (value) {
                final credit = value.cleanAmount.toDoubleAmount();
                _handleAmountChange(credit, false);
              },
            ),
          ),

          // Narration Field
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 40,
              child: TextField(
                key: ValueKey('narration_${widget.entry.rowId}'),
                controller: widget.narrationController,
                textInputAction: TextInputAction.done,
                maxLines: 1,
                style: TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.narration,
                  suffixText: (widget.entry.debit > 0 || widget.entry.credit > 0)
                      ? '@${widget.exchangeRate.toStringAsFixed(2)}'
                      : null,
                  suffixStyle: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: showCurrencyError
                          ? Colors.orange
                          : Theme.of(context).colorScheme.outline.withValues(alpha: .5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: showCurrencyError
                          ? Colors.orange
                          : Theme.of(context).colorScheme.outline.withValues(alpha: .5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: showCurrencyError
                          ? Colors.orange
                          : Theme.of(context).colorScheme.primary,
                      width: 1,
                    ),
                  ),
                ),
                onChanged: (value) {
                  widget.onChanged(widget.entry.copyWith(narration: value));
                },
              ),
            ),
          ),

          // Delete Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 20,
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
  final String fromCurrencySymbol;
  final String toCurrencySymbol;
  final double exchangeRate;
  final double totalConvertedAmount;

  const _TransferSummary({
    required this.totalDebit,
    required this.totalCredit,
    required this.fromCurrencySymbol,
    required this.toCurrencySymbol,
    required this.exchangeRate,
    required this.totalConvertedAmount,
  });

  @override
  Widget build(BuildContext context) {
    // Check if credit matches converted amount
    final creditMatchesConverted = (totalCredit - totalConvertedAmount).abs() < 0.01;
    final difference = (totalCredit - totalConvertedAmount).abs();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: creditMatchesConverted ? Colors.green : Colors.red,
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
                    'Total Debit',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: .6),
                    ),
                  ),
                  Text(
                    '$fromCurrencySymbol ${totalDebit.toAmount()}',
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
                    'Exchange Rate',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: .6),
                    ),
                  ),
                  Text(
                    '1 $fromCurrencySymbol = $exchangeRate $toCurrencySymbol',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Converted Amount',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: .6),
                    ),
                  ),
                  Text(
                    '$toCurrencySymbol ${totalConvertedAmount.toAmount()}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Credit',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: .6),
                    ),
                  ),
                  Text(
                    '$toCurrencySymbol ${totalCredit.toAmount()}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: creditMatchesConverted ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!creditMatchesConverted)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Credit amount does not match converted amount. '
                          'Difference: $toCurrencySymbol ${difference.toAmount()}',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}