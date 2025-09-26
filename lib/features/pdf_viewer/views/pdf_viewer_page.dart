import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../controllers/pdf_viewer_controller.dart';

class PdfViewerPage extends StatelessWidget {
  const PdfViewerPage({super.key, required this.pdfUrl, this.title});

  final String pdfUrl;
  final String? title;

  static const _blurSigma = 8.0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      PdfViewerPageController(),
      tag: pdfUrl,
      permanent: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initialize(pdfUrl);
    });

    return Obx(() {
      final isFullscreen = controller.isFullscreen.value;

      return Scaffold(
        backgroundColor: controller.isNightMode.value
            ? Colors.grey[900]
            : Colors.black,
        appBar: isFullscreen ? null : _buildAppBar(context, controller),
        body: _buildBody(context, controller),
      );
    });
  }

  AppBar _buildAppBar(
    BuildContext context,
    PdfViewerPageController controller,
  ) {
    return AppBar(
      title: Text(title ?? 'PDF Viewer'),
      backgroundColor: controller.isNightMode.value
          ? Colors.grey[900]
          : Theme.of(context).colorScheme.surface,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Search',
          onPressed: () => _showSearchDialog(context, controller),
        ),
        IconButton(
          icon: Icon(
            controller.isNightMode.value ? Icons.light_mode : Icons.dark_mode,
          ),
          tooltip: 'Toggle night mode',
          onPressed: controller.toggleNightMode,
        ),
        IconButton(
          icon: const Icon(Icons.zoom_in),
          tooltip: 'Zoom in',
          onPressed: controller.zoomIn,
        ),
        IconButton(
          icon: const Icon(Icons.zoom_out),
          tooltip: 'Zoom out',
          onPressed: controller.zoomOut,
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, controller),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'jump_page',
              child: Row(
                children: [
                  Icon(Icons.skip_next),
                  SizedBox(width: 8),
                  Text('Jump to page'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'fit_width',
              child: Row(
                children: [
                  Icon(Icons.fit_screen),
                  SizedBox(width: 8),
                  Text('Fit width'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'reset_zoom',
              child: Row(
                children: [
                  Icon(Icons.zoom_out_map),
                  SizedBox(width: 8),
                  Text('Reset zoom'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'copy_text',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text('Copy selected text'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Download'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'fullscreen',
              child: Row(
                children: [
                  Icon(Icons.fullscreen),
                  SizedBox(width: 8),
                  Text('Toggle fullscreen'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, PdfViewerPageController controller) {
    return Obx(() {
      if (controller.isLoading.value) return _buildLoading(context, controller);
      if (controller.hasError.value) return _buildError(context, controller);
      if (!controller.pdfReady.value || controller.localPath == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return _buildPdfViewer(context, controller);
    });
  }

  Widget _buildPdfViewer(
    BuildContext context,
    PdfViewerPageController controller,
  ) {
    return Stack(
      children: [
        Container(
          color: controller.isNightMode.value ? Colors.grey[900] : Colors.white,
          child: SfPdfViewer.file(
            File(controller.localPath!),
            controller: controller.pdfController,
            onDocumentLoaded: controller.onDocumentLoaded,
            onPageChanged: controller.onPageChanged,
            onDocumentLoadFailed: (details) {
              controller.handleLoadError(details.error, StackTrace.current);
            },
          ),
        ),
        _buildPageIndicator(controller, context),
        _buildSearchOverlay(controller, context),
        _buildZoomIndicator(controller, context),
      ],
    );
  }

  Widget _buildPageIndicator(
    PdfViewerPageController controller,
    BuildContext context,
  ) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Obx(
        () => AnimatedOpacity(
          opacity: controller.pdfReady.value ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: Center(
            child: GestureDetector(
              onTap: () => _showJumpToPageDialog(context, controller),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _blurSigma,
                    sigmaY: _blurSigma,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.black.withValues(alpha: 0.4),
                    child: Text(
                      controller.totalPages.value > 0
                          ? '${controller.currentPageNumber.value} / ${controller.totalPages.value}'
                          : 'Page ${controller.currentPageNumber.value}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(
    BuildContext context,
    PdfViewerPageController controller,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  value: controller.downloadProgress.value / 100,
                  strokeWidth: 4,
                ),
              ),
              Text(
                '${controller.downloadProgress.value.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Loading PDF...'),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, PdfViewerPageController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage ?? 'Failed to load PDF',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchOverlay(
    PdfViewerPageController controller,
    BuildContext context,
  ) {
    return Obx(() {
      if (!controller.isSearching.value &&
          controller.searchResultCount.value == 0) {
        return const SizedBox.shrink();
      }

      return Positioned(
        top: 60,
        right: 16,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
          ),
          child: controller.isSearching.value
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Searching...',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${controller.currentSearchIndex.value + 1} of ${controller.searchResultCount.value}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: controller.previousSearchResult,
                      child: const Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.nextSearchResult,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: controller.clearSearch,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  Widget _buildZoomIndicator(
    PdfViewerPageController controller,
    BuildContext context,
  ) {
    return Positioned(
      top: 60,
      left: 16,
      child: Obx(() {
        if (controller.zoomLevel.value == 1.0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${(controller.zoomLevel.value * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
    );
  }

  void _showSearchDialog(
    BuildContext context,
    PdfViewerPageController controller,
  ) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search in PDF'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Enter text to search...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              controller.searchText(value);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                controller.searchText(searchController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showJumpToPageDialog(
    BuildContext context,
    PdfViewerPageController controller,
  ) {
    final pageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jump to Page'),
        content: TextField(
          controller: pageController,
          decoration: InputDecoration(
            hintText: 'Page number (1-${controller.totalPages.value})',
            prefixIcon: const Icon(Icons.skip_next),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
          onSubmitted: (value) {
            final page = int.tryParse(value);
            if (page != null &&
                page > 0 &&
                page <= controller.totalPages.value) {
              controller.jumpToPage(page);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final page = int.tryParse(pageController.text);
              if (page != null &&
                  page > 0 &&
                  page <= controller.totalPages.value) {
                controller.jumpToPage(page);
                Navigator.pop(context);
              }
            },
            child: const Text('Jump'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, PdfViewerPageController controller) {
    switch (action) {
      case 'jump_page':
        _showJumpToPageDialog(Get.context!, controller);
        break;
      case 'fit_width':
        controller.fitWidth();
        break;
      case 'reset_zoom':
        controller.resetZoom();
        break;
      case 'copy_text':
        controller.copySelectedText();
        break;
      case 'download':
        controller.savePdfToDevice();
        break;
      case 'share':
        controller.sharePdf();
        break;
      case 'fullscreen':
        controller.toggleFullscreen();
        break;
    }
  }
}
