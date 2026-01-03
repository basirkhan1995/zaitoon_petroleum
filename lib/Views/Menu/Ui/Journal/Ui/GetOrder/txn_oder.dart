import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Views/Auth/bloc/auth_bloc.dart';
import '../bloc/transactions_bloc.dart';
import 'bloc/order_txn_bloc.dart';
import 'model/get_order_model.dart';

class OrderTxnView extends StatelessWidget {
  final String reference;


  const OrderTxnView({
    super.key,
    required this.reference,

  });

  @override
  Widget build(BuildContext context) {
    return const _OrderTxnDialog();
  }
}

class _OrderTxnDialog extends StatefulWidget {
  const _OrderTxnDialog();

  @override
  State<_OrderTxnDialog> createState() => _OrderTxnDialogState();
}

class _OrderTxnDialogState extends State<_OrderTxnDialog> {
  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final auth = context.watch<AuthBloc>().state;

    if (auth is! AuthenticatedState) {
      return const SizedBox();
    }

    final login = auth.loginData;

    return BlocBuilder<CompanyProfileBloc, CompanyProfileState>(
      builder: (context, state) {
        String companyName = "";
        String companyAddress = "";
        Uint8List companyLogo = Uint8List(0);

        if (state is CompanyProfileLoadedState) {
          final company = state.company;
          companyName = company.comName ?? "";
          companyAddress = company.addName ?? "";

          final base64Logo = company.comLogo;
          if (base64Logo != null && base64Logo.isNotEmpty) {
            try {
              companyLogo = base64Decode(base64Logo);
            } catch (e) {
              companyLogo = Uint8List(0);
            }
          }
        }

        return ZFormDialog(
          padding: EdgeInsets.all(8),
          onAction: null,
          title: tr.transactionDetails,
          isActionTrue: false,
          width: 850,
          child: BlocConsumer<OrderTxnBloc, OrderTxnState>(
            listener: (context, state) {
              // Handle state changes if needed
            },
            builder: (context, state) {
              if (state is OrderTxnErrorState) {
                return NoDataWidget(
                  message: state.message,
                );
              }

              if (state is OrderTxnLoadingState) {
                return SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is OrderTxnLoadedState) {
                final orderTxn = state.data;
                final records = orderTxn.records ?? [];
                final billItems = orderTxn.bill ?? [];

                // Check permissions
                final showDeleteButton = orderTxn.trnStatus == 0 && orderTxn.usrName == login.usrName;
                final showAuthorizeButton = orderTxn.trnStatus == 0 && orderTxn.usrName != login.usrName;
                final showAnyButton = showDeleteButton || showAuthorizeButton;

                // Get loading states
                final isDeleteLoading = context.watch<TransactionsBloc>().state is TxnDeleteLoadingState;
                final isAuthorizeLoading = context.watch<TransactionsBloc>().state is TxnAuthorizeLoadingState;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Reference and Status
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr.referenceNumber,
                                  style: textTheme.titleSmall?.copyWith(
                                    color: color.onSurface.withAlpha(150),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  orderTxn.trnReference ?? "-",
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: color.primary,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "${tr.branch}: ${orderTxn.branch ?? "-"}",
                                  style: textTheme.bodyMedium,
                                ),
                              ],
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildStatusBadge(context, orderTxn.trnStateText ?? ""),
                                SizedBox(height: 8),
                                Text(
                                  "${tr.date}: ${orderTxn.trnEntryDate?.toLocal().toString().split(' ')[0] ?? "-"}",
                                  style: textTheme.bodyMedium,
                                ),
                                Text(
                                  "time: ${orderTxn.trnEntryDate?.toLocal().toString().split(' ')[1].substring(0, 5) ?? "-"}",
                                  style: textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Divider(height: 20, thickness: 1),

                      // Total Amount Card
                      Cover(
                        color: color.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tr.totalAmount,
                                    style: textTheme.titleMedium?.copyWith(
                                      color: color.onSurface.withAlpha(150),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        orderTxn.ccySymbol ?? "\$",
                                        style: textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        orderTxn.totalBill ?? "0.00",
                                        style: textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: color.primary,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        orderTxn.ccyName ?? "USD",
                                        style: textTheme.titleMedium?.copyWith(
                                          color: color.onSurface.withAlpha(150),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    tr.transactionType,
                                    style: textTheme.titleMedium?.copyWith(
                                      color: color.onSurface.withAlpha(150),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Chip(
                                    backgroundColor: color.primary.withAlpha(30),
                                    label: Text(
                                      orderTxn.trntName ?? orderTxn.trnType ?? "-",
                                      style: TextStyle(
                                        color: color.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Two Column Layout
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bill Items
                          Expanded(
                            flex: 3,
                            child: Cover(
                              color: color.surface,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.shopping_cart, size: 20, color: color.primary),
                                        SizedBox(width: 8),
                                        Text(
                                          "items",
                                          style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(height: 20, thickness: 1),

                                    if (billItems.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        child: Center(
                                          child: Text(
                                            "noItems",
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: color.onSurface.withAlpha(150),
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      ...billItems.map((item) => _buildBillItem(item, context)).toList(),

                                    SizedBox(height: 16),

                                    // Remark
                                    if (orderTxn.remark?.isNotEmpty == true) ...[
                                      Divider(height: 20, thickness: 1),
                                      Text(
                                        tr.remark,
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        orderTxn.remark!,
                                        style: textTheme.bodyMedium,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 16),

                          // Accounting Records
                          Expanded(
                            flex: 2,
                            child: Cover(
                              color: color.surface,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.account_balance, size: 20, color: color.primary),
                                        SizedBox(width: 8),
                                        Text(
                                          "accountingEntries",
                                          style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(height: 20, thickness: 1),

                                    if (records.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        child: Center(
                                          child: Text(
                                            "noRecords",
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: color.onSurface.withAlpha(150),
                                            ),
                                          ),
                                        ),
                                      )
                                    else ...records.map((record) => _buildRecordItem(record, context)).toList(),

                                    SizedBox(height: 16),

                                    // User Info
                                    Divider(height: 20, thickness: 1),
                                    _buildDetailRow(tr.users, orderTxn.usrName ?? "-"),
                                    _buildDetailRow(tr.currencyTitle, "${orderTxn.ccySymbol ?? "\$"} ${orderTxn.ccyName ?? "-"}"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Action Buttons
                      if (showAnyButton) ...[
                        SizedBox(height: 20),
                        Cover(
                          color: color.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr.actions,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Divider(height: 20, thickness: 1),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  spacing: 12,
                                  children: [
                                    if (showDeleteButton)
                                      ZOutlineButton(
                                        width: 150,
                                        height: 45,
                                        icon: isDeleteLoading
                                            ? null
                                            : Icons.delete_outline_rounded,
                                        isActive: true,
                                        backgroundHover: color.error,
                                        onPressed: () {
                                          context.read<TransactionsBloc>().add(
                                            DeletePendingTxnEvent(
                                              reference: orderTxn.trnReference ?? "",
                                              usrName: login.usrName ?? "",
                                            ),
                                          );
                                        },
                                        label: isDeleteLoading
                                            ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: color.primary,
                                          ),
                                        )
                                            : Text(tr.delete),
                                      ),

                                    if (showAuthorizeButton)
                                      ZOutlineButton(
                                        width: 150,
                                        height: 45,
                                        onPressed: () {
                                          context.read<TransactionsBloc>().add(
                                            AuthorizeTxnEvent(
                                              reference: orderTxn.trnReference ?? "",
                                              usrName: login.usrName ?? "",
                                            ),
                                          );
                                        },
                                        icon: isAuthorizeLoading
                                            ? null
                                            : Icons.check_circle_outline,
                                        isActive: true,
                                        backgroundColor: color.primary,
                                        textColor: color.onPrimary,
                                        label: isAuthorizeLoading
                                            ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: color.surface,
                                          ),
                                        )
                                            : Text(tr.authorize),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 20),
                    ],
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final color = Theme.of(context).colorScheme;
    final tr = AppLocalizations.of(context)!;
    final isAuthorized = status.toLowerCase().contains("authorize");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAuthorized ? color.primary.withAlpha(30) : Colors.orange.withAlpha(30),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: isAuthorized ? color.primary.withAlpha(100) : Colors.orange.withAlpha(100),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAuthorized ? Icons.verified : Icons.pending,
            size: 14,
            color: isAuthorized ? color.primary : Colors.orange,
          ),
          SizedBox(width: 6),
          Text(
            isAuthorized ? tr.authorizedTitle : tr.pendingTitle,
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

  Widget _buildBillItem(Bill item, BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.outline.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.productName ?? "-",
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBillDetail("Storage", item.storageName ?? "-"),
              _buildBillDetail("Quantity", "${item.quantity ?? "0"} L"),
              _buildBillDetail("Unit Price", "${item.unitPrice ?? "0.00"}"),
            ],
          ),
          SizedBox(height: 8),
          Divider(height: 1, thickness: 1),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "total",
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                item.totalPrice ?? "0.00",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordItem(Record record, BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isDebit = record.debitCredit?.toLowerCase() == "debit";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.outline.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  record.accountName ?? "-",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Chip(
                backgroundColor: isDebit
                    ? Colors.red.withAlpha(30)
                    : Colors.green.withAlpha(30),
                label: Text(
                  record.debitCredit ?? "-",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDebit ? Colors.red[700] : Colors.green[700],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Acc#: ${record.accountNumber ?? "-"}",
                style: TextStyle(
                  fontSize: 11,
                  color: color.onSurface.withAlpha(150),
                ),
              ),
              Text(
                record.amount ?? "0.00",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDebit ? Colors.red[700] : Colors.green[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}