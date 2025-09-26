import 'package:flutter_test/flutter_test.dart';
import 'package:link/features/pdf_viewer/models/models.dart';

void main() {
  group('ReadingSession Model Tests', () {
    late ReadingSession testSession;
    late DateTime startTime;
    late DateTime endTime;

    setUp(() {
      startTime = DateTime(2024, 1, 15, 10, 30);
      endTime = DateTime(2024, 1, 15, 11, 15); // 45 minutes later
      testSession = ReadingSession(
        id: 'session_1',
        pdfId: 'pdf_123',
        startTime: startTime,
        endTime: endTime,
        startPage: 10,
        endPage: 25,
      );
    });

    test('should create ReadingSession with all properties', () {
      expect(testSession.id, 'session_1');
      expect(testSession.pdfId, 'pdf_123');
      expect(testSession.startTime, startTime);
      expect(testSession.endTime, endTime);
      expect(testSession.startPage, 10);
      expect(testSession.endPage, 25);
    });

    test('should serialize to JSON correctly', () {
      final json = testSession.toJson();

      expect(json['id'], 'session_1');
      expect(json['pdfId'], 'pdf_123');
      expect(json['startTime'], startTime.toIso8601String());
      expect(json['endTime'], endTime.toIso8601String());
      expect(json['startPage'], 10);
      expect(json['endPage'], 25);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'session_2',
        'pdfId': 'pdf_456',
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'startPage': 5,
        'endPage': 15,
      };

      final session = ReadingSession.fromJson(json);

      expect(session.id, 'session_2');
      expect(session.pdfId, 'pdf_456');
      expect(session.startTime, startTime);
      expect(session.endTime, endTime);
      expect(session.startPage, 5);
      expect(session.endPage, 15);
    });

    test('should create copy with modified properties', () {
      final modifiedSession = testSession.copyWith(
        endPage: 30,
        endTime: DateTime(2024, 1, 15, 12, 0),
      );

      expect(modifiedSession.id, testSession.id);
      expect(modifiedSession.pdfId, testSession.pdfId);
      expect(modifiedSession.startTime, testSession.startTime);
      expect(modifiedSession.endTime, DateTime(2024, 1, 15, 12, 0));
      expect(modifiedSession.startPage, testSession.startPage);
      expect(modifiedSession.endPage, 30);
    });

    test('should calculate computed properties correctly', () {
      expect(testSession.duration, const Duration(minutes: 45));
      expect(testSession.pagesRead, 16); // 25 - 10 + 1
      expect(
        testSession.readingSpeedPagesPerMinute,
        closeTo(0.356, 0.01),
      ); // 16 pages / 45 minutes
      expect(
        testSession.readingSpeedPagesPerHour,
        closeTo(21.33, 0.01),
      ); // 0.356 * 60
    });

    test('should validate session correctly', () {
      expect(testSession.isValidSession, true);

      // Invalid: end time before start time
      final invalidTimeSession = testSession.copyWith(
        endTime: startTime.subtract(const Duration(minutes: 10)),
      );
      expect(invalidTimeSession.isValidSession, false);

      // Invalid: start page is 0
      final invalidStartPageSession = testSession.copyWith(startPage: 0);
      expect(invalidStartPageSession.isValidSession, false);

      // Invalid: end page before start page
      final invalidEndPageSession = testSession.copyWith(endPage: 5);
      expect(invalidEndPageSession.isValidSession, false);

      // Invalid: too short duration (less than 10 seconds)
      final shortSession = testSession.copyWith(
        endTime: startTime.add(const Duration(seconds: 5)),
      );
      expect(shortSession.isValidSession, false);
    });

    test('should format duration correctly', () {
      expect(testSession.formattedDuration, '45m 0s');

      final hourSession = testSession.copyWith(
        endTime: startTime.add(const Duration(hours: 2, minutes: 30)),
      );
      expect(hourSession.formattedDuration, '2h 30m');

      final secondsSession = testSession.copyWith(
        endTime: startTime.add(const Duration(seconds: 45)),
      );
      expect(secondsSession.formattedDuration, '45s');
    });

    test('should format session date correctly', () {
      expect(testSession.sessionDate, '15/1/2024');
    });

    test('should handle edge cases for pages read', () {
      // Same page (should be 1 page read)
      final samePageSession = testSession.copyWith(startPage: 10, endPage: 10);
      expect(samePageSession.pagesRead, 1);

      // Large page range
      final largeRangeSession = testSession.copyWith(
        startPage: 1,
        endPage: 100,
      );
      expect(largeRangeSession.pagesRead, 100);
    });

    test('should handle zero reading speed correctly', () {
      final instantSession = testSession.copyWith(
        endTime: startTime, // Same time
      );
      expect(instantSession.readingSpeedPagesPerMinute, 0.0);
      expect(instantSession.readingSpeedPagesPerHour, 0.0);
    });

    test('should implement equality correctly', () {
      final identicalSession = ReadingSession(
        id: 'session_1',
        pdfId: 'pdf_123',
        startTime: startTime,
        endTime: endTime,
        startPage: 10,
        endPage: 25,
      );

      final differentSession = testSession.copyWith(id: 'session_2');

      expect(testSession, identicalSession);
      expect(testSession == differentSession, false);
      expect(testSession.hashCode, identicalSession.hashCode);
    });

    test('should have proper toString representation', () {
      expect(
        testSession.toString(),
        'ReadingSession(id: session_1, duration: 45m 0s, pages: 16)',
      );
    });
  });
}
