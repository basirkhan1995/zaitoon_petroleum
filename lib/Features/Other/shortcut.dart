import 'package:flutter/material.dart';

class GlobalShortcuts extends StatelessWidget {
  final Map<ShortcutActivator, VoidCallback> shortcuts;
  final Widget child;

  const GlobalShortcuts({
    super.key,
    required this.shortcuts,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final shortcutMap = <ShortcutActivator, Intent>{};
    final actionMap = <Type, Action<Intent>>{};

    for (final entry in shortcuts.entries) {
      final intent = _GlobalIntent(entry.value);
      shortcutMap[entry.key] = intent;
      actionMap[_GlobalIntent] = CallbackAction<_GlobalIntent>(
        onInvoke: (intent) {
          intent.callback();
          return null;
        },
      );
    }

    return Shortcuts(
      shortcuts: shortcutMap,
      child: Actions(
        actions: actionMap,
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}

class _GlobalIntent extends Intent {
  final VoidCallback callback;
  const _GlobalIntent(this.callback);
}

/// ---------- SHORTCUT BUTTON WITH VISUAL FEEDBACK ----------
class ShortcutButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const ShortcutButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  State<ShortcutButton> createState() => _ShortcutButtonState();
}

class _ShortcutButtonState extends State<ShortcutButton> {
  bool _isPressed = false;

  void trigger() {
    widget.onPressed();
    setState(() => _isPressed = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: _isPressed ? Colors.blue.withValues(alpha: .1) : Colors.transparent,
        boxShadow: _isPressed
            ? [
          BoxShadow(
            color: Colors.blue.withValues(alpha: .25),
            blurRadius: 8,
          )
        ]
            : [],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: trigger,
        child: widget.child,
      ),
    );
  }
}