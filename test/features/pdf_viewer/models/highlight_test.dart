import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link/features/pdf_viewer/models/models.dart';

void main() {
  group('Highlight Model Tests', () {
    late Highlight testHighlight;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testHighlight = Highlight(
        id: 'highlight_1',
        pdfId: 'pdf_123',
        pageNumber: 5,
        selectedText: 'This is a test highlight text that should be preserved.',
        boundingBox: const Rect.fromLTRB(10.0, 20.0, 100.0, 40.0),
        color: Colors.yellow,
        createdAt: testDate,
        noteId: 'note_1',
      );
    });

    test('should create Highlight with all properties', () {
      expect(testHighlight.id, 'highlight_1');
      expect(testHighlight.pdfId, 'pdf_123');
      expect(testHighlight.pageNumber, 5);
      expect(
        testHighlight.selectedText,
        'This is a test highlight text that should be preserved.',
      );
      expect(
        testHighlight.boundingBox,
        const Rect.fromLTRB(10.0, 20.0, 100.0, 40.0),
      );
      expect(testHighlight.color, Colors.yellow);
      expect(testHighlight.createdAt, testDate);
      expect(testHighlight.noteId, 'note_1');
    });

    test('should serialize to JSON correctly', () {
      final json = testHighlight.toJson();

      expect(json['id'], 'highlight_1');
      expect(json['pdfId'], 'pdf_123');
      expect(json['pageNumber'], 5);
      expect(
        json['selectedText'],
        'This is a test highlight text that should be preserved.',
      );
      expect(json['boundingBox']['left'], 10.0);
      expect(json['boundingBox']['top'], 20.0);
      expect(json['boundingBox']['right'], 100.0);
      expect(json['boundingBox']['bottom'], 40.0);
      expect(json['color'], Colors.yellow.value);
      expect(json['createdAt'], testDate.toIso8601String());
      expect(json['noteId'], 'note_1');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'highlight_2',
        'pdfId': 'pdf_456',
        'pageNumber': 10,
        'selectedText': 'Another test text',
        'boundingBox': {
          'left': 5.0,
          'top': 15.0,
          'right': 95.0,
          'bottom': 35.0,
        },
        'color': Colors.green.value,
        'createdAt': testDate.toIso8601String(),
        'noteId': null,
      };

      final highlight = Highlight.fromJson(json);

      expect(highlight.id, 'highlight_2');
      expect(highlight.pdfId, 'pdf_456');
      expect(highlight.pageNumber, 10);
      expect(highlight.selectedText, 'Another test text');
      expect(highlight.boundingBox, const Rect.fromLTRB(5.0, 15.0, 95.0, 35.0));
      expect(highlight.color.value, Colors.green.value);
      expect(highlight.createdAt, testDate);
      expect(highlight.noteId, null);
    });

    test('should create copy with modified properties', () {
      final modifiedHighlight = testHighlight.copyWith(
        pageNumber: 8,
        color: Colors.blue,
        noteId: 'note_2',
      );

      expect(modifiedHighlight.id, testHighlight.id);
      expect(modifiedHighlight.pdfId, testHighlight.pdfId);
      expect(modifiedHighlight.pageNumber, 8);
      expect(modifiedHighlight.selectedText, testHighlight.selectedText);
      expect(modifiedHighlight.boundingBox, testHighlight.boundingBox);
      expect(modifiedHighlight.color, Colors.blue);
      expect(modifiedHighlight.createdAt, testHighlight.createdAt);
      expect(modifiedHighlight.noteId, 'note_2');
    });

    test('should validate computed properties correctly', () {
      expect(testHighlight.hasNote, true);
      expect(testHighlight.colorName, 'Yellow');

      final highlightWithoutNote = testHighlight.copyWith(noteId: '');
      expect(highlightWithoutNote.hasNote, false);

      final blueHighlight = testHighlight.copyWith(color: Colors.blue);
      expect(blueHighlight.colorName, 'Blue');

      final customColorHighlight = testHighlight.copyWith(
        color: const Color(0xFF123456),
      );
      expect(customColorHighlight.colorName, 'Custom');
    });

    test('should truncate long text for shortText property', () {
      final longText =
          'This is a very long text that should be truncated when displayed as short text to maintain UI consistency';
      final longTextHighlight = testHighlight.copyWith(selectedText: longText);

      expect(
        longTextHighlight.shortText,
        'This is a very long text that should be truncat...',
      );
      expect(longTextHighlight.shortText.length, 50);

      final shortText = 'Short text';
      final shortTextHighlight = testHighlight.copyWith(
        selectedText: shortText,
      );
      expect(shortTextHighlight.shortText, shortText);
    });

    test('should implement equality correctly', () {
      final identicalHighlight = Highlight(
        id: 'highlight_1',
        pdfId: 'pdf_123',
        pageNumber: 5,
        selectedText: 'This is a test highlight text that should be preserved.',
        boundingBox: const Rect.fromLTRB(10.0, 20.0, 100.0, 40.0),
        color: Colors.yellow,
        createdAt: testDate,
        noteId: 'note_1',
      );

      final differentHighlight = testHighlight.copyWith(id: 'highlight_2');

      expect(testHighlight, identicalHighlight);
      expect(testHighlight == differentHighlight, false);
      expect(testHighlight.hashCode, identicalHighlight.hashCode);
    });

    test('should have proper toString representation', () {
      final shortTextHighlight = testHighlight.copyWith(
        selectedText: 'Short text',
      );

      expect(
        shortTextHighlight.toString(),
        'Highlight(id: highlight_1, page: 5, text: Short text)',
      );
    });
  });
}
