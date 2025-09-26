import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../shared/models/book.dart';
import '../../book_detail/book_detail.dart';
import '../../home/controllers/home_controller.dart';
import '../controller/favorite_controller.dart';

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate({required this.child, required this.height});
  final Widget child;
  final double height;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxExtent != oldDelegate.maxExtent ||
        minExtent != oldDelegate.minExtent ||
        child != oldDelegate.child;
  }
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late final FavoriteController favController;
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    favController = Get.find<FavoriteController>();
    _searchCtrl = TextEditingController(text: favController.searchQuery.value);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => favController.refreshFavorites(),
        child: Obx(() {
          if (favController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favController.favorites.isEmpty) {
            return _buildEmptyState(context);
          }

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 80,
                floating: true,
                pinned: true,
                backgroundColor: colorScheme.surface,
                elevation: 1,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'My Favorites',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  expandedTitleScale: 1.2,
                ),
              ),
              _buildSortAndViewOptions(favController, context),
              _buildFavoritesList(favController, context),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSortAndViewOptions(
    FavoriteController controller,
    BuildContext context,
  ) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
        height: 72,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: controller.setSearchQuery,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search favorites...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: (_searchCtrl.text.isNotEmpty)
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              controller.setSearchQuery('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                tooltip: 'Sort by',
                icon: const Icon(Icons.sort),
                onSelected: controller.setSortBy,
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: FavoriteController.sortByTitle,
                    child: Text('Sort by Title'),
                  ),
                  PopupMenuItem(
                    value: FavoriteController.sortByAuthor,
                    child: Text('Sort by Author'),
                  ),
                  PopupMenuItem(
                    value: FavoriteController.sortByYear,
                    child: Text('Sort by Year'),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Obx(
                  () => Icon(
                    controller.isGridView.value
                        ? Icons.view_list
                        : Icons.grid_view,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                onPressed: controller.toggleView,
                tooltip: controller.isGridView.value
                    ? 'List view'
                    : 'Grid view',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesList(
    FavoriteController controller,
    BuildContext context,
  ) {
    return Obx(() {
      if (controller.displayedFavorites.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No matches found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search or filter to find what you\'re looking for.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      }

      if (controller.isGridView.value) {
        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final book = controller.displayedFavorites[index];
              return BookTile(book: book, isGrid: true);
            }, childCount: controller.displayedFavorites.length),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final book = controller.displayedFavorites[index];
          return BookTile(book: book);
        }, childCount: controller.displayedFavorites.length),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/empty-favorites.json',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
                repeat: true,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.favorite_outline,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your Favorites List is Empty',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Looks like you haven\'t added any books to your favorites yet. Start exploring and add your favorite books to this list!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.tonal(
                onPressed: () {
                  final homeController = Get.find<HomeController>();
                  homeController.goToHome();
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Browse Books',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookTile extends StatelessWidget {
  const BookTile({super.key, required this.book, this.isGrid = false});

  final Book book;
  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    final FavoriteController favController = Get.find<FavoriteController>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (isGrid) {
      return _buildGridItem(context, favController, textTheme, colorScheme);
    }

    return _buildListItem(context, favController, textTheme, colorScheme);
  }

  Widget _buildGridItem(
    BuildContext context,
    FavoriteController controller,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.to(() => BookDetailPage(bookId: book.workId)),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image
            Expanded(flex: 3, child: _buildCoverImage(context)),
            // Book Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      book.title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book.authorName ?? 'Unknown Author',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (book.firstPublishYear != null)
                          Text(
                            '${book.firstPublishYear}',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ), // consistent opacity
                            ),
                          ),
                        const Spacer(),
                        _buildFavoriteButton(controller, colorScheme),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    FavoriteController controller,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surface,
        child: InkWell(
          onTap: () => Get.to(BookDetailPage(bookId: book.workId)),
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 120),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Image with Read Status
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 70,
                      minWidth: 70,
                    ),
                    child: _buildCoverImage(context),
                  ),
                  const SizedBox(width: 12),
                  // Book Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 48, // 2 lines of text
                          ),
                          child: Text(
                            book.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 20),
                          child: Text(
                            book.authorName ?? 'Unknown Author',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (book.firstPublishYear != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${book.firstPublishYear}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Favorite Button
                  Align(
                    alignment: Alignment.topCenter,
                    child: _buildFavoriteButton(controller, colorScheme),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    final theme = Theme.of(context);
    final cover = book.coverUrl;
    return AspectRatio(
      aspectRatio: 2 / 3, // Standard book aspect ratio
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: (cover != null && cover.isNotEmpty)
            ? Image.network(
                cover,
                width: isGrid ? double.infinity : 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: isGrid ? 40 : 32,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
              )
            : Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.menu_book_rounded,
                  size: isGrid ? 40 : 32,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFavoriteButton(
    FavoriteController controller,
    ColorScheme colorScheme,
  ) {
    return IconButton(
      onPressed: () => controller.toggleFavorite(book),
      icon: Obx(
        () => Icon(
          controller.isFavorite(book)
              ? Icons.favorite_rounded
              : Icons.favorite_outline_rounded,
          color: controller.isFavorite(book)
              ? Colors.red
              : colorScheme.onSurfaceVariant,
          size: 24,
        ),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      tooltip: controller.isFavorite(book)
          ? 'Remove from favorites'
          : 'Add to favorites',
    );
  }
}
