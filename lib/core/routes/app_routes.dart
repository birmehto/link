import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link/features/books/views/book_detail_page.dart';
import 'package:link/features/books/views/book_list_page.dart';
import 'package:link/features/home/controllers/home_controller.dart';
import 'package:link/features/home/views/home_page.dart';
import 'package:link/features/pdf_viewer/views/optimized_pdf_viewer_page.dart';

/// Application route names
class AppRoutes {
  AppRoutes._();

  // Core routes
  static const String home = '/';
  static const String splash = '/splash';

  // Book routes
  static const String books = '/books';
  static const String bookDetail = '/books/:id';
  static const String search = '/search';

  // PDF routes
  static const String pdfViewer = '/pdf-viewer';

  // Settings routes
  static const String settings = '/settings';
  static const String about = '/about';
}

/// Application pages configuration
class AppPages {
  AppPages._();

  static const Transition defaultTransition = Transition.cupertino;

  static final List<GetPage> pages = [
    // Home with bottom navigation
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      transition: defaultTransition,
      binding: HomeBinding(),
    ),

    // Books listing (same as home but separate route)
    GetPage(
      name: AppRoutes.books,
      page: () => const BookListPage(),
      transition: defaultTransition,
      binding: BooksBinding(),
    ),

    // Search page (reuses book list with search mode)
    GetPage(
      name: AppRoutes.search,
      page: () => const BookListPage(isSearchMode: true),
      transition: Transition.cupertino,
      binding: BooksBinding(),
    ),

    // Book details page
    GetPage(
      name: AppRoutes.bookDetail,
      page: () => _buildBookDetailPage(),
      transition: Transition.cupertino,
      binding: BookDetailBinding(),
    ),

    // PDF viewer page
    GetPage(
      name: AppRoutes.pdfViewer,
      page: () => _buildPdfViewerPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
      binding: PdfViewerBinding(),
    ),
  ];

  /// Build book detail page with parameter validation
  static Widget _buildBookDetailPage() {
    final bookId = Get.parameters['id'];

    if (bookId == null || bookId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Book ID not provided', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    return BookDetailPage(bookId: bookId);
  }

  /// Build PDF viewer page with argument validation
  static Widget _buildPdfViewerPage() {
    final args = Get.arguments;

    if (args == null) {
      return const Scaffold(
        body: Center(
          child: Text('PDF URL not provided', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    // Args can be either a String (URL) or Map with additional data
    if (args is String) {
      return OptimizedPdfViewerPage(pdfUrl: args);
    } else if (args is Map<String, dynamic>) {
      final pdfUrl = args['url'] as String?;
      final title = args['title'] as String?;

      if (pdfUrl == null) {
        return const Scaffold(
          body: Center(
            child: Text('Invalid PDF URL', style: TextStyle(fontSize: 16)),
          ),
        );
      }

      return OptimizedPdfViewerPage(pdfUrl: pdfUrl, title: title);
    }

    return const Scaffold(
      body: Center(
        child: Text('Invalid PDF arguments', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

/// Navigation helper methods
class AppNavigation {
  AppNavigation._();

  /// Navigate to home page
  static Future<T?>? toHome<T>() {
    return Get.offAllNamed(AppRoutes.home);
  }

  /// Navigate to book detail page
  static Future<T?>? toBookDetail<T>(String bookId) {
    return Get.toNamed(AppRoutes.bookDetail.replaceFirst(':id', bookId));
  }

  /// Navigate to search page
  static Future<T?>? toSearch<T>({String? query}) {
    return Get.toNamed(
      AppRoutes.search,
      arguments: query != null ? {'query': query} : null,
    );
  }

  /// Navigate to PDF viewer
  static Future<T?>? toPdfViewer<T>({required String pdfUrl, String? title}) {
    return Get.toNamed(
      AppRoutes.pdfViewer,
      arguments: title != null ? {'url': pdfUrl, 'title': title} : pdfUrl,
    );
  }

  /// Go back or to home if no previous route
  static void back() {
    if (Get.routing.previous.isEmpty) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.back();
    }
  }
}

// Placeholder bindings - will be implemented when we move controllers
class BooksBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => BookController());
  }
}

class BookDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => BookDetailController());
  }
}

class PdfViewerBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => PdfViewerController());
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}
