import 'dart:typed_data';

/// Interface for PDF-related operations
abstract class IPdfService {
  /// Download and cache a PDF from the given URL
  /// Returns the local file path of the cached PDF
  Future<String> downloadAndCachePdf(String url);

  /// Extract text content from a specific page
  /// Returns a list of text strings found on the page
  Future<List<String>> extractTextFromPage(int pageNumber);

  /// Generate a thumbnail image for a specific page
  /// Returns the thumbnail as bytes
  Future<Uint8List> generateThumbnail(
    int pageNumber, {
    int width = 200,
    int height = 300,
  });

  /// Search for text within the PDF
  /// Returns a list of search results with page numbers and positions
  Future<List<SearchResult>> searchInPdf(String query);

  /// Get the total number of pages in the PDF
  Future<int> getPageCount();

  /// Extract table of contents/outline from the PDF
  /// Returns a hierarchical structure of the document outline
  Future<List<OutlineItem>> extractOutline();

  /// Check if the PDF is password protected
  Future<bool> isPasswordProtected();

  /// Validate if the PDF file is corrupted or invalid
  Future<bool> validatePdf(String filePath);
}

/// Represents a search result within the PDF
class SearchResult {
  const SearchResult({
    required this.pageNumber,
    required this.text,
    required this.boundingBox,
    required this.context,
  });

  final int pageNumber;
  final String text;
  final Rect boundingBox;
  final String context; // Surrounding text for context

  @override
  String toString() => 'SearchResult(page: $pageNumber, text: $text)';
}

/// Represents an outline/table of contents item
class OutlineItem {
  const OutlineItem({
    required this.title,
    required this.pageNumber,
    this.level = 0,
    this.children = const [],
  });

  final String title;
  final int pageNumber;
  final int level; // Hierarchy level (0 = top level)
  final List<OutlineItem> children;

  @override
  String toString() =>
      'OutlineItem(title: $title, page: $pageNumber, level: $level)';
}

/// Custom Rect class for search results (since we can't import Flutter's Rect here)
class Rect {
  const Rect.fromLTRB(this.left, this.top, this.right, this.bottom);

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;

  @override
  String toString() => 'Rect.fromLTRB($left, $top, $right, $bottom)';
}
