import 'package:flutter/material.dart';

class ZDraggableSheet {
  static Future<T?> show<T>({
    required BuildContext context,

    /// 🔹 BODY BUILDER ONLY
    required Widget Function(
        BuildContext context,
        ScrollController scrollController,
        ) bodyBuilder,

    /// 🔹 HEADER OPTIONS
    String? title,
    bool showCloseButton = true,
    bool showDragHandle = true,

    /// 🔹 SIZE CONTROL
    double initialChildSize = 0.6,
    double minChildSize = 0.4,
    double maxChildSize = 0.95,

    /// 🔹 STYLE
    Color? backgroundColor,
    BorderRadius? borderRadius,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final color = Theme.of(context).colorScheme;

        return DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor ?? Theme.of(context).cardColor,
                borderRadius: borderRadius ??
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  /// 🔹 Drag Handle
                  if (showDragHandle)
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                  /// 🔹 Header Row
                  if (title != null || showCloseButton)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (title != null)
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          const SizedBox(),

                        if (showCloseButton)
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                      ],
                    ),

                  if (title != null || showCloseButton)
                    Divider(color: color.outlineVariant),

                  /// 🔹 BODY
                  Expanded(
                    child: bodyBuilder(context, scrollController),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}