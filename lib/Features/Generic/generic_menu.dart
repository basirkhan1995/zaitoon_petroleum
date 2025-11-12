import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Localizations/Bloc/localizations_bloc.dart';

class GenericMenuItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final String label;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final double borderRadius;
  final double? fontSize;
  final bool isExpanded;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const GenericMenuItem({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.fontSize,
    this.icon,
    required this.label,
    this.isExpanded = true,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.transparent,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = Colors.black,
    this.borderRadius = 3,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    this.margin = const EdgeInsets.symmetric(horizontal: 1),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        alignment: context.read<LocalizationBloc>().state.languageCode == "en"? AlignmentGeometry.centerLeft : AlignmentGeometry.centerRight,
        children: [
          Container(
            height: 38,
            width: 3,
            decoration: BoxDecoration(
              color: isSelected? Theme.of(context).colorScheme.primary : Colors.transparent,
            ),
          ),
          Container(
              padding: padding,
              margin: margin,
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : unselectedColor,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: isExpanded? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  if (icon != null)
                    Icon(
                      icon,
                      size: 25,
                      color: isSelected ? selectedTextColor : unselectedTextColor,
                    ),

                  if (isExpanded && icon != null) const SizedBox(width: 6),

                  if (isExpanded)
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? selectedTextColor : unselectedTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              )
          ),
        ],
      ),
    );
  }
}

class GenericMenuWithScreen<T> extends StatefulWidget {
  final double? menuWidth;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final List<MenuDefinition<T>> items;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final double borderRadius;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// 🔹 Optional header (e.g. logo, user info)
  final Widget Function(bool isExpanded)? menuHeaderBuilder;

  /// 🔹 Optional footer (e.g. logout, version)
  final Widget Function(bool isExpanded)? menuFooterBuilder;



  const GenericMenuWithScreen({
    super.key,
    this.menuWidth,
    required this.selectedValue,
    required this.onChanged,
    required this.items,
    this.menuHeaderBuilder,
    this.menuFooterBuilder,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.transparent,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = Colors.black,
    this.borderRadius = 3,
    this.fontSize,
    this.padding,
    this.margin,
  });

  @override
  State<GenericMenuWithScreen<T>> createState() => _GenericMenuWithScreenState<T>();
}

class _GenericMenuWithScreenState<T> extends State<GenericMenuWithScreen<T>> {
  double minScreenSize = 60;
  double maxScreenSize = 170;
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final selectedItem = widget.items.firstWhere((e) => e.value == widget.selectedValue);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔷 Menu sidebar
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isExpanded ? maxScreenSize : minScreenSize,
              height: double.infinity,
              margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: .1)
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    spreadRadius: 2,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .03),
                  ),
                ],
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: .06),
                                borderRadius: BorderRadius.circular(3)
                            ),
                            child: IconButton(
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              icon: Icon(
                                  isExpanded
                                      ? Icons.chevron_left
                                      : Icons.chevron_right),
                              onPressed: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// 🔹 Optional header
                    if (widget.menuHeaderBuilder != null) ...[
                      widget.menuHeaderBuilder!(isExpanded),
                      const SizedBox(height: 8),
                    ],

                    /// 🔹 Menu items in scrollable view
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: widget.items.map((item) {
                          return GenericMenuItem(
                            isSelected: item.value == widget.selectedValue,
                            onTap: () => widget.onChanged(item.value),
                            label: item.label,
                            icon: item.icon,
                            fontSize: widget.fontSize,
                            isExpanded: isExpanded,
                            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                            margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 3),
                            borderRadius: widget.borderRadius,
                            selectedColor: widget.selectedColor,
                            unselectedColor: widget.unselectedColor,
                            selectedTextColor: widget.selectedTextColor,
                            unselectedTextColor: widget.unselectedTextColor,
                          );
                        }).toList(),
                      ),
                    ),

                    /// 🔹 Optional footer
                    if (widget.menuFooterBuilder != null) ...[
                      widget.menuFooterBuilder!(isExpanded),
                    ],

                  ],
                ),
              ),
            ),

            /// 🔷 Main content - Use Expanded with flex to ensure it takes remaining space
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: selectedItem.screen,
              ),
            ),
          ],
        );
      },
    );
  }
}

class MenuDefinition<T> {
  final T value;
  final String label;
  final Widget screen;
  final IconData? icon;

  MenuDefinition({
    required this.value,
    required this.label,
    required this.screen,
    this.icon,
  });
}