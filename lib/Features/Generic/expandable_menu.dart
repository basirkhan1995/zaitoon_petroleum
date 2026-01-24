import 'package:flutter/material.dart';

class SidebarItem<T> {
  final T value;
  final String label;
  final Widget? screen;
  final IconData? icon;
  final List<SidebarItem<T>>? children;

  const SidebarItem({
    required this.value,
    required this.label,
    this.screen,
    this.icon,
    this.children,
  });

  bool get hasChildren => children != null && children!.isNotEmpty;
}

class SidebarTile extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final String label;
  final IconData? icon;
  final bool expanded;

  const SidebarTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.label,
    this.icon,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment:
          expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : Colors.black,
              ),
            if (expanded && icon != null) const SizedBox(width: 8),
            if (expanded)
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SidebarExpandableGroup<T> extends StatefulWidget {
  final SidebarItem<T> item;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool expanded;

  const SidebarExpandableGroup({
    super.key,
    required this.item,
    required this.selected,
    required this.onChanged,
    required this.expanded,
  });

  @override
  State<SidebarExpandableGroup<T>> createState() =>
      _SidebarExpandableGroupState<T>();
}

class _SidebarExpandableGroupState<T>
    extends State<SidebarExpandableGroup<T>> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    final bool childSelected = widget.item.children!
        .any((e) => e.value == widget.selected);

    return Column(
      children: [
        /// Parent
        SidebarTile(
          selected: childSelected,
          onTap: () => setState(() => open = !open),
          label: widget.item.label,
          icon: widget.item.icon,
          expanded: widget.expanded,
        ),

        /// Children
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState:
          open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: widget.item.children!.map((child) {
              return Padding(
                padding: const EdgeInsets.only(left: 14),
                child: SidebarTile(
                  selected: widget.selected == child.value,
                  onTap: () => widget.onChanged(child.value),
                  label: child.label,
                  icon: child.icon,
                  expanded: widget.expanded,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class AdaptiveSidebarMenu<T> extends StatefulWidget {
  final List<SidebarItem<T>> items;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool initiallyExpanded;

  const AdaptiveSidebarMenu({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.initiallyExpanded = true,
  });

  @override
  State<AdaptiveSidebarMenu<T>> createState() =>
      _AdaptiveSidebarMenuState<T>();
}

class _AdaptiveSidebarMenuState<T> extends State<AdaptiveSidebarMenu<T>> {
  late bool expanded;

  @override
  void initState() {
    super.initState();
    expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final current =
    widget.items.expand((e) => e.children ?? [e]).firstWhere(
          (e) => e.value == widget.selected,
    );

    return Row(
      children: [
        /// Sidebar
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: expanded ? 180 : 60,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color:
              Theme.of(context).colorScheme.primary.withValues(alpha: .1),
            ),
          ),
          child: Column(
            children: [
              /// Toggle
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                      expanded ? Icons.chevron_left : Icons.chevron_right),
                  onPressed: () => setState(() => expanded = !expanded),
                ),
              ),

              /// Menu
              Expanded(
                child: ListView(
                  children: widget.items.map((item) {
                    if (item.hasChildren) {
                      return SidebarExpandableGroup<T>(
                        item: item,
                        selected: widget.selected,
                        onChanged: widget.onChanged,
                        expanded: expanded,
                      );
                    }

                    return SidebarTile(
                      selected: widget.selected == item.value,
                      onTap: () => widget.onChanged(item.value),
                      label: item.label,
                      icon: item.icon,
                      expanded: expanded,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        /// Screen
        Expanded(
          child: current.screen ?? const SizedBox.shrink(),
        ),
      ],
    );
  }
}
