import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Duration? duration;

  const SkeletonLoader({
    super.key,
    required this.child,
    this.isLoading = false,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Improved colors for better visibility in both themes
    final baseColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
        : theme.colorScheme.surfaceContainer.withValues(alpha: 0.4);

    final highlightColor = isDark
        ? theme.colorScheme.surface.withValues(alpha: 0.4)
        : theme.colorScheme.surface.withValues(alpha: 0.8);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: duration ?? const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

/// Book list skeleton loader
class BookListSkeleton extends StatelessWidget {
  final int itemCount;

  const BookListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return BookCardSkeleton(index: index);
      },
    );
  }
}

class BookCardSkeleton extends StatelessWidget {
  final int index;

  const BookCardSkeleton({super.key, required this.index});

  Color _getSkeletonColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    // Use solid colors that contrast well with shimmer effect
    return isDark
        ? const Color(0xFF2A2A2A) // Dark gray that works with shimmer
        : const Color(0xFFE0E0E0); // Light gray that works with shimmer
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: theme.colorScheme.surfaceContainerLowest,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _skeletonBox(theme, width: 80, height: 120, borderRadius: 12),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonLine(theme, width: double.infinity, height: 20),
                    const SizedBox(height: 8),
                    _skeletonLine(theme, width: 200, height: 16),
                    const SizedBox(height: 12),
                    _skeletonLine(theme, width: 150, height: 14),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _skeletonBadge(theme, width: 60),
                        const SizedBox(width: 8),
                        _skeletonBadge(theme, width: 40),
                        const Spacer(),
                        _skeletonBadge(theme, width: 50),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, duration: 400.ms);
  }

  Widget _skeletonBox(
    ThemeData theme, {
    required double width,
    required double height,
    double borderRadius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _getSkeletonColor(theme),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  Widget _skeletonLine(
    ThemeData theme, {
    required double width,
    required double height,
  }) {
    return _skeletonBox(theme, width: width, height: height);
  }

  Widget _skeletonBadge(ThemeData theme, {required double width}) {
    return _skeletonBox(theme, width: width, height: 24, borderRadius: 12);
  }
}

/// Book detail skeleton
class BookDetailSkeleton extends StatelessWidget {
  const BookDetailSkeleton({super.key});

  Color _getSkeletonColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark
        ? theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6)
        : theme.colorScheme.surfaceContainer.withValues(alpha: 0.7);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SkeletonLoader(
      isLoading: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: _skeletonBox(
                theme,
                width: 200,
                height: 300,
                borderRadius: 16,
              ),
            ),
            const SizedBox(height: 24),
            _skeletonLine(theme, width: double.infinity, height: 28),
            const SizedBox(height: 12),
            _skeletonLine(theme, width: 250, height: 20),
            const SizedBox(height: 20),
            Row(
              children: [
                _skeletonBadge(theme, width: 80),
                const SizedBox(width: 12),
                _skeletonBadge(theme, width: 60),
                const Spacer(),
                _skeletonBadge(theme, width: 70),
              ],
            ),
            const SizedBox(height: 24),
            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _skeletonLine(
                  theme,
                  width: index == 4 ? 200 : double.infinity,
                  height: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _skeletonBox(
                    theme,
                    width: double.infinity,
                    height: 48,
                    borderRadius: 12,
                  ),
                ),
                const SizedBox(width: 12),
                _skeletonBox(theme, width: 48, height: 48, borderRadius: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeletonLine(
    ThemeData theme, {
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _getSkeletonColor(theme),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _skeletonBadge(ThemeData theme, {required double width}) {
    return Container(
      width: width,
      height: 32,
      decoration: BoxDecoration(
        color: _getSkeletonColor(theme),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _skeletonBox(
    ThemeData theme, {
    required double width,
    required double height,
    double borderRadius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _getSkeletonColor(theme),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Grid skeleton loader
class GridSkeleton extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const GridSkeleton({super.key, this.itemCount = 8, this.crossAxisCount = 2});

  Color _getSkeletonColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark
        ? theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6)
        : theme.colorScheme.surfaceContainer.withValues(alpha: 0.7);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: _getSkeletonColor(theme),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getSkeletonColor(theme),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getSkeletonColor(theme),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Loading overlay with blur effect
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    this.isLoading = false,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Improved overlay colors for better visibility
    final overlayColor =
        backgroundColor ??
        (isDark
            ? Colors.black.withValues(alpha: 0.7)
            : Colors.black.withValues(alpha: 0.4));

    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor,
            child: Center(
              child:
                  Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: isDark
                              ? Border.all(
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : Colors.black.withValues(alpha: 0.1),
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
                                backgroundColor: theme.colorScheme.outline
                                    .withValues(alpha: 0.2),
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
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .scale(begin: const Offset(0.8, 0.8), duration: 300.ms),
            ),
          ),
      ],
    );
  }
}
