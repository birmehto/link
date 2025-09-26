import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:link/features/pdf_viewer/controllers/enhanced_pdf_viewer_controller.dart';
import 'package:link/features/pdf_viewer/services/services.dart';

void main() {
  group('EnhancedPdfViewerController Simple Tests', () {
    late EnhancedPdfViewerController controller;

    setUp(() async {
      // Initialize GetX
      Get.testMode = true;

      // Bind services
      PdfServicesBinding().dependencies();

      // Create controller
      controller = EnhancedPdfViewerController();
    });

    tearDown(() async {
      // Clean up
      controller.onClose();
      Get.reset();
    });

    test('should initialize with default values', () {
      expect(controller.highlights.isEmpty, true);
      expect(controller.notes.isEmpty, true);
      expect(controller.bookmarks.isEmpty, true);
      expect(controller.readingSessions.isEmpty, true);
      expect(controller.readingStats.value, null);
      expect(controller.currentSession.value, null);
      expect(controller.isAnnotationMode.value, false);
      expect(controller.isControlsVisible.value, true);
    });

    test('should have reactive state variables', () {
      expect(controller.highlights, isA<RxList>());
      expect(controller.notes, isA<RxList>());
      expect(controller.bookmarks, isA<RxList>());
      expect(controller.readingSessions, isA<RxList>());
      expect(controller.readingStats, isA<Rxn>());
      expect(controller.readingPreferences, isA<Rxn>());
      expect(controller.currentSession, isA<Rxn>());
      expect(controller.selectedText, isA<Rxn>());
      expect(controller.isAnnotationMode, isA<RxBool>());
      expect(controller.isControlsVisible, isA<RxBool>());
    });

    test('should toggle controls visibility', () {
      expect(controller.isControlsVisible.value, true);

      controller.toggleControls();
      expect(controller.isControlsVisible.value, false);

      controller.toggleControls();
      expect(controller.isControlsVisible.value, true);
    });

    test('should manage annotation state', () {
      expect(controller.isAnnotationMode.value, false);
      expect(controller.selectedText.value, null);
      expect(controller.selectedTextBounds.value, null);
      expect(controller.isAnnotationToolbarVisible.value, false);

      // Test state changes
      controller.isAnnotationMode.value = true;
      expect(controller.isAnnotationMode.value, true);

      controller.selectedText.value = 'Selected text';
      expect(controller.selectedText.value, 'Selected text');
    });

    test('should manage UI panel visibility', () {
      expect(controller.isBookmarkPanelVisible.value, false);
      expect(controller.isStatsPanelVisible.value, false);

      controller.isBookmarkPanelVisible.value = true;
      expect(controller.isBookmarkPanelVisible.value, true);

      controller.isStatsPanelVisible.value = true;
      expect(controller.isStatsPanelVisible.value, true);
    });

    test('should handle empty collections correctly', () {
      expect(controller.highlights.isEmpty, true);
      expect(controller.notes.isEmpty, true);
      expect(controller.bookmarks.isEmpty, true);
      expect(controller.readingSessions.isEmpty, true);

      expect(controller.highlights.length, 0);
      expect(controller.notes.length, 0);
      expect(controller.bookmarks.length, 0);
      expect(controller.readingSessions.length, 0);
    });
  });
}
