import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/models/book.dart';
import '../../../shared/widgets/snack_bar.dart';
import '../../books/services/book_service.dart';

class BookDetailController extends GetxController {
  final BookService _service = Get.find<BookService>();

  // State variables
  final book = Rxn<Book>();
  final isLoading = false.obs;
  final error = ''.obs;

  String? _bookId;

  void initialize(String bookId) {
    _bookId = bookId;
    loadBookDetails(bookId);
  }

  Future<void> loadBookDetails(String bookId) async {
    try {
      isLoading.value = true;
      error.value = '';
      log('Loading book details for: $bookId');

      final bookData = await _service.getBookDetails(bookId);
      book.value = bookData;
    } catch (e, stackTrace) {
      log('Error loading book details', error: e, stackTrace: stackTrace);
      error.value = e.toString();

      CommonSnackbar.show(
        Get.context!,
        message: 'Failed to load book details: ${e.toString()}',
        icon: Icons.error_outline,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        textColor: Get.theme.colorScheme.onErrorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void shareBook() {
    final currentBook = book.value;
    if (currentBook != null) {
      // TODO: Implement share functionality
      log('Sharing book: ${currentBook.title}');
    }
  }

  void openPdf() {
    final currentBook = book.value;
    if (currentBook != null && currentBook.hasPdf) {
      // TODO: Navigate to PDF viewer
      log('Opening PDF for: ${currentBook.title}');
    }
  }

  void retry() {
    if (_bookId != null) {
      loadBookDetails(_bookId!);
    }
  }
}
