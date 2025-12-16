import 'package:flutter/material.dart';

/// A generic card widget for displaying information with avatar, title, subtitle,
/// status badge, and multiple info rows.
class ZCard extends StatefulWidget {
  /// The image to display (can be network URL, asset path, or widget)
  final Widget? image;

  /// The main title text
  final String title;

  /// The subtitle text
  final String? subtitle;

  /// List of info items to display (icon + text)
  final List<InfoItem> infoItems;

  /// Status badge configuration
  final InfoStatus? status;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Whether the card is hoverable
  final bool hoverable;

  /// Minimum height of the card
  final double minHeight;

  /// Maximum height of the card
  final double maxHeight;

  /// Border radius
  final double borderRadius;

  /// Padding inside the card
  final EdgeInsets padding;

  /// Whether to show divider between header and info items
  final bool showDivider;

  /// Custom builder for the image section
  final Widget Function(BuildContext context)? imageBuilder;

  /// Custom builder for the title section
  final Widget Function(BuildContext context)? titleBuilder;

  /// Custom builder for the info items section
  final Widget Function(BuildContext context)? infoItemsBuilder;

  const ZCard({
    super.key,
    this.image,
    required this.title,
    this.subtitle,
    this.infoItems = const [],
    this.status,
    this.onTap,
    this.hoverable = true,
    this.minHeight = 180,
    this.maxHeight = 280,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(12),
    this.showDivider = true,
    this.imageBuilder,
    this.titleBuilder,
    this.infoItemsBuilder,
  });

  @override
  State<ZCard> createState() => _ZCardState();
}

/// Represents an info item (icon + text)
class InfoItem {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final TextStyle? textStyle;

  const InfoItem({
    required this.icon,
    required this.text,
    this.iconColor,
    this.textStyle,
  });
}

/// Represents a status badge
class InfoStatus {
  final String label;
  final Color color;
  final Color? backgroundColor;
  final TextStyle? labelStyle;

  const InfoStatus({
    required this.label,
    required this.color,
    this.backgroundColor,
    this.labelStyle,
  });
}

class _ZCardState extends State<ZCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: widget.hoverable ? (_) => setState(() => _isHovering = true) : null,
      onExit: widget.hoverable ? (_) => setState(() => _isHovering = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: _isHovering && widget.hoverable
                ? color.primary.withValues(alpha: .3)
                : color.outline.withValues(alpha: .25),
            width: 1.2,
          ),
          boxShadow: _isHovering && widget.hoverable
              ? [
            BoxShadow(
              color: color.primary.withValues(alpha: .35),
              blurRadius: 3,
              offset: const Offset(0, 2),
            )
          ] : [
            BoxShadow(
              color: color.outline.withValues(alpha: .15),
              spreadRadius: 0,
              blurRadius: 1,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          onTap: widget.onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: widget.minHeight,
              maxHeight: widget.maxHeight,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: widget.padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section (Image + Title + Status)
                    _buildHeaderSection(context),

                    if (widget.showDivider && widget.infoItems.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                    ],

                    // Info items section
                    if (widget.infoItems.isNotEmpty) _buildInfoItemsSection(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    // Use custom builder if provided
    if (widget.imageBuilder != null) {
      return widget.imageBuilder!(context);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image
              if (widget.image != null) ...[
                widget.image!,
                const SizedBox(height: 10),
              ],

              // Title - use custom builder or default
              if (widget.titleBuilder != null)
                widget.titleBuilder!(context)
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),

        // Status badge
        if (widget.status != null) _buildStatusBadge(widget.status!),
      ],
    );
  }

  Widget _buildInfoItemsSection(BuildContext context) {
    // Use custom builder if provided
    if (widget.infoItemsBuilder != null) {
      return widget.infoItemsBuilder!(context);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < widget.infoItems.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          _buildInfoRow(widget.infoItems[i], context),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(InfoStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.backgroundColor ?? status.color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: status.labelStyle ??
            TextStyle(
              fontSize: 11,
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildInfoRow(InfoItem item, BuildContext context) {
    return Row(
      children: [
        Icon(
          item.icon,
          size: 14,
          color: item.iconColor ?? Theme.of(context).hintColor,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            item.text,
            style: item.textStyle ?? Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

