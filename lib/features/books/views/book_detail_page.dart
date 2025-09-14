import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:link/features/books/models/book.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/deep_link_service.dart';
import '../../../core/widgets/app_state_message.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../controllers/book_detail_controller.dart';

/// Book detail page showing detailed information about a specific book
class BookDetailPage extends StatelessWidget {
  final String bookId;

  const BookDetailPage({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      BookDetailController(),
      tag: bookId, // Use bookId as tag to allow multiple instances
    );

    // Initialize the controller with the bookId
    controller.initialize(bookId);

    return Scaffold(body: Obx(() => _buildBody(context, controller)));
  }

  Widget _buildBody(BuildContext context, BookDetailController controller) {
    if (controller.isLoading.value) {
      return _buildLoadingState();
    }

    if (controller.error.value.isNotEmpty) {
      return _buildErrorState(controller);
    }

    final book = controller.book.value;
    if (book == null) {
      return _buildNotFoundState();
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(context, book, controller),
        SliverToBoxAdapter(child: _buildBookContent(context, book)),
      ],
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    dynamic book,
    BookDetailController controller,
  ) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 320,
      collapsedHeight: kToolbarHeight,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        title: Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.2,
            shadows: const [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 8,
                color: Colors.black87,
              ),
            ],
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 80),
        background: Hero(
          tag: 'book-cover-${book.workId}',
          child: _buildCoverBackground(context, book),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () => _shareBook(book),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.share_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            tooltip: 'Share Book',
            splashRadius: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildCoverBackground(BuildContext context, dynamic book) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.3),
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: book.hasCover
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  book.coverUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildCoverPlaceholder();
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      _buildCoverPlaceholder(),
                ),
                // Gradient overlay for better text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.6, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : _buildCoverPlaceholder(),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade300, Colors.grey.shade400],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_stories_rounded,
          size: 80,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildBookContent(BuildContext context, dynamic book) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Book info section
          _buildBookInfo(context, book)
              .animate()
              .fadeIn(duration: 500.ms, delay: 150.ms)
              .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutQuart),

          // Action buttons
          _buildActionButtons(context, book)
              .animate()
              .fadeIn(duration: 500.ms, delay: 250.ms)
              .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutQuart),

          // Book details sections
          _buildBookDetails(context, book)
              .animate()
              .fadeIn(duration: 500.ms, delay: 350.ms)
              .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutQuart),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBookInfo(BuildContext context, dynamic book) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        color: theme.colorScheme.surfaceContainerLowest,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                book.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  letterSpacing: -0.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Author
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      book.displayAuthor,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.9,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Badges
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (book.firstPublishYear != null)
                    _buildInfoBadge(
                      context,
                      icon: Icons.calendar_today_rounded,
                      label: book.publishYear,
                      color: theme.colorScheme.primary,
                    ),
                  if (book.hasRating)
                    _buildInfoBadge(
                      context,
                      icon: Icons.star_rounded,
                      label: book.formattedRating,
                      color: Colors.amber,
                    ),
                  if (book.subjects.isNotEmpty)
                    _buildInfoBadge(
                      context,
                      icon: Icons.category_rounded,
                      label: '${book.subjects.length} subjects',
                      color: Colors.green,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, dynamic book) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: book.hasPdf
                  ? () {
                      HapticFeedback.mediumImpact();
                      _openPdf(book);
                    }
                  : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: book.hasPdf ? 2 : 0,
              ),
              icon: Icon(
                book.hasPdf ? Icons.picture_as_pdf_rounded : Icons.lock_rounded,
                size: 20,
              ),
              label: Text(
                book.hasPdf ? 'Read PDF' : 'PDF Unavailable',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                _shareBook(book);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text(
                'Share',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookDetails(BuildContext context, dynamic book) {
    return Column(
      children: [
        const SizedBox(height: 24),

        // Description
        if (book.description != null && book.description!.isNotEmpty)
          _buildDescriptionSection(context, book),

        // Subjects
        if (book.subjects.isNotEmpty) _buildSubjectsSection(context, book),

        // Additional metadata
        _buildMetadataSection(context, book),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context, dynamic book) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_rounded,
                size: 24,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Description',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Card(
            elevation: 1,
            shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            color: theme.colorScheme.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                book.description!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSubjectsSection(BuildContext context, dynamic book) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.category_rounded,
                size: 24,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Subjects',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: book.subjects.map<Widget>((subject) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  subject,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(BuildContext context, Book book) {
    final theme = Theme.of(context);
    final metadata = <String, dynamic>{};

    // Only add properties that exist on the Book model
    try {
      metadata['Work ID'] = book.workId;
    } catch (e) {
      log('Somthing Wrong:$e');
    }

    // Add other available properties safely
    try {
      if (book.firstPublishYear != null) {
        metadata['First Published'] = book.firstPublishYear.toString();
      }
    } catch (e) {
      log('Somthing Wrong:$e');
    }

    try {
      if (book.subjects.isNotEmpty) {
        metadata['Subject Count'] = '${book.subjects.length} topics';
      }
    } catch (e) {
       log('Somthing Wrong:$e');
    }

    if (metadata.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_rounded,
                size: 24,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Card(
            elevation: 1,
            shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            color: theme.colorScheme.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: metadata.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            '${entry.key}:',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const BookDetailSkeleton();
  }

  Widget _buildErrorState(BookDetailController controller) {
    return AppStateMessage(
      icon: Icons.error_outline_rounded,
      iconColor: Colors.red,
      title: 'Failed to load book details',
      message: controller.error.value,
      primaryLabel: 'Retry',
      onPrimary: controller.retry,
    );
  }

  Widget _buildNotFoundState() {
    return const AppStateMessage(
      icon: Icons.search_off_rounded,
      title: 'Book not found',
      message: 'The requested book could not be found.',
    );
  }

  void _openPdf(dynamic book) {
    if (book.hasPdf) {
      AppNavigation.toPdfViewer(pdfUrl: book.pdfUrl!, title: book.title);
    }
  }

  void _shareBook(dynamic book) async {
    try {
      final deepLinkService = Get.find<DeepLinkService>();
      final bookLink = deepLinkService.createBookLink(book.workId);

      await SharePlus.instance.share(
        ShareParams(
          text:
              'Check out "${book.title}" by ${book.displayAuthor}\n\n'
              'Read it here: $bookLink',
        ),
      );
    } catch (e) {
      // Handle share error gracefully
      Get.snackbar(
        'Share Failed',
        'Unable to share this book at the moment.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }
}
