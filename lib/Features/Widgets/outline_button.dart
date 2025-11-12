import 'package:flutter/material.dart';

class ZOutlineButton extends StatefulWidget {
  final Widget label;
  final VoidCallback? onPressed;
  final double? height;
  final double? width;
  final String toolTip;
  final Color? backgroundColor;
  final Color? backgroundHover;
  final Color? foregroundHover;
  final Color? textColor;
  final IconData? icon;
  final double? iconSize;
  final bool isActive; // <-- New parameter
  final bool disable;

  const ZOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundHover,
    this.foregroundHover,
    this.textColor,
    this.toolTip = '',
    this.disable = false,
    this.iconSize,
    this.width,
    this.icon,
    this.backgroundColor,
    this.height,
    this.isActive = false, // default to false
  });

  @override
  ZOutlineButtonState createState() => ZOutlineButtonState();
}

class ZOutlineButtonState extends State<ZOutlineButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine colors based on isActive and hover
    final bgColor = widget.isActive
        ? widget.backgroundHover ?? theme.colorScheme.primary
        : (_isHovered
        ? widget.backgroundHover ?? theme.colorScheme.primary
        : widget.backgroundColor ?? theme.colorScheme.surface);

    final borderColor = widget.isActive
        ? bgColor // same as background when active
        : (_isHovered
        ? widget.backgroundHover ?? theme.colorScheme.primary
        : Colors.grey.withValues(alpha: .5));

    final disabledStatus = widget.disable
        ? theme.colorScheme.error // same as background when active
        : (_isHovered
        ? widget.backgroundHover ?? theme.colorScheme.primary
        : Colors.grey.withValues(alpha: .5));

    final textColor = widget.isActive
        ? widget.foregroundHover ?? theme.colorScheme.onPrimary
        : (_isHovered
        ? widget.foregroundHover ?? theme.colorScheme.onPrimary
        : widget.textColor ?? theme.colorScheme.primary.withValues(alpha: .9));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.width ?? double.infinity,
          minHeight: widget.height ?? 40,
        ),
        child: Tooltip(
          message: widget.toolTip,
          child: SizedBox(
            width: widget.width ?? 145,
            height: widget.height ?? 40,
            child: OutlinedButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 8),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                ),
                backgroundColor: WidgetStateProperty.all(bgColor),
                side: WidgetStateProperty.all(BorderSide(color: widget.disable? disabledStatus : borderColor)),
              ),
              onPressed: widget.disable ? null : widget.onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null)
                    Icon(widget.icon, color: textColor, size: widget.iconSize),
                  if (widget.icon != null) const SizedBox(width: 5),
                  DefaultTextStyle.merge(style: TextStyle(color: textColor), child: widget.label),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
