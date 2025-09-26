import '../models/models.dart';

/// Interface for reading statistics and session tracking
abstract class IReadingStatsService {
  /// Start a new reading session
  Future<ReadingSession> startSession(String pdfId, int startPage);

  /// End the current reading session
  Future<ReadingSession?> endSession(String sessionId, int endPage);

  /// Update the current session with new page information
  Future<void> updateSession(String sessionId, int currentPage);

  /// Get all reading sessions for a PDF
  Future<List<ReadingSession>> getSessionsForPdf(String pdfId);

  /// Get reading statistics for a PDF
  Future<ReadingStats> getStatsForPdf(String pdfId);

  /// Get global reading statistics across all PDFs
  Future<GlobalReadingStats> getGlobalStats();

  /// Get reading statistics for a specific date range
  Future<ReadingStats> getStatsForDateRange(
    String pdfId,
    DateTime start,
    DateTime end,
  );

  /// Get daily reading time for the last N days
  Future<Map<DateTime, Duration>> getDailyReadingTime(
    int days, {
    String? pdfId,
  });

  /// Get reading streak information
  Future<ReadingStreak> getReadingStreak({String? pdfId});

  /// Get reading goals and progress
  Future<ReadingGoals> getReadingGoals();

  /// Set reading goals
  Future<void> setReadingGoals(ReadingGoals goals);

  /// Update reading goal progress
  Future<void> updateGoalProgress(
    String goalId,
    Duration timeRead,
    int pagesRead,
  );

  /// Get reading achievements/milestones
  Future<List<ReadingAchievement>> getAchievements();

  /// Check and award new achievements
  Future<List<ReadingAchievement>> checkForNewAchievements(String pdfId);

  /// Export reading statistics
  Future<String> exportStats(StatsExportFormat format, {String? pdfId});

  /// Get reading insights and recommendations
  Future<ReadingInsights> getReadingInsights({String? pdfId});

  /// Track reading behavior patterns
  Future<ReadingPatterns> analyzeReadingPatterns({String? pdfId});

  /// Get reading productivity metrics
  Future<ProductivityMetrics> getProductivityMetrics(
    DateTime start,
    DateTime end,
  );
}

/// Global reading statistics across all PDFs
class GlobalReadingStats {
  const GlobalReadingStats({
    required this.totalReadingTime,
    required this.totalPagesRead,
    required this.totalSessions,
    required this.averageSessionDuration,
    required this.averageReadingSpeed,
    required this.totalPdfsRead,
    required this.favoriteReadingTimes,
    required this.readingStreak,
  });

  final Duration totalReadingTime;
  final int totalPagesRead;
  final int totalSessions;
  final Duration averageSessionDuration;
  final double averageReadingSpeed; // pages per minute
  final int totalPdfsRead;
  final List<TimeSlot> favoriteReadingTimes; // Most common reading hours
  final int readingStreak; // Current streak in days

  @override
  String toString() =>
      'GlobalReadingStats(time: ${totalReadingTime.inHours}h, pages: $totalPagesRead)';
}

/// Reading streak information
class ReadingStreak {
  const ReadingStreak({
    required this.currentStreak,
    required this.longestStreak,
    required this.streakStartDate,
    required this.lastReadingDate,
    required this.streakGoal,
  });

  final int currentStreak; // Days
  final int longestStreak; // Days
  final DateTime? streakStartDate;
  final DateTime? lastReadingDate;
  final int streakGoal; // Target streak in days

  bool get isStreakActive {
    if (lastReadingDate == null) return false;
    final now = DateTime.now();
    final daysSinceLastReading = now.difference(lastReadingDate!).inDays;
    return daysSinceLastReading <= 1; // Allow 1 day gap
  }

  @override
  String toString() =>
      'ReadingStreak(current: $currentStreak, longest: $longestStreak)';
}

/// Reading goals and targets
class ReadingGoals {
  const ReadingGoals({
    required this.dailyTimeGoal,
    required this.dailyPagesGoal,
    required this.weeklyTimeGoal,
    required this.weeklyPagesGoal,
    required this.monthlyTimeGoal,
    required this.monthlyPagesGoal,
    required this.yearlyTimeGoal,
    required this.yearlyPagesGoal,
    required this.streakGoal,
  });

  final Duration dailyTimeGoal;
  final int dailyPagesGoal;
  final Duration weeklyTimeGoal;
  final int weeklyPagesGoal;
  final Duration monthlyTimeGoal;
  final int monthlyPagesGoal;
  final Duration yearlyTimeGoal;
  final int yearlyPagesGoal;
  final int streakGoal; // Days

  @override
  String toString() =>
      'ReadingGoals(daily: ${dailyTimeGoal.inMinutes}m, ${dailyPagesGoal}p)';
}

/// Reading achievements and milestones
class ReadingAchievement {
  const ReadingAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.threshold,
    required this.isUnlocked,
    required this.unlockedDate,
    required this.progress,
  });

  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final double threshold; // Target value to unlock
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final double progress; // Current progress towards threshold (0.0 - 1.0)

  @override
  String toString() =>
      'ReadingAchievement(title: $title, unlocked: $isUnlocked)';
}

/// Types of reading achievements
enum AchievementType {
  totalTime,
  totalPages,
  streak,
  speed,
  consistency,
  milestone,
}

/// Reading insights and recommendations
class ReadingInsights {
  const ReadingInsights({
    required this.optimalReadingTimes,
    required this.readingSpeedTrend,
    required this.focusPatterns,
    required this.recommendations,
    required this.strengths,
    required this.areasForImprovement,
  });

  final List<TimeSlot> optimalReadingTimes;
  final SpeedTrend readingSpeedTrend;
  final FocusPatterns focusPatterns;
  final List<String> recommendations;
  final List<String> strengths;
  final List<String> areasForImprovement;

  @override
  String toString() =>
      'ReadingInsights(recommendations: ${recommendations.length})';
}

/// Reading behavior patterns
class ReadingPatterns {
  const ReadingPatterns({
    required this.preferredReadingDuration,
    required this.mostActiveHours,
    required this.readingConsistency,
    required this.sessionLengthTrend,
    required this.breakPatterns,
  });

  final Duration preferredReadingDuration;
  final List<int> mostActiveHours; // Hours of day (0-23)
  final double readingConsistency; // 0.0 - 1.0
  final SessionLengthTrend sessionLengthTrend;
  final BreakPatterns breakPatterns;

  @override
  String toString() =>
      'ReadingPatterns(duration: ${preferredReadingDuration.inMinutes}m)';
}

/// Productivity metrics
class ProductivityMetrics {
  const ProductivityMetrics({
    required this.focusScore,
    required this.efficiencyRating,
    required this.consistencyScore,
    required this.improvementAreas,
    required this.productivityTrend,
  });

  final double focusScore; // 0.0 - 1.0
  final double efficiencyRating; // 0.0 - 1.0
  final double consistencyScore; // 0.0 - 1.0
  final List<String> improvementAreas;
  final ProductivityTrend productivityTrend;

  @override
  String toString() =>
      'ProductivityMetrics(focus: $focusScore, efficiency: $efficiencyRating)';
}

/// Time slot for reading patterns
class TimeSlot {
  const TimeSlot({
    required this.startHour,
    required this.endHour,
    required this.frequency,
  });

  final int startHour;
  final int endHour;
  final double frequency; // 0.0 - 1.0

  @override
  String toString() =>
      'TimeSlot($startHour:00-$endHour:00, ${(frequency * 100).toInt()}%)';
}

/// Export format for statistics
enum StatsExportFormat { json, csv, pdf, html }

/// Placeholder classes for complex analytics
class SpeedTrend {
  const SpeedTrend({required this.trend, required this.changePercent});
  final TrendDirection trend;
  final double changePercent;
}

class FocusPatterns {
  const FocusPatterns({
    required this.averageFocusTime,
    required this.distractionPoints,
  });
  final Duration averageFocusTime;
  final List<int> distractionPoints; // Pages where focus dropped
}

class SessionLengthTrend {
  const SessionLengthTrend({required this.trend, required this.averageLength});
  final TrendDirection trend;
  final Duration averageLength;
}

class BreakPatterns {
  const BreakPatterns({
    required this.averageBreakLength,
    required this.breakFrequency,
  });
  final Duration averageBreakLength;
  final double breakFrequency; // Breaks per hour
}

class ProductivityTrend {
  const ProductivityTrend({required this.trend, required this.changePercent});
  final TrendDirection trend;
  final double changePercent;
}

enum TrendDirection { increasing, decreasing, stable }
