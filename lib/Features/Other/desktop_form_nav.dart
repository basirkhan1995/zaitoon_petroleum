import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormNavigation extends StatelessWidget {
  final Widget child;
  const FormNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.arrowDown):
        const NextFocusIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp):
        const PreviousFocusIntent(),
      },
      child: Actions(
        actions: {
          NextFocusIntent: CallbackAction(
            onInvoke: (_) {
              FocusScope.of(context).nextFocus();
              return null;
            },
          ),
          PreviousFocusIntent: CallbackAction(
            onInvoke: (_) {
              FocusScope.of(context).previousFocus();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}
