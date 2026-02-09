import 'package:flutter/material.dart';

class _OverlayContent extends StatelessWidget {
  final String? title;
  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback onDismiss;
  final int? durationInSeconds;
  final bool showProgressBar;

  const _OverlayContent({
    this.title,
    required this.message,
    required this.color,
    required this.icon,
    required this.onDismiss,
    this.durationInSeconds,
    this.showProgressBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return _ToastContainer(
      color: color,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Icon with subtle background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: .2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.surface,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                      ),
                    if (title != null) const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: .95),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Dismiss button
              GestureDetector(
                onTap: onDismiss,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'DISMISS',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: .8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Progress bar for auto-dismiss
          if (showProgressBar && durationInSeconds != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: _ProgressIndicator(
                durationInSeconds: durationInSeconds!,
                color: Theme.of(context).colorScheme.surface.withValues(alpha: .3),
                backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: .1),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToastContainer extends StatelessWidget {
  final Widget child;
  final Color color;

  const _ToastContainer({
    required this.child,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(5),
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .15),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatefulWidget {
  final int durationInSeconds;
  final Color color;
  final Color backgroundColor;

  const _ProgressIndicator({
    required this.durationInSeconds,
    required this.color,
    required this.backgroundColor,
  });

  @override
  State<_ProgressIndicator> createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<_ProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: widget.durationInSeconds),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: 3,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 1.0 - _controller.value,
            child: Container(
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Usage example - Toast Manager class
class ToastManager {
  static void show({
    required BuildContext context,
    String? title,
    required String message,
    required ToastType type,
    int durationInSeconds = 4,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 0,
        right: 0,
        child: _ToastContentWrapper(
          title: title,
          message: message,
          type: type,
          durationInSeconds: durationInSeconds,
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: durationInSeconds), () {
      overlayEntry.remove();
    });
  }
}

enum ToastType {
  success,
  error,
  warning,
  info,
}

extension ToastTypeExtension on ToastType {
  Color get color {
    switch (this) {
      case ToastType.success:
        return Colors.green.shade600;
      case ToastType.error:
        return Colors.red.shade600;
      case ToastType.warning:
        return Colors.orange.shade600;
      case ToastType.info:
        return Colors.blue.shade600;
    }
  }

  IconData get icon {
    switch (this) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }
}

class _ToastContentWrapper extends StatefulWidget {
  final String? title;
  final String message;
  final ToastType type;
  final int durationInSeconds;

  const _ToastContentWrapper({
    this.title,
    required this.message,
    required this.type,
    required this.durationInSeconds,
  });

  @override
  State<_ToastContentWrapper> createState() => _ToastContentWrapperState();
}

class _ToastContentWrapperState extends State<_ToastContentWrapper> {
  late bool _visible;

  @override
  void initState() {
    super.initState();
    _visible = true;
    // Auto-dismiss after duration
    Future.delayed(Duration(seconds: widget.durationInSeconds), () {
      if (mounted && _visible) {
        setState(() => _visible = false);
      }
    });
  }

  void _dismiss() {
    if (_visible) {
      setState(() => _visible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _visible ? 1.0 : 0.0,
      onEnd: () {
        if (!_visible) {
          // Find and remove from overlay
          Overlay.of(context).dispose();
        }
      },
      child: Material(
        color: Colors.transparent,
        child: _OverlayContent(
          title: widget.title,
          message: widget.message,
          color: widget.type.color,
          icon: widget.type.icon,
          onDismiss: _dismiss,
          durationInSeconds: widget.durationInSeconds,
          showProgressBar: true,
        ),
      ),
    );
  }
}