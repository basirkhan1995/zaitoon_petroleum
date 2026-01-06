import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Other/utils.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/OrderScreen/NewPurchase/bloc/purchase_invoice_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/OrderScreen/NewSale/bloc/sale_invoice_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/Orders/bloc/orders_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/search_field.dart';
import '../../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import '../../OrderScreen/GetOrderById/order_by_id.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

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
  String? baseCurrency;
  final Map<String, bool> _copiedStates = {};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersBloc>().add(const LoadOrdersEvent());
    });

    final companyState = context.read<CompanyProfileBloc>().state;
    if (companyState is CompanyProfileLoadedState) {
      baseCurrency = companyState.company.comLocalCcy ?? "";
    }
  }

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    TextStyle? titleStyle = textTheme.titleSmall;
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: color.surface,
      body: MultiBlocListener(
        listeners: [
          BlocListener<PurchaseInvoiceBloc, PurchaseInvoiceState>(
            listener: (context, state) {
              if (state is PurchaseInvoiceSaved) {
                if (state.success) {
                  context.read<OrdersBloc>().add(LoadOrdersEvent());
                }
              }
            },
          ),
          BlocListener<SaleInvoiceBloc, SaleInvoiceState>(
            listener: (context, state) {
              if (state is SaleInvoiceSaved) {
                if (state.success) {
                  context.read<OrdersBloc>().add(LoadOrdersEvent());
                }
              }
            },
          ),
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    flex: 5,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        tr.orderTitle,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 20),
                      ),
                      subtitle: Text(
                        tr.ordersSubtitle,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ZSearchField(
                      icon: FontAwesomeIcons.magnifyingGlass,
                      controller: searchController,
                      hint: AppLocalizations.of(context)!.orderSearchHint,
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
                    onPressed: onRefresh,
                    label: Text(tr.refresh),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  SizedBox(width: 30, child: Text("#", style: titleStyle)),
                  SizedBox(width: 100, child: Text(tr.date, style: titleStyle)),
                  SizedBox(
                    width: 215,
                    child: Text(tr.referenceNumber, style: titleStyle),
                  ),

                  Expanded(child: Text(tr.party, style: titleStyle)),

                  SizedBox(
                    width: 100,
                    child: Text(tr.invoiceType, style: titleStyle),
                  ),

                  SizedBox(
                    width: 130,
                    child: Text(tr.totalInvoice, style: titleStyle),
                  ),
                ],
              ),
            ),
            Divider(endIndent: 8, indent: 8),
            Expanded(
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersErrorState) {
                    return NoDataWidget(message: state.message);
                  }
                  if (state is OrdersLoadingState) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (state is OrdersLoadedState) {
                    final query = searchController.text.toLowerCase().trim();
                    final filteredList = state.order.where((item) {
                      final ref = item.ordTrnRef?.toLowerCase() ?? '';
                      final ordId = item.ordId?.toString() ?? '';
                      final ordName = item.ordName?.toLowerCase() ?? '';
                      return ref.contains(query) ||
                          ordId.contains(query) ||
                          ordName.contains(query);
                    }).toList();

                    if (filteredList.isEmpty) {
                      return NoDataWidget(message: tr.noDataFound);
                    }
                    if (state.order.isEmpty) {
                      return NoDataWidget(enableAction: false);
                    }
                    return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final ord = filteredList[index];
                        final isCopied =
                            _copiedStates[ord.ordTrnRef ?? ""] ?? false;
                        final reference = ord.ordTrnRef ?? "";
                        return InkWell(
                          onTap: () {
                            Utils.goto(
                              context,
                              OrderByIdView(orderId: ord.ordId!,ordName: ord.ordName),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: index.isEven
                                  ? color.primary.withValues(alpha: .05)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 30,
                                  child: Text(ord.ordId.toString()),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    ord.ordEntryDate?.toFormattedDate() ?? "",
                                  ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _copyToClipboard(
                                            reference,
                                            context,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          hoverColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: .05),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 100,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isCopied
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withAlpha(25)
                                                  : Colors.transparent,
                                              border: Border.all(
                                                color: isCopied
                                                    ? Theme.of(
                                                        context,
                                                      ).colorScheme.primary
                                                    : Theme.of(context)
                                                          .colorScheme
                                                          .outline
                                                          .withValues(
                                                            alpha: .3,
                                                          ),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Center(
                                              child: AnimatedSwitcher(
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                child: Icon(
                                                  isCopied
                                                      ? Icons.check
                                                      : Icons.content_copy,
                                                  key: ValueKey<bool>(
                                                    isCopied,
                                                  ), // Important for AnimatedSwitcher
                                                  size: 15,
                                                  color: isCopied
                                                      ? Theme.of(
                                                          context,
                                                        ).colorScheme.primary
                                                      : Theme.of(context)
                                                            .colorScheme
                                                            .outline
                                                            .withValues(
                                                              alpha: .6,
                                                            ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Reference text that takes remaining space
                                    SizedBox(
                                      width: 180,
                                      child: Text(ord.ordTrnRef ?? ""),
                                    ),
                                  ],
                                ),
                                Expanded(child: Text(ord.personal ?? "")),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    Utils.getInvoiceType(
                                      txn: ord.ordName ?? "",
                                      context: context,
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    "${ord.totalBill?.toAmount()} $baseCurrency",
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

  void onRefresh() {
    context.read<OrdersBloc>().add(LoadOrdersEvent());
  }
}
