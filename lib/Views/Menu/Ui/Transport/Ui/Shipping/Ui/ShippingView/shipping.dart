import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon_petroleum/Features/Other/shortcut.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Shipping/shipping_screen.dart';
import '../../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import 'bloc/shipping_bloc.dart';

class ShippingView extends StatelessWidget {
  const ShippingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(),
      desktop: _Desktop(),
      tablet: _Tablet(),
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

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShippingBloc>().add(LoadShippingEvent());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final shortcuts = {
      const SingleActivator(LogicalKeyboardKey.f1): onAdd,
      const SingleActivator(LogicalKeyboardKey.f5): onRefresh,
    };
    return GlobalShortcuts(
      shortcuts: shortcuts,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 8,
              ),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
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
                    toolTip: "F1",
                    width: 120,
                    icon: Icons.add,
                    isActive: true,
                    onPressed: onAdd,
                    label: Text(tr.newKeyword),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<ShippingBloc, ShippingState>(
                listener: (context, state) {
                  if(state is ShippingSuccessState){
                    Navigator.of(context).pop();
                  }
                },
                builder: (context, state) {
                  if(state is ShippingLoadingState){
                    return Center(child: CircularProgressIndicator());
                  }
                  if(state is ShippingErrorState){
                    return NoDataWidget(
                      message: state.error,
                      onRefresh: onRefresh,
                    );
                  }
                  if(state is ShippingLoadedState){
                    if(state.shipping.isEmpty){
                      return NoDataWidget(
                        message: tr.noDataFound,
                      );
                    }
                    return ListView.builder(
                        itemCount: state.shipping.length,
                        itemBuilder: (context,index){
                          final shp = state.shipping[index];
                          return InkWell(
                            onTap: (){},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8,horizontal: 5),
                                decoration: BoxDecoration(
                                  color: index.isEven? Theme.of(context).colorScheme.primary.withValues(alpha: .05) : Colors.transparent
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                        width: 30,
                                        child: Text(shp.shpId.toString())),

                                    Expanded(
                                        child: Text(shp.vehicle??"")),
                                    SizedBox(
                                        width: 130,
                                        child: Text(shp.proName??"")),

                                    SizedBox(
                                        width: 130,
                                        child: Text(shp.customer??"")),
                                    SizedBox(
                                        width: 90,
                                        child: Text(shp.shpMovingDate.toFormattedDate())),
                                    SizedBox(
                                        width: 60,
                                        child: Text(shp.shpUnit??"")),
                                    SizedBox(
                                        width: 70,
                                        child: Text(shp.shpLoadSize??"")),
                                    SizedBox(
                                        width: 70,
                                        child: Text(shp.shpUnloadSize??"")),
                                    SizedBox(
                                        width: 110,
                                        child: Text(shp.total?.toAmount()??"")),
                                    SizedBox(
                                        width: 60,
                                        child: Text(shp.shpStatus == 1? tr.active : tr.inactive)),
                                  ],
                                ),
                              ),
                            ),
                          );
                    });
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

  void onAdd() {
    showDialog(
      context: context,
      builder: (context) {
        return ShippingScreen();
      },
    );
  }

  void onRefresh() {
    context.read<ShippingBloc>().add(LoadShippingEvent());
  }
}
