import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// ---------------- Skeleton Loader ----------------
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    required this.child,
    this.isLoading = false,
    this.duration,
    this.borderRadius,
  });

  final Widget child;
  final bool isLoading;
  final Duration? duration;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Stronger contrast colors
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: duration ?? const Duration(milliseconds: 1200),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: child,
      ),
    );
  }
}

/// ---------------- Skeleton Helpers ----------------
Color skeletonColor(BuildContext context) {
  final theme = Theme.of(context);
  return theme.brightness == Brightness.dark
      ? Colors.grey[800]!
      : Colors.grey[300]!;
}

Widget skeletonBox({
  required double width,
  required double height,
  double radius = 4,
  required Color color,
}) => Container(
  width: width,
  height: height,
  decoration: BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
  ),
);

Widget skeletonLine({
  required double width,
  required double height,
  required Color color,
}) => skeletonBox(width: width, height: height, color: color);

Widget skeletonBadge({required double width, required Color color}) =>
    skeletonBox(width: width, height: 32, radius: 16, color: color);


/// ---------------- Grid Skeleton ----------------
class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key, this.itemCount = 8, this.crossAxisCount = 2});
  final int itemCount;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    final color = skeletonColor(context);

    return SkeletonLoader(
      isLoading: true,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: itemCount,
        itemBuilder: (_, _) => _gridItem(color),
      ),
    );
  }

  Widget _gridItem(Color color) => Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 12),
        Container(
          width: 100,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    ),
  );
}

/// ---------------- Loading Overlay ----------------
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.child,
    this.isLoading = false,
    this.message,
    this.backgroundColor,
  });

  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    final theme = Theme.of(context);
    final overlayColor =
        backgroundColor ??
        (theme.brightness == Brightness.dark
            ? Colors.black.withValues(alpha:0.7)
            : Colors.black.withValues(alpha:0.4));

    return Stack(
      children: [
        child,
        Container(
          color: overlayColor,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:
                      theme.brightness == Brightness.dark ? 0.3 : 0.1,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.outline.withValues(alpha:
                        0.2,
                      ),
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
