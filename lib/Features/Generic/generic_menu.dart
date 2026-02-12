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
        alignment: context.read<LocalizationBloc>().state.languageCode == "en"
            ? Alignment.centerLeft
            : Alignment.centerRight,
        children: [
          Container(
            height: 38,
            width: 3,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
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
              mainAxisAlignment:
              isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
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
            ),
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

  /// 🔹 External control for default expanded/collapsed state
  final bool isExpanded;

  /// 🔹 Optional header
  final Widget Function(bool isExpanded)? menuHeaderBuilder;

  /// 🔹 Optional footer
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
    this.isExpanded = true,
  });

  @override
  State<GenericMenuWithScreen<T>> createState() =>
      _GenericMenuWithScreenState<T>();
}

class _GenericMenuWithScreenState<T> extends State<GenericMenuWithScreen<T>> {
  double minScreenSize = 60;
  double maxScreenSize = 170;
  late bool isMenuExpanded;

  // Track if we've already attempted to fix the selection
  bool _fixAttempted = false;

  @override
  void initState() {
    super.initState();
    isMenuExpanded = widget.isExpanded;
    _validateAndFixSelectedValue();
  }

  @override
  void didUpdateWidget(GenericMenuWithScreen<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if items or selectedValue changed
    if (oldWidget.items != widget.items ||
        oldWidget.selectedValue != widget.selectedValue) {
      _fixAttempted = false; // Reset for new validation
      _validateAndFixSelectedValue();
    }
  }

  void _validateAndFixSelectedValue() {
    // Prevent infinite loops
    if (_fixAttempted) return;

    // If items list is empty, we can't fix anything
    if (widget.items.isEmpty) {
      _fixAttempted = true;
      return;
    }

    // Check if current selectedValue exists in items
    final isValid = widget.items.any((item) => item.value == widget.selectedValue);

    if (!isValid) {
      _fixAttempted = true;
      // Current selection is invalid, use first available item
      final firstAvailableValue = widget.items.first.value;

      // Call onChanged with the first available value
      // Use addPostFrameCallback to avoid calling during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onChanged(firstAvailableValue);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle empty items case - show empty state
    if (widget.items.isEmpty) {
      return Row(
        children: [
          /// Sidebar (collapsed or expanded)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isMenuExpanded ? maxScreenSize : minScreenSize,
            height: double.infinity,
            margin: widget.margin ??
                const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 3,
                  spreadRadius: 2,
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: .03),
                ),
              ],
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              children: [
                /// Toggle arrow (still functional)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: .06),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: IconButton(
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          icon: Icon(isMenuExpanded
                              ? Icons.chevron_left
                              : Icons.chevron_right),
                          onPressed: () {
                            setState(() {
                              isMenuExpanded = !isMenuExpanded;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ),

                /// Header (if provided)
                if (widget.menuHeaderBuilder != null) ...[
                  widget.menuHeaderBuilder!(isMenuExpanded),
                  const SizedBox(height: 8),
                ],

                /// Empty state message
                Expanded(
                  child: Center(
                    child: isMenuExpanded
                        ? Text(
                      'No menu items available',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .5),
                      ),
                    )
                        : const SizedBox.shrink(),
                  ),
                ),

                /// Footer (if provided)
                if (widget.menuFooterBuilder != null)
                  widget.menuFooterBuilder!(isMenuExpanded),
              ],
            ),
          ),

          /// Empty content area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: const Center(
                child: Text('No content available'),
              ),
            ),
          ),
        ],
      );
    }

    // Check if selected value exists in items
    final bool isSelectedValid = widget.items.any(
            (item) => item.value == widget.selectedValue
    );

    // If selected value doesn't exist, return SizedBox.shrink() as requested
    if (!isSelectedValid) {
      // We still want to attempt to fix it, but return empty widget for now
      if (!_fixAttempted) {
        _validateAndFixSelectedValue();
      }
      return const SizedBox.shrink();
    }

    // Safely get the selected item - we know it exists now
    final selectedItem = widget.items.firstWhere(
          (e) => e.value == widget.selectedValue,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔷 Sidebar
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isMenuExpanded ? maxScreenSize : minScreenSize,
              clipBehavior: Clip.hardEdge,
              height: double.infinity,
              margin: widget.margin ??
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    spreadRadius: 2,
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: .03),
                  ),
                ],
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2),
                child: Column(
                  children: [
                    /// Toggle arrow
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: .06),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: IconButton(
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              icon: Icon(isMenuExpanded
                                  ? Icons.chevron_left
                                  : Icons.chevron_right),
                              onPressed: () {
                                setState(() {
                                  isMenuExpanded = !isMenuExpanded;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Header
                    if (widget.menuHeaderBuilder != null) ...[
                      widget.menuHeaderBuilder!(isMenuExpanded),
                      const SizedBox(height: 8),
                    ],

                    /// Menu list
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: widget.items.map((item) {
                          return GenericMenuItem(
                            isSelected: item.value == widget.selectedValue,
                            onTap: () {
                              widget.onChanged(item.value);
                            },
                            label: item.label,
                            icon: item.icon,
                            fontSize: widget.fontSize,
                            isExpanded: isMenuExpanded,
                            padding: widget.padding ??
                                const EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 5),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 2.0, vertical: 3),
                            borderRadius: widget.borderRadius,
                            selectedColor: widget.selectedColor,
                            unselectedColor: widget.unselectedColor,
                            selectedTextColor: widget.selectedTextColor,
                            unselectedTextColor: widget.unselectedTextColor,
                          );
                        }).toList(),
                      ),
                    ),

                    /// Footer
                    if (widget.menuFooterBuilder != null)
                      widget.menuFooterBuilder!(isMenuExpanded),
                  ],
                ),
              ),
            ),

            /// 🔷 Main content
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