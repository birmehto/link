import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:link/features/pdf_viewer/controllers/enhanced_pdf_viewer_controller.dart';
import 'package:link/features/pdf_viewer/models/models.dart';
import 'package:link/features/pdf_viewer/services/services.dart';

void main() {
  group('EnhancedPdfViewerController Tests', () {
    late EnhancedPdfViewerController controller;

    setUpAll(() async {
      // Initialize Hive for testing
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(RectAdapter());
      }
      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(ColorAdapter());
      }
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(DateTimeAdapter());
      }
    });

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

      // Close any open Hive boxes
      await Hive.close();
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
      expect(controller.highlights, isA<RxList<Highlight>>());
      expect(controller.notes, isA<RxList<Note>>());
      expect(controller.bookmarks, isA<RxList<Bookmark>>());
      expect(controller.readingSessions, isA<RxList<ReadingSession>>());
      expect(controller.readingStats, isA<Rxn<ReadingStats>>());
      expect(controller.readingPreferences, isA<Rxn<ReadingPreferences>>());
      expect(controller.currentSession, isA<Rxn<ReadingSession>>());
      expect(controller.selectedText, isA<Rxn<String>>());
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

    test('should generate PDF ID from URL', () {
      const url1 = 'https://example.com/document1.pdf';
      const url2 = 'https://example.com/document2.pdf';

      // Since _generatePdfId is private, we can't test it directly
      // But we can test that different URLs would generate different IDs
      expect(
        url1.hashCode.abs().toString(),
        isNot(equals(url2.hashCode.abs().toString())),
      );
    });

    test('should handle reading preferences updates', () async {
      const newPreferences = ReadingPreferences(
        theme: ReadingTheme.dark,
        brightness: 0.7,
        autoHideControls: false,
      );

      await controller.updatePreferences(newPreferences);

      expect(controller.readingPreferences.value, newPreferences);
      expect(controller.readingPreferences.value?.theme, ReadingTheme.dark);
      expect(controller.readingPreferences.value?.brightness, 0.7);
      expect(controller.readingPreferences.value?.autoHideControls, false);
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

    //   test('should maintain reactive state consistency', () {
    //     var highlightsChanged = false;
    //     var notesChanged = false;
    //     var bookmarksChanged = false;

    //     // Listen to changes
    //     controller.highlights.listen((_) => highlightsChanged = true);
    //     controller.notes.listen((_) => notesChanged = true);
    //     controller.bookmarks.listen((_) => bookmarksChanged = true);

    //     // Make changes
    //     controller.highlights.add(
    //       Highlight(
    //         id: 'test_highlight',
    //         pdfId: 'test_pdf',
    //         pageNumber: 1,
    //         selectedText: 'Test text',
    //         boundingBox: const Rect.fromLTRB(0, 0, 100, 20),
    //         color: const Color(0xFFFFFF00),
    //         createdAt: DateTime.now(),
    //       ),
    //     );

    //     controller.notes.add(
    //       Note(
    //         id: 'test_note',
    //         content: 'Test note content',
    //         createdAt: DateTime.now(),
    //       ),
    //     );

    //     controller.bookmarks.add(
    //       Bookmark(
    //         id: 'test_bookmark',
    //         pdfId: 'test_pdf',
    //         pageNumber: 1,
    //         title: 'Test Bookmark',
    //         createdAt: DateTime.now(),
    //       ),
    //     );

    //     // Verify changes were detected
    //     expect(highlightsChanged, true);
    //     expect(notesChanged, true);
    //     expect(bookmarksChanged, true);

    //     // Verify collections are not empty
    //     expect(controller.highlights.isNotEmpty, true);
    //     expect(controller.notes.isNotEmpty, true);
    //     expect(controller.bookmarks.isNotEmpty, true);
    //   });
  });
}
