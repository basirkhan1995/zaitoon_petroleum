import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../../../Features/Other/cover.dart';
import '../../../../../../Features/Other/responsive.dart';
import '../../../../../../Features/Other/utils.dart';
import '../../../../../../Localizations/l10n/translations/app_localizations.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
        tablet: _Tablet(),
        mobile: _Mobile(),
        desktop: _Desktop());
  }
}

class _Desktop extends StatefulWidget {
  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = "${info.version} + ${info.buildNumber}";
    });
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,

        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(
                    width: 130,
                    height: 130,
                    child: Image.asset("assets/images/zaitoonLogo.png")),
                SizedBox(height: 10),
                Text(AppLocalizations.of(context)!.zPetroleum,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23)),
                SizedBox(height: 2),
                Text(_version,style: theme.textTheme.titleMedium),
                SizedBox(height: 20),
                InkWell(
                  highlightColor: Theme.of(context).colorScheme.surface,
                  hoverColor: Theme.of(context).colorScheme.surface,
                  onTap: (){
                    Utils.launchWhatsApp(phoneNumber: '+93792496200');
                  },
                  child: Row(
                    spacing: 10,
                    children: [
                      ZCard(
                          padding: EdgeInsets.symmetric(vertical: 2,horizontal: 3),
                          color: Theme.of(context).colorScheme.surface,
                          child: Icon(FontAwesomeIcons.whatsapp,color: Theme.of(context).colorScheme.primary)),
                      Text("WhatsApp"),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ZCard(
                        padding: EdgeInsets.symmetric(vertical: 2,horizontal: 3),
                        color: Theme.of(context).colorScheme.surface,
                        child: Icon(Icons.phone,color: Theme.of(context).colorScheme.primary)),
                    Text("93792496200",style: TextStyle(color: Theme.of(context).colorScheme.onSurface))
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ZCard(
                        padding: EdgeInsets.symmetric(vertical: 2,horizontal: 3),
                        color: Theme.of(context).colorScheme.surface,
                        child: Icon(Icons.language_rounded,color: Theme.of(context).colorScheme.primary)),
                    Text("www.zaitoonsoft.com",style: TextStyle(color: Theme.of(context).colorScheme.onSurface),)
                  ],
                ),

                SizedBox(height: 10),
                Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ZCard(
                        padding: EdgeInsets.symmetric(vertical: 2,horizontal: 3),
                        color: Theme.of(context).colorScheme.surface,
                        child: Icon(Icons.email,color: Theme.of(context).colorScheme.primary)),
                    Text("basirkhan.hashemi@gmail.com",style: TextStyle(color: Theme.of(context).colorScheme.onSurface))
                  ],
                ),
              ],
            ),
          ),
        )
    );
  }
}

class _Mobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Tablet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

