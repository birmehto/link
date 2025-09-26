import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 1)
class Note extends Equatable {
  const Note({
    required this.id,
    required this.content,
    required this.createdAt,
    this.modifiedAt,
    this.highlightId,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime? modifiedAt;

  @HiveField(4)
  final String? highlightId;

  // Factory constructor for creating from JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: json['modifiedAt'] != null
          ? DateTime.parse(json['modifiedAt'] as String)
          : null,
      highlightId: json['highlightId'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt?.toIso8601String(),
      'highlightId': highlightId,
    };
  }

  // CopyWith method for immutability
  Note copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? highlightId,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      highlightId: highlightId ?? this.highlightId,
    );
  }

  // Computed properties
  bool get isAttachedToHighlight =>
      highlightId != null && highlightId!.trim().isNotEmpty;

  bool get isModified => modifiedAt != null && modifiedAt!.isAfter(createdAt);

  String get shortContent {
    if (content.length <= 100) return content;
    return '${content.substring(0, 97)}...';
  }

  DateTime get lastUpdated => modifiedAt ?? createdAt;

  // Validation methods
  bool get isValid => content.trim().isNotEmpty;

  int get wordCount => content.trim().split(RegExp(r'\s+')).length;

  @override
  List<Object?> get props => [id, content, createdAt, modifiedAt, highlightId];

  @override
  String toString() => 'Note(id: $id, content: $shortContent)';
}
