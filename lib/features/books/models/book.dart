import 'package:equatable/equatable.dart';
import 'package:link/core/constants/api_constants.dart';

/// Book model representing a book from various sources (OpenLibrary, Gutendex)
class Book extends Equatable {
  const Book({
    required this.workId,
    required this.title,
    this.authorName,
    this.coverUrl,
    this.pdfUrl,
    this.description,
    this.subjects = const [],
    this.firstPublishYear,
    this.rating,
  });

  // Factory constructors
  factory Book.fromOpenLibraryJson(Map<String, dynamic> json) {
    final workId = _parseWorkId(json['key']);
    final title = json['title'] ?? 'No Title';
    final authorName = _parseAuthorName(json['author_name']);
    final coverUrl = _parseOpenLibraryCoverUrl(json['cover_i']);
    final description = _parseDescription(json['first_sentence']);
    final subjects = _parseSubjects(json['subject']);
    final firstPublishYear = _parseFirstPublishYear(json['first_publish_year']);
    final rating = _parseRating(json['ratings_average'], json['ratings_count']);

    return Book(
      workId: workId,
      title: title,
      authorName: authorName,
      coverUrl: coverUrl,
      description: description,
      subjects: subjects,
      firstPublishYear: firstPublishYear,
      rating: rating,
    );
  }

  factory Book.fromGutendexJson(Map<String, dynamic> json) {
    final formats = json['formats'] as Map?;

    return Book(
      workId: json['id'].toString(),
      title: json['title'] ?? 'No Title',
      authorName: _parseGutendexAuthor(json['authors']),
      coverUrl: _parseGutendexCover(formats),
      pdfUrl: _parseGutendexPdfUrl(formats),
      description: _parseGutendexDescription(json['subjects']),
      subjects: _parseGutendexSubjects(json['bookshelves']),
      firstPublishYear: _parseGutendexYear(json['id']),
    );
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      workId: json['workId'] as String,
      title: json['title'] as String,
      authorName: json['authorName'] as String?,
      coverUrl: json['coverUrl'] as String?,
      pdfUrl: json['pdfUrl'] as String?,
      description: json['description'] as String?,
      subjects: (json['subjects'] as List?)?.cast<String>() ?? [],
      firstPublishYear: json['firstPublishYear'] as int?,
      rating: json['rating'] != null
          ? Rating.fromJson(json['rating'] as Map<String, dynamic>)
          : null,
    );
  }
  final String workId;
  final String title;
  final String? authorName;
  final String? coverUrl;
  final String? pdfUrl;
  final String? description;
  final List<String> subjects;
  final int? firstPublishYear;
  final Rating? rating;

  // Computed properties
  String get publishYear => firstPublishYear?.toString() ?? 'Unknown Year';

  String get formattedRating => rating?.formatted ?? 'No ratings';

  String get shortDescription {
    if (description == null || description!.isEmpty) {
      return 'No description available.';
    }
    final firstSentence = description!.split('.').first;
    return firstSentence.isEmpty ? description! : '$firstSentence.';
  }

  String get displayAuthor => authorName ?? 'Unknown Author';

  bool get hasPdf => pdfUrl != null && pdfUrl!.isNotEmpty;

  bool get hasCover => coverUrl != null && coverUrl!.isNotEmpty;

  bool get hasRating => rating != null && rating!.average != null;

  /// Get cover URL with specific size
  String? getCoverUrl({String size = ApiConstants.mediumSize}) {
    if (!hasCover) {
      return null;
    }
    if (coverUrl!.contains('covers.openlibrary.org')) {
      // Replace size in existing OpenLibrary URL
      return coverUrl!.replaceAll(RegExp(r'-[SML]\.jpg$'), '-$size.jpg');
    }
    return coverUrl;
  }

  // Private parsing helpers
  static String _parseWorkId(dynamic key) {
    return key?.toString().split('/').last ?? '';
  }

  static String? _parseAuthorName(dynamic authorList) {
    if (authorList is! List) {
      return null;
    }
    return authorList
        .firstWhere(
          (name) => name != null && name.toString().isNotEmpty,
          orElse: () => null,
        )
        ?.toString();
  }

  static String? _parseOpenLibraryCoverUrl(dynamic coverId) {
    if (coverId == null) {
      return null;
    }
    return ApiConstants.getCoverUrl(
      'id',
      coverId.toString(),
      ApiConstants.largeSize,
    );
  }

  static String? _parseDescription(dynamic firstSentence) {
    if (firstSentence is List) {
      return firstSentence.join(' ');
    }
    return firstSentence?.toString();
  }

  static List<String> _parseSubjects(dynamic subjectData) {
    if (subjectData is! List) {
      return [];
    }
    return subjectData
        .take(5)
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static int? _parseFirstPublishYear(dynamic year) {
    if (year == null) {
      return null;
    }
    return int.tryParse(year.toString());
  }

  static Rating? _parseRating(dynamic average, dynamic count) {
    final avgRating = average != null
        ? double.tryParse(average.toString())
        : null;
    final ratingCount = count != null ? int.tryParse(count.toString()) : null;

    if (avgRating == null && ratingCount == null) {
      return null;
    }
    return Rating(average: avgRating, count: ratingCount);
  }

  // Gutendex specific parsing
  static String? _parseGutendexAuthor(dynamic authors) {
    if (authors is! List || authors.isEmpty) {
      return null;
    }
    // ignore: avoid_dynamic_calls
    return authors[0]['name']?.toString();
  }

  static String? _parseGutendexCover(Map? formats) {
    return formats?['image/jpeg'] ?? formats?['image/png'];
  }

  static String? _parseGutendexPdfUrl(Map? formats) {
    return formats?['application/pdf'] ?? formats?['text/html'];
  }

  static String? _parseGutendexDescription(dynamic subjects) {
    if (subjects is! List || subjects.isEmpty) {
      return null;
    }
    return subjects.join('. ');
  }

  static List<String> _parseGutendexSubjects(dynamic bookshelves) {
    // ignore: always_put_control_body_on_new_line
    if (bookshelves is! List) return [];
    return bookshelves
        .take(5)
        .map((e) => e.toString().replaceAll('_', ' '))
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static int? _parseGutendexYear(dynamic id) {
    if (id == null) return null;
    // Placeholder year calculation - should be replaced with actual logic
    return 1900 + (id as int) % 100;
  }

  // Equatable implementation
  @override
  List<Object?> get props => [
    workId,
    title,
    authorName,
    coverUrl,
    pdfUrl,
    description,
    subjects,
    firstPublishYear,
    rating,
  ];

  // CopyWith method for immutability
  Book copyWith({
    String? workId,
    String? title,
    String? authorName,
    String? coverUrl,
    String? pdfUrl,
    String? description,
    List<String>? subjects,
    int? firstPublishYear,
    Rating? rating,
  }) {
    return Book(
      workId: workId ?? this.workId,
      title: title ?? this.title,
      authorName: authorName ?? this.authorName,
      coverUrl: coverUrl ?? this.coverUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      description: description ?? this.description,
      subjects: subjects ?? this.subjects,
      firstPublishYear: firstPublishYear ?? this.firstPublishYear,
      rating: rating ?? this.rating,
    );
  }

  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'workId': workId,
      'title': title,
      'authorName': authorName,
      'coverUrl': coverUrl,
      'pdfUrl': pdfUrl,
      'description': description,
      'subjects': subjects,
      'firstPublishYear': firstPublishYear,
      'rating': rating?.toJson(),
    };
  }

  @override
  String toString() =>
      'Book(workId: $workId, title: $title, author: $authorName)';
}

/// Rating model for book ratings
class Rating extends Equatable {
  const Rating({this.average, this.count});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      average: (json['average'] as num?)?.toDouble(),
      count: json['count'] as int?,
    );
  }
  final double? average;
  final int? count;

  // Format only the numeric value and count — no stars here
  String get formatted {
    if (average == null) return 'No rating';
    return '${average!.toStringAsFixed(1)} (${count ?? 0})';
  }

  double get normalizedRating => average != null ? (average! / 5.0) : 0.0;

  bool get hasValidRating => average != null && average! > 0;

  Map<String, dynamic> toJson() {
    return {'average': average, 'count': count};
  }

  @override
  List<Object?> get props => [average, count];

  @override
  String toString() => formatted;
}
