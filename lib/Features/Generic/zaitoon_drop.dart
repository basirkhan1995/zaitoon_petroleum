import 'package:flutter/material.dart';
import '../../Localizations/l10n/translations/app_localizations.dart';

class ZDropdown<T> extends StatefulWidget {
  final double? radius;
  final String title;
  final List<T> items;
  final double? height;
  final String? initialValue;
  final bool disableAction;
  final TextStyle? itemStyle;
  final T? selectedItem;
  final List<T>? selectedItems;
  final Widget Function(T)? leadingBuilder;
  final String Function(T) itemLabel;
  final Function(T) onItemSelected;
  final Function(List<T>)? onMultiSelectChanged;
  final bool multiSelect;
  final bool isLoading;
  final Widget? customTitle;

  const ZDropdown({
    super.key,
    required this.title,
    this.height,
    this.itemStyle,
    this.radius,
    this.leadingBuilder,
    this.disableAction = false,
    this.initialValue,
    this.selectedItem,
    this.selectedItems,
    this.onMultiSelectChanged,
    this.multiSelect = false,
    required this.items,
    required this.itemLabel,
    required this.onItemSelected,
    this.isLoading = false,
    this.customTitle, // Add this line
  });


  @override
  State<ZDropdown<T>> createState() => _ZDropdownState<T>();
}

class _ZDropdownState<T> extends State<ZDropdown<T>> {
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();

  T? _selectedItem;
  late List<T> _selectedItems;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
    _selectedItems = widget.selectedItems != null ? List.from(widget.selectedItems!) : [];
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isOpen) {
      removeOverlay();
    }
  }

  void removeOverlay() {
    if (_overlayEntry != null && _isOpen) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      setState(() => _isOpen = false);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }


  void _onItemTapped(T item) {
    if (widget.multiSelect) {
      setState(() {
        if (_selectedItems.contains(item)) {
          _selectedItems.remove(item);
        } else {
          _selectedItems.add(item);
        }
      });
      widget.onMultiSelectChanged?.call(_selectedItems);
      _refreshOverlay();
    } else {
      // SINGLE SELECT MODE
      setState(() => _selectedItem = item);
      widget.onItemSelected(item);

      // Close the dropdown overlay
      removeOverlay();
    }
  }


  void _refreshOverlay() {
    if (_isOpen) {
      removeOverlay();
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
      setState(() => _isOpen = true);
    }
  }


  @override
  Widget build(BuildContext context) {

    // Display the selected items nicely for multi-select
    String displayText;
    if (widget.multiSelect) {
      if (_selectedItems.isEmpty) {
        displayText = widget.initialValue ?? "";
      } else {
        displayText = _selectedItems.map(widget.itemLabel).join(", ");
      }
    } else {
      displayText = _selectedItem != null
          ? widget.itemLabel(_selectedItem as T)
          : (widget.initialValue ?? "");
    }

    return Focus(
      focusNode: _focusNode,
      child: Column(
        mainAxisSize: MainAxisSize.min, // <-- minimize vertical space
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only show title if it actually has content
          if (widget.customTitle != null && widget.customTitle is! SizedBox)
            widget.customTitle!
          else if (widget.title.isNotEmpty)
            Text(widget.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12)),

          // Only add spacing if title is present
          if ((widget.customTitle != null && widget.customTitle is! SizedBox) || widget.title.isNotEmpty)
            const SizedBox(height: 3),

          GestureDetector(
            onTap: widget.disableAction
                ? null
                : () {
              if (widget.isLoading) return;
              _focusNode.requestFocus();
              if (_isOpen) {
                removeOverlay();
              } else {
                _overlayEntry = _createOverlayEntry(context);
                Overlay.of(context).insert(_overlayEntry!);
                setState(() => _isOpen = true);
              }
            },
            child: Container(
              key: _buttonKey,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              height: widget.height ?? 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(widget.radius ?? 4),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: .3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Expanded(
                    child: Text(
                      displayText,
                      style: widget.itemStyle ?? Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  widget.disableAction
                      ? const SizedBox()
                      : Icon(
                    size: 20,
                    _isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: .9),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    final renderBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final color = Theme.of(context).colorScheme;
    const maxHeight = 260.0;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: removeOverlay,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + renderBox.size.height + 5,
              width: renderBox.size.width,
              child: Material(
                elevation: 1,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(widget.radius ?? 4), // <-- also here
                clipBehavior: Clip.antiAlias, // <-- ensures clipping
                child: Container(
                  decoration: BoxDecoration(
                    color: color.surface,
                    border: Border.all(
                      color: color.outline.withValues(alpha: .3),
                      width: 1,
                    ),

                    borderRadius: BorderRadius.circular(widget.radius ?? 4),
                  ),
                  constraints: const BoxConstraints(maxHeight: maxHeight),
                  child: ClipRRect( // <-- clip content to radius
                    borderRadius: BorderRadius.circular(widget.radius ?? 4),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.multiSelect)
                            Material(
                              color: Colors.transparent, // keep radius visible
                              child: InkWell(
                                onTap: () {
                                  final allSelected = _selectedItems.length == widget.items.length;
                                  setState(() {
                                    if (allSelected) {
                                      _selectedItems.clear();
                                    } else {
                                      _selectedItems = List.from(widget.items);
                                    }
                                  });
                                  widget.onMultiSelectChanged?.call(_selectedItems);
                                  _refreshOverlay();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _selectedItems.length == widget.items.length && widget.items.isNotEmpty,
                                        tristate: true,
                                        onChanged: (checked) {
                                          final allSelected = _selectedItems.length == widget.items.length;
                                          setState(() {
                                            if (allSelected) {
                                              _selectedItems.clear();
                                            } else {
                                              _selectedItems = List.from(widget.items);
                                            }
                                          });
                                          widget.onMultiSelectChanged?.call(_selectedItems);
                                          _refreshOverlay();
                                        },
                                        visualDensity: const VisualDensity(vertical: -2),
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.selectAll,
                                        style: widget.itemStyle ?? Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ...widget.items.map((item) {
                            final isSelected = widget.multiSelect
                                ? _selectedItems.contains(item)
                                : item == _selectedItem;

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _onItemTapped(item),
                                hoverColor: color.primary.withAlpha(12),
                                highlightColor: color.primary.withAlpha(12),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: widget.multiSelect ? 0 :  5, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? color.primary.withAlpha(12) : Colors.transparent,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      widget.multiSelect
                                          ? Checkbox(
                                        value: isSelected,
                                        onChanged: (_) => _onItemTapped(item),
                                      )
                                          : const SizedBox(),
                                      if (widget.leadingBuilder != null)
                                        widget.leadingBuilder!(item)
                                      else
                                        const SizedBox.shrink(),
                                      if(widget.leadingBuilder !=null)
                                        SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          widget.itemLabel(item),
                                          style: widget.itemStyle ?? Theme.of(context).textTheme.bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isSelected && !widget.multiSelect)
                                        const Icon(Icons.check_rounded, size: 17)
                                      else
                                        const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
