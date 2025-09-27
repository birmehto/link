import 'dart:typed_data';

import 'package:get/get.dart';

import 'annotation_service.dart';
import 'annotation_service_interface.dart';
import 'pdf_service_interface.dart';

/// Dependency injection binding for PDF viewer services
class PdfServicesBinding extends Bindings {
  @override
  void dependencies() {
    // Register service interfaces as lazy singletons
    // These will be implemented in future tasks

    // PDF Service - handles core PDF operations
    Get.lazyPut<IPdfService>(() => _MockPdfService(), fenix: true);

    // Annotation Service - handles highlights and notes
    Get.lazyPut<IAnnotationService>(() => AnnotationService(), fenix: true);
  }
}

// Mock implementations for now - will be replaced with real implementations in future tasks

class _MockPdfService implements IPdfService {
  @override
  Future<String> downloadAndCachePdf(String url) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 100));
    return '/mock/path/to/pdf';
  }

  @override
  Future<List<String>> extractTextFromPage(int pageNumber) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return ['Mock text from page $pageNumber'];
  }

  @override
  Future<List<SearchResult>> searchInPdf(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      SearchResult(
        pageNumber: 1,
        text: query,
        boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
        context: 'Mock context containing $query',
      ),
    ];
  }

  @override
  Future<Uint8List> generateThumbnail(
    int pageNumber, {
    int width = 200,
    int height = 300,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Uint8List(0); // Empty bytes for mock
  }

  @override
  Future<int> getPageCount() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return 100; // Mock page count
  }

  @override
  Future<List<OutlineItem>> extractOutline() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      const OutlineItem(title: 'Chapter 1', pageNumber: 1),
      const OutlineItem(title: 'Chapter 2', pageNumber: 25),
    ];
  }

  @override
  Future<bool> isPasswordProtected() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return false;
  }

  @override
  Future<bool> validatePdf(String filePath) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }
}
