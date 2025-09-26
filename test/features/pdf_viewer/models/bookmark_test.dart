import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link/features/pdf_viewer/models/models.dart';

void main() {
  group('Bookmark Model Tests', () {
    late Bookmark testBookmark;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testBookmark = Bookmark(
        id: 'bookmark_1',
        pdfId: 'pdf_123',
        pageNumber: 25,
        title: 'Important Chapter',
        createdAt: testDate,
        description:
            'This chapter contains crucial information about the main topic.',
        color: Colors.red,
      );
    });

    test('should create Bookmark with all properties', () {
      expect(testBookmark.id, 'bookmark_1');
      expect(testBookmark.pdfId, 'pdf_123');
      expect(testBookmark.pageNumber, 25);
      expect(testBookmark.title, 'Important Chapter');
      expect(testBookmark.createdAt, testDate);
      expect(
        testBookmark.description,
        'This chapter contains crucial information about the main topic.',
      );
      expect(testBookmark.color, Colors.red);
    });

    test('should serialize to JSON correctly', () {
      final json = testBookmark.toJson();

      expect(json['id'], 'bookmark_1');
      expect(json['pdfId'], 'pdf_123');
      expect(json['pageNumber'], 25);
      expect(json['title'], 'Important Chapter');
      expect(json['createdAt'], testDate.toIso8601String());
      expect(
        json['description'],
        'This chapter contains crucial information about the main topic.',
      );
      expect(json['color'], Colors.red.value);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'bookmark_2',
        'pdfId': 'pdf_456',
        'pageNumber': 50,
        'title': 'Another Chapter',
        'createdAt': testDate.toIso8601String(),
        'description': null,
        'color': null,
      };

      final bookmark = Bookmark.fromJson(json);

      expect(bookmark.id, 'bookmark_2');
      expect(bookmark.pdfId, 'pdf_456');
      expect(bookmark.pageNumber, 50);
      expect(bookmark.title, 'Another Chapter');
      expect(bookmark.createdAt, testDate);
      expect(bookmark.description, null);
      expect(bookmark.color, null);
    });

    test('should create copy with modified properties', () {
      final modifiedBookmark = testBookmark.copyWith(
        pageNumber: 30,
        title: 'Updated Chapter Title',
        color: Colors.blue,
      );

      expect(modifiedBookmark.id, testBookmark.id);
      expect(modifiedBookmark.pdfId, testBookmark.pdfId);
      expect(modifiedBookmark.pageNumber, 30);
      expect(modifiedBookmark.title, 'Updated Chapter Title');
      expect(modifiedBookmark.createdAt, testBookmark.createdAt);
      expect(modifiedBookmark.description, testBookmark.description);
      expect(modifiedBookmark.color, Colors.blue);
    });

    test('should validate computed properties correctly', () {
      expect(testBookmark.hasDescription, true);
      expect(testBookmark.hasColor, true);
      expect(testBookmark.displayTitle, 'Important Chapter');

      final bookmarkWithoutDescription = Bookmark(
        id: testBookmark.id,
        pdfId: testBookmark.pdfId,
        pageNumber: testBookmark.pageNumber,
        title: testBookmark.title,
        createdAt: testBookmark.createdAt,
      );
      expect(bookmarkWithoutDescription.hasDescription, false);

      final bookmarkWithEmptyDescription = Bookmark(
        id: testBookmark.id,
        pdfId: testBookmark.pdfId,
        pageNumber: testBookmark.pageNumber,
        title: testBookmark.title,
        createdAt: testBookmark.createdAt,
        description: '   ',
        color: testBookmark.color,
      );
      expect(bookmarkWithEmptyDescription.hasDescription, false);

      final bookmarkWithoutColor = Bookmark(
        id: testBookmark.id,
        pdfId: testBookmark.pdfId,
        pageNumber: testBookmark.pageNumber,
        title: testBookmark.title,
        createdAt: testBookmark.createdAt,
        description: testBookmark.description,
      );
      expect(bookmarkWithoutColor.hasColor, false);

      final bookmarkWithEmptyTitle = testBookmark.copyWith(title: '');
      expect(bookmarkWithEmptyTitle.displayTitle, 'Page 25');
    });

    test('should truncate long description for shortDescription property', () {
      final longDescription =
          'This is a very long description that should be truncated when displayed in lists or previews to maintain UI consistency and readability.';
      final longDescBookmark = testBookmark.copyWith(
        description: longDescription,
      );

      expect(longDescBookmark.shortDescription.length, 50);
      expect(longDescBookmark.shortDescription.endsWith('...'), true);

      final shortDescription = 'Short description';
      final shortDescBookmark = testBookmark.copyWith(
        description: shortDescription,
      );
      expect(shortDescBookmark.shortDescription, shortDescription);

      final noDescBookmark = Bookmark(
        id: 'bookmark_no_desc',
        pdfId: 'pdf_123',
        pageNumber: 25,
        title: 'No Description Bookmark',
        createdAt: testDate,
      );
      expect(noDescBookmark.shortDescription, '');
    });

    test('should format date correctly', () {
      final now = DateTime.now();

      // Test recent bookmark (minutes ago)
      final recentBookmark = testBookmark.copyWith(
        createdAt: now.subtract(const Duration(minutes: 30)),
      );
      expect(recentBookmark.formattedDate, '30m ago');

      // Test bookmark from hours ago
      final hoursAgoBookmark = testBookmark.copyWith(
        createdAt: now.subtract(const Duration(hours: 3)),
      );
      expect(hoursAgoBookmark.formattedDate, '3h ago');

      // Test yesterday's bookmark
      final yesterdayBookmark = testBookmark.copyWith(
        createdAt: now.subtract(const Duration(days: 1)),
      );
      expect(yesterdayBookmark.formattedDate, 'Yesterday');

      // Test bookmark from few days ago
      final daysAgoBookmark = testBookmark.copyWith(
        createdAt: now.subtract(const Duration(days: 3)),
      );
      expect(daysAgoBookmark.formattedDate, '3d ago');

      // Test old bookmark (more than a week)
      final oldDate = DateTime(2023, 12, 1, 10, 30);
      final oldBookmark = testBookmark.copyWith(createdAt: oldDate);
      expect(oldBookmark.formattedDate, '1/12/2023');
    });

    test('should validate bookmark correctly', () {
      expect(testBookmark.isValid, true);

      final invalidTitleBookmark = testBookmark.copyWith(title: '   ');
      expect(invalidTitleBookmark.isValid, false);

      final invalidPageBookmark = testBookmark.copyWith(pageNumber: 0);
      expect(invalidPageBookmark.isValid, false);

      final negativePageBookmark = testBookmark.copyWith(pageNumber: -1);
      expect(negativePageBookmark.isValid, false);
    });

    test('should implement equality correctly', () {
      final identicalBookmark = Bookmark(
        id: 'bookmark_1',
        pdfId: 'pdf_123',
        pageNumber: 25,
        title: 'Important Chapter',
        createdAt: testDate,
        description:
            'This chapter contains crucial information about the main topic.',
        color: Colors.red,
      );

      final differentBookmark = testBookmark.copyWith(id: 'bookmark_2');

      expect(testBookmark, identicalBookmark);
      expect(testBookmark == differentBookmark, false);
      expect(testBookmark.hashCode, identicalBookmark.hashCode);
    });

    test('should have proper toString representation', () {
      expect(
        testBookmark.toString(),
        'Bookmark(id: bookmark_1, page: 25, title: Important Chapter)',
      );

      final emptyTitleBookmark = testBookmark.copyWith(title: '');
      expect(
        emptyTitleBookmark.toString(),
        'Bookmark(id: bookmark_1, page: 25, title: Page 25)',
      );
    });
  });
}
