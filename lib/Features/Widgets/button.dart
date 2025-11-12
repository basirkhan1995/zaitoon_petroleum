import 'package:flutter/material.dart';

class ZButton extends StatelessWidget {
  final Widget label;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final bool isEnabled;
  final Color? color;
  const ZButton({super.key,
    required this.label,
    this.onPressed,
    this.width,
    this.isEnabled = true,
    this.color,
    this.height = 40
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width,
      height: height,
      child: ElevatedButton(
          style: ButtonStyle(
              elevation: WidgetStateProperty.all(0),
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
              backgroundColor:  WidgetStateProperty.all(!isEnabled? Colors.grey : color ?? Theme.of(context).colorScheme.primary),
              foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surface)
          ),
          onPressed: isEnabled? onPressed : null,
          child: label),
    );
  }
}
