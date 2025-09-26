import '../models/models.dart';

/// Interface for bookmark-related operations
abstract class IBookmarkService {
  /// Add a new bookmark
  Future<void> addBookmark(Bookmark bookmark);

  /// Update an existing bookmark
  Future<void> updateBookmark(Bookmark bookmark);

  /// Remove a bookmark by ID
  Future<void> removeBookmark(String bookmarkId);

  /// Get all bookmarks for a specific PDF
  Future<List<Bookmark>> getBookmarksForPdf(String pdfId);

  /// Get a specific bookmark by ID
  Future<Bookmark?> getBookmark(String bookmarkId);

  /// Check if a page is bookmarked
  Future<bool> isPageBookmarked(String pdfId, int pageNumber);

  /// Get bookmark for a specific page (if exists)
  Future<Bookmark?> getBookmarkForPage(String pdfId, int pageNumber);

  /// Search bookmarks by title or description
  Future<List<Bookmark>> searchBookmarks(String query, {String? pdfId});

  /// Get bookmarks sorted by various criteria
  Future<List<Bookmark>> getSortedBookmarks(
    String pdfId,
    BookmarkSortCriteria sortBy, {
    bool ascending = true,
  });

  /// Export bookmarks for a PDF
  Future<String> exportBookmarks(String pdfId, BookmarkExportFormat format);

  /// Import bookmarks from a file
  Future<List<Bookmark>> importBookmarks(String filePath);

  /// Get bookmark statistics for a PDF
  Future<BookmarkStats> getBookmarkStats(String pdfId);

  /// Get recently added bookmarks
  Future<List<Bookmark>> getRecentBookmarks({int limit = 10, String? pdfId});

  /// Backup all bookmarks
  Future<String> backupBookmarks();

  /// Restore bookmarks from backup
  Future<void> restoreBookmarks(String backupFilePath);

  /// Organize bookmarks into categories/folders
  Future<void> categorizeBookmark(String bookmarkId, String category);

  /// Get bookmarks by category
  Future<List<Bookmark>> getBookmarksByCategory(
    String category, {
    String? pdfId,
  });

  /// Get all bookmark categories
  Future<List<String>> getBookmarkCategories({String? pdfId});
}

/// Sorting criteria for bookmarks
enum BookmarkSortCriteria { pageNumber, createdDate, title, category }

/// Export format options for bookmarks
enum BookmarkExportFormat { json, markdown, html, txt, csv }

/// Statistics about bookmarks for a PDF
class BookmarkStats {
  const BookmarkStats({
    required this.totalBookmarks,
    required this.bookmarksByPage,
    required this.bookmarksByCategory,
    required this.averageBookmarksPerPage,
    required this.mostBookmarkedPages,
    required this.bookmarkCreationTrend,
  });

  final int totalBookmarks;
  final Map<int, int> bookmarksByPage; // Page number -> count
  final Map<String, int> bookmarksByCategory; // Category -> count
  final double averageBookmarksPerPage;
  final List<int> mostBookmarkedPages; // Top 5 most bookmarked pages
  final Map<String, int>
  bookmarkCreationTrend; // Date -> count of bookmarks created

  @override
  String toString() =>
      'BookmarkStats(total: $totalBookmarks, categories: ${bookmarksByCategory.length})';
}
