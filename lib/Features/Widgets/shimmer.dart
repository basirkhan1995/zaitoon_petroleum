import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final double borderRadius;
  final double height;

  const ShimmerLoader({
    super.key,
    required this.isLoading,
    required this.child,
    this.borderRadius = 8,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.primary.withValues(alpha: .07),
      highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: .04),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .9),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
