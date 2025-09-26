import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/app_state_message.dart';
import '../controllers/book_controller.dart';
import '../widgets/book_card.dart';
import '../widgets/book_shimmer.dart';

class BookListPage extends StatelessWidget {
  const BookListPage({super.key, this.isSearchMode = false});
  final bool isSearchMode;

  BookController get controller => Get.find<BookController>();

  void _onSearchChanged(String query) {
    if (query.trim().isNotEmpty) {
      controller.searchBooks(query.trim());
    }
  }

  void _onBookTapped(String bookId) {
    HapticFeedback.selectionClick();
    AppNavigation.toBookDetail(bookId);
  }

  Future<void> _onRefresh() async {
    controller.books.clear();
    if (isSearchMode) {
      final query = Get.arguments?['query'] as String?;
      if (query?.isNotEmpty == true) {
        await controller.searchBooks(query!);
        return;
      }
    }
    await controller.fetchBooksDefault();
  }

  @override
  Widget build(BuildContext context) {
    final bookController = Get.put(BookController());
    final searchController = TextEditingController();
    final scrollController = ScrollController();

    // Initial data loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isSearchMode) {
        bookController.fetchBooksDefault();
      } else {
        final query = Get.arguments?['query'] as String?;
        if (query?.isNotEmpty == true) {
          searchController.text = query!;
          bookController.searchBooks(query);
        }
      }
    });

    // Infinite scroll listener
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        bookController.loadMoreBooks();
      }
    });

    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: scrollController,
          // physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(child: _buildSearchBar(searchController)),
            Obx(() => _buildSliverBookList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 90,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          isSearchMode ? 'Search Books' : 'Discover Books',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 8),
        background: isSearchMode
            ? null
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.1),
                      theme.scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSearchBar(TextEditingController searchController) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search for books...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    controller.books.clear();
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: _onSearchChanged,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildSliverBookList() {
    if (controller.isLoading.value && controller.books.isEmpty) {
      return const SliverFillRemaining(child: BookListSkeleton(itemCount: 8));
    }
    if (controller.error.value.isNotEmpty && controller.books.isEmpty) {
      return SliverFillRemaining(
        child: AppStateMessage(
          icon: Icons.error_outline,
          iconColor: Colors.red,
          title: 'Something went wrong',
          message: controller.error.value,
          primaryLabel: 'Retry',
          onPrimary: controller.retryFetching,
        ),
      );
    }
    if (controller.books.isEmpty) {
      final searchMode =
          isSearchMode || controller.currentQuery.value.isNotEmpty;
      return SliverFillRemaining(
        child: AppStateMessage(
          icon: searchMode ? Icons.search_off : Icons.library_books,
          title: searchMode ? 'No books found' : 'Welcome to Open Library',
          message: searchMode
              ? 'Try a different search term'
              : 'Search for books to get started',
          primaryLabel: searchMode ? null : 'Start Searching',
          onPrimary: searchMode ? null : () => AppNavigation.toSearch(),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == controller.books.length) {
              return _buildBottomLoader();
            }
            final book = controller.books[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BookCard(
                book: book,
                onTap: () => _onBookTapped(book.workId),
                index: index,
              ),
            );
          },
          childCount:
              controller.books.length + (controller.hasMore.value ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildBottomLoader() {
    if (!controller.isLoadingMore.value) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading more books...',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
