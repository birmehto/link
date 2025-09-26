import 'package:flutter/material.dart';

class BookDetailAppBar extends StatelessWidget {
  const BookDetailAppBar({
    super.key,
    required this.title,
    required this.hasCover,
    required this.coverUrl,
    required this.onShare,
  });
  final String title;
  final String? coverUrl;
  final bool hasCover;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 380,
      floating: true,
      collapsedHeight: kToolbarHeight,
      pinned: true,
      stretch: true,
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          return FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
              StretchMode.fadeTitle,
            ],

            background: _CoverBackground(
              hasCover: hasCover,
              coverUrl: coverUrl,
            ),
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: onShare,
          icon: const Icon(Icons.share_rounded, size: 18),
          tooltip: 'Share Book',
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class _CoverBackground extends StatelessWidget {
  const _CoverBackground({required this.coverUrl, required this.hasCover});
  final String? coverUrl;
  final bool hasCover;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.primaryColor.withValues(alpha: 0.2),
            theme.colorScheme.secondary.withValues(alpha: 0.6),
            Colors.black.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: hasCover
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  coverUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : const _CoverPlaceholder(),
                  errorBuilder: (context, error, stack) =>
                      const _CoverPlaceholder(),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.4, 0.7, 1],
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const _CoverPlaceholder(),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade400,
            Colors.grey.shade600,
            Colors.grey.shade700,
          ],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Icon(
            Icons.auto_stories_rounded,
            size: 48,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
