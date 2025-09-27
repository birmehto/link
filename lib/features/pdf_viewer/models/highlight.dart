import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'highlight.g.dart';

@HiveType(typeId: 0)
class Highlight extends Equatable {
  // Factory constructor for creating from JSON
  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      id: json['id'] as String,
      pdfId: json['pdfId'] as String,
      pageNumber: json['pageNumber'] as int,
      selectedText: json['selectedText'] as String,
      boundingBox: Rect.fromLTRB(
        (json['boundingBox']['left'] as num).toDouble(),
        (json['boundingBox']['top'] as num).toDouble(),
        (json['boundingBox']['right'] as num).toDouble(),
        (json['boundingBox']['bottom'] as num).toDouble(),
      ),
      color: Color(json['color'] as int),
      createdAt: DateTime.parse(json['createdAt'] as String),
      noteId: json['noteId'] as String?,
    );
  }
  const Highlight({
    required this.id,
    required this.pdfId,
    required this.pageNumber,
    required this.selectedText,
    required this.boundingBox,
    required this.color,
    required this.createdAt,
    this.noteId,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String pdfId;

  @HiveField(2)
  final int pageNumber;

  @HiveField(3)
  final String selectedText;

  @HiveField(4)
  final Rect boundingBox;

  @HiveField(5)
  final Color color;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final String? noteId;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pdfId': pdfId,
      'pageNumber': pageNumber,
      'selectedText': selectedText,
      'boundingBox': {
        'left': boundingBox.left,
        'top': boundingBox.top,
        'right': boundingBox.right,
        'bottom': boundingBox.bottom,
      },
      'color': color.value,
      'createdAt': createdAt.toIso8601String(),
      'noteId': noteId,
    };
  }

  // CopyWith method for immutability
  Highlight copyWith({
    String? id,
    String? pdfId,
    int? pageNumber,
    String? selectedText,
    Rect? boundingBox,
    Color? color,
    DateTime? createdAt,
    String? noteId,
  }) {
    return Highlight(
      id: id ?? this.id,
      pdfId: pdfId ?? this.pdfId,
      pageNumber: pageNumber ?? this.pageNumber,
      selectedText: selectedText ?? this.selectedText,
      boundingBox: boundingBox ?? this.boundingBox,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      noteId: noteId ?? this.noteId,
    );
  }

  // Computed properties
  bool get hasNote => noteId != null && noteId!.trim().isNotEmpty;

  String get shortText {
    if (selectedText.length <= 50) return selectedText;
    return '${selectedText.substring(0, 47)}...';
  }

  String get colorName {
    if (color == Colors.yellow) return 'Yellow';
    if (color == Colors.green) return 'Green';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.pink) return 'Pink';
    if (color == Colors.orange) return 'Orange';
    return 'Custom';
  }

  @override
  List<Object?> get props => [
    id,
    pdfId,
    pageNumber,
    selectedText,
    boundingBox,
    color,
    createdAt,
    noteId,
  ];

  @override
  String toString() =>
      'Highlight(id: $id, page: $pageNumber, text: $shortText)';
}
