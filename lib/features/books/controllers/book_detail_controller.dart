import 'dart:developer';

import 'package:get/get.dart';

import '../models/book.dart';
import '../services/book_service.dart';

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

      Get.snackbar(
        'Error',
        'Failed to load book details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
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
