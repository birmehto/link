import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../models/book.dart';

class OptimizedBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final int index;

  const OptimizedBookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return VisibilityDetector(
      key: Key('book-card-${book.workId}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && book.hasCover) {
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
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: _buildCardContent(context, theme),
                ),
              )
              .animate(delay: Duration(milliseconds: index * 50))
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildCardContent(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookCover(context, theme),
          const SizedBox(width: 16),
          Expanded(child: _buildBookInfo(context, theme)),
        ],
      ),
    );
  }

  Widget _buildBookCover(BuildContext context, ThemeData theme) {
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
                  placeholder: (context, url) => _buildCoverPlaceholder(theme),
                  errorWidget: (context, url, error) =>
                      _buildCoverPlaceholder(theme),
                  memCacheWidth: 160,
                  memCacheHeight: 240,
                )
              : _buildCoverPlaceholder(theme),
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder(ThemeData theme) {
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

  Widget _buildBookInfo(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context, theme),
        const SizedBox(height: 8),
        if (book.authorName != null) ...[
          _buildAuthor(context, theme),
          const SizedBox(height: 4),
        ],
        _buildMetaBadges(context, theme),
        if (_shouldShowDescription()) ...[
          const SizedBox(height: 8),
          _buildDescription(context, theme),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTitle(BuildContext context, ThemeData theme) {
    return Text(
      book.title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAuthor(BuildContext context, ThemeData theme) {
    return Row(
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
    );
  }

  Widget _buildMetaBadges(BuildContext context, ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (book.hasRating) _buildRatingBadge(theme),
        if (book.firstPublishYear != null) _buildYearBadge(theme),
      ],
    );
  }

  Widget _buildRatingBadge(ThemeData theme) {
    final rating = book.rating;
    if (rating == null || !rating.hasValidRating) {
      return const SizedBox.shrink();
    }

    // Clamp between 0 and 5
    final average = (rating.average ?? 0.0).clamp(0.0, 5.0);
    final roundedAverage = (average * 2).round() / 2.0;

    final fullStars = roundedAverage.floor();
    final hasHalfStar = (roundedAverage - fullStars) == 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Full stars
          ...List.generate(
            fullStars,
            (index) => const Icon(Icons.star, size: 14, color: Colors.amber),
          ),
          // Half star if needed
          if (hasHalfStar)
            const Icon(Icons.star_half, size: 14, color: Colors.amber),
          // Empty stars
          ...List.generate(
            emptyStars,
            (index) =>
                const Icon(Icons.star_border, size: 14, color: Colors.white),
          ),

          const SizedBox(width: 6),
          // Rating text only showing the number and count
          Text(
            rating.formatted,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearBadge(ThemeData theme) {
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
            book.publishYear,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context, ThemeData theme) {
    return Text(
      book.shortDescription,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  bool _shouldShowDescription() {
    return book.shortDescription.isNotEmpty &&
        book.shortDescription != 'No description available.';
  }
}
