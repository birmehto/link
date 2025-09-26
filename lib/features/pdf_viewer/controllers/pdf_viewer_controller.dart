import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../shared/shared.dart';

class PdfViewerPageController extends GetxController {
  // Reactive state variables
  final isLoading = true.obs;
  final hasError = false.obs;
  final currentPageNumber = 1.obs;
  final totalPages = 0.obs;
  final isFullscreen = false.obs;
  final pdfReady = false.obs;
  final isNightMode = false.obs;
  final zoomLevel = 1.0.obs;

  // Download progress (0–100)
  final downloadProgress = 0.0.obs;

  // Search functionality
  final isSearching = false.obs;
  final searchQuery = ''.obs;
  final searchResultCount = 0.obs;
  final currentSearchIndex = 0.obs;

  // PDF controller
  PdfViewerController? pdfController;
  PdfTextSearchResult? currentSearchResult;

  // Dio for download
  final Dio _dio = Dio();

  // Other properties
  String? _pdfUrl;
  String? _errorMessage;
  String? _localPath;

  // Getters
  String? get errorMessage => _errorMessage;
  String? get pdfUrl => _pdfUrl;
  String? get localPath => _localPath;

  // Initialize PDF viewer with URL
  Future<void> initialize(String url, {String? title}) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      pdfReady.value = false;
      downloadProgress.value = 0;

      _pdfUrl = url;
      pdfController = PdfViewerController();

      // Download and cache PDF
      await _downloadAndCachePdf(url);

      debugPrint('PDF download completed, setting ready state');
      pdfReady.value = true;

      // Set fallback page count in case onDocumentLoaded doesn't trigger
      _setFallbackPageCount();
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      hasError.value = true;
      log('PDF load failed', error: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------------------
  // Download PDF to app storage
  // ------------------------------
  Future<void> _downloadAndCachePdf(String url) async {
    try {
      // Get app-specific storage directory
      Directory directory;
      if (Platform.isAndroid) {
        directory = (await getExternalStorageDirectory())!;
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getTemporaryDirectory();
      }

      final fileName = url.split('/').last;
      _localPath = '${directory.path}/$fileName';

      // Download with progress
      await _dio.download(
        url,
        _localPath,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total > 0) {
            downloadProgress.value = (received / total * 100);
          }
        },
      );

      debugPrint('PDF downloaded to: $_localPath');

      // Verify the file exists and has content
      final file = File(_localPath!);
      if (await file.exists()) {
        final fileSize = await file.length();
        debugPrint('PDF file size: $fileSize bytes');
        if (fileSize == 0) {
          throw Exception('Downloaded PDF file is empty');
        }
      } else {
        throw Exception('Downloaded PDF file does not exist');
      }
    } catch (e) {
      _errorMessage = 'Failed to download PDF: $e';
      hasError.value = true;
      rethrow;
    }
  }

  // ------------------------------
  // Document loaded callback
  // ------------------------------
  void onDocumentLoaded(PdfDocumentLoadedDetails details) {
    totalPages.value = details.document.pages.count;
    currentPageNumber.value = 1;
    debugPrint('PDF loaded with ${totalPages.value} pages');
  }

  // Fallback method to set total pages if callback doesn't work
  void _setFallbackPageCount() {
    // This will be called after a delay to ensure PDF is loaded
    Timer(const Duration(milliseconds: 1000), () {
      if (totalPages.value == 0 && pdfController != null) {
        // Try to get page count from controller if available
        debugPrint('Using fallback page count method');
        totalPages.value = 1; // Set to 1 as minimum to show the PDF
      }
    });
  }

  // ------------------------------
  // Share PDF file
  // ------------------------------
  Future<void> sharePdf() async {
    if (_localPath == null) return;
    try {
      await Share.shareXFiles([XFile(_localPath!)], text: 'Sharing PDF');
    } catch (e) {
      _showErrorSnackbar('Failed to share PDF: $e');
    }
  }

  // ------------------------------
  // Save PDF to device (Downloads)
  // ------------------------------
  Future<void> savePdfToDevice() async {
    if (_localPath == null) return;

    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!directory.existsSync()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      final fileName = _pdfUrl?.split('/').last ?? 'document.pdf';
      final savePath = '${directory!.path}/$fileName';

      await File(_localPath!).copy(savePath);

      Get.snackbar(
        'Download Complete',
        'PDF saved to $savePath',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _showErrorSnackbar('Failed to save PDF: $e');
    }
  }

  // ------------------------------
  // Page navigation
  // ------------------------------
  void onPageChanged(PdfPageChangedDetails details) {
    currentPageNumber.value = details.newPageNumber;
  }

  void nextPage() {
    if (pdfController != null && currentPageNumber.value < totalPages.value) {
      pdfController!.nextPage();
    }
  }

  void previousPage() {
    if (pdfController != null && currentPageNumber.value > 1) {
      pdfController!.previousPage();
    }
  }

  void jumpToPage(int page) {
    if (pdfController != null && page > 0 && page <= totalPages.value) {
      pdfController!.jumpToPage(page);
    }
  }

  // ------------------------------
  // Zoom controls
  // ------------------------------
  void zoomIn() {
    if (pdfController != null) {
      final newZoom = (zoomLevel.value * 1.25).clamp(0.5, 3.0);
      pdfController!.zoomLevel = newZoom;
      zoomLevel.value = newZoom;
    }
  }

  void zoomOut() {
    if (pdfController != null) {
      final newZoom = (zoomLevel.value / 1.25).clamp(0.5, 3.0);
      pdfController!.zoomLevel = newZoom;
      zoomLevel.value = newZoom;
    }
  }

  void resetZoom() {
    if (pdfController != null) {
      pdfController!.zoomLevel = 1.0;
      zoomLevel.value = 1.0;
    }
  }

  void fitWidth() {
    if (pdfController != null) {
      pdfController!.zoomLevel =
          1.0; // Syncfusion handles fit width automatically
    }
  }

  // ------------------------------
  // Search functionality
  // ------------------------------
  Future<void> searchText(String text) async {
    if (text.isEmpty || pdfController == null) return;

    isSearching.value = true;
    searchQuery.value = text;

    try {
      currentSearchResult = pdfController!.searchText(text);
      if (currentSearchResult != null) {
        searchResultCount.value = currentSearchResult!.totalInstanceCount;
        currentSearchIndex.value = 0;
        if (searchResultCount.value > 0) {
          currentSearchResult!.nextInstance();
        }
      }
    } catch (e) {
      log('Search error: $e');
    } finally {
      isSearching.value = false;
    }
  }

  void nextSearchResult() {
    if (currentSearchResult != null && searchResultCount.value > 0) {
      currentSearchResult!.nextInstance();
      currentSearchIndex.value =
          (currentSearchIndex.value + 1) % searchResultCount.value;
    }
  }

  void previousSearchResult() {
    if (currentSearchResult != null && searchResultCount.value > 0) {
      currentSearchResult!.previousInstance();
      currentSearchIndex.value = currentSearchIndex.value > 0
          ? currentSearchIndex.value - 1
          : searchResultCount.value - 1;
    }
  }

  void clearSearch() {
    currentSearchResult?.clear();
    searchResultCount.value = 0;
    searchQuery.value = '';
    currentSearchIndex.value = 0;
    isSearching.value = false;
  }

  // ------------------------------
  // Text selection and copy
  // ------------------------------
  void copySelectedText() {
    // Note: Syncfusion PDF viewer handles text selection and copy automatically
    // when text is selected. This method can be used for custom copy functionality
    Get.snackbar(
      'Info',
      'Select text in the PDF and use the context menu to copy',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // ------------------------------
  // Night mode
  // ------------------------------
  void toggleNightMode() {
    isNightMode.toggle();
  }

  // ------------------------------
  // Fullscreen / AppBar
  // ------------------------------
  final RxBool _isAppBarVisible = true.obs;
  Timer? _appBarTimer;

  void toggleFullscreen() => isFullscreen.toggle();

  void toggleAppBar() {
    if (isFullscreen.value) {
      _isAppBarVisible.toggle();
      if (_isAppBarVisible.value) {
        _startAppBarTimer();
      } else {
        _appBarTimer?.cancel();
      }
    }
  }

  void _startAppBarTimer() {
    _appBarTimer?.cancel();
    _appBarTimer = Timer(
      const Duration(seconds: 3),
      () => _isAppBarVisible.value = false,
    );
  }

  // ------------------------------
  // Retry loading PDF
  // ------------------------------
  Future<void> retry() async {
    if (_pdfUrl != null) await initialize(_pdfUrl!);
  }

  // ------------------------------
  // Debug method to test PDF directly
  // ------------------------------
  void testPdfDirectly() {
    if (_localPath != null) {
      debugPrint('Testing PDF directly at: $_localPath');
      final file = File(_localPath!);
      debugPrint('File exists: ${file.existsSync()}');
      if (file.existsSync()) {
        debugPrint('File size: ${file.lengthSync()} bytes');
      }
    }
  }

  // ------------------------------
  // Error handling
  // ------------------------------
  void handleLoadError(dynamic error, StackTrace stackTrace) {
    _errorMessage = error.toString();
    hasError.value = true;
    log('PDF load error', error: error, stackTrace: stackTrace);
    _showErrorSnackbar('Failed to load PDF: $error');
  }

  void _showErrorSnackbar(String message) {
    CommonSnackbar.show(Get.context!, message: message);
  }

  @override
  void onClose() {
    pdfController?.dispose();
    currentSearchResult?.clear();
    _appBarTimer?.cancel();
    Get.delete<PdfViewerPageController>(tag: _pdfUrl);
    super.onClose();
  }
}
