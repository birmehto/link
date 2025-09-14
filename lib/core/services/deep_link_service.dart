import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

/// Service for handling deep links and app navigation
class DeepLinkService extends GetxService {
  static const String tag = 'DeepLinkService';

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  Future<void> onInit() async {
    super.onInit();
    _appLinks = AppLinks();
    await _initializeDeepLinks();
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }

  /// Initialize deep link handling
  Future<void> _initializeDeepLinks() async {
    try {
      log('Initializing deep link service...');

      // Check for initial link when app is opened
      await _handleInitialLink();

      // Listen for incoming deep links when app is already running
      _linkSubscription = _appLinks.uriLinkStream.listen(
        _handleDeepLink,
        onError: (error, stackTrace) {
          log('Deep link stream error', error: error, stackTrace: stackTrace);
        },
      );

      log('Deep link service initialized successfully');
    } catch (e, stackTrace) {
      log(
        'Failed to initialize deep link service',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handle initial deep link when app is opened from closed state
  Future<void> _handleInitialLink() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        log('Initial deep link received: $initialUri');
        await _processDeepLink(initialUri);
      }
    } catch (e, stackTrace) {
      log(
        'Failed to handle initial deep link',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handle incoming deep link
  void _handleDeepLink(Uri uri) {
    log('Deep link received: $uri');
    _processDeepLink(uri);
  }

  /// Process and route deep link
  Future<void> _processDeepLink(Uri uri) async {
    try {
      log('Processing deep link: ${uri.toString()}');

      // Parse the URI and extract routing information
      final pathSegments = uri.pathSegments;

      if (pathSegments.isEmpty) {
        _navigateToHome();
        return;
      }

      switch (pathSegments.first) {
        case 'book':
        case 'books':
          await _handleBookDeepLink(pathSegments, uri.queryParameters);
          break;
        case 'search':
          await _handleSearchDeepLink(uri.queryParameters);
          break;
        case 'pdf':
          await _handlePdfDeepLink(uri.queryParameters);
          break;
        default:
          log('Unknown deep link path: ${pathSegments.first}');
          _navigateToHome();
      }
    } catch (e, stackTrace) {
      log('Failed to process deep link', error: e, stackTrace: stackTrace);
      _navigateToHome();
    }
  }

  /// Handle book-related deep links
  Future<void> _handleBookDeepLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) async {
    if (pathSegments.length >= 2) {
      final bookId = pathSegments[1];
      log('Navigating to book detail: $bookId');
      await AppNavigation.toBookDetail(bookId);
    } else {
      log('Navigating to book list');
      await AppNavigation.toHome();
    }
  }

  /// Handle search deep links
  Future<void> _handleSearchDeepLink(Map<String, String> queryParams) async {
    final query = queryParams['q'] ?? queryParams['query'];
    log('Navigating to search: $query');
    await AppNavigation.toSearch(query: query);
  }

  /// Handle PDF viewer deep links
  Future<void> _handlePdfDeepLink(Map<String, String> queryParams) async {
    final pdfUrl = queryParams['url'];
    final title = queryParams['title'];

    if (pdfUrl != null && pdfUrl.isNotEmpty) {
      log('Navigating to PDF viewer: $pdfUrl');
      await AppNavigation.toPdfViewer(pdfUrl: pdfUrl, title: title);
    } else {
      log('PDF URL not provided in deep link');
      _navigateToHome();
    }
  }

  /// Navigate to home as fallback
  void _navigateToHome() {
    log('Navigating to home (fallback)');
    AppNavigation.toHome();
  }

  /// Create a deep link for sharing
  Uri createBookLink(String bookId) {
    return Uri.parse('https://openlibrary.link/book/$bookId');
  }

  /// Create a search link for sharing
  Uri createSearchLink(String query) {
    return Uri.parse(
      'https://openlibrary.link/search?q=${Uri.encodeComponent(query)}',
    );
  }

  /// Create a PDF viewer link for sharing
  Uri createPdfLink(String pdfUrl, {String? title}) {
    final params = {'url': pdfUrl};
    if (title != null) params['title'] = title;

    return Uri.parse(
      'https://openlibrary.link/pdf',
    ).replace(queryParameters: params);
  }
}
