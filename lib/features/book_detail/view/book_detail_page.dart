import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/core.dart';
import '../../../shared/models/book.dart';
import '../../../shared/shared.dart';
import '../../favorate/controller/favorite_controller.dart';
import '../book_detail.dart';

class BookDetailPage extends StatelessWidget {
  const BookDetailPage({super.key, required this.bookId});
  final String bookId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookDetailController(), tag: bookId);

    controller.initialize(bookId);

    return Scaffold(body: Obx(() => _buildBody(context, controller)));
  }

  Widget _buildBody(BuildContext context, BookDetailController controller) {
    if (controller.isLoading.value) return const BookDetailSkeleton();

    if (controller.error.value.isNotEmpty) {
      return _buildErrorState(controller);
    }

    final book = controller.book.value;
    if (book == null) return _buildNotFoundState();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        BookDetailAppBar(
          title: book.title,
          hasCover: book.hasCover,
          coverUrl: book.coverUrl,
          onShare: () => _shareBook(book),
        ),
        SliverToBoxAdapter(child: _buildBookContent(context, book)),
      ],
    );
  }

  Widget _buildBookContent(BuildContext context, Book book) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Drag indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _buildBookInfo(context, book),
          const SizedBox(height: 20),
          _buildActionButtons(context, book),
          const SizedBox(height: 24),
          _buildBookDetails(context, book),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBookInfo(BuildContext context, Book book) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with improved typography
          Text(
            book.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.2,
              letterSpacing: -0.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // Author with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Author',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book.displayAuthor,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Enhanced info badges
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (book.firstPublishYear != null)
                _buildModernInfoBadge(
                  context,
                  icon: Icons.calendar_today_rounded,
                  label: book.publishYear,
                  color: theme.colorScheme.primary,
                ),
              if (book.hasRating)
                _buildModernInfoBadge(
                  context,
                  icon: Icons.star_rounded,
                  label: book.formattedRating,
                  color: Colors.amber,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Book book) {
    final theme = Theme.of(context);
    final favController = Get.find<FavoriteController>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Primary action button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: book.hasPdf ? () => _openPdf(book) : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: book.hasPdf ? 3 : 0,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
              icon: Icon(
                book.hasPdf ? Icons.picture_as_pdf_rounded : Icons.lock_rounded,
                size: 22,
              ),
              label: Text(
                book.hasPdf ? 'Read PDF' : 'PDF Unavailable',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Secondary action buttons row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareBook(book),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: const Text(
                    'Share',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => favController.toggleFavorite(book),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: theme.colorScheme.error, width: 1.5),
                ),
                child: Obx(
                  () => Icon(
                    favController.isFavorite(book)
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookDetails(BuildContext context, Book book) {
    return Column(
      children: [
        if (book.description != null && book.description!.isNotEmpty)
          _buildDescriptionSection(context, book),
        if (book.subjects.isNotEmpty) _buildSubjectsSection(context, book),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context, Book book) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.description_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Description',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: MarkdownBody(
              data: book.description ?? 'No description available.',
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
                h1: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                h2: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                a: TextStyle(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
              onTapLink: (text, href, title) async {
                if (href != null) {
                  await launchUrl(Uri.parse(href));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsSection(BuildContext context, Book book) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.category_rounded,
                  size: 20,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Categories',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: book.subjects
                .map(
                  (subject) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      subject,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BookDetailController controller) => AppStateMessage(
    icon: Icons.error_outline_rounded,
    iconColor: Colors.red,
    title: 'Failed to load book details',
    message: controller.error.value,
    primaryLabel: 'Retry',
    onPrimary: controller.retry,
  );

  Widget _buildNotFoundState() => const AppStateMessage(
    icon: Icons.search_off_rounded,
    title: 'Book not found',
    message: 'The requested book could not be found.',
  );

  void _openPdf(Book book) {
    if (book.hasPdf) {
      AppNavigation.toPdfViewer(pdfUrl: book.pdfUrl!, title: book.title);
    }
  }

  Future<void> _shareBook(Book book) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text:
              'Check out "${book.title}" by ${book.displayAuthor}\n\nRead it here: ${book.workId}',
        ),
      );
    } catch (e) {
      log('Error sharing book: $e');
    }
  }
}
