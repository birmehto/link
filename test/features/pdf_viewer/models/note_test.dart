import 'package:flutter_test/flutter_test.dart';
import 'package:link/features/pdf_viewer/models/models.dart';

void main() {
  group('Note Model Tests', () {
    late Note testNote;
    late DateTime testCreatedDate;
    late DateTime testModifiedDate;

    setUp(() {
      testCreatedDate = DateTime(2024, 1, 15, 10, 30);
      testModifiedDate = DateTime(2024, 1, 15, 11, 45);
      testNote = Note(
        id: 'note_1',
        content:
            'This is a test note content that provides additional context to the highlighted text.',
        createdAt: testCreatedDate,
        modifiedAt: testModifiedDate,
        highlightId: 'highlight_1',
      );
    });

    test('should create Note with all properties', () {
      expect(testNote.id, 'note_1');
      expect(
        testNote.content,
        'This is a test note content that provides additional context to the highlighted text.',
      );
      expect(testNote.createdAt, testCreatedDate);
      expect(testNote.modifiedAt, testModifiedDate);
      expect(testNote.highlightId, 'highlight_1');
    });

    test('should serialize to JSON correctly', () {
      final json = testNote.toJson();

      expect(json['id'], 'note_1');
      expect(
        json['content'],
        'This is a test note content that provides additional context to the highlighted text.',
      );
      expect(json['createdAt'], testCreatedDate.toIso8601String());
      expect(json['modifiedAt'], testModifiedDate.toIso8601String());
      expect(json['highlightId'], 'highlight_1');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'note_2',
        'content': 'Another test note',
        'createdAt': testCreatedDate.toIso8601String(),
        'modifiedAt': null,
        'highlightId': null,
      };

      final note = Note.fromJson(json);

      expect(note.id, 'note_2');
      expect(note.content, 'Another test note');
      expect(note.createdAt, testCreatedDate);
      expect(note.modifiedAt, null);
      expect(note.highlightId, null);
    });

    test('should create copy with modified properties', () {
      final modifiedNote = testNote.copyWith(
        content: 'Updated note content',
        modifiedAt: DateTime(2024, 1, 16, 9),
        highlightId: 'highlight_2',
      );

      expect(modifiedNote.id, testNote.id);
      expect(modifiedNote.content, 'Updated note content');
      expect(modifiedNote.createdAt, testNote.createdAt);
      expect(modifiedNote.modifiedAt, DateTime(2024, 1, 16, 9));
      expect(modifiedNote.highlightId, 'highlight_2');
    });

    test('should validate computed properties correctly', () {
      expect(testNote.isAttachedToHighlight, true);
      expect(testNote.isModified, true);
      expect(testNote.lastUpdated, testModifiedDate);

      final unattachedNote = Note(
        id: testNote.id,
        content: testNote.content,
        createdAt: testNote.createdAt,
        modifiedAt: testNote.modifiedAt,
      );
      expect(unattachedNote.isAttachedToHighlight, false);

      final unmodifiedNote = Note(
        id: testNote.id,
        content: testNote.content,
        createdAt: testCreatedDate,
        highlightId: testNote.highlightId,
      );
      expect(unmodifiedNote.isModified, false);
      expect(unmodifiedNote.lastUpdated, testCreatedDate);
    });

    test('should truncate long content for shortContent property', () {
      final longContent =
          'This is a very long note content that should be truncated when displayed in lists or previews to maintain UI consistency and readability. It contains multiple sentences and detailed information.';
      final longContentNote = testNote.copyWith(content: longContent);

      expect(longContentNote.shortContent.length, 100);
      expect(longContentNote.shortContent.endsWith('...'), true);

      final shortContent = 'Short note';
      final shortContentNote = testNote.copyWith(content: shortContent);
      expect(shortContentNote.shortContent, shortContent);
    });

    test('should validate note content correctly', () {
      expect(testNote.isValid, true);

      final emptyNote = testNote.copyWith(content: '');
      expect(emptyNote.isValid, false);

      final whitespaceNote = testNote.copyWith(content: '   \n\t  ');
      expect(whitespaceNote.isValid, false);

      final validNote = testNote.copyWith(content: 'Valid content');
      expect(validNote.isValid, true);
    });

    test('should count words correctly', () {
      expect(testNote.wordCount, 14); // Count words in the test content

      final singleWordNote = testNote.copyWith(content: 'Word');
      expect(singleWordNote.wordCount, 1);

      final multiSpaceNote = testNote.copyWith(
        content: 'Multiple   spaces    between words',
      );
      expect(multiSpaceNote.wordCount, 4);

      final emptyNote = testNote.copyWith(content: '');
      expect(
        emptyNote.wordCount,
        1,
      ); // Empty string split returns array with one empty element
    });

    test('should implement equality correctly', () {
      final identicalNote = Note(
        id: 'note_1',
        content:
            'This is a test note content that provides additional context to the highlighted text.',
        createdAt: testCreatedDate,
        modifiedAt: testModifiedDate,
        highlightId: 'highlight_1',
      );

      final differentNote = testNote.copyWith(id: 'note_2');

      expect(testNote, identicalNote);
      expect(testNote == differentNote, false);
      expect(testNote.hashCode, identicalNote.hashCode);
    });

    test('should have proper toString representation', () {
      final shortContentNote = testNote.copyWith(content: 'Short note content');

      expect(
        shortContentNote.toString(),
        'Note(id: note_1, content: Short note content)',
      );
    });
  });
}
