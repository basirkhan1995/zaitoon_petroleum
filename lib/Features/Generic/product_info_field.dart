import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';

typedef LoadingBuilder = Widget Function(BuildContext context);
typedef ItemToString<T> = String Function(T item);
typedef OnProductSelected<T> = void Function(T? product);
typedef BlocSearchFunction<B> = void Function(B bloc, String query);
typedef BlocFetchAllFunction<B> = void Function(B bloc);
// Add these two typedefs
typedef ProductListItemBuilder<T> = Widget Function(BuildContext context, T product);
typedef ProductDetailsBuilder<T> = Widget Function(BuildContext context, T product);

class ProductSearchField<T, B extends BlocBase<S>, S> extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool enabled;
  final B? bloc;
  final BlocSearchFunction<B>? searchFunction;
  final BlocFetchAllFunction<B>? fetchAllFunction;
  final List<T> Function(S state) stateToItems;
  final bool Function(S state)? stateToLoading;
  final ItemToString<T> itemToString;
  final OnProductSelected<T>? onProductSelected;

  // Product-specific fields (using dynamic access since T is generic)
  final String? Function(T) getProductId;
  final String? Function(T) getProductName;
  final String? Function(T) getProductCode;
  final int? Function(T) getStorageId;
  final String? Function(T) getStorageName;
  final String? Function(T) getAvailable;
  final String? Function(T) getAveragePrice;
  final String? Function(T) getRecentPrice;
  final String? Function(T) getSellPrice;

  // Optional custom builders (if you need different styling)
  final ProductListItemBuilder<T>? customListItemBuilder;
  final ProductDetailsBuilder<T>? customDetailsBuilder;

  final String noResultsText;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool showClearButton;
  final bool showAllOnFocus;

  const ProductSearchField({
    super.key,
    required this.controller,
    required this.bloc,
    required this.searchFunction,
    required this.fetchAllFunction,
    required this.stateToItems,
    required this.itemToString,
    required this.onProductSelected,

    // Required product field getters
    required this.getProductId,
    required this.getProductName,
    required this.getProductCode,
    required this.getStorageId,
    required this.getStorageName,
    required this.getAvailable,
    required this.getAveragePrice,
    required this.getRecentPrice,
    required this.getSellPrice,

    // Optional custom builders
    this.customListItemBuilder,
    this.customDetailsBuilder,

    this.hintText,
    this.enabled = true,
    this.stateToLoading,
    this.noResultsText = 'No products found',
    this.width,
    this.padding,
    this.showClearButton = true,
    this.showAllOnFocus = true,
  });

  @override
  State<ProductSearchField<T, B, S>> createState() => _ProductSearchFieldState<T, B, S>();
}

class _ProductSearchFieldState<T, B extends BlocBase<S>, S> extends State<ProductSearchField<T, B, S>> {
  int _highlightedIndex = -1;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final GlobalKey _fieldKey = GlobalKey();
  List<T> _currentSuggestions = [];
  Timer? _debounce;
  late FocusNode _focusNode;
  bool _firstFocus = true;
  bool _isFocused = false;
  final FocusNode _keyboardListenerFocusNode = FocusNode(skipTraversal: true);
  T? _selectedItem;
  T? _currentHighlightedItem;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _keyboardListenerFocusNode.dispose();
    widget.controller.removeListener(_onControllerChanged);
    _debounce?.cancel();
    _removeOverlay();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted) return;

    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_focusNode.hasFocus) {
      if (widget.showAllOnFocus && _firstFocus && widget.fetchAllFunction != null) {
        widget.fetchAllFunction!(widget.bloc!);
        _firstFocus = false;
      }

      final hasText = widget.controller.text.isNotEmpty;
      if (hasText && _currentSuggestions.isNotEmpty) {
        _showOverlay(_currentSuggestions);
      }
    } else {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _refreshOverlay() {
    if (_overlayEntry != null && mounted) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _scrollToHighlightedItem() {
    if (_scrollController.hasClients && _highlightedIndex >= 0) {
      final itemHeight = 72.0;
      final scrollOffset = _highlightedIndex * itemHeight;
      _scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showOverlay(List<T> items) {
    if (items.isEmpty || widget.controller.text.isEmpty) {
      _removeOverlay();
      return;
    }

    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (renderBox == null || overlay == null || !mounted) return;

    const overlayWidth = 1000.0;
    const overlayHeight = 600.0;
    const detailsPanelWidth = 400.0;

    final centerPosition = Offset(
      (overlay.size.width - overlayWidth) / 2,
      (overlay.size.height - overlayHeight) / 2,
    );

    _overlayEntry = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Positioned(
          left: centerPosition.dx,
          top: centerPosition.dy,
          width: overlayWidth,
          height: overlayHeight,
          child: Material(
            elevation: 8,
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    // Left side - Search Results
                    Container(
                      width: overlayWidth - detailsPanelWidth,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: .2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: .05),
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).colorScheme.outline.withValues(alpha: .1),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Search Results (${items.length})',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Search results list
                          Expanded(
                            child: KeyboardListener(
                              focusNode: _keyboardListenerFocusNode,
                              onKeyEvent: (event) {},
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  final isHighlighted = index == _highlightedIndex;

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: isHighlighted
                                          ? Theme.of(context).colorScheme.primary.withValues(alpha: .1)
                                          : Colors.transparent,
                                      border: isHighlighted
                                          ? Border(
                                        left: BorderSide(
                                          color: Theme.of(context).colorScheme.primary,
                                          width: 3,
                                        ),
                                      )
                                          : null,
                                    ),
                                    child: InkWell(
                                      onTap: () => _handleItemSelection(item),
                                      onHover: (hovered) {
                                        if (hovered && mounted) {
                                          setState(() {
                                            _highlightedIndex = index;
                                            _currentHighlightedItem = item;
                                          });
                                          _refreshOverlay();
                                        }
                                      },
                                      child: widget.customListItemBuilder != null
                                          ? widget.customListItemBuilder!(context, item)
                                          : _buildDefaultListItem(item),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Keyboard navigation footer
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .5),
                              border: Border(
                                top: BorderSide(
                                  color: Theme.of(context).colorScheme.outline.withValues(alpha: .1),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildKeyHint(context, '↑↓', 'Navigate'),
                                const SizedBox(width: 16),
                                _buildKeyHint(context, '⏎', 'Select'),
                                const SizedBox(width: 16),
                                _buildKeyHint(context, 'ESC', 'Close'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right side - Details Panel
                    if (_currentHighlightedItem != null)
                      Container(
                        width: detailsPanelWidth,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_rounded,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Product Details',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Complete information',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: SingleChildScrollView(
                                child: widget.customDetailsBuilder != null
                                    ? widget.customDetailsBuilder!(context, _currentHighlightedItem as T)
                                    : _buildDefaultDetails(_currentHighlightedItem as T),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // Default list item builder
  Widget _buildDefaultListItem(T product) {
    return ListTile(
      visualDensity: VisualDensity(vertical: -4),
      title: Text(widget.getProductName(product) ?? ''),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.getProductCode(product) ?? 'N/A',
           style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline)
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(widget.getAvailable(product) ?? '0',style: Theme.of(context).textTheme.titleMedium),
          Text(widget.getStorageName(product) ?? "",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }

  // Default details builder
  Widget _buildDefaultDetails(T product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailCard('Basic Information', [
          _buildDetailItem(Icons.tag, 'ID', widget.getProductId(product)?.toString() ?? 'N/A'),
          _buildDetailItem(Icons.label, 'Name', widget.getProductName(product) ?? 'N/A'),
          _buildDetailItem(Icons.qr_code, 'Code', widget.getProductCode(product) ?? 'N/A'),
        ]),
        const SizedBox(height: 16),

        _buildDetailCard('Storage Information', [
          _buildDetailItem(Icons.inventory, 'Storage', widget.getStorageName(product) ?? 'N/A'),
          _buildDetailItem(Icons.numbers, 'Storage ID', widget.getStorageId(product)?.toString() ?? 'N/A'),
          _buildDetailItem(Icons.shopping_bag, 'Available', widget.getAvailable(product) ?? '0'),
        ]),
        const SizedBox(height: 16),

        _buildDetailCard('Pricing Information', [
          _buildDetailItem(Icons.trending_up, 'Average Price', widget.getAveragePrice(product).toAmount()),
          _buildDetailItem(Icons.history, 'Recent Price', widget.getRecentPrice(product).toAmount()),
          _buildDetailItem(Icons.attach_money, 'Sell Price', widget.getSellPrice(product).toAmount()),
        ]),
      ],
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withValues(alpha: .2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyHint(BuildContext context, String key, String action) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            key,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          action,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _handleItemSelection(T item) {
    widget.controller.text = widget.itemToString(item);

    setState(() {
      _selectedItem = item;
      _currentHighlightedItem = item;
    });

    widget.onProductSelected?.call(item);
    _removeOverlay();
    _focusNode.unfocus();
  }

  Widget? _buildSuffixIcon() {
    final isBlocLoading = widget.bloc != null &&
        widget.stateToLoading != null &&
        widget.stateToLoading!(widget.bloc!.state);

    final shouldShowLoading = isBlocLoading && _isFocused && widget.controller.text.isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (shouldShowLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        if (widget.showClearButton && !shouldShowLoading && widget.controller.text.isNotEmpty)
          IconButton(
            constraints: const BoxConstraints(),
            splashRadius: 2,
            icon: Icon(Icons.clear, size: 16, color: Theme.of(context).colorScheme.secondary),
            onPressed: () {
              widget.controller.clear();
              if (mounted) {
                setState(() {
                  _currentSuggestions = [];
                  _firstFocus = true;
                  _selectedItem = null;
                  _currentHighlightedItem = null;
                  _highlightedIndex = -1;
                });
              }
              widget.onProductSelected?.call(null);
              _removeOverlay();
            },
          ),
      ],
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (_overlayEntry == null) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_currentSuggestions.isNotEmpty && mounted) {
        setState(() {
          _highlightedIndex = (_highlightedIndex + 1) % _currentSuggestions.length;
          _currentHighlightedItem = _currentSuggestions[_highlightedIndex];
        });
        _scrollToHighlightedItem();
        _refreshOverlay();
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_currentSuggestions.isNotEmpty && mounted) {
        setState(() {
          _highlightedIndex = (_highlightedIndex - 1 + _currentSuggestions.length) %
              _currentSuggestions.length;
          _currentHighlightedItem = _currentSuggestions[_highlightedIndex];
        });
        _scrollToHighlightedItem();
        _refreshOverlay();
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_highlightedIndex >= 0 &&
          _highlightedIndex < _currentSuggestions.length) {
        final selectedItem = _currentSuggestions[_highlightedIndex];
        _handleItemSelection(selectedItem);
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _removeOverlay();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: widget.width ?? double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CompositedTransformTarget(
              link: _layerLink,
              child: Focus(
                focusNode: _keyboardListenerFocusNode,
                onKeyEvent: _handleKeyEvent,
                child: TextFormField(
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  key: _fieldKey,
                  controller: widget.controller,
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        _highlightedIndex = -1;
                      });
                    }

                    if (_selectedItem != null) {
                      setState(() {
                        _selectedItem = null;
                      });
                      widget.onProductSelected?.call(null);
                    }

                    if (_debounce?.isActive ?? false) _debounce!.cancel();

                    _debounce = Timer(const Duration(milliseconds: 300), () {
                      if (!mounted) return;

                      if (value.isNotEmpty && widget.searchFunction != null) {
                        widget.searchFunction!(widget.bloc!, value);
                      } else if (value.isEmpty) {
                        setState(() {
                          _currentSuggestions = [];
                        });
                        _removeOverlay();
                      }
                    });
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIconConstraints: const BoxConstraints(),
                    suffixIcon: _buildSuffixIcon(),
                    isDense: true,
                    hintText: widget.hintText,
                  ),
                ),
              ),
            ),

            if (widget.bloc != null)
              BlocListener<B, S>(
                bloc: widget.bloc,
                listener: (context, state) {
                  final items = widget.stateToItems(state);
                  if (mounted) {
                    setState(() {
                      _currentSuggestions = items;
                      if (_highlightedIndex >= items.length) {
                        _highlightedIndex = items.isEmpty ? -1 : 0;
                      }
                      if (items.isNotEmpty && _highlightedIndex >= 0) {
                        _currentHighlightedItem = items[_highlightedIndex];
                      } else if (items.isNotEmpty) {
                        _currentHighlightedItem = items.first;
                      }
                    });
                  }

                  final hasText = widget.controller.text.isNotEmpty;
                  if (_focusNode.hasFocus && hasText && items.isNotEmpty) {
                    _showOverlay(items);
                  } else {
                    _removeOverlay();
                  }
                },
                child: const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}