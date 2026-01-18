import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchTRPT/bloc/trpt_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchTRPT/model/trtp_model.dart';
import '../../../../../../Auth/bloc/auth_bloc.dart';
import '../../bloc/transactions_bloc.dart';

class TrptView extends StatelessWidget {
  final String reference;

  const TrptView({super.key, required this.reference});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(reference: reference),
      tablet: _Tablet(),
    );
  }
}

class _Desktop extends StatefulWidget {
  final String reference;

  const _Desktop({required this.reference});

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  TrptModel? loadedTrpt;
  bool _isAuthorizing = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    _isDeleting = context.watch<TransactionsBloc>().state is TxnDeleteLoadingState;
    _isAuthorizing = context.watch<TransactionsBloc>().state is TxnAuthorizeLoadingState;
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthenticatedState) {
      return const SizedBox();
    }
    final login = auth.loginData;

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.all(8),
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        width: MediaQuery.of(context).size.width *.5,
        height: double.infinity,
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .15),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: BlocConsumer<TrptBloc, TrptState>(
          listener: (context, state) {
            if (state is TrptLoadedState) {
              loadedTrpt = state.trpt;
            }
          },
          builder: (context, state) {
            if (state is TrptLoadingState) {
              return _buildLoadingState();
            } else if (state is TrptErrorState) {
              return _buildErrorState(state.error);
            } else if (state is TrptLoadedState) {
              return _buildLoadedState(context, state.trpt, locale, login);
            }
            return _buildInitialState();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Transport Details...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Transport Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                context.read<TrptBloc>().add(LoadTrptEvent(widget.reference));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(
      BuildContext context,
      TrptModel trpt,
      AppLocalizations tr,
      dynamic login,
      ) {
    final transaction = trpt.transaction;
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;

    // Check if any buttons should be shown
    final bool showAuthorizeButton = trpt.shpStatus == 1 && (transaction?.trnStatus == 0 && login.usrName != transaction?.maker);
    final bool showDeleteButton = trpt.shpStatus == 1 && (trpt.transaction?.trnStatus == 0 && transaction?.maker == login.usrName);
    final bool showAnyButton = showAuthorizeButton || showDeleteButton;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr.transactionDetails,
                    style: const TextStyle(

                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    trpt.shdTrnRef ?? '',
                    style: TextStyle(

                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 24),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main Amount Card
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.amount,
                              style: textTheme.titleSmall?.copyWith(
                                color: color.onSurface.withValues(alpha: .7),
                              ),
                            ),
                            Text(
                              "${trpt.transaction?.amount?.toAmount() ?? "0.00"} ${transaction?.currency ?? ""}",
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                     Row(
                       spacing: 8,
                       children: [
                         IconButton(
                           isSelected: true,
                           onPressed: (){},
                           icon: Icon(Icons.print),),

                         if (transaction != null)
                           _buildTransactionStatusBadge(context, transaction.trnStatus),

                       ],
                     )
                    ],
                  ),
                ),

                // Two Column Layout for Transport and Shipping Details
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transport Information Card
                      Expanded(
                        child: ZCover(
                          color: color.surface,
                          radius: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.local_shipping, size: 20, color: color.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      tr.transportInformation,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20, thickness: 1),
                                _buildDetailRow(tr.vehicle, trpt.vehicle ?? "-"),
                                _buildDetailRow(tr.productName, trpt.proName ?? "-"),
                                _buildDetailRow(tr.customer, trpt.customer ?? "-"),
                                _buildDetailRow(tr.fromTo, '${trpt.shpFrom ?? "-"} → ${trpt.shpTo ?? "-"}'),
                                _buildDetailRow(tr.status, _getTransportStatusText(trpt.shpStatus)),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Shipping Details Card
                      Expanded(
                        child: ZCover(
                          color: color.surface,
                          radius: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.inventory_2, size: 20, color: color.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      tr.shippingDetails,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20, thickness: 1),
                                _buildDetailRow(tr.loadingSize, '${trpt.shpLoadSize?.toAmount()} ${trpt.shpUnit}'),
                                _buildDetailRow(tr.unloadingSize, '${trpt.shpUnloadSize?.toAmount()} ${trpt.shpUnit}'),
                                _buildDetailRow(tr.shippingRent, '${trpt.shpRent?.toAmount()} ${transaction?.currency}'),
                                _buildDetailRow(tr.movingDate, _formatDate(trpt.shpMovingDate)),
                                _buildDetailRow(tr.arrivalDate, _formatDate(trpt.shpArriveDate)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Transaction Details Card
                if (transaction != null)...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ZCover(
                      color: color.surface,
                      radius: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.receipt_long, size: 20, color: color.primary),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.transactionDetails,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20, thickness: 1),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailRow(AppLocalizations.of(context)!.referenceNumber, transaction.trnReference ?? "-"),
                                      _buildDetailRow(AppLocalizations.of(context)!.amount, '${transaction.amount?.toAmount()} ${transaction.currency}'),
                                      _buildDetailRow(AppLocalizations.of(context)!.debitAccount, transaction.debitAccount?.toString() ?? "-"),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailRow(AppLocalizations.of(context)!.creditAccount, transaction.creditAccount?.toString() ?? "-"),
                                      _buildDetailRow(AppLocalizations.of(context)!.maker, transaction.maker ?? "-"),
                                      _buildDetailRow(AppLocalizations.of(context)!.checker, transaction.checker ?? "Not Checked",
                                          isHighlighted: transaction.checker == null),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // Narration Card
                if (transaction?.narration?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ZCover(
                      color: color.surface,
                      radius: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.description, size: 20, color: color.primary),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.narration,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20, thickness: 1),
                            Text(
                              transaction!.narration!,
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Action Buttons
                if (showAnyButton) ...[

                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      spacing: 12,
                      children: [
                        if (showDeleteButton)
                          ZOutlineButton(
                            width: 150,
                            height: 45,
                            icon: _isDeleting ? null : Icons.delete_outline_rounded,
                            isActive: true,
                            backgroundHover: color.error,
                            onPressed: () async {
                              context.read<TransactionsBloc>().add(
                                DeletePendingTxnEvent(
                                  reference: trpt.shdTrnRef ?? "",
                                  usrName: login.maker ?? "",
                                ),
                              );
                            },
                            label: _isDeleting
                                ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: color.surface,
                              ),
                            )
                                : Text(tr.delete),
                          ),

                        if (showAuthorizeButton)
                          ZOutlineButton(
                            width: 150,
                            height: 45,
                            onPressed: () async {
                              context.read<TransactionsBloc>().add(
                                AuthorizeTxnEvent(
                                  reference: trpt.shdTrnRef ?? "",
                                  usrName: login.usrName ?? "",
                                ),
                              );
                            },
                            icon: _isAuthorizing ? null : Icons.check_circle_outline,
                            isActive: true,
                            backgroundColor: color.primary,
                            textColor: color.onPrimary,
                            label: _isAuthorizing
                                ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: color.surface,
                              ),
                            )
                                : Text(AppLocalizations.of(context)!.authorize),
                          ),
                      ],
                    ),
                  ),
                ],

              ],
            ),
          ),
        ),
        if(trpt.shpStatus == 0)...[
          ListTile(
            title: Text(AppLocalizations.of(context)!.attentionTitle,style: TextStyle(color: Theme.of(context).colorScheme.error),),
            subtitle: Text(AppLocalizations.of(context)!.pendingShippingMessage),
          ),
          SizedBox(height: 10),
        ]
      ],
    );
  }

  Widget _buildTransactionStatusBadge(BuildContext context, int? status) {
    final color = Theme.of(context).colorScheme;
    final isAuthorized = status == 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAuthorized ? color.primary.withAlpha(30) : Colors.orange.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isAuthorized ? color.primary : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAuthorized ? Icons.check_circle : Icons.pending,
            size: 14,
            color: isAuthorized ? color.primary : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            _getTransactionStatusText(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isAuthorized ? color.primary : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    final color = Theme.of(context).colorScheme;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                "$label:",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color.onSurface.withValues(alpha: .7),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                  color: isHighlighted ? Colors.green[700] : color.onSurface,
                ),
              ),
            ),
          ],
        )
    );
  }

  String _getTransportStatusText(int? status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Delivered';
      default:
        return 'In Transit';
    }
  }

  String _getTransactionStatusText(int? status) {
    switch (status) {
      case 0:
        return AppLocalizations.of(context)!.pendingTitle;
      case 1:
        return AppLocalizations.of(context)!.authorizedTitle;
      default:
        return '';
    }
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Not Available';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
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