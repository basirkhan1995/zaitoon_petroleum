import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zaitoon_petroleum/Features/Other/responsive.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon_petroleum/Features/Other/shortcut.dart';
import 'package:zaitoon_petroleum/Features/Widgets/no_data_widget.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Shipping/Ui/add_edit_shipping.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Transport/Ui/Shipping/bloc/shipping_bloc.dart';
import '../../../../../../../Features/Widgets/outline_button.dart';
import '../../../../../../../Features/Widgets/search_field.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';

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
    final color = Theme.of(context).colorScheme;
    final tr = AppLocalizations.of(context)!;
    final shortcuts = {
      const SingleActivator(LogicalKeyboardKey.f1): onAdd,
      const SingleActivator(LogicalKeyboardKey.f5): onRefresh,
    };
    return GlobalShortcuts(
      shortcuts: shortcuts,
      child: Scaffold(
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
                          return ListTile(
                            title: Text(shp.proName??""),
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
        return AddEditShippingView();
      },
    );
  }

  void onRefresh() {
    context.read<ShippingBloc>().add(LoadShippingEvent());
  }
}
