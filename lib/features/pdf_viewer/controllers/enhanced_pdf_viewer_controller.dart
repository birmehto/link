import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../shared/models/book.dart';
import '../../../shared/shared.dart';
import '../models/models.dart';
import 'pdf_viewer_controller.dart';

class EnhancedPdfViewerController extends GetxController {
  // Core PDF functionality - delegate to existing controller
  late final PdfViewerPageController _pdfController;

  // Enhanced features state
  final highlights = <Highlight>[].obs;
  final notes = <Note>[].obs;
  final bookmarks = <Bookmark>[].obs;
  final readingSessions = <ReadingSession>[].obs;
  final readingStats = Rxn<ReadingStats>();
  final readingPreferences = Rxn<ReadingPreferences>();

  // Current reading session tracking
  final currentSession = Rxn<ReadingSession>();
  final sessionStartTime = Rxn<DateTime>();
  final sessionStartPage = 1.obs;

  // Annotation state
  final selectedText = Rxn<String>();
  final selectedTextBounds = Rxn<Rect>();
  final isAnnotationMode = false.obs;
  final selectedHighlightColor = Colors.yellow.obs;

  // UI state
  final isControlsVisible = true.obs;
  final isAnnotationToolbarVisible = false.obs;
  final isBookmarkPanelVisible = false.obs;
  final isStatsPanelVisible = false.obs;

  // Auto-hide timer
  Timer? _autoHideTimer;

  // Hive boxes for persistence
  Box<Highlight>? _highlightsBox;
  Box<Note>? _notesBox;
  Box<Bookmark>? _bookmarksBox;
  Box<ReadingSession>? _sessionsBox;
  Box<ReadingStats>? _statsBox;
  Box<ReadingPreferences>? _preferencesBox;

  // Current PDF info
  String? _currentPdfId;
  String? _currentPdfTitle;

  // Getters to expose core PDF controller functionality
  PdfViewerPageController get pdfController => _pdfController;
  bool get isLoading => _pdfController.isLoading.value;
  bool get hasError => _pdfController.hasError.value;
  String? get errorMessage => _pdfController.errorMessage;
  int get currentPageNumber => _pdfController.currentPageNumber.value;
  int get totalPages => _pdfController.totalPages.value;
  bool get pdfReady => _pdfController.pdfReady.value;
  double get downloadProgress => _pdfController.downloadProgress.value;

  @override
  void onInit() {
    super.onInit();
    _initializeHiveBoxes();
    _initializePdfController();
    _loadDefaultPreferences();
  }

  // Initialize Hive storage boxes
  Future<void> _initializeHiveBoxes() async {
    try {
      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HighlightAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(NoteAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(BookmarkAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(ReadingSessionAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(ReadingStatsAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(ReadingThemeAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(PageTransitionTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(7)) {
        Hive.registerAdapter(ReadingPreferencesAdapter());
      }
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(RectAdapter());
      }
      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(ColorAdapter());
      }
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(DateTimeAdapter());
      }

      // Open boxes
      _highlightsBox = await Hive.openBox<Highlight>('highlights');
      _notesBox = await Hive.openBox<Note>('notes');
      _bookmarksBox = await Hive.openBox<Bookmark>('bookmarks');
      _sessionsBox = await Hive.openBox<ReadingSession>('reading_sessions');
      _statsBox = await Hive.openBox<ReadingStats>('reading_stats');
      _preferencesBox = await Hive.openBox<ReadingPreferences>(
        'reading_preferences',
      );

      log('Enhanced PDF viewer Hive boxes initialized successfully');
    } catch (e, stackTrace) {
      log('Failed to initialize Hive boxes', error: e, stackTrace: stackTrace);
    }
  }

  // Initialize the core PDF controller
  void _initializePdfController() {
    _pdfController = Get.put(PdfViewerPageController(), permanent: false);

    // Listen to page changes to track reading progress
    ever(_pdfController.currentPageNumber, (int page) {
      _onPageChanged(page);
    });

    // Listen to PDF ready state to load annotations
    ever(_pdfController.pdfReady, (bool ready) {
      if (ready) {
        _onPdfReady();
      }
    });
  }

  // Load default reading preferences
  void _loadDefaultPreferences() {
    final savedPrefs = _preferencesBox?.get('default');
    if (savedPrefs != null) {
      readingPreferences.value = savedPrefs;
    } else {
      readingPreferences.value = const ReadingPreferences();
      _savePreferences();
    }

    // Apply auto-hide settings
    if (readingPreferences.value?.autoHideControls == true) {
      _startAutoHideTimer();
    }
  }

  // Initialize PDF with enhanced features
  Future<void> initializePdf(
    String url, {
    String? title,
    Book? bookData,
  }) async {
    try {
      _currentPdfId = _generatePdfId(url);
      _currentPdfTitle = title ?? bookData?.title ?? 'Unknown Document';

      // Initialize core PDF functionality
      await _pdfController.initialize(url, title: title);

      // Load existing annotations and bookmarks for this PDF
      await _loadPdfData();

      // Start reading session
      _startReadingSession();
    } catch (e, stackTrace) {
      log(
        'Failed to initialize enhanced PDF viewer',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Generate a unique PDF ID from URL
  String _generatePdfId(String url) {
    return url.hashCode.abs().toString();
  }

  // Load existing data for the current PDF
  Future<void> _loadPdfData() async {
    if (_currentPdfId == null) return;

    try {
      // Load highlights
      final pdfHighlights =
          _highlightsBox?.values
              .where((h) => h.pdfId == _currentPdfId)
              .toList() ??
          [];
      highlights.assignAll(pdfHighlights);

      // Load notes
      final pdfNotes =
          _notesBox?.values
              .where(
                (n) =>
                    n.highlightId != null &&
                    pdfHighlights.any((h) => h.id == n.highlightId),
              )
              .toList() ??
          [];
      notes.assignAll(pdfNotes);

      // Load bookmarks
      final pdfBookmarks =
          _bookmarksBox?.values
              .where((b) => b.pdfId == _currentPdfId)
              .toList() ??
          [];
      bookmarks.assignAll(pdfBookmarks);

      // Load reading stats
      final stats = _statsBox?.get(_currentPdfId!);
      if (stats != null) {
        readingStats.value = stats;
        readingSessions.assignAll(stats.sessions);
      } else {
        readingStats.value = ReadingStats(pdfId: _currentPdfId!, sessions: []);
      }

      log(
        'Loaded PDF data: ${highlights.length} highlights, ${bookmarks.length} bookmarks',
      );
    } catch (e, stackTrace) {
      log('Failed to load PDF data', error: e, stackTrace: stackTrace);
    }
  }

  // Start a new reading session
  void _startReadingSession() {
    sessionStartTime.value = DateTime.now();
    sessionStartPage.value = currentPageNumber;

    final session = ReadingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pdfId: _currentPdfId!,
      startTime: sessionStartTime.value!,
      endTime: sessionStartTime.value!, // Will be updated when session ends
      startPage: sessionStartPage.value,
      endPage: sessionStartPage.value, // Will be updated as user reads
    );

    currentSession.value = session;
  }

  // Handle page changes
  void _onPageChanged(int page) {
    // Update current session end page
    if (currentSession.value != null) {
      currentSession.value = currentSession.value!.copyWith(
        endPage: page,
        endTime: DateTime.now(),
      );
    }

    // Restart auto-hide timer
    if (readingPreferences.value?.autoHideControls == true) {
      _startAutoHideTimer();
    }
  }

  // Handle PDF ready state
  void _onPdfReady() {
    log('PDF ready, enhanced features initialized');
    // Any additional setup when PDF is ready
  }

  // Auto-hide controls functionality
  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();

    final delay =
        readingPreferences.value?.autoHideDelay ?? const Duration(seconds: 3);
    _autoHideTimer = Timer(delay, () {
      if (isControlsVisible.value && !isAnnotationMode.value) {
        isControlsVisible.value = false;
      }
    });
  }

  // Toggle controls visibility
  void toggleControls() {
    isControlsVisible.toggle();

    if (isControlsVisible.value &&
        readingPreferences.value?.autoHideControls == true) {
      _startAutoHideTimer();
    } else {
      _autoHideTimer?.cancel();
    }
  }

  // Save current reading preferences
  Future<void> _savePreferences() async {
    if (readingPreferences.value != null) {
      await _preferencesBox?.put('default', readingPreferences.value!);
    }
  }

  // Update reading preferences
  Future<void> updatePreferences(ReadingPreferences newPreferences) async {
    readingPreferences.value = newPreferences;
    await _savePreferences();

    // Apply new settings
    if (newPreferences.autoHideControls) {
      _startAutoHideTimer();
    } else {
      _autoHideTimer?.cancel();
    }
  }

  // End current reading session and save stats
  Future<void> _endReadingSession() async {
    if (currentSession.value == null || _currentPdfId == null) return;

    try {
      final endedSession = currentSession.value!.copyWith(
        endTime: DateTime.now(),
        endPage: currentPageNumber,
      );

      // Only save valid sessions (minimum duration)
      if (endedSession.isValidSession) {
        // Save session
        await _sessionsBox?.add(endedSession);
        readingSessions.add(endedSession);

        // Update reading stats
        final updatedStats =
            (readingStats.value ??
                    ReadingStats(pdfId: _currentPdfId!, sessions: []))
                .addSession(endedSession);

        readingStats.value = updatedStats;
        await _statsBox?.put(_currentPdfId!, updatedStats);

        log(
          'Reading session saved: ${endedSession.formattedDuration}, ${endedSession.pagesRead} pages',
        );
      }

      currentSession.value = null;
    } catch (e, stackTrace) {
      log('Failed to end reading session', error: e, stackTrace: stackTrace);
    }
  }

  // Delegate core PDF methods to the underlying controller
  Future<void> sharePdf() => _pdfController.sharePdf();
  Future<void> savePdfToDevice() => _pdfController.savePdfToDevice();
  void nextPage() => _pdfController.nextPage();
  void previousPage() => _pdfController.previousPage();
  void jumpToPage(int page) => _pdfController.jumpToPage(page);
  void zoomIn() => _pdfController.zoomIn();
  void zoomOut() => _pdfController.zoomOut();
  void resetZoom() => _pdfController.resetZoom();
  void fitWidth() => _pdfController.fitWidth();
  Future<void> searchText(String text) => _pdfController.searchText(text);
  void nextSearchResult() => _pdfController.nextSearchResult();
  void previousSearchResult() => _pdfController.previousSearchResult();
  void clearSearch() => _pdfController.clearSearch();
  void toggleNightMode() => _pdfController.toggleNightMode();
  void toggleFullscreen() => _pdfController.toggleFullscreen();
  Future<void> retry() => _pdfController.retry();

  @override
  void onClose() {
    // End current reading session
    _endReadingSession();

    // Cancel timers
    _autoHideTimer?.cancel();

    // Close Hive boxes
    _highlightsBox?.close();
    _notesBox?.close();
    _bookmarksBox?.close();
    _sessionsBox?.close();
    _statsBox?.close();
    _preferencesBox?.close();

    // Dispose core controller
    _pdfController.onClose();

    super.onClose();
  }
}
