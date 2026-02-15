import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Features/Widgets/txn_status_widget.dart';
import 'package:zaitoon_petroleum/Views/Auth/bloc/auth_bloc.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Stock/Ui/GoodsShift/shift_details.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../Features/Other/utils.dart';
import '../../../../../../Features/Widgets/no_data_widget.dart';
import '../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import 'bloc/goods_shift_bloc.dart';

class GoodsShiftView extends StatelessWidget {
  const GoodsShiftView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), desktop: _Desktop(), tablet: _Tablet());
  }
}

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  String? baseCurrency;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoodsShiftBloc>().add(LoadGoodsShiftsEvent());
    });

    final companyState = context.read<CompanyProfileBloc>().state;
    if (companyState is CompanyProfileLoadedState) {
      baseCurrency = companyState.company.comLocalCcy ?? "";
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onRefresh() {
    context.read<GoodsShiftBloc>().add(LoadGoodsShiftsEvent());
  }
  String? usrName;
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    TextStyle? titleStyle = textTheme.titleSmall?.copyWith(color: color.surface);
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthenticatedState) {
            usrName = authState.loginData.usrName;
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      flex: 5,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        tileColor: Colors.transparent,
                        title: Text(
                          tr.shift,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20),
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
                      onPressed: onRefresh,
                      label: Text(tr.refresh),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                    color: color.primary.withValues(alpha: .9)
                ),
                child: Row(
                  children: [
                    SizedBox(width: 40, child: Text(tr.id, style: titleStyle)),
                    SizedBox(
                      width: 100,
                      child: Text(tr.date, style: titleStyle),
                    ),
                    Expanded(
                      child: Text(tr.referenceNumber, style: titleStyle),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(tr.accountTitle, style: titleStyle),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(tr.amount, style: titleStyle),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(tr.status, style: titleStyle),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: BlocConsumer<GoodsShiftBloc, GoodsShiftState>(
                  listener: (context, state) {
                    // When we get a deleted state, refresh the data
                    if (state is GoodsShiftDeletedState) {
                      // Show success message
                      Utils.showOverlayMessage(
                        context,
                        message: state.message,
                        isError: false,
                      );
                      // Reload the shifts
                      context.read<GoodsShiftBloc>().add(LoadGoodsShiftsEvent());
                    }
                    // When we get a saved state (from add), refresh the data
                    if (state is GoodsShiftSavedState) {
                      Utils.showOverlayMessage(
                        context,
                        message: state.message,
                        isError: false,
                      );
                      // Reload the shifts
                      context.read<GoodsShiftBloc>().add(LoadGoodsShiftsEvent());
                    }
                    if (state is GoodsShiftErrorState) {
                      Utils.showOverlayMessage(context, message: state.error, isError: true);
                    }
                  },
                  builder: (context, state) {
                    // Loading states
                    if (state is GoodsShiftLoadingState ||
                        state is GoodsShiftSavingState ||
                        state is GoodsShiftDeletingState) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Error state
                    if (state is GoodsShiftErrorState) {
                      return NoDataWidget(
                        imageName: 'error.png',
                        message: state.error,
                        onRefresh: onRefresh,
                      );
                    }

                    // Loaded state
                    if (state is GoodsShiftLoadedState) {
                      final query = searchController.text.toLowerCase().trim();
                      final filteredList = state.shifts.where((item) {
                        final ref = item.ordTrnRef?.toLowerCase() ?? '';
                        final ordId = item.ordId?.toString() ?? '';
                        final account = item.account?.toString() ?? '';
                        final amount = item.amount?.toLowerCase() ?? '';
                        final status = item.trnStateText?.toLowerCase() ?? '';
                        return ref.contains(query) ||
                            ordId.contains(query) ||
                            account.contains(query) ||
                            amount.contains(query) ||
                            status.contains(query);
                      }).toList();

                      if (filteredList.isEmpty) {
                        return NoDataWidget(
                          message: tr.noDataFound,
                          onRefresh: onRefresh,
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final shift = filteredList[index];

                          return InkWell(
                            onTap: () {
                              Utils.goto(context, GoodsShiftDetailView(shiftId: shift.ordId!));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: index.isEven
                                    ? color.primary.withValues(alpha: .05)
                                    : Colors.transparent,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Text(shift.ordId.toString()),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      shift.ordEntryDate != null
                                          ? shift.ordEntryDate.toFormattedDate()
                                          : "",
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      shift.ordTrnRef ?? "-",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      shift.account?.toString() ?? "-",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      shift.amount != null
                                          ? "${shift.totalAmount.toAmount()} $baseCurrency"
                                          : "-",
                                    ),
                                  ),
                                  TransactionStatusBadge(status: shift.trnStateText??"")
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }

                    // Initial state - show loading
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet();

  @override
  Widget build(BuildContext context) {
    return _Desktop();
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}