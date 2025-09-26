import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'reading_session.dart';

part 'reading_stats.g.dart';

@HiveType(typeId: 4)
class ReadingStats extends Equatable {
  // Date string -> minutes

  // Factory constructor for creating from JSON
  factory ReadingStats.fromJson(Map<String, dynamic> json) {
    final sessionsJson = json['sessions'] as List? ?? [];
    final sessions = sessionsJson
        .map(
          (sessionJson) =>
              ReadingSession.fromJson(sessionJson as Map<String, dynamic>),
        )
        .toList();

    final dailyTimeJson = json['dailyReadingTime'] as Map? ?? {};
    final dailyReadingTime = Map<String, int>.from(dailyTimeJson);

    return ReadingStats(
      pdfId: json['pdfId'] as String,
      sessions: sessions,
      dailyReadingTime: dailyReadingTime,
    );
  }
  const ReadingStats({
    required this.pdfId,
    required this.sessions,
    this.dailyReadingTime = const {},
  });

  @HiveField(0)
  final String pdfId;

  @HiveField(1)
  final List<ReadingSession> sessions;

  @HiveField(2)
  final Map<String, int> dailyReadingTime;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'pdfId': pdfId,
      'sessions': sessions.map((session) => session.toJson()).toList(),
      'dailyReadingTime': dailyReadingTime,
    };
  }

  // CopyWith method for immutability
  ReadingStats copyWith({
    String? pdfId,
    List<ReadingSession>? sessions,
    Map<String, int>? dailyReadingTime,
  }) {
    return ReadingStats(
      pdfId: pdfId ?? this.pdfId,
      sessions: sessions ?? this.sessions,
      dailyReadingTime: dailyReadingTime ?? this.dailyReadingTime,
    );
  }

  // Computed properties
  Duration get totalReadingTime {
    return sessions.fold(
      Duration.zero,
      (total, session) => total + session.duration,
    );
  }

  int get totalPagesRead {
    return sessions.fold(0, (total, session) => total + session.pagesRead);
  }

  double get averageReadingSpeed {
    if (sessions.isEmpty) return 0.0;

    final totalMinutes = totalReadingTime.inMinutes;
    if (totalMinutes == 0) return 0.0;

    return totalPagesRead / totalMinutes;
  }

  int get totalSessions => sessions.length;

  Duration get averageSessionDuration {
    if (sessions.isEmpty) return Duration.zero;

    final totalMinutes = totalReadingTime.inMinutes;
    return Duration(minutes: (totalMinutes / sessions.length).round());
  }

  List<ReadingSession> get validSessions {
    return sessions.where((session) => session.isValidSession).toList();
  }

  // Get reading time for a specific date
  Duration getReadingTimeForDate(DateTime date) {
    final dateKey = _formatDateKey(date);
    final minutes = dailyReadingTime[dateKey] ?? 0;
    return Duration(minutes: minutes);
  }

  // Get reading time for the last N days
  Duration getReadingTimeForLastDays(int days) {
    final now = DateTime.now();
    var totalMinutes = 0;

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = _formatDateKey(date);
      totalMinutes += dailyReadingTime[dateKey] ?? 0;
    }

    return Duration(minutes: totalMinutes);
  }

  // Get reading streak (consecutive days with reading)
  int get currentReadingStreak {
    final now = DateTime.now();
    var streak = 0;

    for (int i = 0; i < 365; i++) {
      // Check up to a year
      final date = now.subtract(Duration(days: i));
      final dateKey = _formatDateKey(date);

      if (dailyReadingTime.containsKey(dateKey) &&
          dailyReadingTime[dateKey]! > 0) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  // Get longest reading streak
  int get longestReadingStreak {
    if (dailyReadingTime.isEmpty) return 0;

    final sortedDates = dailyReadingTime.keys.toList()..sort();
    var maxStreak = 0;
    var currentStreak = 0;
    DateTime? lastDate;

    for (final dateKey in sortedDates) {
      if (dailyReadingTime[dateKey]! > 0) {
        final date = DateTime.parse(dateKey);

        if (lastDate == null || date.difference(lastDate).inDays == 1) {
          currentStreak++;
          maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
        } else {
          currentStreak = 1;
        }

        lastDate = date;
      }
    }

    return maxStreak;
  }

  // Get sessions for a specific date range
  List<ReadingSession> getSessionsInDateRange(DateTime start, DateTime end) {
    return sessions.where((session) {
      return session.startTime.isAfter(
            start.subtract(const Duration(days: 1)),
          ) &&
          session.startTime.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Add a new session and update daily reading time
  ReadingStats addSession(ReadingSession session) {
    final updatedSessions = List<ReadingSession>.from(sessions)..add(session);
    final updatedDailyTime = Map<String, int>.from(dailyReadingTime);

    final dateKey = _formatDateKey(session.startTime);
    final existingMinutes = updatedDailyTime[dateKey] ?? 0;
    updatedDailyTime[dateKey] = existingMinutes + session.duration.inMinutes;

    return copyWith(
      sessions: updatedSessions,
      dailyReadingTime: updatedDailyTime,
    );
  }

  // Helper method to format date as key
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [pdfId, sessions, dailyReadingTime];

  @override
  String toString() =>
      'ReadingStats(pdfId: $pdfId, sessions: $totalSessions, totalTime: ${totalReadingTime.inMinutes}m)';
}
