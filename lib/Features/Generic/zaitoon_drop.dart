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

  /// SINGLE
  final T? selectedItem;
  final ValueChanged<T> onItemSelected; // ✅ REQUIRED

  /// MULTI
  final List<T>? selectedItems;
  final ValueChanged<List<T>>? onMultiSelectChanged; // ✅ OPTIONAL
  final bool multiSelect;

  final Widget Function(T)? leadingBuilder;
  final String Function(T) itemLabel;
  final bool isLoading;
  final Widget? customTitle;

  const ZDropdown({
    super.key,
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.onItemSelected, // 👈 REQUIRED
    this.selectedItem,
    this.selectedItems,
    this.onMultiSelectChanged,
    this.multiSelect = false,
    this.height,
    this.itemStyle,
    this.radius,
    this.leadingBuilder,
    this.disableAction = false,
    this.initialValue,
    this.isLoading = false,
    this.customTitle,
  });

  @override
  State<ZDropdown<T>> createState() => _ZDropdownState<T>();
}

class _ZDropdownState<T> extends State<ZDropdown<T>> {
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();

  T? _selectedItem;
  late List<T> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
    _selectedItems =
    widget.selectedItems != null ? List.from(widget.selectedItems!) : [];
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isOpen) {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      setState(() => _isOpen = false);
    }
  }

  @override
  void didUpdateWidget(covariant ZDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.multiSelect &&
        widget.selectedItem != oldWidget.selectedItem) {
      _selectedItem = widget.selectedItem;
    }

    if (widget.multiSelect &&
        widget.selectedItems != oldWidget.selectedItems) {
      _selectedItems =
      widget.selectedItems != null ? List.from(widget.selectedItems!) : [];
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onItemTapped(T item) {
    if (widget.multiSelect) {
      setState(() {
        _selectedItems.contains(item)
            ? _selectedItems.remove(item)
            : _selectedItems.add(item);
      });
      widget.onMultiSelectChanged?.call(_selectedItems);
      _refreshOverlay();
    } else {
      setState(() => _selectedItem = item);
      widget.onItemSelected(item);
      _removeOverlay();
    }
  }

  void _refreshOverlay() {
    if (_isOpen) {
      _removeOverlay();
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
      setState(() => _isOpen = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.multiSelect
        ? (_selectedItems.isEmpty
        ? widget.initialValue ?? ''
        : _selectedItems.map(widget.itemLabel).join(', '))
        : (_selectedItem != null
        ? widget.itemLabel(_selectedItem as T)
        : widget.initialValue ?? '');

    return Focus(
      focusNode: _focusNode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.customTitle != null)
            widget.customTitle!
          else if (widget.title.isNotEmpty)
            Text(widget.title,
                style: Theme.of(context).textTheme.titleSmall),

          const SizedBox(height: 4),

          GestureDetector(
            onTap: widget.disableAction || widget.isLoading
                ? null
                : () {
              _focusNode.requestFocus();
              if (_isOpen) {
                _removeOverlay();
              } else {
                _overlayEntry = _createOverlayEntry(context);
                Overlay.of(context).insert(_overlayEntry!);
                setState(() => _isOpen = true);
              }
            },
            child: Container(
              key: _buttonKey,
              height: widget.height ?? 40,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.radius ?? 4),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withAlpha(80),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayText,
                      overflow: TextOverflow.ellipsis,
                      style: widget.itemStyle ??
                          Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Icon(_isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    final renderBox =
    _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final color = Theme.of(context).colorScheme;

    return OverlayEntry(
      builder: (_) => Positioned(
        left: offset.dx,
        top: offset.dy + renderBox.size.height + 4,
        width: renderBox.size.width,
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(widget.radius ?? 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.multiSelect)
                InkWell(
                  onTap: () {
                    final allSelected =
                        _selectedItems.length == widget.items.length;
                    setState(() {
                      _selectedItems = allSelected
                          ? []
                          : List.from(widget.items);
                    });
                    widget.onMultiSelectChanged?.call(_selectedItems);
                    _refreshOverlay();
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectedItems.length ==
                            widget.items.length &&
                            widget.items.isNotEmpty,
                        onChanged: (_) {},
                      ),
                      Text(AppLocalizations.of(context)!.selectAll),
                    ],
                  ),
                ),
              ...widget.items.map((item) {
                final isSelected = widget.multiSelect
                    ? _selectedItems.contains(item)
                    : item == _selectedItem;

                return InkWell(
                  onTap: () => _onItemTapped(item),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    color: isSelected
                        ? color.primary.withAlpha(15)
                        : null,
                    child: Row(
                      children: [
                        if (widget.multiSelect)
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) => _onItemTapped(item),
                          ),
                        if (widget.leadingBuilder != null)
                          widget.leadingBuilder!(item),
                        const SizedBox(width: 6),
                        Expanded(child: Text(widget.itemLabel(item))),
                        if (isSelected && !widget.multiSelect)
                          const Icon(Icons.check, size: 16),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
