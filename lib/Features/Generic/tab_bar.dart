import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';

/// ------------------------------------------------------------
///  Z TAB STYLE OPTIONS
/// ------------------------------------------------------------
enum ZTabStyle { rounded, underline }

/// ------------------------------------------------------------
///  Z TAB ITEM MODEL
/// ------------------------------------------------------------
class ZTabItem<T> {
  final T value;
  final String label;
  final Widget screen;
  final IconData? icon;

  ZTabItem({
    required this.value,
    required this.label,
    required this.screen,
    this.icon,
  });
}

/// ------------------------------------------------------------
///  Z TAB CONTAINER (Unified Layout)
/// ------------------------------------------------------------
class ZTabContainer<T> extends StatelessWidget {
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final List<ZTabItem<T>> tabs;

  final String? title;
  final String? description;
  final VoidCallback? onBack;

  final ZTabStyle style;

  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;

  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry tabBarPadding;
  final MainAxisAlignment tabAlignment;
  final Color tabContainerColor;

  const ZTabContainer({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    required this.tabs,

    this.title,
    this.description,
    this.onBack,

    this.style = ZTabStyle.rounded,

    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.transparent,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = Colors.black,

    this.borderRadius = 3,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    this.margin = const EdgeInsets.symmetric(horizontal: 3),
    this.tabBarPadding = const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
    this.tabAlignment = MainAxisAlignment.start,
    this.tabContainerColor = const Color(0xFFF5F5F5),
  });

  @override
  Widget build(BuildContext context) {
    final selectedTab = tabs.firstWhere((e) => e.value == selectedValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ---------------- Header + Tabs
        Container(
          width: double.infinity,
          padding: tabBarPadding,
          decoration: BoxDecoration(
            color: tabContainerColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------------- Title + Back
              if (title != null) ...[
                Row(
                  children: [
                    if (onBack != null)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        onPressed: onBack,
                        padding: EdgeInsets.zero,
                      ),
                    if (onBack != null) const SizedBox(width: 5),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 5),
                        child: Text(
                          title!,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              /// ---------------- Optional Description
              if (description != null) ...[
                Text(
                  description!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 10),
              ],

              /// ---------------- Tabs Row
              Row(
                mainAxisAlignment: tabAlignment,
                children: _buildZTabs(context),
              ),
            ],
          ),
        ),

        /// ---------------- Body
        Expanded(child: selectedTab.screen),
      ],
    );
  }

  /// ------------------------------------------------------------
  ///  BUILD TABS (Renamed to avoid conflicts)
  /// ------------------------------------------------------------
  List<Widget> _buildZTabs(BuildContext context) {
    switch (style) {
      case ZTabStyle.rounded:
        return tabs.map((tab) => _ZRoundedTab<T>(
          tab: tab,
          isSelected: tab.value == selectedValue,
          onTap: () => onChanged(tab.value),
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          selectedTextColor: selectedTextColor,
          unselectedTextColor: unselectedTextColor,
          borderRadius: borderRadius,
          padding: padding,
          margin: margin,
        )).toList();

      case ZTabStyle.underline:
        return tabs.map((tab) => _ZUnderlineTab<T>(
          tab: tab,
          isSelected: tab.value == selectedValue,
          onTap: () => onChanged(tab.value),
          activeColor: selectedColor,
          inactiveColor: unselectedTextColor,
        )).toList();
    }
  }
}

/// ------------------------------------------------------------
///  ROUNDED TAB ITEM (Renamed)
/// ------------------------------------------------------------
class _ZRoundedTab<T> extends StatelessWidget {
  final ZTabItem<T> tab;
  final bool isSelected;
  final VoidCallback onTap;

  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;

  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const _ZRoundedTab({
    required this.tab,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    required this.borderRadius,
    required this.padding,
    required this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          border: Border.all(
            color: isSelected
                ? selectedColor
                : selectedColor.withValues(alpha: .2),
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          children: [
            if (tab.icon != null)
              Icon(
                tab.icon,
                size: context.scaledFont(0.011),
                color: isSelected ? selectedTextColor : unselectedTextColor,
              ),
            if (tab.icon != null) const SizedBox(width: 5),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: context.scaledFont(0.010),
                color: isSelected ? selectedTextColor : unselectedTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
///  UNDERLINE TAB ITEM (Renamed)
/// ------------------------------------------------------------
class _ZUnderlineTab<T> extends StatelessWidget {
  final ZTabItem<T> tab;
  final bool isSelected;
  final VoidCallback onTap;

  final Color activeColor;
  final Color inactiveColor;

  const _ZUnderlineTab({
    required this.tab,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary.withValues(alpha: .1)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? activeColor : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          children: [
            if (tab.icon != null)
              Icon(
                tab.icon,
                size: context.scaledFont(0.011),
                color: isSelected ? activeColor : inactiveColor,
              ),
            if (tab.icon != null) const SizedBox(width: 5),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: context.scaledFont(0.010),
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
