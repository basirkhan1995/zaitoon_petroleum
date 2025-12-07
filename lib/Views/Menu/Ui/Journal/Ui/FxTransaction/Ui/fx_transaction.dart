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
  final Map<int, List<TextEditingController>> _debitControllers = {};
  final Map<int, List<TextEditingController>> _creditControllers = {};
  final TextEditingController _narrationController = TextEditingController();
  final Map<int, FocusNode> _debitFocusNodes = {};
  final Map<int, FocusNode> _creditFocusNodes = {};

  String? userName;
  String? _baseCurrency;
  final Map<String, double> _exchangeRates = {};
  bool _isDisposed = false;

  // Track which rate requests are for which currencies
  final Map<String, Completer<double>> _pendingRateRequests = {};
  final Map<String, String> _rateCurrencyPairs = {};

  @override
  void initState() {
    super.initState();
    context.read<FxBloc>().add(InitializeFxEvent());

    // Set default base currency from company profile
    final comState = context.read<CompanyProfileBloc>().state;
    if (comState is CompanyProfileLoadedState) {
      _baseCurrency = comState.company.comLocalCcy;
      if (_baseCurrency != null) {
        context.read<FxBloc>().add(UpdateBaseCurrencyEvent(_baseCurrency));
      }
    }
  }

  Future<double> _fetchExchangeRate(String fromCcy, String toCcy) async {
    if (_baseCurrency == null) return 1.0;

    final key = '$fromCcy:$toCcy';

    // Don't fetch rate if same currency
    if (fromCcy == toCcy) {
      _exchangeRates[key] = 1.0;
      return 1.0;
    }

    // Check if rate is already cached
    if (_exchangeRates.containsKey(key)) {
      return _exchangeRates[key]!;
    }

    // Check if request is already pending
    if (_pendingRateRequests.containsKey(key)) {
      return await _pendingRateRequests[key]!.future;
    }

    // Create new completer for this request
    final completer = Completer<double>();
    _pendingRateRequests[key] = completer;

    // Store currency pair for this request
    _rateCurrencyPairs[key] = '$fromCcy:$toCcy';

    final xBloc = context.read<ExchangeRateBloc>();
    xBloc.add(
      GetExchangeRateEvent(
        fromCcy: fromCcy,
        toCcy: toCcy,
      ),
    );

    // Wait for response (will be completed in listener)
    final rate = await completer.future;
    _pendingRateRequests.remove(key);
    _rateCurrencyPairs.remove(key);

    return rate;
  }

  void _handleExchangeRateResponse(String fromCcy, String toCcy, double rate) {
    final key = '$fromCcy:$toCcy';
    _exchangeRates[key] = rate;

    // Also store the reverse rate
    final reverseKey = '$toCcy:$fromCcy';
    if (rate > 0) {
      _exchangeRates[reverseKey] = 1.0 / rate;
    }

    // Complete pending request if exists
    if (_pendingRateRequests.containsKey(key)) {
      _pendingRateRequests[key]!.complete(rate);
    }

    // Update UI
    if (mounted) {
      setState(() {});
    }
  }

  double _getExchangeRate(String fromCcy, String toCcy) {
    if (fromCcy == toCcy) return 1.0;

    final key = '$fromCcy:$toCcy';
    return _exchangeRates[key] ?? 1.0;
  }

  double _convertToBase(double amount, String currency) {
    if (_baseCurrency == null || currency == _baseCurrency) return amount;
    final rate = _getExchangeRate(currency, _baseCurrency!);
    return amount * rate;
  }

  void _clearAllControllers() {
    for (final controllers in _debitControllers.values) {
      for (final controller in controllers) {
        controller.dispose();
      }
    }
    for (final controllers in _creditControllers.values) {
      for (final controller in controllers) {
        controller.dispose();
      }
    }
    for (final node in _debitFocusNodes.values) {
      node.dispose();
    }
    for (final node in _creditFocusNodes.values) {
      node.dispose();
    }

    _debitControllers.clear();
    _creditControllers.clear();
    _debitFocusNodes.clear();
    _creditFocusNodes.clear();

    _narrationController.clear();
    _exchangeRates.clear();
    _pendingRateRequests.clear();
    _rateCurrencyPairs.clear();
  }

  void _ensureControllerForEntry(TransferEntry entry, bool isDebit) {
    final map = isDebit ? _debitControllers : _creditControllers;
    final focusMap = isDebit ? _debitFocusNodes : _creditFocusNodes;

    if (!map.containsKey(entry.rowId)) {
      map[entry.rowId] = [
        TextEditingController(text: entry.accountName ?? ''),
        TextEditingController(text: entry.amount.toAmount()),
      ];

      if (!focusMap.containsKey(entry.rowId)) {
        focusMap[entry.rowId] = FocusNode();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _clearAllControllers();
    _narrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExchangeRateBloc, ExchangeRateState>(
      listener: (context, state) {
        if (state is ExchangeRateLoadedState && state.rate != null) {
          final rate = double.tryParse(state.rate ?? "1.0") ?? 1.0;

          // We need to know which currencies this rate is for
          // Since your state doesn't include from/to, we'll check pending requests
          // This is a workaround - ideally ExchangeRateLoadedState should have fromCcy/toCcy

          // Find which pending request this rate belongs to
          for (final key in _pendingRateRequests.keys.toList()) {
            if (_rateCurrencyPairs.containsKey(key)) {
              final currencies = _rateCurrencyPairs[key]!.split(':');
              if (currencies.length == 2) {
                final fromCcy = currencies[0];
                final toCcy = currencies[1];
                _handleExchangeRateResponse(fromCcy, toCcy, rate);
                break; // Assume first match is correct
              }
            }
          }
        }
      },
      child: ZFormDialog(
        width: MediaQuery.of(context).size.width * .99,
        icon: Icons.currency_exchange,
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
                  _clearAllControllers();
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

                if (state is FxLoadedState || state is FxSavingState || state is FxApiErrorState) {
                  // These states all have the properties we need
                  final isSaving = state is FxSavingState;
                  final hasError = state is FxApiErrorState;

                  // Extract properties from state
                  String? baseCurrency;
                  String narration = '';
                  List<TransferEntry> debitEntries = [];
                  List<TransferEntry> creditEntries = [];
                  double totalDebitBase = 0.0;
                  double totalCreditBase = 0.0;

                  if (state is FxLoadedState) {
                    baseCurrency = state.baseCurrency;
                    narration = state.narration;
                    debitEntries = state.debitEntries;
                    creditEntries = state.creditEntries;
                    totalDebitBase = state.totalDebitBase;
                    totalCreditBase = state.totalCreditBase;
                  } else if (state is FxSavingState) {
                    baseCurrency = state.baseCurrency;
                    narration = state.narration;
                    debitEntries = state.debitEntries;
                    creditEntries = state.creditEntries;
                    totalDebitBase = state.totalDebitBase;
                    totalCreditBase = state.totalCreditBase;
                  } else if (state is FxApiErrorState) {
                    baseCurrency = state.baseCurrency;
                    narration = state.narration;
                    debitEntries = state.debitEntries;
                    creditEntries = state.creditEntries;
                    totalDebitBase = state.totalDebitBase;
                    totalCreditBase = state.totalCreditBase;
                  }

                  // Ensure controllers exist for all entries
                  for (final entry in debitEntries) {
                    _ensureControllerForEntry(entry, true);
                  }
                  for (final entry in creditEntries) {
                    _ensureControllerForEntry(entry, false);
                  }

                  // Update narration controller
                  if (_narrationController.text != narration) {
                    _narrationController.text = narration;
                  }

                  return _buildLoadedState(
                    context,
                    baseCurrency: baseCurrency,
                    narration: narration,
                    debitEntries: debitEntries,
                    creditEntries: creditEntries,
                    totalDebitBase: totalDebitBase,
                    totalCreditBase: totalCreditBase,
                    isSaving: isSaving,
                    hasError: hasError,
                    fxState: state,
                  );
                } else if (state is FxErrorState) {
                  return Center(
                    child: Text(
                      state.error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                } else if (state is FxSavedState) {
                  // After saving, show success message
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'Transaction Successful!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Reference: ${state.reference}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<FxBloc>().add(InitializeFxEvent());
                          },
                          child: const Text('New Transaction'),
                        ),
                      ],
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

  Widget _buildLoadedState(
      BuildContext context, {
        required String? baseCurrency,
        required String narration,
        required List<TransferEntry> debitEntries,
        required List<TransferEntry> creditEntries,
        required double totalDebitBase,
        required double totalCreditBase,
        required bool isSaving,
        required bool hasError,
        required FxState fxState,
      }) {
    final hasDebitEntries = debitEntries.isNotEmpty;
    final hasCreditEntries = creditEntries.isNotEmpty;
    final hasEntries = hasDebitEntries || hasCreditEntries;

    // Calculate totals in base currency
    double calculatedDebitBase = 0;
    for (final entry in debitEntries) {
      if (entry.currency != null && entry.amount > 0) {
        if (baseCurrency != null && entry.currency != baseCurrency) {
          // Fetch exchange rate if needed (async, will update UI when completed)
          _fetchExchangeRate(entry.currency!, baseCurrency);
        }
        calculatedDebitBase += _convertToBase(entry.amount, entry.currency!);
      }
    }

    double calculatedCreditBase = 0;
    for (final entry in creditEntries) {
      if (entry.currency != null && entry.amount > 0) {
        if (baseCurrency != null && entry.currency != baseCurrency) {
          // Fetch exchange rate if needed (async, will update UI when completed)
          _fetchExchangeRate(entry.currency!, baseCurrency);
        }
        calculatedCreditBase += _convertToBase(entry.amount, entry.currency!);
      }
    }

    final totalsMatch = (calculatedDebitBase - calculatedCreditBase).abs() < 0.01;
    final difference = (calculatedDebitBase - calculatedCreditBase).abs();

    return Column(
      children: [
        // Header Section
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              if (hasError && fxState is FxApiErrorState)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fxState.error,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CurrencyDropdown(
                      height: 40,
                      title: 'Base Currency',
                      initiallySelectedSingle: CurrenciesModel(
                        ccyCode: baseCurrency,
                      ),
                      isMulti: false,
                      onMultiChanged: (_) {},
                      onSingleChanged: (e) {
                        final newCurrency = e?.ccyCode;
                        if (newCurrency != baseCurrency) {
                          _baseCurrency = newCurrency;
                          context.read<FxBloc>().add(UpdateBaseCurrencyEvent(newCurrency));

                          // Clear exchange rates when base currency changes
                          _exchangeRates.clear();
                          _pendingRateRequests.clear();
                          _rateCurrencyPairs.clear();

                          // Fetch new rates for all entries
                          for (final entry in debitEntries) {
                            if (entry.currency != null && entry.currency != newCurrency) {
                              _fetchExchangeRate(entry.currency!, newCurrency!);
                            }
                          }
                          for (final entry in creditEntries) {
                            if (entry.currency != null && entry.currency != newCurrency) {
                              _fetchExchangeRate(entry.currency!, newCurrency!);
                            }
                          }

                          // Update UI
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: ZTextFieldEntitled(
                      title: 'Narration',
                      controller: _narrationController,
                      onChanged: (value) {
                        context.read<FxBloc>().add(UpdateNarrationEvent(value));
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildSaveButton(
                    context,
                    baseCurrency: baseCurrency,
                    debitEntries: debitEntries,
                    creditEntries: creditEntries,
                    totalsMatch: totalsMatch,
                    isSaving: isSaving,
                  ),
                ],
              ),

              // Validation message
              if (!totalsMatch && hasEntries)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Debit and Credit totals must match in base currency. '
                              'Difference: ${baseCurrency ?? ''} ${difference.toAmount()}',
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Debit and Credit Sections
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Debit Section
              Expanded(
                child: _buildSideSection(
                  context,
                  title: 'Debit Side',
                  entries: debitEntries,
                  isDebit: true,
                  totalAmount: debitEntries.fold(0.0, (sum, entry) => sum + entry.amount),
                  totalBase: calculatedDebitBase,
                  baseCurrency: baseCurrency,
                ),
              ),

              const SizedBox(width: 16),

              // Credit Section
              Expanded(
                child: _buildSideSection(
                  context,
                  title: 'Credit Side',
                  entries: creditEntries,
                  isDebit: false,
                  totalAmount: creditEntries.fold(0.0, (sum, entry) => sum + entry.amount),
                  totalBase: calculatedCreditBase,
                  baseCurrency: baseCurrency,
                ),
              ),
            ],
          ),
        ),

        // Summary Section
        if (hasEntries)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _buildSummarySection(
              context,
              totalDebitBase: calculatedDebitBase,
              totalCreditBase: calculatedCreditBase,
              totalsMatch: totalsMatch,
              difference: difference,
              baseCurrency: baseCurrency,
            ),
          ),
      ],
    );
  }

  Widget _buildSideSection(
      BuildContext context, {
        required String title,
        required List<TransferEntry> entries,
        required bool isDebit,
        required double totalAmount,
        required double totalBase,
        required String? baseCurrency,
      }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isDebit ? Colors.blue.shade50 : Colors.green.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDebit ? Colors.blue.shade800 : Colors.green.shade800,
                  ),
                ),
                const Spacer(),
                ZOutlineButton(
                  height: 32,
                  icon: Icons.add,
                  onPressed: () {
                    context.read<FxBloc>().add(AddFxEntryEvent(isDebit: isDebit));
                  },
                  label: const Text('Add Row'),
                ),
              ],
            ),
          ),

          // Table Header
          _TableHeaderRow(isDebit: isDebit, baseCurrency: baseCurrency),

          // Entries
          Expanded(
            child: entries.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No entries',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final controllers = (isDebit ? _debitControllers : _creditControllers)[entry.rowId];
                final focusNode = (isDebit ? _debitFocusNodes : _creditFocusNodes)[entry.rowId];

                if (controllers == null || focusNode == null) {
                  return const SizedBox.shrink();
                }

                return _EntryRow(
                  entry: entry,
                  index: index,
                  isDebit: isDebit,
                  baseCurrency: baseCurrency,
                  accountController: controllers[0],
                  amountController: controllers[1],
                  focusNode: focusNode,
                  exchangeRates: _exchangeRates,
                  fetchExchangeRate: _fetchExchangeRate,
                  onAccountSelected: (account) {
                    final updatedEntry = entry.copyWith(
                      accountNumber: account.accNumber,
                      accountName: account.accName,
                      currency: account.actCurrency,
                    );

                    context.read<FxBloc>().add(UpdateFxEntryEvent(
                      id: entry.rowId,
                      isDebit: isDebit,
                      accountNumber: account.accNumber,
                      accountName: account.accName,
                      currency: account.actCurrency,
                    ));

                    // Fetch exchange rate if needed
                    if (baseCurrency != null && account.actCurrency != null && account.actCurrency != baseCurrency) {
                      _fetchExchangeRate(account.actCurrency!, baseCurrency);
                    }
                  },
                  onAmountChanged: (amount) {
                    context.read<FxBloc>().add(UpdateFxEntryEvent(
                      id: entry.rowId,
                      isDebit: isDebit,
                      amount: amount,
                    ));

                    // Fetch exchange rate if needed
                    if (baseCurrency != null && entry.currency != null && entry.currency != baseCurrency) {
                      _fetchExchangeRate(entry.currency!, baseCurrency);
                    }
                  },
                  onRemove: () {
                    context.read<FxBloc>().add(RemoveFxEntryEvent(entry.rowId, isDebit: isDebit));
                  },
                );
              },
            ),
          ),

          // Footer with totals
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${totalAmount.toAmount()} (various)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${baseCurrency ?? ''} ${totalBase.toAmount()} (base)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
      BuildContext context, {
        required double totalDebitBase,
        required double totalCreditBase,
        required bool totalsMatch,
        required double difference,
        required String? baseCurrency,
      }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: totalsMatch ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: totalsMatch ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Total Debit (Base)',
            '${baseCurrency ?? ''} ${totalDebitBase.toAmount()}',
            totalsMatch ? Colors.green.shade800 : Colors.red.shade800,
          ),
          _buildSummaryItem(
            'Total Credit (Base)',
            '${baseCurrency ?? ''} ${totalCreditBase.toAmount()}',
            totalsMatch ? Colors.green.shade800 : Colors.red.shade800,
          ),
          _buildSummaryItem(
            'Status',
            totalsMatch ? 'BALANCED' : 'UNBALANCED',
            totalsMatch ? Colors.green : Colors.red,
            isBold: true,
          ),
          if (!totalsMatch)
            _buildSummaryItem(
              'Difference',
              '${baseCurrency ?? ''} ${difference.toAmount()}',
              Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, {bool isBold = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(
      BuildContext context, {
        required String? baseCurrency,
        required List<TransferEntry> debitEntries,
        required List<TransferEntry> creditEntries,
        required bool totalsMatch,
        required bool isSaving,
      }) {
    final hasDebitEntries = debitEntries.isNotEmpty;
    final hasCreditEntries = creditEntries.isNotEmpty;
    final allAccountsValid = [...debitEntries, ...creditEntries]
        .every((entry) => entry.accountNumber != null);
    final hasNonZeroAmounts = [...debitEntries, ...creditEntries]
        .any((entry) => entry.amount > 0);
    final baseCurrencySelected = baseCurrency != null && baseCurrency.isNotEmpty;

    final isValid = baseCurrencySelected &&
        hasDebitEntries &&
        hasCreditEntries &&
        allAccountsValid &&
        hasNonZeroAmounts &&
        totalsMatch;

    return ZOutlineButton(
      height: 40,
      icon: Icons.save,
      onPressed: !isValid || userName == null || isSaving
          ? null
          : () async {
        final completer = Completer<String>();
        context.read<FxBloc>().add(
          SaveFxEvent(
            userName: userName!,
            completer: completer,
          ),
        );
        try {
          await completer.future;
        } catch (e) {
          // Error is handled in listener
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
          : const Text('Save'),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  final bool isDebit;
  final String? baseCurrency;

  const _TableHeaderRow({required this.isDebit, required this.baseCurrency});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: const Text('#')),
          const Expanded(child: Text('Account')),
          SizedBox(width: 80, child: const Text('Currency')),
          SizedBox(width: 120, child: const Text('Amount')),
          SizedBox(width: 140, child: const Text('Exchange Rate')),
          SizedBox(width: 120, child: Text('Amount in ${baseCurrency ?? "Base"}')),
          SizedBox(width: 40, child: const Text('')),
        ],
      ),
    );
  }
}

class _EntryRow extends StatefulWidget {
  final TransferEntry entry;
  final int index;
  final bool isDebit;
  final String? baseCurrency;
  final TextEditingController accountController;
  final TextEditingController amountController;
  final FocusNode focusNode;
  final Map<String, double> exchangeRates;
  final Future<double> Function(String, String) fetchExchangeRate;
  final Function(AccountsModel) onAccountSelected;
  final Function(double) onAmountChanged;
  final Function() onRemove;

  const _EntryRow({
    required this.entry,
    required this.index,
    required this.isDebit,
    required this.baseCurrency,
    required this.accountController,
    required this.amountController,
    required this.focusNode,
    required this.exchangeRates,
    required this.fetchExchangeRate,
    required this.onAccountSelected,
    required this.onAmountChanged,
    required this.onRemove,
  });

  @override
  State<_EntryRow> createState() => __EntryRowState();
}

class __EntryRowState extends State<_EntryRow> {
  String? baseCurrency;
  String? currentLocale;
  double _amountInBase = 0.0;
  double _exchangeRate = 1.0;
  bool _isLoadingRate = false;

  @override
  void initState() {
    super.initState();
    _calculateAmountInBase();
    _fetchRateIfNeeded();
  }

  void _fetchRateIfNeeded() async {
    if (widget.baseCurrency != null &&
        widget.entry.currency != null &&
        widget.entry.currency != widget.baseCurrency) {

      final key = '${widget.entry.currency}:${widget.baseCurrency}';

      if (!widget.exchangeRates.containsKey(key)) {
        setState(() {
          _isLoadingRate = true;
        });

        try {
          await widget.fetchExchangeRate(widget.entry.currency!, widget.baseCurrency!);
        } catch (e) {
          // Handle error
        } finally {
          if (mounted) {
            setState(() {
              _isLoadingRate = false;
            });
          }
        }
      }
    }
  }

  void _calculateAmountInBase() {
    if (widget.baseCurrency != null && widget.entry.currency != null && widget.entry.amount > 0) {
      if (widget.entry.currency == widget.baseCurrency) {
        _exchangeRate = 1.0;
        _amountInBase = widget.entry.amount;
      } else {
        // Get exchange rate from the map
        final key = '${widget.entry.currency}:${widget.baseCurrency}';
        _exchangeRate = widget.exchangeRates[key] ?? 1.0;
        _amountInBase = widget.entry.amount * _exchangeRate;
      }
    } else {
      _amountInBase = 0.0;
      _exchangeRate = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _EntryRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entry.currency != oldWidget.entry.currency ||
        widget.entry.amount != oldWidget.entry.amount ||
        widget.baseCurrency != oldWidget.baseCurrency ||
        widget.exchangeRates != oldWidget.exchangeRates) {
      _calculateAmountInBase();

      // Fetch rate if needed when currencies change
      if ((widget.entry.currency != oldWidget.entry.currency ||
          widget.baseCurrency != oldWidget.baseCurrency) &&
          widget.baseCurrency != null &&
          widget.entry.currency != null &&
          widget.entry.currency != widget.baseCurrency) {
        _fetchRateIfNeeded();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    currentLocale = context.watch<LocalizationBloc>().state.countryCode;
    final comState = context.watch<CompanyProfileBloc>().state;
    if (comState is CompanyProfileLoadedState) {
      baseCurrency = comState.company.comLocalCcy;
    }

    // Update calculation when widget updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateAmountInBase();
    });

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Index
          SizedBox(
            width: 40,
            child: Text('${widget.index + 1}'),
          ),

          // Account Selection
          Expanded(
            child: SizedBox(
              height: 40,
              child: GenericTextfield<AccountsModel, AccountsBloc, AccountsState>(
                controller: widget.accountController,
                title: '',
                hintText: 'Select Account',
                isRequired: true,
                bloc: context.read<AccountsBloc>(),
                fetchAllFunction: (bloc) => bloc.add(
                  LoadAccountsFilterEvent(
                    start: 1,
                    end: 5,
                    exclude: "10101011",
                    ccy: baseCurrency,
                    locale: currentLocale ?? 'en',
                  ),
                ),
                searchFunction: (bloc, query) => bloc.add(
                  LoadAccountsFilterEvent(
                    input: query,
                    start: 1,
                    end: 5,
                    exclude: "10101011",
                    ccy: baseCurrency,
                    locale: currentLocale ?? 'en',
                  ),
                ),
                itemBuilder: (context, account) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${account.accNumber} | ${account.accName}",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          account.actCurrency ?? baseCurrency ?? "",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                onSelected: widget.onAccountSelected,
                noResultsText: 'No account found',
                showClearButton: true,
              ),
            ),
          ),

          // Currency Display
          SizedBox(
            width: 80,
            child: Center(
              child: Text(
                widget.entry.currency ?? '---',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.entry.currency == widget.baseCurrency
                      ? Colors.green
                      : Colors.blue,
                ),
              ),
            ),
          ),

          // Amount Field
          SizedBox(
            width: 120,
            height: 40,
            child: TextField(
              controller: widget.amountController,
              focusNode: widget.focusNode,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]*')),
                SmartThousandsDecimalFormatter(),
              ],
              decoration: const InputDecoration(
                hintText: '0.00',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              onChanged: (value) {
                final amount = value.cleanAmount.toDoubleAmount();
                widget.onAmountChanged(amount);
                // Recalculate amount in base
                _calculateAmountInBase();
                setState(() {});
              },
            ),
          ),

          // Exchange Rate Display
          SizedBox(
            width: 140,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_isLoadingRate)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 1),
                    )
                  else if (widget.entry.currency != null && widget.baseCurrency != null)
                    Column(
                      children: [
                        if (widget.entry.currency != widget.baseCurrency)
                          Text(
                            '1 ${widget.entry.currency} = ${_exchangeRate.toStringAsFixed(6)} ${widget.baseCurrency}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          )
                        else
                          const Text(
                            'Same Currency',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    )
                  else
                    const Text(
                      '---',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),

          // Amount in Base Currency
          SizedBox(
            width: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${widget.baseCurrency ?? ""} ${_amountInBase.toAmount()}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Remove Button
          SizedBox(
            width: 40,
            child: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              onPressed: widget.onRemove,
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}