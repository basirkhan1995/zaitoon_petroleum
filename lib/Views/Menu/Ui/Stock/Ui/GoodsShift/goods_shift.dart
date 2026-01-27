import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:zaitoon_petroleum/Views/Auth/bloc/auth_bloc.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../../../../../../Features/Other/utils.dart';
import '../../../../../../Features/Widgets/no_data_widget.dart';
import '../../../Settings/Ui/Company/CompanyProfile/bloc/company_profile_bloc.dart';
import 'add_shift.dart';
import 'bloc/goods_shift_bloc.dart';

class GoodsShiftView extends StatelessWidget {
  const GoodsShiftView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobile: _Mobile(), desktop: _Desktop(),tablet: _Tablet(),);
  }
}

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

// goods_shift_view.dart - Update the _DesktopState class
class _DesktopState extends State<_Desktop> {
  String? baseCurrency;
  GoodsShiftLoadedState? _cachedShifts;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoodsShiftBloc>().add(LoadGoodsShiftsEvent());
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
  builder: (context, state) {
    if(state is AuthenticatedState){
      usrName = state.loginData.usrName;
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
                ZOutlineButton(
                  toolTip: "F5",
                  isActive: true,
                  width: 120,
                  icon: Icons.add,
                  onPressed: () => Utils.goto(context, AddGoodsShiftView()),
                  label: Text(tr.newKeyword),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 5),
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
                    child: Text(tr.accounts, style: titleStyle)),
                SizedBox(
                  width: 120,
                  child: Text(tr.amount, style: titleStyle),
                ),
                SizedBox(
                  width: 140,
                  child: Text(tr.status, style: titleStyle),
                ),

              ],
            ),
          ),

          Expanded(
            child: BlocConsumer<GoodsShiftBloc, GoodsShiftState>(
              listener: (context, state) {
                if (state is GoodsShiftDeletedState || state is GoodsShiftSavedState) {
                  if (state is GoodsShiftLoadedState) {
                    _cachedShifts = state;
                  }
                }
                if (state is GoodsShiftErrorState) {
                  Utils.showOverlayMessage(context, message: state.error, isError: true);
                }
              },
              builder: (context, state) {
                if (state is GoodsShiftLoadedState) {
                  _cachedShifts = state;
                }

                final shouldUseCached = state is GoodsShiftDetailLoadingState ||
                    state is GoodsShiftDetailLoadedState ||
                    state is GoodsShiftSavingState ||
                    state is GoodsShiftDeletingState;

                final displayState = shouldUseCached ? _cachedShifts : state;

                if (shouldUseCached && _cachedShifts == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (displayState is GoodsShiftErrorState) {
                  return NoDataWidget(
                    imageName: 'error.png',
                    message: displayState.error,
                    onRefresh: () {
                      context.read<GoodsShiftBloc>().add(LoadGoodsShiftsEvent());
                    },
                  );
                }

                if (displayState is GoodsShiftLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (displayState is GoodsShiftLoadedState) {
                  final query = searchController.text.toLowerCase().trim();
                  final filteredList = displayState.shifts.where((item) {
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
                      onRefresh: () {
                        context.read<GoodsShiftBloc>().add(LoadGoodsShiftsEvent());
                      },
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final shift = filteredList[index];

                      return Container(
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
                                shift.ordTrnRef ?? "",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(
                                shift.account?.toString() ?? "",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(
                                "${shift.amount?.toAmount()} $baseCurrency",
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                shift.trnStateText ?? "",
                                style: TextStyle(
                                  color: (shift.trnStateText?.toLowerCase() == 'authorized')
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 40,
                              child: IconButton(
                                constraints: BoxConstraints(),
                                  onPressed: (){
                                    context.read<GoodsShiftBloc>().add(DeleteGoodsShiftEvent(orderId: shift.ordId!, usrName: usrName??""));
                                  },
                                  icon: Icon(Icons.delete_outline_rounded,color: Theme.of(context).colorScheme.error,size: 19))
                            ),

                          ],
                        ),
                      );
                    },
                  );
                }

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
    return const Placeholder();
  }
}
class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
