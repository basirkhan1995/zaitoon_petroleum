import 'dart:ui';
import 'package:flutter/material.dart';

class BlurLoader extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final double blur;
  final Color overlayColor;

  const BlurLoader({
    super.key,
    required this.isLoading,
    required this.child,
    this.blur = 3.0,
    this.overlayColor = const Color(0x55FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,

        // Blur + Overlay only when loading
        if (isLoading)
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  color: overlayColor, // glass effect
                ),
              ),
            ),
          ),

        // Loader on top
        if (isLoading)
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
      ],
    );
  }
}
