import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/network_service.dart';

/// Maximum number of retry attempts for failed PDF loads
const int _maxRetryAttempts = 3;

/// Delay between retry attempts
const Duration _retryDelay = Duration(seconds: 2);

/// Optimized controller for PDF viewer functionality with memory management
class PdfViewerPageController extends GetxController {
  final _dio = Dio();
  int _retryCount = 0;
  Timer? _inactivityTimer;
  final Duration _inactivityDuration = const Duration(seconds: 3);

  // PDF document and controller
  dynamic
  _pdfDocument; // Using dynamic to handle different PDF viewer implementations
  dynamic
  _pdfxController; // Using dynamic to handle different PDF viewer implementations

  // Cache manager for better performance
  static final _cacheManager = CacheManager(
    Config(
      'pdf_cache_v2', // Versioned to force cache refresh if needed
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 50,
      // maxAgeCacheObject: const Duration(days: 30),
      fileService: HttpFileService(),
      repo: JsonCacheInfoRepository(databaseName: 'pdf_cache_v2'),
    ),
  );

  // Reactive state variables
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isDownloading = false.obs;
  final currentPageNumber = 1.obs;
  final totalPages = 0.obs;
  final showControls = true.obs;
  final downloadProgress = 0.0.obs;
  final isVisible = true.obs;
  final zoomLevel = 1.0.obs;
  final pdfReady = false.obs;
  final isInitialized = false.obs;
  final isPageChanging = false.obs;

  // Configuration
  String? pdfUrl;
  String? title;
  CancelToken? _downloadCancelToken;

  @override
  void onInit() {
    super.onInit();
    _setupInactivityTimer();
    _checkNetworkConnection();
    _setupMemoryOptimizations();
  }

  @override
  void onClose() {
    _cleanupResources();
    super.onClose();
  }

  void _setupInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityDuration, () {
      if (showControls.value) {
        showControls.value = false;
      }
    });
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _setupInactivityTimer();
  }

  void _setupMemoryOptimizations() {
    // Auto-pause/resume based on visibility
    ever(isVisible, (visible) {
      if (!visible) {
        _pauseRenderingOptimizations();
      } else {
        _resumeRenderingOptimizations();
      }
    });

    // Auto-hide controls after period of inactivity
    ever(currentPageNumber, (_) {
      if (!showControls.value) {
        showControls.value = true;
      }
      _resetInactivityTimer();
    });

    ever(zoomLevel, (_) {
      if (!showControls.value) {
        showControls.value = true;
      }
      _resetInactivityTimer();
    });
  }

  void _pauseRenderingOptimizations() {
    // Reduce memory usage when not visible
    log('Pausing PDF rendering optimizations');
  }

  void _resumeRenderingOptimizations() {
    // Resume normal operations
    log('Resuming PDF rendering optimizations');
  }

  Future<void> _cleanupResources() async {
    try {
      _downloadCancelToken?.cancel('Cleanup in progress');
      _downloadCancelToken = null;

      try {
        if (_pdfxController != null) {
          await _pdfxController.dispose();
          _pdfxController = null;
        }
      } catch (e) {
        log('Error disposing PDF controller', error: e);
      }

      try {
        if (_pdfDocument != null) {
          await _pdfDocument.close();
          _pdfDocument = null;
        }
      } catch (e) {
        log('Error closing PDF document', error: e);
      }

      // Force garbage collection
      try {
        await SystemChannels.platform.invokeMethod('System.gc');
      } catch (e) {
        // Ignore GC errors
      }
    } catch (e, stackTrace) {
      log('Error during cleanup', error: e, stackTrace: stackTrace);
    }
  }

  void initialize(String url, String? bookTitle) {
    pdfUrl = url;
    title = bookTitle;
    _loadPdfDocument();
  }

  void _checkNetworkConnection() {
    final networkService = Get.find<NetworkService>();
    if (!networkService.isConnected.value) {
      hasError.value = true;
      errorMessage.value =
          'No internet connection. Please check your connection and try again.';
      isLoading.value = false;
    }
  }

  /// Load PDF document with caching and optimization
  Future<void> _loadPdfDocument() async {
    if (pdfUrl == null) return;
    if (_retryCount >= _maxRetryAttempts) {
      handleLoadError(
        'Maximum retry attempts ($_maxRetryAttempts) reached',
        StackTrace.current,
      );
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      downloadProgress.value = 0.0;
      pdfReady.value = false;

      log('Loading PDF: $pdfUrl (Attempt ${_retryCount + 1})');

      // Cancel any ongoing download
      _downloadCancelToken?.cancel('New load started');
      _downloadCancelToken = CancelToken();

      // Check cache first
      final fileInfo = await _cacheManager.getFileFromCache(pdfUrl!);
      Uint8List bytes;

      if (fileInfo != null) {
        log('Loading PDF from cache');
        bytes = await fileInfo.file.readAsBytes();
      } else {
        log('Downloading PDF from network');
        bytes = await _downloadPdfBytes();
        if (bytes.isEmpty) throw Exception('Downloaded PDF is empty');

        // Cache the downloaded file
        await _cacheManager.putFile(pdfUrl!, bytes, fileExtension: 'pdf');
      }

      // Create PDF document
      await _cleanupResources();

      try {
        // Open PDF document
        _pdfDocument = await PdfDocument.openData(bytes);

        // Create controller with the document
        _pdfxController = PdfController(document: _pdfDocument);

        // Get total pages count
        final pageCount = await _pdfDocument.pageCount;
        totalPages.value = pageCount;
        currentPageNumber.value = 1;

        // Set up page change listener
        _pdfxController.pageStream?.listen((page) {
          if (page != null) {
            currentPageNumber.value = page.round();
          }
        });

        // Mark as loaded
        isLoading.value = false;
        pdfReady.value = true;
        _retryCount = 0; // Reset retry counter on success
        isInitialized.value = true;

        log('PDF loaded successfully: ${totalPages.value} pages');
      } catch (e, stackTrace) {
        log(
          'Error initializing PDF document or controller',
          error: e,
          stackTrace: stackTrace,
        );
        await _cleanupResources();
        rethrow;
      }
    } catch (e, stackTrace) {
      _retryCount++;
      log(
        'Failed to load PDF (Attempt $_retryCount/$_maxRetryAttempts)',
        error: e,
        stackTrace: stackTrace,
      );

      if (_retryCount < _maxRetryAttempts) {
        log('Retrying in ${_retryDelay.inSeconds} seconds...');
        await Future.delayed(_retryDelay);
        _loadPdfDocument().catchError((error, stackTrace) {
          handleLoadError(error, stackTrace);
        });
      } else {
        handleLoadError(e, stackTrace);
      }
    }
  }

  Future<Uint8List> _downloadPdfBytes() async {
    try {
      final response = await _dio.get<List<int>>(
        pdfUrl!,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          validateStatus: (status) => status != null && status < 500,
          headers: {
            'User-Agent':
                'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125 Safari/537.36',
            'Accept':
                'application/pdf,application/octet-stream;q=0.9,*/*;q=0.8',
            'Accept-Encoding': 'gzip',
            'Connection': 'keep-alive',
          },
        ),
        cancelToken: _downloadCancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            downloadProgress.value = progress;

            // Update loading message based on progress
            if (progress < 0.3) {
              log('Downloading PDF: ${(progress * 100).toStringAsFixed(0)}%');
            } else if (progress < 0.7) {
              log('Downloading PDF: ${(progress * 100).toStringAsFixed(0)}%');
            } else if (progress < 0.9) {
              log(
                'Finishing download: ${(progress * 100).toStringAsFixed(0)}%',
              );
            }
          }
        },
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }

      final data = response.data;
      if (data == null || data.isEmpty) {
        throw Exception('Empty response from server');
      }

      return Uint8List.fromList(data);
    } on DioException catch (e) {
      log('Download failed', error: e);
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timed out. Please check your internet connection.',
        );
      } else if (e.response != null) {
        throw Exception('Server responded with ${e.response?.statusCode}');
      } else {
        throw Exception('Download failed: ${e.message}');
      }
    } catch (e) {
      log('Unexpected error during download', error: e);
      rethrow;
    }
  }

  void handleLoadError(dynamic error, StackTrace stackTrace) {
    final message = error.toString();
    log('PDF load error: $message', error: error, stackTrace: stackTrace);
    hasError.value = true;
    errorMessage.value = message;
    isLoading.value = false;
    pdfReady.value = false;

    _retryCount++;
    if (_retryCount < _maxRetryAttempts) {
      Future.delayed(const Duration(seconds: 2), () {
        _loadPdfDocument();
      });
    }
  }

  /// PDF Controller getters
  dynamic get pdfController => _pdfxController;
  bool get hasDocument => _pdfDocument != null;

  // Getter for current page with null safety
  int get currentPage => currentPageNumber.value;

  // Getter for total pages with null safety
  int get pageCount => totalPages.value;

  // Getter for download progress percentage
  int get downloadPercentage => (downloadProgress.value * 100).toInt();

  // Getter for cache status
  Future<bool> get isCached async {
    if (pdfUrl == null) return false;
    final fileInfo = await _cacheManager.getFileFromCache(pdfUrl!);
    return fileInfo != null;
  }

  void onPageChanged(int pageNumber) {
    currentPageNumber.value = pageNumber;
  }

  void onVisibilityChanged(bool visible) {
    isVisible.value = visible;
  }

  void toggleControls() {
    showControls.value = !showControls.value;
  }

  void previousPage() {
    if (_pdfxController != null && currentPageNumber.value > 1) {
      _pdfxController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void nextPage() {
    if (_pdfxController != null && currentPageNumber.value < totalPages.value) {
      _pdfxController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _updateZoom(double newZoom) async {
    final clampedZoom = newZoom.clamp(0.5, 5.0);
    zoomLevel.value = clampedZoom;

    if (_pdfxController != null) {
      try {
        // Update the controller's zoom level by recreating it with the new zoom
        final currentPage = _pdfxController.page?.round() ?? 1;
        await _pdfxController.dispose();

        _pdfxController = PdfController(
          document: _pdfDocument!,
          initialPage: currentPage,
        );
      } catch (e) {
        log('Error updating zoom', error: e);
      }
    }
  }

  Future<void> zoomIn() async {
    await _updateZoom(zoomLevel.value + 0.2);
  }

  Future<void> zoomOut() async {
    await _updateZoom(zoomLevel.value - 0.2);
  }

  Future<void> zoomTo(double zoom) async {
    await _updateZoom(zoom);
  }

  Future<void> resetZoom() async {
    await _updateZoom(1.0);
  }

  Future<void> jumpToPage(int pageNumber) async {
    if (_pdfxController == null ||
        pageNumber < 1 ||
        pageNumber > totalPages.value ||
        isPageChanging.value) {
      return;
    }

    try {
      isPageChanging.value = true;
      await _pdfxController.jumpTo(page: pageNumber);
      currentPageNumber.value = pageNumber;
    } catch (e, stackTrace) {
      log(
        'Error jumping to page $pageNumber',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      isPageChanging.value = false;
    }
  }

  void toggleFullscreen() {
    if (showControls.value) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    toggleControls();
  }

  void openInBrowser() async {
    if (pdfUrl != null) {
      final uri = Uri.parse(pdfUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open PDF in browser',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void sharePdf() async {
    if (pdfUrl != null) {
      await SharePlus.instance.share(
        ShareParams(text: 'Check out this PDF: $pdfUrl'),
      );
    }
  }

  void downloadPdf() async {
    if (isDownloading.value || pdfUrl == null) return;

    isDownloading.value = true;

    try {
      // First try to launch in external app for download
      final uri = Uri.parse(pdfUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        Get.snackbar(
          'Download Started',
          'PDF download initiated in your browser',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer,
        );
      } else {
        throw Exception('Could not download PDF');
      }
    } catch (e) {
      log('Download failed', error: e);
      Get.snackbar(
        'Download Failed',
        'Could not download PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    } finally {
      isDownloading.value = false;
    }
  }

  Future<void> retry() async {
    hasError.value = false;
    errorMessage.value = '';
    downloadProgress.value = 0.0;
    _retryCount = 0; // Reset retry counter
    await _loadPdfDocument();
  }

  /// Clear cache for current PDF
  Future<void> clearCache() async {
    if (pdfUrl != null) {
      await _cacheManager.removeFile(pdfUrl!);
      log('Cleared cache for PDF: $pdfUrl');
    }
  }

  /// Get cache info for current PDF
  Future<bool> isInCache() async {
    if (pdfUrl == null) return false;
    final fileInfo = await _cacheManager.getFileFromCache(pdfUrl!);
    return fileInfo != null;
  }
}
