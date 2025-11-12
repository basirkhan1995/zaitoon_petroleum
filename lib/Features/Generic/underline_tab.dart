import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';

class CustomUnderlineTabBar<T> extends StatelessWidget {
  final List<T> tabs;
  final T currentTab;
  final void Function(T) onTabChanged;
  final IconData? Function(T)? iconBuilder; // made optional
  final String Function(T) labelBuilder;
  final Color? activeColor;
  final Color? inactiveColor;

  const CustomUnderlineTabBar({
    super.key,
    required this.tabs,
    required this.currentTab,
    required this.onTabChanged,
    this.iconBuilder,
    required this.labelBuilder,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final activeClr = activeColor ?? theme.primary;
    final inactiveClr = inactiveColor ?? theme.secondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: tabs.map((tab) {
        final isSelected = tab == currentTab;

        return Material(
          child: InkWell(
            onTap: () => onTabChanged(tab),
            highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: .05),
            hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: .05),
            borderRadius: BorderRadius.circular(2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInExpo,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected? theme.primary.withValues(alpha: .1) : theme.primary.withValues(alpha: .04),

                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? activeClr : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (iconBuilder != null && iconBuilder!(tab) != null) ...[
                    Icon(
                      iconBuilder!(tab),
                      size: context.scaledFont(0.011),
                      color: isSelected ? activeClr : inactiveClr,
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    labelBuilder(tab),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: context.scaledFont(0.010),
                      color: isSelected ? activeClr : inactiveClr,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
