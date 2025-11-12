import 'package:flutter/material.dart';

class HoverWidget extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final double radius;
  final Color? color;
  final Color? hoverColor;
  final Color? foregroundColor;
  final Color? hoverForegroundColor;
  final double height;
  final double width;
  final double? fontSize;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const HoverWidget({
    super.key,
    required this.onTap,
    required this.label,
    required this.icon,
    this.color,
    this.fontSize,
    this.hoverColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.radius = 5,
    this.height = 100,
    this.width = 250,
    this.margin,
    this.padding,
  });

  @override
  State<HoverWidget> createState() => _HoverWidgetState();
}

class _HoverWidgetState extends State<HoverWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isHovered
        ? (widget.hoverColor ?? Colors.redAccent)
        : (widget.color ?? Colors.redAccent.withValues(alpha: .05));
    final textColor = _isHovered
        ? (widget.hoverForegroundColor ?? Colors.white)
        : (widget.foregroundColor ?? Colors.black);
    final iconColor = textColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(widget.radius),
        child: Container(
          margin: widget.margin ?? const EdgeInsets.all(0),
          padding: widget.padding ?? const EdgeInsets.all(4),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: widget.color ?? Colors.redAccent,
            ),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          child: Center(
            child: ListTile(
              title: Text(
                widget.label,
                style: TextStyle(color: textColor, fontSize: widget.fontSize),
              ),
              trailing: Icon(
                widget.icon,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
