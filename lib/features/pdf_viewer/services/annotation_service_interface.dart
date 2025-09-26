import '../models/models.dart';

/// Interface for annotation-related operations
abstract class IAnnotationService {
  /// Save a highlight to persistent storage
  Future<void> saveHighlight(Highlight highlight);

  /// Save a note to persistent storage
  Future<void> saveNote(Note note);

  /// Update an existing highlight
  Future<void> updateHighlight(Highlight highlight);

  /// Update an existing note
  Future<void> updateNote(Note note);

  /// Delete a highlight and its associated note (if any)
  Future<void> deleteHighlight(String highlightId);

  /// Delete a note
  Future<void> deleteNote(String noteId);

  /// Get all highlights for a specific PDF
  Future<List<Highlight>> getHighlightsForPdf(String pdfId);

  /// Get all notes for a specific PDF
  Future<List<Note>> getNotesForPdf(String pdfId);

  /// Get a specific highlight by ID
  Future<Highlight?> getHighlight(String highlightId);

  /// Get a specific note by ID
  Future<Note?> getNote(String noteId);

  /// Get notes associated with a specific highlight
  Future<List<Note>> getNotesForHighlight(String highlightId);

  /// Export annotations for a PDF in various formats
  Future<String> exportAnnotations(String pdfId, ExportFormat format);

  /// Import annotations from a file
  Future<List<Highlight>> importAnnotations(String filePath);

  /// Search within annotations
  Future<List<AnnotationSearchResult>> searchAnnotations(
    String query, {
    String? pdfId,
  });

  /// Get annotation statistics for a PDF
  Future<AnnotationStats> getAnnotationStats(String pdfId);

  /// Backup all annotations to a file
  Future<String> backupAnnotations();

  /// Restore annotations from a backup file
  Future<void> restoreAnnotations(String backupFilePath);
}

/// Export format options for annotations
enum ExportFormat { json, markdown, html, txt, csv }

/// Represents a search result within annotations
class AnnotationSearchResult {
  const AnnotationSearchResult({
    required this.highlight,
    this.note,
    required this.matchType,
    required this.matchedText,
  });

  final Highlight highlight;
  final Note? note;
  final AnnotationMatchType matchType;
  final String matchedText;

  @override
  String toString() =>
      'AnnotationSearchResult(type: $matchType, text: $matchedText)';
}

/// Type of match in annotation search
enum AnnotationMatchType { highlightText, noteContent, both }

/// Statistics about annotations for a PDF
class AnnotationStats {
  const AnnotationStats({
    required this.totalHighlights,
    required this.totalNotes,
    required this.highlightsByColor,
    required this.annotationsByPage,
    required this.averageHighlightLength,
    required this.averageNoteLength,
    required this.mostAnnotatedPages,
  });

  final int totalHighlights;
  final int totalNotes;
  final Map<String, int> highlightsByColor; // Color name -> count
  final Map<int, int> annotationsByPage; // Page number -> count
  final double averageHighlightLength;
  final double averageNoteLength;
  final List<int> mostAnnotatedPages; // Top 5 most annotated pages

  @override
  String toString() =>
      'AnnotationStats(highlights: $totalHighlights, notes: $totalNotes)';
}
