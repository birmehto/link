import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/pdf_viewer_controller.dart';

// Animation durations
const Duration kAnimationDuration = Duration(milliseconds: 200);
const Duration kControlsVisibleDuration = Duration(seconds: 3);

// Constants for UI configuration
const double kControlButtonSize = 48.0;
const double kControlIconSize = 24.0;
const double kPageIndicatorHeight = 40.0;
const double kZoomStep = 0.2;

/// Optimized stateless PDF viewer page with performance enhancements
class OptimizedPdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String? title;
  final bool autoHideControls;
  final bool showPageIndicator;
  final bool enableDownload;
  final bool enableShare;
  final bool enableFullscreen;
  final Color? backgroundColor;
  final Color? progressColor;
  final Color? indicatorColor;
  final Color? indicatorBackgroundColor;
  final Color? indicatorTextColor;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;

  const OptimizedPdfViewerPage({
    super.key,
    required this.pdfUrl,
    this.title,
    this.autoHideControls = true,
    this.showPageIndicator = true,
    this.enableDownload = true,
    this.enableShare = true,
    this.enableFullscreen = true,
    this.backgroundColor,
    this.progressColor,
    this.indicatorColor,
    this.indicatorBackgroundColor,
    this.indicatorTextColor,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
  });

  @override
  State<OptimizedPdfViewerPage> createState() => _OptimizedPdfViewerPageState();
}

class _OptimizedPdfViewerPageState extends State<OptimizedPdfViewerPage>
    with WidgetsBindingObserver {
  late final PdfViewerPageController _controller;
  Timer? _inactivityTimer;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = PdfViewerPageController();
    _initializePdf(widget.pdfUrl, widget.title);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // No-op: Rendering is handled automatically by the controller
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializePdf(String pdfUrl, String? title) async {
    try {
      _controller.initialize(pdfUrl, title);
      // Wait for the PDF to be ready or error state
      await Future.any([
        _controller.pdfReady.stream.firstWhere((ready) => ready == true),
        _controller.hasError.stream.firstWhere((hasError) => hasError == true),
      ]);
    } catch (e) {
      debugPrint('Error initializing PDF: $e');
    }
  }

  void _handleTap() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _resetInactivityTimer();
      } else {
        _inactivityTimer?.cancel();
      }
    });
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (widget.autoHideControls) {
      _inactivityTimer = Timer(kControlsVisibleDuration, () {
        if (mounted) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.progressColor ?? Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading PDF...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Obx(
            () => Text(
              _controller.errorMessage.value.isNotEmpty
                  ? _controller.errorMessage.value
                  : 'Failed to load PDF',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _initializePdf(widget.pdfUrl, widget.title),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No PDF to display',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showControls ? _buildAppBar() : null,
      body: GestureDetector(
        onTap: _handleTap,
        child: Stack(
          children: [
            Container(
              color: widget.backgroundColor ?? Theme.of(context).canvasColor,
              child: _buildPdfView(),
            ),
            if (_showControls && widget.showPageIndicator)
              _buildControlsOverlay(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.title ?? 'PDF Viewer'),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      actions: [
        Obx(
          () => _controller.pdfReady.value
              ? IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _showPageJumpDialog,
                  tooltip: 'Jump to page',
                )
              : const SizedBox.shrink(),
        ),
        if (widget.enableShare)
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _handleMenuAction('share'),
            tooltip: 'Share PDF',
          ),
        if (widget.enableDownload)
          Obx(
            () => _controller.isDownloading.value
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _controller.downloadPdf(),
                    tooltip: 'Download PDF',
                  ),
          ),
        if (widget.enableFullscreen)
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () => _handleMenuAction('fullscreen'),
            tooltip: 'Toggle fullscreen',
          ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Obx(
      () => Container(
        height: kPageIndicatorHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _controller.currentPageNumber.value > 1
                  ? () => _controller.jumpToPage(
                      _controller.currentPageNumber.value - 1,
                    )
                  : null,
            ),
            Expanded(
              child: Text(
                '${_controller.currentPageNumber.value} / ${_controller.totalPages.value}',
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed:
                  _controller.currentPageNumber.value <
                      _controller.totalPages.value
                  ? () => _controller.jumpToPage(
                      _controller.currentPageNumber.value + 1,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: _controller.zoomOut,
          ),
          Text('${(_controller.zoomLevel.value * 100).toInt()}%'),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: _controller.zoomIn,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.resetZoom,
          ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildZoomControls(),
            const SizedBox(height: 8),
            _buildPageIndicator(),
          ],
        ),
      ),
    );
  }

  Future<void> _showPageJumpDialog() async {
    final textController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go to Page'),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Page number (1-${_controller.totalPages.value})',
            border: const OutlineInputBorder(),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final pageNumber = int.tryParse(textController.text);
              if (pageNumber != null &&
                  pageNumber >= 1 &&
                  pageNumber <= _controller.totalPages.value) {
                HapticFeedback.selectionClick();
                _controller.jumpToPage(pageNumber);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please enter a valid page number between 1 and ${_controller.totalPages.value}',
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenuAction(String value) async {
    switch (value) {
      case 'share':
        await Share.share('Check out this PDF: ${widget.pdfUrl}');
        break;
      case 'open_in_browser':
        final uri = Uri.tryParse(widget.pdfUrl);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
        break;
      case 'clear_cache':
        await _controller.clearCache();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Cache cleared')));
        }
        break;
      case 'fullscreen':
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        break;
    }
  }

  Widget _buildPdfView() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return _buildLoadingState();
      } else if (_controller.hasError.value) {
        return _buildErrorState();
      } else if (!_controller.pdfReady.value ||
          _controller.pdfController == null) {
        return _buildEmptyState();
      }

      return PdfView(
        controller: _controller.pdfController,
        onPageChanged: (page) {
          _controller.currentPageNumber.value = page;
          _resetInactivityTimer();
        },
        onDocumentError: (error) {
          _controller.handleLoadError(error, StackTrace.current);
        },
      );
    });
  }
}
