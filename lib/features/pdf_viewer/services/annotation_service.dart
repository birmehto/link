import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import 'annotation_service_interface.dart';

/// Concrete implementation of annotation service using Hive for local storage
class AnnotationService implements IAnnotationService {
  static const String _highlightsBoxName = 'highlights';
  static const String _notesBoxName = 'notes';
  static const _uuid = Uuid();

  Box<Highlight>? _highlightsBox;
  Box<Note>? _notesBox;

  /// Initialize the service and open Hive boxes
  Future<void> initialize() async {
    if (_highlightsBox == null || !_highlightsBox!.isOpen) {
      _highlightsBox = await Hive.openBox<Highlight>(_highlightsBoxName);
    }
    if (_notesBox == null || !_notesBox!.isOpen) {
      _notesBox = await Hive.openBox<Note>(_notesBoxName);
    }
  }

  /// Ensure boxes are initialized
  Future<void> _ensureInitialized() async {
    if (_highlightsBox == null ||
        !_highlightsBox!.isOpen ||
        _notesBox == null ||
        !_notesBox!.isOpen) {
      await initialize();
    }
  }

  @override
  Future<void> saveHighlight(Highlight highlight) async {
    await _ensureInitialized();
    await _highlightsBox!.put(highlight.id, highlight);
  }

  @override
  Future<void> saveNote(Note note) async {
    await _ensureInitialized();
    await _notesBox!.put(note.id, note);
  }

  @override
  Future<void> updateHighlight(Highlight highlight) async {
    await _ensureInitialized();
    if (_highlightsBox!.containsKey(highlight.id)) {
      await _highlightsBox!.put(highlight.id, highlight);
    } else {
      throw Exception('Highlight with id ${highlight.id} not found');
    }
  }

  @override
  Future<void> updateNote(Note note) async {
    await _ensureInitialized();
    if (_notesBox!.containsKey(note.id)) {
      final updatedNote = note.copyWith(modifiedAt: DateTime.now());
      await _notesBox!.put(note.id, updatedNote);
    } else {
      throw Exception('Note with id ${note.id} not found');
    }
  }

  @override
  Future<void> deleteHighlight(String highlightId) async {
    await _ensureInitialized();

    // Get the highlight to check if it has an associated note
    final highlight = await getHighlight(highlightId);
    if (highlight != null && highlight.hasNote) {
      // Delete the associated note
      await deleteNote(highlight.noteId!);
    }

    await _highlightsBox!.delete(highlightId);
  }

  @override
  Future<void> deleteNote(String noteId) async {
    await _ensureInitialized();
    await _notesBox!.delete(noteId);
  }

  @override
  Future<List<Highlight>> getHighlightsForPdf(String pdfId) async {
    await _ensureInitialized();
    return _highlightsBox!.values
        .where((highlight) => highlight.pdfId == pdfId)
        .toList()
      ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
  }

  @override
  Future<List<Note>> getNotesForPdf(String pdfId) async {
    await _ensureInitialized();
    final highlights = await getHighlightsForPdf(pdfId);
    final noteIds = highlights
        .where((h) => h.hasNote)
        .map((h) => h.noteId!)
        .toSet();

    return _notesBox!.values.where((note) => noteIds.contains(note.id)).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<Highlight?> getHighlight(String highlightId) async {
    await _ensureInitialized();
    return _highlightsBox!.get(highlightId);
  }

  @override
  Future<Note?> getNote(String noteId) async {
    await _ensureInitialized();
    return _notesBox!.get(noteId);
  }

  @override
  Future<List<Note>> getNotesForHighlight(String highlightId) async {
    await _ensureInitialized();
    return _notesBox!.values
        .where((note) => note.highlightId == highlightId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<String> exportAnnotations(String pdfId, ExportFormat format) async {
    await _ensureInitialized();

    final highlights = await getHighlightsForPdf(pdfId);
    final notes = await getNotesForPdf(pdfId);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'annotations_${pdfId}_$timestamp';

    switch (format) {
      case ExportFormat.json:
        return await _exportAsJson(highlights, notes, directory, fileName);
      case ExportFormat.markdown:
        return await _exportAsMarkdown(highlights, notes, directory, fileName);
      case ExportFormat.txt:
        return await _exportAsText(highlights, notes, directory, fileName);
      case ExportFormat.csv:
        return await _exportAsCsv(highlights, notes, directory, fileName);
      case ExportFormat.html:
        return await _exportAsHtml(highlights, notes, directory, fileName);
    }
  }

  @override
  Future<List<Highlight>> importAnnotations(String filePath) async {
    await _ensureInitialized();

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Import file not found: $filePath');
    }

    final content = await file.readAsString();
    final jsonData = jsonDecode(content) as Map<String, dynamic>;

    final highlightsJson = jsonData['highlights'] as List<dynamic>;
    final notesJson = jsonData['notes'] as List<dynamic>;

    final highlights = highlightsJson
        .map((json) => Highlight.fromJson(json as Map<String, dynamic>))
        .toList();

    final notes = notesJson
        .map((json) => Note.fromJson(json as Map<String, dynamic>))
        .toList();

    // Save imported data
    for (final highlight in highlights) {
      await saveHighlight(highlight);
    }

    for (final note in notes) {
      await saveNote(note);
    }

    return highlights;
  }

  @override
  Future<List<AnnotationSearchResult>> searchAnnotations(
    String query, {
    String? pdfId,
  }) async {
    await _ensureInitialized();

    final results = <AnnotationSearchResult>[];
    final queryLower = query.toLowerCase();

    // Get highlights to search
    final highlights = pdfId != null
        ? await getHighlightsForPdf(pdfId)
        : _highlightsBox!.values.toList();

    for (final highlight in highlights) {
      final highlightMatches = highlight.selectedText.toLowerCase().contains(
        queryLower,
      );
      Note? associatedNote;
      bool noteMatches = false;

      if (highlight.hasNote) {
        associatedNote = await getNote(highlight.noteId!);
        noteMatches =
            associatedNote?.content.toLowerCase().contains(queryLower) ?? false;
      }

      if (highlightMatches || noteMatches) {
        final matchType = highlightMatches && noteMatches
            ? AnnotationMatchType.both
            : highlightMatches
            ? AnnotationMatchType.highlightText
            : AnnotationMatchType.noteContent;

        final matchedText = highlightMatches
            ? highlight.selectedText
            : associatedNote?.content ?? '';

        results.add(
          AnnotationSearchResult(
            highlight: highlight,
            note: associatedNote,
            matchType: matchType,
            matchedText: matchedText,
          ),
        );
      }
    }

    return results;
  }

  @override
  Future<AnnotationStats> getAnnotationStats(String pdfId) async {
    await _ensureInitialized();

    final highlights = await getHighlightsForPdf(pdfId);
    final notes = await getNotesForPdf(pdfId);

    // Calculate statistics
    final highlightsByColor = <String, int>{};
    final annotationsByPage = <int, int>{};
    double totalHighlightLength = 0;
    double totalNoteLength = 0;

    for (final highlight in highlights) {
      // Count by color
      final colorName = highlight.colorName;
      highlightsByColor[colorName] = (highlightsByColor[colorName] ?? 0) + 1;

      // Count by page
      annotationsByPage[highlight.pageNumber] =
          (annotationsByPage[highlight.pageNumber] ?? 0) + 1;

      // Calculate length
      totalHighlightLength += highlight.selectedText.length;
    }

    for (final note in notes) {
      totalNoteLength += note.content.length;
    }

    // Find most annotated pages
    final sortedPages = annotationsByPage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final mostAnnotatedPages = sortedPages
        .take(5)
        .map((entry) => entry.key)
        .toList();

    return AnnotationStats(
      totalHighlights: highlights.length,
      totalNotes: notes.length,
      highlightsByColor: highlightsByColor,
      annotationsByPage: annotationsByPage,
      averageHighlightLength: highlights.isEmpty
          ? 0
          : totalHighlightLength / highlights.length,
      averageNoteLength: notes.isEmpty ? 0 : totalNoteLength / notes.length,
      mostAnnotatedPages: mostAnnotatedPages,
    );
  }

  @override
  Future<String> backupAnnotations() async {
    await _ensureInitialized();

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = '${directory.path}/annotations_backup_$timestamp.json';

    final allHighlights = _highlightsBox!.values.toList();
    final allNotes = _notesBox!.values.toList();

    final backupData = {
      'version': '1.0',
      'timestamp': timestamp,
      'highlights': allHighlights.map((h) => h.toJson()).toList(),
      'notes': allNotes.map((n) => n.toJson()).toList(),
    };

    final file = File(backupPath);
    await file.writeAsString(jsonEncode(backupData));

    return backupPath;
  }

  @override
  Future<void> restoreAnnotations(String backupFilePath) async {
    await _ensureInitialized();

    final file = File(backupFilePath);
    if (!await file.exists()) {
      throw Exception('Backup file not found: $backupFilePath');
    }

    final content = await file.readAsString();
    final backupData = jsonDecode(content) as Map<String, dynamic>;

    // Clear existing data
    await _highlightsBox!.clear();
    await _notesBox!.clear();

    // Restore highlights
    final highlightsJson = backupData['highlights'] as List<dynamic>;
    for (final json in highlightsJson) {
      final highlight = Highlight.fromJson(json as Map<String, dynamic>);
      await saveHighlight(highlight);
    }

    // Restore notes
    final notesJson = backupData['notes'] as List<dynamic>;
    for (final json in notesJson) {
      final note = Note.fromJson(json as Map<String, dynamic>);
      await saveNote(note);
    }
  }

  // Helper methods for export functionality
  Future<String> _exportAsJson(
    List<Highlight> highlights,
    List<Note> notes,
    Directory directory,
    String fileName,
  ) async {
    final filePath = '${directory.path}/$fileName.json';
    final data = {
      'highlights': highlights.map((h) => h.toJson()).toList(),
      'notes': notes.map((n) => n.toJson()).toList(),
    };

    final file = File(filePath);
    await file.writeAsString(jsonEncode(data));
    return filePath;
  }

  Future<String> _exportAsMarkdown(
    List<Highlight> highlights,
    List<Note> notes,
    Directory directory,
    String fileName,
  ) async {
    final filePath = '${directory.path}/$fileName.md';
    final buffer = StringBuffer();

    buffer.writeln('# PDF Annotations Export');
    buffer.writeln();
    buffer.writeln('Generated on: ${DateTime.now().toIso8601String()}');
    buffer.writeln();

    if (highlights.isNotEmpty) {
      buffer.writeln('## Highlights');
      buffer.writeln();

      for (final highlight in highlights) {
        buffer.writeln('### Page ${highlight.pageNumber}');
        buffer.writeln('**Color:** ${highlight.colorName}');
        buffer.writeln('**Text:** ${highlight.selectedText}');
        buffer.writeln('**Created:** ${highlight.createdAt.toIso8601String()}');

        if (highlight.hasNote) {
          final note = notes.firstWhere(
            (n) => n.id == highlight.noteId,
            orElse: () => throw Exception('Note not found'),
          );
          buffer.writeln('**Note:** ${note.content}');
        }

        buffer.writeln();
      }
    }

    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    return filePath;
  }

  Future<String> _exportAsHtml(
    List<Highlight> highlights,
    List<Note> notes,
    Directory directory,
    String fileName,
  ) async {
    final filePath = '${directory.path}/$fileName.html';
    final buffer = StringBuffer();

    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html><head><title>PDF Annotations</title></head><body>');
    buffer.writeln('<h1>PDF Annotations Export</h1>');
    buffer.writeln('<p>Generated on: ${DateTime.now().toIso8601String()}</p>');

    if (highlights.isNotEmpty) {
      buffer.writeln('<h2>Highlights</h2>');

      for (final highlight in highlights) {
        buffer.writeln(
          '<div style="margin-bottom: 20px; padding: 10px; border-left: 4px solid #ffeb3b;">',
        );
        buffer.writeln('<h3>Page ${highlight.pageNumber}</h3>');
        buffer.writeln(
          '<p><strong>Text:</strong> ${highlight.selectedText}</p>',
        );
        buffer.writeln('<p><strong>Color:</strong> ${highlight.colorName}</p>');
        buffer.writeln(
          '<p><strong>Created:</strong> ${highlight.createdAt.toIso8601String()}</p>',
        );

        if (highlight.hasNote) {
          final note = notes.firstWhere(
            (n) => n.id == highlight.noteId,
            orElse: () => throw Exception('Note not found'),
          );
          buffer.writeln('<p><strong>Note:</strong> ${note.content}</p>');
        }

        buffer.writeln('</div>');
      }
    }

    buffer.writeln('</body></html>');

    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    return filePath;
  }

  Future<String> _exportAsText(
    List<Highlight> highlights,
    List<Note> notes,
    Directory directory,
    String fileName,
  ) async {
    final filePath = '${directory.path}/$fileName.txt';
    final buffer = StringBuffer();

    buffer.writeln('PDF ANNOTATIONS EXPORT');
    buffer.writeln('======================');
    buffer.writeln();
    buffer.writeln('Generated on: ${DateTime.now().toIso8601String()}');
    buffer.writeln();

    if (highlights.isNotEmpty) {
      buffer.writeln('HIGHLIGHTS');
      buffer.writeln('----------');
      buffer.writeln();

      for (final highlight in highlights) {
        buffer.writeln('Page ${highlight.pageNumber} (${highlight.colorName})');
        buffer.writeln('Text: ${highlight.selectedText}');
        buffer.writeln('Created: ${highlight.createdAt.toIso8601String()}');

        if (highlight.hasNote) {
          final note = notes.firstWhere(
            (n) => n.id == highlight.noteId,
            orElse: () => throw Exception('Note not found'),
          );
          buffer.writeln('Note: ${note.content}');
        }

        buffer.writeln();
      }
    }

    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    return filePath;
  }

  Future<String> _exportAsCsv(
    List<Highlight> highlights,
    List<Note> notes,
    Directory directory,
    String fileName,
  ) async {
    final filePath = '${directory.path}/$fileName.csv';
    final buffer = StringBuffer();

    // CSV header
    buffer.writeln('Page,Color,Text,Note,Created,Modified');

    for (final highlight in highlights) {
      String noteContent = '';
      String modifiedDate = '';

      if (highlight.hasNote) {
        final note = notes.firstWhere(
          (n) => n.id == highlight.noteId,
          orElse: () => throw Exception('Note not found'),
        );
        noteContent = note.content.replaceAll('"', '""'); // Escape quotes
        modifiedDate = note.modifiedAt?.toIso8601String() ?? '';
      }

      final escapedText = highlight.selectedText.replaceAll('"', '""');
      buffer.writeln(
        '${highlight.pageNumber},"${highlight.colorName}","$escapedText","$noteContent","${highlight.createdAt.toIso8601String()}","$modifiedDate"',
      );
    }

    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    return filePath;
  }

  /// Generate a unique ID for annotations
  String generateId() => _uuid.v4();

  /// Close the Hive boxes
  Future<void> dispose() async {
    await _highlightsBox?.close();
    await _notesBox?.close();
  }
}
