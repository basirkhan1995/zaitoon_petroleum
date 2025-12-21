import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchATAT/bloc/fetch_atat_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchATAT/fetch_atat.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchGLAT/Ui/glat_view.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchGLAT/bloc/glat_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchTRPT/Ui/trpt_view.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchTRPT/bloc/trpt_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/TxnByReference/bloc/txn_reference_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/TxnByReference/txn_reference.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/bloc/transactions_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../Localizations/Bloc/localizations_bloc.dart';

class PendingTransactionsView extends StatelessWidget {
  const PendingTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      tablet: _Tablet(),
      desktop: _Desktop(),
    );
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
  bool _isLoadingDialog = false;
  String? _loadingRef;
  String? myLocale;

  // Track copied state for each reference
  final Map<String, bool> _copiedStates = {};

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      myLocale = context.read<LocalizationBloc>().state.languageCode;
      context.read<TransactionsBloc>().add(LoadAllTransactionsEvent('pending'));
    });
    super.initState();
  }

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _handleTransactionTap(dynamic txn) async {
    if (_selectionMode) {
      _toggleSelection(txn);
      return;
    }

    setState(() {
      _isLoadingDialog = true;
      _loadingRef = txn.trnReference;
    });

    try {
      if (txn.trnType == "ATAT" || txn.trnType == "CRFX") {
        context.read<FetchAtatBloc>().add(
          FetchAccToAccEvent(txn.trnReference ?? ""),
        );
      } else if (txn.trnType == "GLAT") {
        context.read<GlatBloc>().add(LoadGlatEvent(txn.trnReference ?? ""));
      } else if(txn.trnType == "TRPT"){
        context.read<TrptBloc>().add(LoadTrptEvent(txn.trnReference ?? ""));
      } else {
        context.read<TxnReferenceBloc>().add(
          FetchTxnByReferenceEvent(txn.trnReference ?? ""),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingDialog = false;
        _loadingRef = null;
      });
    }
  }

  // Method to copy reference to clipboard
  Future<void> _copyToClipboard(String reference, BuildContext context) async {
    await Utils.copyToClipboard(reference);

    // Set copied state to true
    setState(() {
      _copiedStates[reference] = true;
    });

    // Reset after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedStates.remove(reference);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<TrptBloc, TrptState>(
          listener: (context, state) {
            if (state is TrptLoadedState) {
              setState(() {
                _isLoadingDialog = false;
                _loadingRef = null;
              });
              showDialog(
                context: context,
                builder: (context) => TrptView(reference: state.trpt.shdTrnRef ?? ""),
              );
            } else if (state is TrptErrorState) {
              setState(() {
                _isLoadingDialog = false;
                _loadingRef = null;
              });
              Utils.showOverlayMessage(
                context,
                title: locale.noData,
                message: state.error,
                isError: true,
              );
            }
          },
        ),
        BlocListener<GlatBloc, GlatState>(
          listener: (context, state) {
            if (state is GlatLoadedState) {
              setState(() {
                _isLoadingDialog = false;
                _loadingRef = null;
              });
              showDialog(
                context: context,
                builder: (context) => GlatView(),
              );
            } else if (state is GlatErrorState) {
              setState(() {
                _isLoadingDialog = false;
                _loadingRef = null;
              });
              Utils.showOverlayMessage(
                context,
                title: locale.noData,
                message: state.message,
                isError: true,
              );
            }
          },
        ),
        BlocListener<FetchAtatBloc, FetchAtatState>(
          listener: (context, state) {
            if (state is FetchATATLoadedState) {
              setState(() {
                _isLoadingDialog = false;
                _loadingRef = null;
              });
              showDialog(
                context: context,
                builder: (context) => FetchAtatView(),
              );
            } else if (state is FetchATATErrorState) {
              setState(() {
                _isLoadingDialog = false;
                _loadingRef = null;
              });
              Utils.showOverlayMessage(
                context,
                title: locale.noData,
                message: state.message,
                isError: true,
              );
            }
          },
        ),
        BlocListener<TxnReferenceBloc, TxnReferenceState>(
          listener: (context, state) {
            if (state is TxnReferenceLoadedState) {
              setState(() {
                _isLoadingDialog = false;
                _loadingRef = null;
              });
              showDialog(
                context: context,
                builder: (context) => TxnReferenceView(),
              );
            } else if (state is TxnReferenceErrorState) {
              setState(() {
                _isLoadingDialog = false;
                _loadingRef = null;
              });
              Utils.showOverlayMessage(
                context,
                title: locale.noData,
                message: state.error,
                isError: true,
              );
            }
          },
        ),
      ],
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Column(
              children: [
                if (_selectionMode)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 8,
                      children: [
                        ZOutlineButton(
                          width: 150,
                          icon: Icons.check_box_rounded,
                          label: Text(
                            "${locale.authorize} (${_selectedRefs.length})",
                          ),
                        ),
                        ZOutlineButton(
                          isActive: true,
                          backgroundHover: Theme.of(
                            context,
                          ).colorScheme.error,
                          width: 120,
                          icon: Icons.delete_outline_rounded,
                          label: Text(
                            "${locale.delete} (${_selectedRefs.length})",
                          ),
                        ),
                        ZOutlineButton(
                          width: 100,
                          onPressed: () {
                            setState(() {
                              _selectionMode = false;
                              _selectedRefs.clear();
                            });
                          },
                          isActive: true,
                          label: Text(locale.cancel),
                        ),
                      ],
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 8,
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      Expanded(
                          flex: 6,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                            title: Text(locale.pendingTransactions,style: Theme.of(context).textTheme.titleMedium),
                            subtitle: Text(locale.pendingTransactionHint),
                          )),
                      Expanded(
                        flex: 3,
                        child: ZSearchField(
                          icon: FontAwesomeIcons.magnifyingGlass,
                          controller: searchController,
                          hint: AppLocalizations.of(context)!.search,
                          onChanged: (e) {
                            setState(() {});
                          },
                          title: "",
                        ),
                      ),
                      ZOutlineButton(
                        toolTip: "F5",
                        width: 120,
                        icon: Icons.refresh,
                        onPressed: () {
                          context.read<TransactionsBloc>().add(
                            LoadAllTransactionsEvent('pending'),
                          );
                        },
                        label: Text(locale.refresh),
                      ),
                    ],
                  ),
                ),

                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      // SELECT-ALL CHECKBOX
                      if (_selectionMode)
                        SizedBox(
                          width: 40,
                          child: BlocBuilder<TransactionsBloc, TransactionsState>(
                            builder: (context, state) {
                              if (state is! TransactionLoadedState) {
                                return const SizedBox();
                              }

                              final allSelected =
                                  _selectedRefs.length == state.txn.length;

                              return Checkbox(
                                value: allSelected && _selectionMode,
                                onChanged: (v) => _toggleSelectAll(state.txn),
                              );
                            },
                          ),
                        ),

                      SizedBox(
                        width: 162,
                        child: Text(
                          locale.txnDate,
                          style: textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              locale.referenceNumber,
                              style: textTheme.titleSmall,
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.content_copy,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: Text(
                          locale.txnType,
                          style: textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 110,
                        child: Text(
                          locale.maker,
                          style: textTheme.titleSmall,
                        ),
                      ),
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
                  child: BlocConsumer<TransactionsBloc, TransactionsState>(
                    listener: (context, state) {
                      if (state is TransactionErrorState) {
                        Utils.showOverlayMessage(
                          context,
                          title: locale.accessDenied,
                          message: state.message,
                          isError: true,
                        );
                      }
                      if (state is TransactionSuccessState) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context).pop();
                          context.read<TransactionsBloc>().add(
                            LoadAllTransactionsEvent('pending'),
                          );
                        });
                      }
                    },
                    builder: (context, state) {
                      if (state is TransactionErrorState) {
                        return NoDataWidget(
                          message: state.message,
                          onRefresh: () {
                            context.read<TransactionsBloc>().add(
                              LoadAllTransactionsEvent('pending'),
                            );
                          },
                        );
                      }

                      if (state is TxnLoadingState) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state is TransactionLoadedState) {
                        final query = searchController.text.toLowerCase().trim();
                        final filteredList = state.txn.where((item) {
                          final name = item.trnReference?.toLowerCase() ?? '';
                          return name.contains(query);
                        }).toList();

                        if (filteredList.isEmpty) {
                          return NoDataWidget(
                            message: locale.noDataFound,
                            onRefresh: () {
                              context.read<TransactionsBloc>().add(
                                LoadAllTransactionsEvent('pending'),
                              );
                            },
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final txn = filteredList[index];
                            final reference = txn.trnReference ?? "";
                            final isSelected = _selectedRefs.contains(reference);
                            final isLoadingThisItem = _isLoadingDialog && _loadingRef == reference;
                            final isCopied = _copiedStates[reference] ?? false;

                            return InkWell(
                              onTap: isLoadingThisItem ? null : () => _handleTransactionTap(txn),
                              onLongPress: () {
                                _toggleSelection(txn);
                              },
                              hoverColor: Theme.of(context).primaryColor.withAlpha(13),
                              child: Container(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary.withAlpha(38)
                                    : index.isOdd
                                    ? Theme.of(context).colorScheme.primary.withAlpha(15)
                                    : Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 8,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_selectionMode)
                                    // CHECKBOX
                                      SizedBox(
                                        width: 40,
                                        child: Checkbox(
                                          visualDensity: const VisualDensity(
                                            vertical: -4,
                                          ),
                                          value: isSelected,
                                          onChanged: (v) => _toggleSelection(txn),
                                        ),
                                      ),

                                    SizedBox(
                                      width: 162,
                                      child: Row(
                                        children: [
                                          if (isLoadingThisItem)
                                            Container(
                                              width: 16,
                                              height: 16,
                                              margin: EdgeInsets.only(
                                                  right: myLocale == "en" ? 8 : 0,
                                                  left: myLocale == "en" ? 0 : 8),
                                              child: const CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          Flexible(
                                            child: Text(
                                              txn.trnEntryDate!.toFullDateTime,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),

                                    // Reference column with copy button on the left
                                    Expanded(
                                      child: Row(
                                        children: [
                                          // Copy Button - Fixed width container
                                          SizedBox(
                                            width: isCopied ? 100 : 30,
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: isCopied
                                                    ? Theme.of(context).colorScheme.primary.withAlpha(25)
                                                    : Colors.transparent,
                                                border: Border.all(
                                                  color: isCopied
                                                      ? Theme.of(context).colorScheme.primary
                                                      : Theme.of(context).dividerColor,
                                                  width: 1,
                                                ),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () => _copyToClipboard(reference, context),
                                                  borderRadius: BorderRadius.circular(6),
                                                  hoverColor: Theme.of(context).colorScheme.primary.withAlpha(13),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        isCopied ? Icons.check : Icons.content_copy,
                                                        size: 16,
                                                        color: isCopied
                                                            ? Theme.of(context).colorScheme.primary
                                                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: .6),
                                                      ),
                                                      if (isCopied)
                                                        AnimatedOpacity(
                                                          duration: const Duration(milliseconds: 200),
                                                          opacity: isCopied ? 1 : 0,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left: 4),
                                                            child: Text(
                                                              locale.copied,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Theme.of(context).colorScheme.primary,
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Reference text that takes remaining space
                                          Expanded(
                                            child: Text(
                                              reference,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(
                                      width: 110,
                                      child: Text(
                                        Utils.getTxnCode(
                                          txn: txn.trnType ?? "",
                                          context: context,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    const SizedBox(width: 20),
                                    SizedBox(
                                      width: 110,
                                      child: Text(
                                        txn.maker ?? "",
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
          ),
          if (_isLoadingDialog && _loadingRef == null)
            Container(
              color: Colors.black.withAlpha(100),
              child: const Center(
                child: CircularProgressIndicator(),
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