import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'reading_session.g.dart';

@HiveType(typeId: 3)
class ReadingSession extends Equatable {
  // Factory constructor for creating from JSON
  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'] as String,
      pdfId: json['pdfId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      startPage: json['startPage'] as int,
      endPage: json['endPage'] as int,
    );
  }
  const ReadingSession({
    required this.id,
    required this.pdfId,
    required this.startTime,
    required this.endTime,
    required this.startPage,
    required this.endPage,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String pdfId;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final DateTime endTime;

  @HiveField(4)
  final int startPage;

  @HiveField(5)
  final int endPage;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pdfId': pdfId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'startPage': startPage,
      'endPage': endPage,
    };
  }

  // CopyWith method for immutability
  ReadingSession copyWith({
    String? id,
    String? pdfId,
    DateTime? startTime,
    DateTime? endTime,
    int? startPage,
    int? endPage,
  }) {
    return ReadingSession(
      id: id ?? this.id,
      pdfId: pdfId ?? this.pdfId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
    );
  }

  // Computed properties
  Duration get duration => endTime.difference(startTime);

  int get pagesRead =>
      (endPage - startPage + 1).clamp(0, double.infinity).toInt();

  double get readingSpeedPagesPerMinute {
    final minutes = duration.inMinutes;
    if (minutes == 0) return 0.0;
    return pagesRead / minutes;
  }

  double get readingSpeedPagesPerHour => readingSpeedPagesPerMinute * 60;

  bool get isValidSession {
    return endTime.isAfter(startTime) &&
        startPage > 0 &&
        endPage >= startPage &&
        duration.inSeconds >= 10; // Minimum 10 seconds to be valid
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String get sessionDate {
    final date = startTime;
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  List<Object?> get props => [
    id,
    pdfId,
    startTime,
    endTime,
    startPage,
    endPage,
  ];

  @override
  String toString() =>
      'ReadingSession(id: $id, duration: $formattedDuration, pages: $pagesRead)';
}
