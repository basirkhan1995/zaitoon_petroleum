import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/cover.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/zForm_dialog.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchGLAT/bloc/glat_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Journal/Ui/FetchGLAT/model/glat_model.dart';
import '../../../../../../../Features/Other/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../Auth/bloc/auth_bloc.dart';
import '../../bloc/transactions_bloc.dart';

class GlatView extends StatelessWidget {
  const GlatView({super.key});

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
  GlatModel? loadedGlat;

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;
    final isDeleteLoading = context.watch<TransactionsBloc>().state is TxnDeleteLoadingState;
    final isAuthorizeLoading = context.watch<TransactionsBloc>().state is TxnAuthorizeLoadingState;
    final auth = context.watch<AuthBloc>().state;

    if (auth is! AuthenticatedState) {
      return const SizedBox();
    }

    final login = auth.loginData;

    return ZFormDialog(
      onAction: null,
      title: tr.transactionDetails,
      isActionTrue: false,
      width: 750,
      child: SingleChildScrollView(
        child: BlocConsumer<GlatBloc, GlatState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is GlatErrorState) {
              return NoDataWidget(
                message: state.message,
              );
            }

            if (state is GlatLoadingState) {
              return SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is GlatLoadedState) {
              loadedGlat = state.data;
              final glat = state.data;
              final transaction = glat.transaction;

              // Check if any buttons should be shown
              final bool showAuthorizeButton = glat.transaction?.trnStatus == 0 && login.usrName != transaction?.maker;
              final bool showDeleteButton = glat.transaction?.trnStatus == 0 && transaction?.maker == login.usrName;
              final bool showAnyButton = showAuthorizeButton || showDeleteButton;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Main Amount Card
                        Cover(
                          color: color.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr.amount,
                                  style: textTheme.titleSmall?.copyWith(
                                    color: color.onSurface.withValues(alpha: .7),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "${glat.vclPurchaseAmount?.toAmount() ?? "0.00"} ${transaction?.purchaseCurrency ?? ""}",
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: color.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          spacing: 8,
                          children: [
                            _buildStatusBadge(context, glat.transaction?.trnStateText??""),
                            IconButton(onPressed: (){}, icon: Icon(Icons.print))
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Two Column Layout for Vehicle and Transaction Details
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vehicle Details Card
                        Expanded(
                          child: Cover(
                            color: color.surface,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.directions_car, size: 20, color: color.primary),
                                      SizedBox(width: 8),
                                      Text(
                                        tr.vehicleDetails,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(height: 20, thickness: 1),
                                  _buildDetailRow(tr.vehicleModel, glat.vclModel ?? "-"),
                                  _buildDetailRow(tr.manufacturedYear, glat.vclYear ?? "-"),
                                  _buildDetailRow(tr.vinNumber, glat.vclVinNo ?? "-"),
                                  _buildDetailRow(tr.vehiclePlate, glat.vclPlateNo ?? "-"),
                                  _buildDetailRow(tr.fuelType, glat.vclFuelType ?? "-"),
                                  _buildDetailRow(tr.enginePower, glat.vclEnginPower ?? "-"),
                                  _buildDetailRow(tr.categoryTitle, glat.vclBodyType ?? "-"),
                                  _buildDetailRow(tr.meter, "${glat.vclOdoMeter ?? 0} km"),
                                  _buildDetailRow(tr.driver, glat.driver ?? "-"),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 8),

                        // Transaction Details Card
                        Expanded(
                          child: Cover(
                            color: color.surface,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.receipt_long, size: 20, color: color.primary),
                                      SizedBox(width: 8),
                                      Text(
                                        tr.transactionDetails,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(height: 20, thickness: 1),
                                  _buildDetailRow(tr.referenceNumber, transaction?.trnReference ?? "-"),
                                  _buildDetailRow(tr.debitAccount, "${transaction?.debitAccount ?? "-"}"),
                                  _buildDetailRow(tr.creditAccount, "${transaction?.creditAccount ?? "-"}"),
                                  _buildDetailRow(tr.maker, transaction?.maker ?? "-"),
                                  _buildDetailRow(tr.checker, transaction?.checker ?? "-",
                                      isHighlighted: transaction?.checker == null),
                                  _buildDetailRow(tr.status, glat.transaction?.trnStatus == 1 ? tr.authorizedTitle : tr.pendingTitle, isHighlighted: glat.transaction?.trnStatus == 1),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 5),

                  // Narration Card
                  if (transaction?.narration?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Cover(
                        color: color.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.description, size: 20, color: color.primary),
                                  SizedBox(width: 8),
                                  Text(
                                    tr.narration,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(height: 20, thickness: 1),
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
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(tr.actions,style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),),
                    ),
                    Divider(indent: 5,endIndent: 5),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
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
                                    reference: loadedGlat?.transaction?.trnReference ?? "",
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
                                    reference: loadedGlat?.transaction?.trnReference ?? "",
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
                    ),
                  ],

                  SizedBox(height: 20),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final color = Theme.of(context).colorScheme;
    final isAuthorized = status.toLowerCase().contains("authorize");
    final tr = AppLocalizations.of(context)!;
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
            status == "Pending"? tr.pendingTitle : tr.authorizedTitle,
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
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                color: isHighlighted ? Colors.green[700] : color.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}