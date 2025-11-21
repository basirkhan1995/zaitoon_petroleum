import 'package:flutter/material.dart';
import '../../Localizations/l10n/translations/app_localizations.dart';
import '../Widgets/button.dart';
import '../Widgets/outline_button.dart';

class ZFormDialog extends StatefulWidget {
  final VoidCallback? onAction;
  final Widget? actionLabel;
  final String title;
  final IconData? icon;
  final Widget? child;
  final bool isButtonEnabled;
  final bool isActionTrue;
  final double? width;
  final double? height;
  final Widget? expandedAction;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? expandedHeader;
  const ZFormDialog({
    super.key,
    required this.onAction,
    this.actionLabel,
    this.child,
    this.isButtonEnabled = true,
    this.expandedAction,
    this.isActionTrue = true,
    this.width,
    this.height,
    this.icon,
    required this.title,
    this.margin,
    this.expandedHeader,
    this.padding
  });

  @override
  State<ZFormDialog> createState() => _ZFormDialogState();
}

class _ZFormDialogState extends State<ZFormDialog> {
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (context,state) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.zero,
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              content: Container(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  width: widget.width ?? MediaQuery.sizeOf(context).width * .4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildHeader(),
                      Flexible(
                        child: Container(
                          padding: widget.padding?? EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                          child: widget.child,
                        ),
                      ),
                      if(widget.isActionTrue)buildAction(context),
                    ],
                  )
              ),
            ),
          );
        }
    );
  }

  Widget buildAction(context){
    final locale = AppLocalizations.of(context)!;
    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              widget.expandedAction?? Text("")
            ],
          ),

          Row(
            spacing: 8,
            children: [
              ZButton(
                  isEnabled: widget.isButtonEnabled,
                  height: 35,
                  width: 100,
                  label: widget.actionLabel ?? Text(""),
                  onPressed: widget.onAction
              ),
              ZOutlineButton(
                label: Text(locale.cancel),
                onPressed: () => Navigator.of(context).pop(),
                height: 35,
                width: 100,
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget buildHeader(){
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      height: 50,
      child: Column(
        children: [
          //Title
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 5
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding:  const EdgeInsets.symmetric(horizontal: 5.0,vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      widget.icon !=null? Icon(widget.icon,color: Theme.of(context).colorScheme.secondary,size: 20) : SizedBox(),
                      widget.icon !=null?  const SizedBox(width: 8) : SizedBox(),
                      Text(
                        widget.title,
                        style: TextStyle(fontSize: 17,color: Theme.of(context).colorScheme.secondary,fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                widget.expandedHeader ?? SizedBox()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
