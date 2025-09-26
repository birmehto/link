import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_contants.dart';
import '../../../shared/models/book.dart';
import '../../../shared/widgets/snack_bar.dart';
import '../services/book_service.dart';

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

    // 👉 Reset immediately when new search starts
    if (!loadMore) {
      _currentPage = 1;
      books.clear(); // clear instantly
      isLoading.value = true;
      hasMore.value = true;
      error.value = '';
      currentQuery.value = query;
    }

    // Debounce to avoid spamming API
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        if (loadMore) {
          isLoadingMore.value = true;
        }

        log('Searching for: $query (Page: $_currentPage)');

        final result = await _service.searchBooks(query, page: _currentPage);

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

        if (!loadMore) {
          CommonSnackbar.show(
            Get.context!,
            message: 'Failed to load books: ${e.toString()}',
            icon: Icons.error_outline,
            backgroundColor: Get.theme.colorScheme.errorContainer,
            textColor: Get.theme.colorScheme.onErrorContainer,
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
    final randomIndex =
        DateTime.now().millisecondsSinceEpoch % randomBookKeywords.length;
    final randomKeyword = randomBookKeywords[randomIndex];
    await searchBooks(randomKeyword);
  }

  Future<Book?> getBookDetails(String workId) async {
    try {
      return await _service.getBookDetails(workId);
    } catch (e, stackTrace) {
      log('Error fetching book details', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
