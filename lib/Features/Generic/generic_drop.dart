import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final double? radius;
  final String title;
  final List<T> items;
  final double? height;
  final String? initialValue;
  final bool disableAction;
  final TextStyle? itemStyle;
  final T? selectedItem;
  final Widget Function(T)? leadingBuilder;
  final String Function(T) itemLabel;
  final Function(T) onItemSelected;
  final bool isLoading;

  const CustomDropdown({
    super.key,
    required this.title,
    this.height,
    this.itemStyle,
    this.radius,
    this.leadingBuilder,
    this.disableAction = false,
    this.initialValue,
    this.selectedItem,
    required this.items,
    required this.itemLabel,
    required this.onItemSelected,
    this.isLoading = false,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();
  T? _selectedItem;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
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

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Focus(
      focusNode: _focusNode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style:TextStyle(
              color: color.onSurface,fontSize: 13
          )),
          if (widget.title.isNotEmpty) const SizedBox(height: 5),
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
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              height: widget.height ?? 40,
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(widget.radius ?? 4),
                border: Border.all(color: color.outline.withValues(alpha: .3)),
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
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            _selectedItem != null
                                ? widget.itemLabel(_selectedItem as T)
                                : widget.initialValue ?? "",
                            style:
                                widget.itemStyle ??
                                Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                  widget.disableAction
                      ? const SizedBox()
                      : Icon(
                          _isOpen
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: widget.isLoading
                              ? Colors.transparent
                              : color.outline,
                    size: 20,
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
    final renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final color = Theme.of(context).colorScheme;
    const maxHeight = 250.0;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: removeOverlay,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + renderBox.size.height + 5,
              child: Material(
                elevation: 1,
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    widget.radius ?? 4,
                  ),
                  child: Container(
                    width: renderBox.size.width,
                    decoration: BoxDecoration(
                      color: color.surface,
                      border: Border.all(
                        color: color.outline.withValues(alpha: .3),
                        width: 1,
                      ),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: maxHeight),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.items.map((item) {
                            final isSelected = item == _selectedItem;
                            return Material(
                              color: isSelected
                                  ? color.primary.withValues(alpha: .05)
                                  : Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() => _selectedItem = item);
                                  widget.onItemSelected(item);
                                  removeOverlay();
                                },
                                hoverColor: color.primary.withValues(
                                  alpha: .05,
                                ),
                                highlightColor: color.primary.withValues(
                                  alpha: .05,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        widget.itemLabel(item),
                                        style:
                                            widget.itemStyle ??
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_rounded,
                                          size: 18,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
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
