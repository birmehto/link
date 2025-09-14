import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/book.dart';

class BookService extends GetxService {
  late final ApiClient _apiClient;
  final Map<String, Completer<String?>> _pdfCheckCompleters = {};

  @override
  Future<void> onInit() async {
    super.onInit();
    _apiClient = Get.find<ApiClient>();
  }

  /// Search books with pagination support
  Future<List<Book>> searchBooks(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      log('Searching books: "$query" (Page: $page, Limit: $limit)');

      // Calculate offset for OpenLibrary (0-based offset)
      final offset = (page - 1) * limit;

      // Search OpenLibrary
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.searchBooks,
        queryParameters: {
          'q': query,
          'offset': offset,
          'limit': limit,
          'fields':
              'key,title,author_name,first_publish_year,cover_i,first_sentence,subject,ratings_average,ratings_count',
        },
      );

      final docs = response['docs'] as List? ?? [];
      final books = docs.map((e) => Book.fromOpenLibraryJson(e)).toList();

      log('Found ${books.length} books for query: "$query"');
      return books;
    } catch (e, stackTrace) {
      log('Error searching books', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get book details by work ID
  Future<Book> getBookDetails(String workId) async {
    try {
      log('Fetching book details for: $workId');

      // First get the basic work info
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getWork.replaceAll('{id}', workId),
      );

      var data = response;

      // Handle redirect
      if (data['type']?['key'] == '/type/redirect' &&
          data['location'] != null) {
        final newId = data['location'].toString().split('/').last;
        log('Redirect found: $newId');
        return getBookDetails(newId);
      }

      // Get author details if available
      String? authorName;
      if (data['authors'] is List && (data['authors'] as List).isNotEmpty) {
        final authorKey = data['authors'][0]['author']['key'];
        if (authorKey != null) {
          try {
            final authorResponse = await _apiClient.get<Map<String, dynamic>>(
              '$authorKey.json',
            );
            authorName = authorResponse['name'] as String?;
          } catch (e) {
            log('Error fetching author details: $e');
          }
        }
      }

      // Get cover URL
      String? coverUrl;
      if (data['covers'] is List && (data['covers'] as List).isNotEmpty) {
        final coverId = data['covers'][0];
        if (coverId != null) {
          coverUrl = ApiConstants.getCoverUrl(
            'id',
            coverId.toString(),
            ApiConstants.largeSize,
          );
        }
      }

      // Get description
      String? description;
      if (data['description'] is String) {
        description = data['description'];
      } else if (data['description'] is Map) {
        description = data['description']['value'] ?? '';
      }

      // Get subjects
      List<String> subjects = [];
      if (data['subjects'] is List) {
        subjects = (data['subjects'] as List).cast<String>().take(5).toList();
      }

      // Check for PDF availability asynchronously
      final pdfUrlFuture = _checkPdfAvailability(workId, data['title'] ?? '');

      // Create and return Book object
      return Book(
        workId: workId,
        title: data['title'] ?? 'Unknown Title',
        authorName: authorName,
        coverUrl: coverUrl,
        description: description,
        subjects: subjects,
        firstPublishYear: data['first_publish_date'] != null
            ? int.tryParse(
                data['first_publish_date'].toString().split('-').first,
              )
            : null,
        pdfUrl: await pdfUrlFuture,
      );
    } catch (e, stackTrace) {
      log('Error fetching book details', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Check PDF availability using multiple sources
  Future<String?> _checkPdfAvailability(String workId, String title) async {
    // Use completer to avoid duplicate requests for same workId
    if (_pdfCheckCompleters.containsKey(workId)) {
      return _pdfCheckCompleters[workId]!.future;
    }

    final completer = Completer<String?>();
    _pdfCheckCompleters[workId] = completer;

    try {
      // Method 1: Check OpenLibrary editions for PDF
      final openLibraryPdf = await _checkOpenLibraryPdf(workId);
      if (openLibraryPdf != null) {
        completer.complete(openLibraryPdf);
        return openLibraryPdf;
      }

      // Method 2: Check Internet Archive
      final archivePdf = await _checkInternetArchivePdf(title);
      if (archivePdf != null) {
        completer.complete(archivePdf);
        return archivePdf;
      }

      // Method 3: Check Gutendex for public domain books
      final gutendexPdf = await _checkGutendexPdf(title);
      if (gutendexPdf != null) {
        completer.complete(gutendexPdf);
        return gutendexPdf;
      }

      completer.complete(null);
      return null;
    } catch (e) {
      log('Error checking PDF availability: $e');
      completer.complete(null);
      return null;
    } finally {
      // Clean up after a delay to avoid memory leaks
      Future.delayed(const Duration(minutes: 5), () {
        _pdfCheckCompleters.remove(workId);
      });
    }
  }

  /// Check OpenLibrary editions for PDF
  Future<String?> _checkOpenLibraryPdf(String workId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEditions.replaceAll('{id}', workId),
        queryParameters: {'limit': 10},
      );

      final entries = response['entries'] as List? ?? [];

      for (final edition in entries) {
        final ebookAccess = edition['ebook_access']?.toString().toLowerCase();
        if (ebookAccess == 'public') {
          final editionId = edition['key']?.toString().split('/').last;
          if (editionId != null) {
            final pdfUrl = await _getEditionPdfUrl(editionId);
            if (pdfUrl != null) return pdfUrl;
          }
        }
      }
      return null;
    } catch (e) {
      log('Error checking OpenLibrary editions: $e');
      return null;
    }
  }

  /// Get PDF URL from a specific edition
  Future<String?> _getEditionPdfUrl(String editionId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/books/$editionId.json',
      );

      final formats = response['formats'] as Map?;
      if (formats != null) {
        final pdfKeys = ['pdf', 'application/pdf', 'application/x-pdf'];
        for (final key in pdfKeys) {
          final url = formats[key]?.toString();
          if (url != null && url.isNotEmpty) {
            return url;
          }
        }
      }
      return null;
    } catch (e) {
      log('Error getting edition PDF: $e');
      return null;
    }
  }

  /// Check Internet Archive for PDF
  Future<String?> _checkInternetArchivePdf(String title) async {
    try {
      // Prefer text items and ensure PDF-related formats
      final response = await _apiClient.get<Map<String, dynamic>>(
        'https://archive.org/advancedsearch.php',
        queryParameters: {
          // mediatype:texts avoids audio (e.g., librivox) results
          // format filters prioritize PDF assets
          'q':
              'title:("$title") AND mediatype:texts AND (format:"Text PDF" OR format:PDF)',
          'output': 'json',
          'fl[]': 'identifier',
          'rows': '1',
          'sort[]': 'downloads desc',
        },
      );

      final docs = response['response']?['docs'] as List? ?? [];
      if (docs.isNotEmpty) {
        final identifier = docs[0]['identifier']?.toString();
        if (identifier == null || identifier.isEmpty) return null;
        // Resolve exact PDF file via metadata
        final pdfUrl = await _resolveArchivePdfFromMetadata(identifier);
        return pdfUrl;
      }
      return null;
    } catch (e) {
      log('Error checking Internet Archive: $e');
      return null;
    }
  }

  /// Resolve the exact PDF filename for an Archive.org item using metadata API
  Future<String?> _resolveArchivePdfFromMetadata(String identifier) async {
    try {
      final meta = await _apiClient.get<Map<String, dynamic>>(
        'https://archive.org/metadata/$identifier',
      );

      final files = meta['files'] as List? ?? [];
      if (files.isEmpty) return null;

      // Prefer 'Text PDF' format, then any .pdf
      Map<String, dynamic>? best;
      for (final f in files) {
        if (f is Map<String, dynamic>) {
          final name = f['name']?.toString() ?? '';
          final format = f['format']?.toString().toLowerCase() ?? '';
          if (name.toLowerCase().endsWith('.pdf')) {
            if (format.contains('text pdf')) {
              best = f;
              break;
            }
            best ??= f; // fallback first PDF encountered
          }
        }
      }

      if (best == null) return null;
      final fileName = best['name'].toString();
      return 'https://archive.org/download/$identifier/$fileName';
    } catch (e) {
      log('Error resolving Archive PDF metadata: $e');
      return null;
    }
  }

  /// Check Gutendex for public domain PDF
  Future<String?> _checkGutendexPdf(String title) async {
    try {
      const gutendexBase = 'https://gutendex.com/books';
      final response = await _apiClient.get<Map<String, dynamic>>(
        gutendexBase,
        queryParameters: {
          'search': title,
          'mime_type': 'application/pdf',
          'page_size': '1',
        },
      );

      final results = response['results'] as List? ?? [];
      if (results.isNotEmpty) {
        final book = results[0];
        final formats = book['formats'] as Map?;
        return formats?['application/pdf'] as String?;
      }
      return null;
    } catch (e) {
      log('Error checking Gutendx: $e');
      return null;
    }
  }

  /// Clear PDF check cache
  void clearPdfCache() {
    _pdfCheckCompleters.clear();
  }

  @override
  void onClose() {
    _pdfCheckCompleters.clear();
    super.onClose();
  }
}
