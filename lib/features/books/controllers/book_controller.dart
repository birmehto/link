import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';

import 'package:link/features/books/models/book.dart';
import 'package:link/features/books/services/book_service.dart';

class BookController extends GetxController {
  final BookService _service = Get.find<BookService>();

  // State variables
  final books = <Book>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final error = ''.obs;
  final hasMore = true.obs;
  final currentQuery = ''.obs;

  // Pagination
  int _currentPage = 1;
  static const int _itemsPerPage = 20;

  // Debouncer for search
  Timer? _debounce;

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> searchBooks(String query, {bool loadMore = false}) async {
    if (query.isEmpty) {
      return;
    }

    // Cancel any pending debounce
    _debounce?.cancel();

    // Set up debounce for search
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        if (!loadMore) {
          _currentPage = 1;
          isLoading.value = true;
          hasMore.value = true;
        } else {
          isLoadingMore.value = true;
        }

        error.value = '';
        currentQuery.value = query;

        log('Searching for: $query (Page: $_currentPage)');

        final result = await _service.searchBooks(query, page: _currentPage);

        if (!loadMore) {
          books.clear();
        }

        if (result.isNotEmpty) {
          books.addAll(result);
          hasMore.value = result.length >= _itemsPerPage;
          _currentPage++;
        } else {
          hasMore.value = false;
        }
      } catch (e, stackTrace) {
        log('Error searching books', error: e, stackTrace: stackTrace);
        error.value = e.toString();

        // Show error message if it's not a load more operation
        if (!loadMore) {
          Get.snackbar(
            'Error',
            'Failed to load books: ${e.toString()}',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } finally {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    });
  }

  Future<void> loadMoreBooks() async {
    if (isLoadingMore.value || !hasMore.value || currentQuery.value.isEmpty) {
      return;
    }
    await searchBooks(currentQuery.value, loadMore: true);
  }

  Future<void> refreshBooks() async {
    if (currentQuery.value.isNotEmpty) {
      await searchBooks(currentQuery.value);
    } else {
      await fetchBooksDefault();
    }
  }

  Future<void> retryFetching() async {
    if (currentQuery.value.isNotEmpty) {
      await searchBooks(currentQuery.value);
    } else {
      await fetchBooksDefault();
    }
  }

  Future<void> fetchBooksDefault() async {
    await searchBooks('popular'); // Default search query
  }

  /// Fetch book details by ID
  Future<Book?> getBookDetails(String workId) async {
    try {
      return await _service.getBookDetails(workId);
    } catch (e, stackTrace) {
      log('Error fetching book details', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
