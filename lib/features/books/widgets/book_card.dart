import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../shared/models/book.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.index,
  });

  final Book book;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return VisibilityDetector(
      key: Key('book-card-${book.workId}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && book.hasCover) {
          // Precache only once (prevent repeated calls)
          precacheImage(CachedNetworkImageProvider(book.coverUrl!), context);
        }
      },
      child:
          Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                color: theme.colorScheme.surfaceContainerLowest,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BookCover(book: book),
                        const SizedBox(width: 16),
                        Expanded(child: _BookInfo(book: book)),
                      ],
                    ),
                  ),
                ),
              )
              .animate(delay: Duration(milliseconds: index * 50))
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOut),
    );
  }
}

/// --------------------
/// 📚 Sub-widgets
/// --------------------

class _BookCover extends StatelessWidget {
  const _BookCover({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Hero(
      tag: 'book-cover-${book.workId}',
      child: Container(
        width: 80,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: book.hasCover
              ? CachedNetworkImage(
                  imageUrl: book.coverUrl!,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 300),
                  fadeOutDuration: const Duration(milliseconds: 100),
                  placeholder: (_, _) => _CoverPlaceholder(theme: theme),
                  errorWidget: (_, _, _) => _CoverPlaceholder(theme: theme),
                  memCacheWidth: 160,
                  memCacheHeight: 240,
                )
              : _CoverPlaceholder(theme: theme),
        ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.surfaceContainer,
      child: Center(
        child: Icon(
          Icons.book,
          size: 50,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _BookInfo extends StatelessWidget {
  const _BookInfo({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        if (book.authorName != null) ...[
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  book.displayAuthor,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (book.hasRating) _RatingBadge(rating: book.rating),
            if (book.firstPublishYear != null)
              _YearBadge(year: book.publishYear),
          ],
        ),
        if (_shouldShowDescription(book)) ...[
          const SizedBox(height: 8),
          Text(
            book.shortDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  bool _shouldShowDescription(Book book) {
    return book.shortDescription.isNotEmpty &&
        book.shortDescription != 'No description available.';
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});
  final Rating? rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (rating == null || !rating!.hasValidRating) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 6),
          Text(
            rating!.formatted,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _YearBadge extends StatelessWidget {
  const _YearBadge({required this.year});
  final String year;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 12,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            year,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
