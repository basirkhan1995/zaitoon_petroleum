
import 'package:flutter/material.dart';

class Cover extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? shadowColor;
  final double? radius;


  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  const Cover({super.key,
    this.shadowColor,
    required this.child,
    this.color,this.radius,
    this.padding,
    this.margin
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 3,vertical: 0),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: shadowColor ?? Theme.of(context).colorScheme.surfaceContainer,
                blurRadius: 0,
                spreadRadius: 1
            )
          ],
          borderRadius: BorderRadius.circular(radius ?? 3),
          color: color ?? Theme.of(context).colorScheme.primary.withValues(alpha: .05)
      ),
      child: child,
    );
  }
}
