import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:link/features/pdf_viewer/models/highlight.dart';
import 'package:link/features/pdf_viewer/models/note.dart';
import 'package:link/features/pdf_viewer/services/annotation_service.dart';

void main() {
  group('AnnotationService Basic Tests', () {
    late AnnotationService annotationService;
    late Directory tempDir;

    setUpAll(() async {
      // Initialize Hive for testing
      tempDir = await Directory.systemTemp.createTemp('annotation_test');
      Hive.init(tempDir.path);
    });

    setUp(() async {
      annotationService = AnnotationService();
      await annotationService.initialize();
    });

    tearDown(() async {
      await annotationService.dispose();
      await Hive.deleteBoxFromDisk('highlights');
      await Hive.deleteBoxFromDisk('notes');
    });

    tearDownAll(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should initialize service', () async {
      // The service should initialize without errors
      expect(annotationService, isNotNull);
    });

    test('should save and retrieve highlight', () async {
      // Arrange
      final highlight = Highlight(
        id: 'test-highlight-1',
        pdfId: 'test-pdf-1',
        pageNumber: 1,
        selectedText: 'This is a test highlight',
        boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
        color: Colors.yellow,
        createdAt: DateTime.now(),
      );

      // Act
      await annotationService.saveHighlight(highlight);
      final retrieved = await annotationService.getHighlight(highlight.id);

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(highlight.id));
      expect(retrieved.selectedText, equals(highlight.selectedText));
    });

    test('should save and retrieve note', () async {
      // Arrange
      final note = Note(
        id: 'test-note-1',
        content: 'This is a test note',
        createdAt: DateTime.now(),
      );

      // Act
      await annotationService.saveNote(note);
      final retrieved = await annotationService.getNote(note.id);

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(note.id));
      expect(retrieved.content, equals(note.content));
    });

    test('should generate unique IDs', () async {
      // Act
      final id1 = annotationService.generateId();
      final id2 = annotationService.generateId();

      // Assert
      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id1, isNot(equals(id2)));
    });
  });
}
