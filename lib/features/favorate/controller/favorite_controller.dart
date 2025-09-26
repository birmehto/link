import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../shared/models/book.dart';

typedef SortBy = String;

extension on Book {
  bool matchesQuery(String query) {
    final searchQuery = query.toLowerCase();
    return title.toLowerCase().contains(searchQuery) ||
        (authorName?.toLowerCase().contains(searchQuery) ?? false);
  }
}

class FavoriteController extends GetxController {
  static const _boxName = 'favoritesBox';
  static const _readBoxName = 'read_books';
  static const _readKey = 'read';
  static const sortByTitle = 'Title';
  static const sortByAuthor = 'Author';
  static const sortByYear = 'Year';

  final RxList<Book> favorites = <Book>[].obs;
  final RxList<Book> displayedFavorites = <Book>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString sortBy = sortByTitle.obs;
  final RxBool isGridView = false.obs;
  final RxBool isLoading = true.obs;
  final RxSet<String> readBooks = <String>{}.obs;

  late Box<String> _box;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _initFavorites();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> _initFavorites() async {
    try {
      isLoading.value = true;
      _box = await Hive.openBox<String>(_boxName);
      final saved = _box.values
          .map((s) => Book.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
      favorites.assignAll(saved);
      _loadReadStatus();
      _filterAndSort();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load favorites');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadReadStatus() async {
    final Box<List> readBox = await Hive.openBox<List>(_readBoxName);
    readBooks.addAll(
      Set<String>.from(readBox.get(_readKey, defaultValue: const <String>[]) ?? const <String>[]),
    );
  }

  Future<void> _saveReadStatus() async {
    final Box<List> readBox = await Hive.openBox<List>(_readBoxName);
    await readBox.put(_readKey, readBooks.toList());
  }

  void _filterAndSort() {
    final filtered = favorites
        .where((book) => book.matchesQuery(searchQuery.value))
        .toList();

    filtered.sort((a, b) {
      switch (sortBy.value) {
        case sortByAuthor:
          return (a.authorName ?? '').compareTo(b.authorName ?? '');
        case sortByYear:
          return (b.firstPublishYear ?? 0).compareTo(a.firstPublishYear ?? 0);
        case sortByTitle:
        default:
          return a.title.compareTo(b.title);
      }
    });

    displayedFavorites.assignAll(filtered);
  }

  void setSearchQuery(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = query;
      _filterAndSort();
    });
  }

  void setSortBy(String sortValue) {
    sortBy.value = sortValue;
    _filterAndSort();
  }

  void toggleView() {
    isGridView.toggle();
  }

  bool isFavorite(Book book) {
    return favorites.any((b) => b.workId == book.workId);
  }

  bool isRead(Book book) {
    return readBooks.contains(book.workId);
  }

  void toggleReadStatus(Book book) {
    if (isRead(book)) {
      readBooks.remove(book.workId);
    } else {
      readBooks.add(book.workId);
    }
    _saveReadStatus();
  }

  Future<void> toggleFavorite(Book book, {bool showSnackbar = true}) async {
    try {
      if (isFavorite(book)) {
        final shouldRemove = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Remove from Favorites'),
            content: const Text(
              'Are you sure you want to remove this book from your favorites?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),

                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text(
                  'REMOVE',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (shouldRemove != true) return;

        favorites.removeWhere((b) => b.workId == book.workId);
        await _box.delete(book.workId);
        if (showSnackbar) {
          Get.snackbar(
            'Removed from Favorites',
            '${book.title} has been removed from your favorites',
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        favorites.add(book);
        await _box.put(book.workId, jsonEncode(book.toJson()));
      }
      _filterAndSort();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update favorites');
    }
  }

  Future<void> refreshFavorites() async {
    await _initFavorites();
  }
}
