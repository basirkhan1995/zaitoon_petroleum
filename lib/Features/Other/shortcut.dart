import 'package:flutter/material.dart';

class ShortcutButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final ShortcutActivator keySet;

  const ShortcutButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.keySet,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        keySet: const ActivateIntent(),
      },
      child: Actions(
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              onPressed();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}
