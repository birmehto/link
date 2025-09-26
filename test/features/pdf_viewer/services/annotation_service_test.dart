import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../lib/features/pdf_viewer/models/models.dart';
import '../../../../lib/features/pdf_viewer/services/annotation_service.dart';
import '../../../../lib/features/pdf_viewer/services/annotation_service_interface.dart';

void main() {
  group('AnnotationService', () {
    late AnnotationService annotationService;
    late Directory tempDir;

    setUpAll(() async {
      // Initialize Hive for testing
      tempDir = await Directory.systemTemp.createTemp('annotation_test');
      Hive.init(tempDir.path);

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HighlightAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(NoteAdapter());
      }
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

    group('Highlight Operations', () {
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
        expect(retrieved.color, equals(highlight.color));
      });

      test('should update existing highlight', () async {
        // Arrange
        final highlight = Highlight(
          id: 'test-highlight-2',
          pdfId: 'test-pdf-1',
          pageNumber: 1,
          selectedText: 'Original text',
          boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
          color: Colors.yellow,
          createdAt: DateTime.now(),
        );

        await annotationService.saveHighlight(highlight);

        final updatedHighlight = highlight.copyWith(
          selectedText: 'Updated text',
          color: Colors.green,
        );

        // Act
        await annotationService.updateHighlight(updatedHighlight);
        final retrieved = await annotationService.getHighlight(highlight.id);

        // Assert
        expect(retrieved!.selectedText, equals('Updated text'));
        expect(retrieved.color, equals(Colors.green));
      });

      test('should delete highlight', () async {
        // Arrange
        final highlight = Highlight(
          id: 'test-highlight-3',
          pdfId: 'test-pdf-1',
          pageNumber: 1,
          selectedText: 'To be deleted',
          boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
          color: Colors.yellow,
          createdAt: DateTime.now(),
        );

        await annotationService.saveHighlight(highlight);

        // Act
        await annotationService.deleteHighlight(highlight.id);
        final retrieved = await annotationService.getHighlight(highlight.id);

        // Assert
        expect(retrieved, isNull);
      });

      test('should get highlights for PDF sorted by page number', () async {
        // Arrange
        final highlights = [
          Highlight(
            id: 'highlight-1',
            pdfId: 'test-pdf-1',
            pageNumber: 3,
            selectedText: 'Third page',
            boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
            color: Colors.yellow,
            createdAt: DateTime.now(),
          ),
          Highlight(
            id: 'highlight-2',
            pdfId: 'test-pdf-1',
            pageNumber: 1,
            selectedText: 'First page',
            boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
            color: Colors.green,
            createdAt: DateTime.now(),
          ),
          Highlight(
            id: 'highlight-3',
            pdfId: 'test-pdf-2',
            pageNumber: 2,
            selectedText: 'Different PDF',
            boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
            color: Colors.blue,
            createdAt: DateTime.now(),
          ),
        ];

        for (final highlight in highlights) {
          await annotationService.saveHighlight(highlight);
        }

        // Act
        final retrieved = await annotationService.getHighlightsForPdf(
          'test-pdf-1',
        );

        // Assert
        expect(retrieved.length, equals(2));
        expect(retrieved[0].pageNumber, equals(1)); // Should be sorted
        expect(retrieved[1].pageNumber, equals(3));
        expect(retrieved.every((h) => h.pdfId == 'test-pdf-1'), isTrue);
      });
    });

    group('Note Operations', () {
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

      test('should update note with modified timestamp', () async {
        // Arrange
        final note = Note(
          id: 'test-note-2',
          content: 'Original content',
          createdAt: DateTime.now(),
        );

        await annotationService.saveNote(note);

        final updatedNote = note.copyWith(content: 'Updated content');

        // Act
        await annotationService.updateNote(updatedNote);
        final retrieved = await annotationService.getNote(note.id);

        // Assert
        expect(retrieved!.content, equals('Updated content'));
        expect(retrieved.modifiedAt, isNotNull);
        expect(retrieved.isModified, isTrue);
      });

      test('should delete note', () async {
        // Arrange
        final note = Note(
          id: 'test-note-3',
          content: 'To be deleted',
          createdAt: DateTime.now(),
        );

        await annotationService.saveNote(note);

        // Act
        await annotationService.deleteNote(note.id);
        final retrieved = await annotationService.getNote(note.id);

        // Assert
        expect(retrieved, isNull);
      });
    });

    group('Highlight-Note Relationships', () {
      test('should delete associated note when highlight is deleted', () async {
        // Arrange
        final note = Note(
          id: 'test-note-4',
          content: 'Associated note',
          createdAt: DateTime.now(),
        );

        final highlight = Highlight(
          id: 'test-highlight-4',
          pdfId: 'test-pdf-1',
          pageNumber: 1,
          selectedText: 'Highlighted text',
          boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
          color: Colors.yellow,
          createdAt: DateTime.now(),
          noteId: note.id,
        );

        await annotationService.saveNote(note);
        await annotationService.saveHighlight(highlight);

        // Act
        await annotationService.deleteHighlight(highlight.id);

        // Assert
        final retrievedHighlight = await annotationService.getHighlight(
          highlight.id,
        );
        final retrievedNote = await annotationService.getNote(note.id);

        expect(retrievedHighlight, isNull);
        expect(retrievedNote, isNull);
      });

      test('should get notes for highlight', () async {
        // Arrange
        final highlightId = 'test-highlight-5';
        final notes = [
          Note(
            id: 'note-1',
            content: 'First note',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            highlightId: highlightId,
          ),
          Note(
            id: 'note-2',
            content: 'Second note',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            highlightId: highlightId,
          ),
          Note(
            id: 'note-3',
            content: 'Different highlight',
            createdAt: DateTime.now(),
            highlightId: 'different-highlight',
          ),
        ];

        for (final note in notes) {
          await annotationService.saveNote(note);
        }

        // Act
        final retrieved = await annotationService.getNotesForHighlight(
          highlightId,
        );

        // Assert
        expect(retrieved.length, equals(2));
        expect(
          retrieved[0].content,
          equals('First note'),
        ); // Should be sorted by creation time
        expect(retrieved[1].content, equals('Second note'));
      });
    });

    group('Search Operations', () {
      test('should search annotations by highlight text', () async {
        // Arrange
        final highlights = [
          Highlight(
            id: 'search-highlight-1',
            pdfId: 'test-pdf-1',
            pageNumber: 1,
            selectedText: 'Flutter is awesome',
            boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
            color: Colors.yellow,
            createdAt: DateTime.now(),
          ),
          Highlight(
            id: 'search-highlight-2',
            pdfId: 'test-pdf-1',
            pageNumber: 2,
            selectedText: 'Dart programming language',
            boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
            color: Colors.green,
            createdAt: DateTime.now(),
          ),
        ];

        for (final highlight in highlights) {
          await annotationService.saveHighlight(highlight);
        }

        // Act
        final results = await annotationService.searchAnnotations('Flutter');

        // Assert
        expect(results.length, equals(1));
        expect(results[0].highlight.selectedText, contains('Flutter'));
        expect(results[0].matchType, equals(AnnotationMatchType.highlightText));
      });

      test('should search annotations by note content', () async {
        // Arrange
        final note = Note(
          id: 'search-note-1',
          content: 'This note mentions Flutter development',
          createdAt: DateTime.now(),
          highlightId: 'search-highlight-3',
        );

        final highlight = Highlight(
          id: 'search-highlight-3',
          pdfId: 'test-pdf-1',
          pageNumber: 1,
          selectedText: 'Some text',
          boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
          color: Colors.yellow,
          createdAt: DateTime.now(),
          noteId: note.id,
        );

        await annotationService.saveNote(note);
        await annotationService.saveHighlight(highlight);

        // Act
        final results = await annotationService.searchAnnotations(
          'development',
        );

        // Assert
        expect(results.length, equals(1));
        expect(results[0].note!.content, contains('development'));
        expect(results[0].matchType, equals(AnnotationMatchType.noteContent));
      });
    });

    group('Statistics', () {
      test('should calculate annotation statistics', () async {
        // Arrange
        final highlights = [
          Highlight(
            id: 'stats-highlight-1',
            pdfId: 'test-pdf-1',
            pageNumber: 1,
            selectedText: 'Short',
            boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
            color: Colors.yellow,
            createdAt: DateTime.now(),
          ),
          Highlight(
            id: 'stats-highlight-2',
            pdfId: 'test-pdf-1',
            pageNumber: 1,
            selectedText: 'This is a longer highlight text',
            boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
            color: Colors.yellow,
            createdAt: DateTime.now(),
          ),
          Highlight(
            id: 'stats-highlight-3',
            pdfId: 'test-pdf-1',
            pageNumber: 2,
            selectedText: 'Green highlight',
            boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
            color: Colors.green,
            createdAt: DateTime.now(),
          ),
        ];

        for (final highlight in highlights) {
          await annotationService.saveHighlight(highlight);
        }

        // Act
        final stats = await annotationService.getAnnotationStats('test-pdf-1');

        // Assert
        expect(stats.totalHighlights, equals(3));
        expect(stats.highlightsByColor['Yellow'], equals(2));
        expect(stats.highlightsByColor['Green'], equals(1));
        expect(stats.annotationsByPage[1], equals(2));
        expect(stats.annotationsByPage[2], equals(1));
        expect(stats.mostAnnotatedPages.first, equals(1));
      });
    });

    group('Export and Import', () {
      test('should export annotations as JSON', () async {
        // Arrange
        final highlight = Highlight(
          id: 'export-highlight-1',
          pdfId: 'test-pdf-1',
          pageNumber: 1,
          selectedText: 'Export test',
          boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
          color: Colors.yellow,
          createdAt: DateTime.now(),
        );

        await annotationService.saveHighlight(highlight);

        // Act
        final exportPath = await annotationService.exportAnnotations(
          'test-pdf-1',
          ExportFormat.json,
        );

        // Assert
        expect(exportPath, isNotNull);
        final file = File(exportPath);
        expect(await file.exists(), isTrue);

        final content = await file.readAsString();
        expect(content, contains('Export test'));
      });

      test('should backup and restore annotations', () async {
        // Arrange
        final highlight = Highlight(
          id: 'backup-highlight-1',
          pdfId: 'test-pdf-1',
          pageNumber: 1,
          selectedText: 'Backup test',
          boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
          color: Colors.yellow,
          createdAt: DateTime.now(),
        );

        await annotationService.saveHighlight(highlight);

        // Act - Backup
        final backupPath = await annotationService.backupAnnotations();

        // Clear data
        await annotationService.deleteHighlight(highlight.id);
        expect(await annotationService.getHighlight(highlight.id), isNull);

        // Restore
        await annotationService.restoreAnnotations(backupPath);

        // Assert
        final restored = await annotationService.getHighlight(highlight.id);
        expect(restored, isNotNull);
        expect(restored!.selectedText, equals('Backup test'));
      });
    });

    group('Error Handling', () {
      test(
        'should throw exception when updating non-existent highlight',
        () async {
          // Arrange
          final highlight = Highlight(
            id: 'non-existent',
            pdfId: 'test-pdf-1',
            pageNumber: 1,
            selectedText: 'Test',
            boundingBox: const Rect.fromLTRB(10, 20, 100, 40),
            color: Colors.yellow,
            createdAt: DateTime.now(),
          );

          // Act & Assert
          expect(
            () => annotationService.updateHighlight(highlight),
            throwsException,
          );
        },
      );

      test('should throw exception when updating non-existent note', () async {
        // Arrange
        final note = Note(
          id: 'non-existent',
          content: 'Test',
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(() => annotationService.updateNote(note), throwsException);
      });
    });
  });
}

// Mock adapters for testing (these would normally be generated)
class HighlightAdapter extends TypeAdapter<Highlight> {
  @override
  final int typeId = 0;

  @override
  Highlight read(BinaryReader reader) {
    return Highlight(
      id: reader.readString(),
      pdfId: reader.readString(),
      pageNumber: reader.readInt(),
      selectedText: reader.readString(),
      boundingBox: reader.read() as Rect,
      color: reader.read() as Color,
      createdAt: reader.read() as DateTime,
      noteId: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Highlight obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.pdfId);
    writer.writeInt(obj.pageNumber);
    writer.writeString(obj.selectedText);
    writer.write(obj.boundingBox);
    writer.write(obj.color);
    writer.write(obj.createdAt);
    writer.writeString(obj.noteId ?? '');
  }
}

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 1;

  @override
  Note read(BinaryReader reader) {
    return Note(
      id: reader.readString(),
      content: reader.readString(),
      createdAt: reader.read() as DateTime,
      modifiedAt: reader.read() as DateTime?,
      highlightId: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.content);
    writer.write(obj.createdAt);
    writer.write(obj.modifiedAt);
    writer.writeString(obj.highlightId ?? '');
  }
}

class RectAdapter extends TypeAdapter<Rect> {
  @override
  final int typeId = 10;

  @override
  Rect read(BinaryReader reader) {
    final left = reader.readDouble();
    final top = reader.readDouble();
    final right = reader.readDouble();
    final bottom = reader.readDouble();
    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  void write(BinaryWriter writer, Rect obj) {
    writer.writeDouble(obj.left);
    writer.writeDouble(obj.top);
    writer.writeDouble(obj.right);
    writer.writeDouble(obj.bottom);
  }
}

class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = 11;

  @override
  Color read(BinaryReader reader) {
    final value = reader.readInt();
    return Color(value);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    writer.writeInt(obj.value);
  }
}

class DateTimeAdapter extends TypeAdapter<DateTime> {
  @override
  final int typeId = 12;

  @override
  DateTime read(BinaryReader reader) {
    final millisecondsSinceEpoch = reader.readInt();
    return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
  }

  @override
  void write(BinaryWriter writer, DateTime obj) {
    writer.writeInt(obj.millisecondsSinceEpoch);
  }
}
