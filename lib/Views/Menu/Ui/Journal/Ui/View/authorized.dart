import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchGLAT/Ui/glat_view.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchGLAT/bloc/glat_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/bloc/transactions_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../Features/Other/utils.dart';
import '../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../Localizations/Bloc/localizations_bloc.dart';
import '../FetchATAT/bloc/fetch_atat_bloc.dart';
import '../FetchATAT/fetch_atat.dart';
import '../FetchTRPT/Ui/trpt_view.dart';
import '../FetchTRPT/bloc/trpt_bloc.dart';
import '../TxnByReference/bloc/txn_reference_bloc.dart';
import '../TxnByReference/txn_reference.dart';

class AuthorizedTransactionsView extends StatelessWidget {
  const AuthorizedTransactionsView({super.key});

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
  final Map<String, bool> _copiedStates = {};
  bool _isLoadingDialog = false;
  String? _loadingRef;
  String? myLocale;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      myLocale = context.read<LocalizationBloc>().state.languageCode;
      context.read<TransactionsBloc>().add(LoadAllTransactionsEvent('auth'));
    });
    super.initState();
  }

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _handleTransactionTap(dynamic txn) {
    setState(() {
      _isLoadingDialog = true;
      _loadingRef = txn.trnReference;
    });

    if (txn.trnType == "ATAT" || txn.trnType == "CRFX") {
      context.read<FetchAtatBloc>().add(
        FetchAccToAccEvent(txn.trnReference ?? ""),
      );
    }else if(txn.trnType == "TRPT"){
      context.read<TrptBloc>().add(LoadTrptEvent(txn.trnReference ?? ""));
    } else if (txn.trnType == "GLAT") {
      context.read<GlatBloc>().add(LoadGlatEvent(txn.trnReference ?? ""));
    } else {
      context.read<TxnReferenceBloc>().add(
        FetchTxnByReferenceEvent(txn.trnReference ?? ""),
      );
    }
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
            } else if (state is GlatLoadingState) {
              setState(() {
                _isLoadingDialog = true;
              });
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
            } else if (state is FetchATATLoadingState) {
              setState(() {
                _isLoadingDialog = true;
              });
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
            } else if (state is TxnReferenceLoadingState) {
              setState(() {
                _isLoadingDialog = true;
              });
            }
          },
        ),
      ],
      child: Stack(
        children: [
          Scaffold(
            body: Column(
              children: [
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
                            tileColor: Colors.transparent,
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                            title: Text(locale.todayTransaction,style: Theme.of(context).textTheme.titleMedium),
                            subtitle: Text(DateTime.now().toFormattedDate()),
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
                          context
                              .read<TransactionsBloc>()
                              .add(LoadAllTransactionsEvent('auth'));
                        },
                        label: Text(locale.refresh),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 162,
                        child:
                        Text(locale.txnDate, style: textTheme.titleSmall),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          locale.referenceNumber,
                          style: textTheme.titleSmall,
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: Text(locale.txnType, style: textTheme.titleSmall),
                      ),
                      SizedBox(width: 20),
                      SizedBox(
                        width: 110,
                        child: Text(locale.maker, style: textTheme.titleSmall),
                      ),
                      SizedBox(
                        width: 110,
                        child: Text(locale.checker, style: textTheme.titleSmall),
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.outline,
                ),
                Expanded(
                  child: BlocConsumer<TransactionsBloc, TransactionsState>(
                    listener: (context, state) {
                      if (state is TransactionSuccessState) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context).pop();
                          context.read<TransactionsBloc>().add(
                            LoadAllTransactionsEvent('auth'),
                          );
                        });
                      }
                    },
                    builder: (context, state) {
                      if (state is TransactionErrorState) {
                        return NoDataWidget(
                          message: state.message,
                          onRefresh: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              context.read<TransactionsBloc>().add(
                                LoadAllTransactionsEvent('auth'),
                              );
                            });
                          },
                        );
                      }
                      if (state is TxnLoadingState) {
                        return Center(child: CircularProgressIndicator());
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
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                context.read<TransactionsBloc>().add(
                                  LoadAllTransactionsEvent('auth'),
                                );
                              });
                            },
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final txn = filteredList[index];
                            final isLoadingThisItem = _isLoadingDialog && _loadingRef == txn.trnReference;
                            final isCopied = _copiedStates[txn.trnReference ?? ""] ?? false;
                            final reference = txn.trnReference ?? "";
                            return InkWell(
                              onTap: isLoadingThisItem
                                  ? null
                                  : () => _handleTransactionTap(txn),
                              hoverColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: .05),
                              highlightColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: .05),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: index.isOdd
                                      ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: .06)
                                      : Colors.transparent,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 162,
                                        child: Row(
                                          children: [
                                            if (isLoadingThisItem)
                                              Container(
                                                width: 16,
                                                height: 16,
                                                margin: EdgeInsets.only(right: myLocale == "en"? 8 : 0, left: myLocale == "en"? 0 : 8),
                                                child:
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                            Text(
                                              txn.trnEntryDate!.toFullDateTime,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 28, // Fixed width
                                              height: 28, // Fixed height
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () => _copyToClipboard(reference, context),
                                                  borderRadius: BorderRadius.circular(4),
                                                  hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: .05),
                                                  child: AnimatedContainer(
                                                    duration: const Duration(milliseconds: 100),
                                                    decoration: BoxDecoration(
                                                      color: isCopied
                                                          ? Theme.of(context).colorScheme.primary.withAlpha(25)
                                                          : Colors.transparent,
                                                      border: Border.all(
                                                        color: isCopied
                                                            ? Theme.of(context).colorScheme.primary
                                                            : Theme.of(context).colorScheme.outline.withValues(alpha: .3),
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Center(
                                                      child: AnimatedSwitcher(
                                                        duration: const Duration(milliseconds: 300),
                                                        child: Icon(
                                                          isCopied ? Icons.check : Icons.content_copy,
                                                          key: ValueKey<bool>(isCopied), // Important for AnimatedSwitcher
                                                          size: 15,
                                                          color: isCopied
                                                              ? Theme.of(context).colorScheme.primary
                                                              : Theme.of(context).colorScheme.outline.withValues(alpha: .6),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Reference text that takes remaining space
                                            Expanded(
                                                child:
                                                Text(txn.trnReference.toString())),
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
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      SizedBox(
                                        width: 110,
                                        child: Text(txn.maker ?? ""),
                                      ),
                                      SizedBox(
                                        width: 110,
                                        child: Text(txn.checker ?? ""),
                                      ),
                                      SizedBox(width: 20),
                                    ],
                                  ),
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
}