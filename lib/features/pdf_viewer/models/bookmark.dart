import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'bookmark.g.dart';

@HiveType(typeId: 2)
class Bookmark extends Equatable {
  // Factory constructor for creating from JSON
  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      pdfId: json['pdfId'] as String,
      pageNumber: json['pageNumber'] as int,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
      color: json['color'] != null ? Color(json['color'] as int) : null,
    );
  }
  const Bookmark({
    required this.id,
    required this.pdfId,
    required this.pageNumber,
    required this.title,
    required this.createdAt,
    this.description,
    this.color,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String pdfId;

  @HiveField(2)
  final int pageNumber;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final Color? color;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pdfId': pdfId,
      'pageNumber': pageNumber,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'color': color?.value,
    };
  }

  // CopyWith method for immutability
  Bookmark copyWith({
    String? id,
    String? pdfId,
    int? pageNumber,
    String? title,
    DateTime? createdAt,
    String? description,
    Color? color,
  }) {
    return Bookmark(
      id: id ?? this.id,
      pdfId: pdfId ?? this.pdfId,
      pageNumber: pageNumber ?? this.pageNumber,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      color: color ?? this.color,
    );
  }

  // Computed properties
  bool get hasDescription =>
      description != null && description!.trim().isNotEmpty;

  bool get hasColor => color != null;

  String get displayTitle {
    if (title.trim().isEmpty) return 'Page $pageNumber';
    return title;
  }

  String get shortDescription {
    if (!hasDescription) return '';
    if (description!.length <= 50) return description!;
    return '${description!.substring(0, 47)}...';
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  // Validation methods
  bool get isValid => title.trim().isNotEmpty && pageNumber > 0;

  @override
  List<Object?> get props => [
    id,
    pdfId,
    pageNumber,
    title,
    createdAt,
    description,
    color,
  ];

  @override
  String toString() =>
      'Bookmark(id: $id, page: $pageNumber, title: $displayTitle)';
}
