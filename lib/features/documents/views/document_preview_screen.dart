import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../models/document_model.dart';
import '../view_model/documents_bloc.dart';
import '../view_model/documents_event.dart';

/// Full-featured In-App Document Preview Screen
/// Loads and previews documents directly in-app using the "Url" from the Sitefinity Document API.
class DocumentPreviewScreen extends StatefulWidget {
  final DocumentModel document;
  final String? initialUrl;

  const DocumentPreviewScreen({
    super.key,
    required this.document,
    this.initialUrl,
  });

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  WebViewController? _webViewController;
  bool _isLoading = true;
  double _progress = 0.0;
  bool _hasError = false;
  String? _errorMessage;
  bool _useGoogleDocsViewer = false;

  late final String _targetUrl;

  bool get _isImage => [
        'png',
        'jpg',
        'jpeg',
        'gif',
        'webp',
        'svg',
      ].contains(widget.document.fileExtension.toLowerCase());

  bool get _isOfficeOrPdf => [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
      ].contains(widget.document.fileExtension.toLowerCase());

  @override
  void initState() {
    super.initState();
    _targetUrl = _resolveDocumentUrl();
    if (_isOfficeOrPdf) {
      _useGoogleDocsViewer = true;
    }
    _initWebView();
  }

  String _resolveDocumentUrl() {
    String raw = '';
    if (widget.initialUrl != null && widget.initialUrl!.trim().isNotEmpty) {
      raw = widget.initialUrl!.trim();
    } else {
      raw = widget.document.previewUrl;
    }

    if (raw.isEmpty) return '';

    // If query string (?sfvrsn=...&download=true) is missing in raw, check downloadUrl or url
    if (!raw.contains('?')) {
      final docUrl = (widget.document.downloadUrl != null && widget.document.downloadUrl!.contains('?'))
          ? widget.document.downloadUrl!
          : ((widget.document.url != null && widget.document.url!.contains('?')) ? widget.document.url! : '');
      if (docUrl.isNotEmpty && docUrl.contains('?')) {
        final query = docUrl.substring(docUrl.indexOf('?'));
        raw = '$raw$query';
      }
    }

    // Always guarantee full scheme and host
    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      if (!raw.startsWith('/')) {
        raw = '/$raw';
      }
      raw = '${ApiEndpoints.baseUrl}$raw';
    }

    return raw;
  }

  void _initWebView() {
    if (_targetUrl.isEmpty || _isImage) {
      _isLoading = false;
      return;
    }

    try {
      final effectiveUrl = _useGoogleDocsViewer
          ? 'https://docs.google.com/viewer?url=${Uri.encodeComponent(_targetUrl)}&embedded=true'
          : _targetUrl;

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) {
                setState(() => _progress = progress / 100);
              }
            },
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              // If standard WebView fails on doc/pdf, auto-fallback to Google Docs Viewer
              if (!_useGoogleDocsViewer && _isOfficeOrPdf && mounted) {
                setState(() {
                  _useGoogleDocsViewer = true;
                });
                _initWebView();
                return;
              }

              if (mounted) {
                setState(() {
                  _hasError = true;
                  _isLoading = false;
                  _errorMessage = error.description;
                });
              }
            },
          ),
        );

      final uri = Uri.tryParse(effectiveUrl);
      if (uri != null) {
        controller.loadRequest(uri);
      }
      _webViewController = controller;
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _openInExternalBrowser() async {
    if (_targetUrl.isEmpty) {
      UIHelpers.showSnackBar(context, 'No valid document URL available');
      return;
    }

    final uri = Uri.tryParse(_targetUrl);
    if (uri == null) {
      UIHelpers.showSnackBar(context, 'Invalid document URL');
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          UIHelpers.showSnackBar(context, 'Could not open URL: $e');
        }
      }
    }
  }

  void _copyDocumentUrl() {
    if (_targetUrl.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _targetUrl));
      UIHelpers.showSuccessSnackBar(context, 'Document URL copied to clipboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    final isDownloaded = doc.isDownloaded;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doc.title,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${doc.libraryTitle} • ${doc.fileExtension.toUpperCase()} • ${doc.fileSize}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          // Offline / Download Action
          IconButton(
            icon: Icon(
              isDownloaded ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
              color: isDownloaded ? const Color(0xFF00965E) : AppColors.textSecondary,
              size: 22,
            ),
            tooltip: isDownloaded ? 'Saved offline' : 'Save for offline',
            onPressed: () {
              context.read<DocumentsBloc>().add(DocumentsToggleDownloadEvent(doc.id));
              UIHelpers.showSuccessSnackBar(
                context,
                isDownloaded
                    ? 'Removed from offline storage'
                    : 'Saved "${doc.title}" for offline preview',
              );
            },
          ),

          // External browser / InApp browser open button
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded, color: AppColors.textSecondary, size: 22),
            tooltip: 'Open in browser',
            onPressed: _openInExternalBrowser,
          ),

          // Popup Menu for more options
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
            onSelected: (val) {
              if (val == 'copy_url') {
                _copyDocumentUrl();
              } else if (val == 'reload') {
                _initWebView();
              } else if (val == 'toggle_viewer') {
                setState(() {
                  _useGoogleDocsViewer = !_useGoogleDocsViewer;
                });
                _initWebView();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'copy_url',
                height: 38,
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded, size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('Copy Document URL', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reload',
                height: 38,
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('Reload Preview', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              if (_isOfficeOrPdf)
                PopupMenuItem(
                  value: 'toggle_viewer',
                  height: 38,
                  child: Row(
                    children: [
                      const Icon(Icons.visibility_outlined, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        _useGoogleDocsViewer ? 'Direct URL View' : 'Google Docs Viewer View',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: const Color(0xFF00965E),
                  minHeight: 3,
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          // URL indicator bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _targetUrl.isNotEmpty ? _targetUrl : 'No URL provided by API',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: _copyDocumentUrl,
                  child: const Text(
                    'Copy',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF003D99),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Preview Content
          Expanded(
            child: _buildPreviewBody(),
          ),

          // Bottom Info Bar matching Sitefinity Document Metadata
          _buildBottomMetadataBar(doc),
        ],
      ),
    );
  }

  Widget _buildPreviewBody() {
    if (_targetUrl.isEmpty) {
      return _buildEmptyState(
        icon: Icons.link_off_rounded,
        title: 'Document URL not available',
        subtitle: 'The document record does not contain a valid URL in the API response.',
      );
    }

    if (_isImage) {
      return Container(
        color: const Color(0xFF0F172A),
        child: Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: _targetUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: Color(0xFF00965E)),
              ),
              errorWidget: (context, url, error) => _buildEmptyState(
                icon: Icons.broken_image_rounded,
                title: 'Unable to render image',
                subtitle: 'The image preview could not be loaded from $_targetUrl.',
                showOpenInBrowser: true,
              ),
            ),
          ),
        ),
      );
    }

    if (_hasError) {
      return _buildEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Preview Unavailable in WebView',
        subtitle: _errorMessage ??
            'This document format (${widget.document.fileExtension.toUpperCase()}) could not be rendered directly in the embedded view.',
        showOpenInBrowser: true,
        showToggleViewer: _isOfficeOrPdf,
      );
    }

    if (_webViewController != null) {
      return Stack(
        children: [
          WebViewWidget(controller: _webViewController!),
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF00965E)),
                    SizedBox(height: 12),
                    Text(
                      'Loading document preview...',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    return const Center(child: CircularProgressIndicator(color: Color(0xFF00965E)));
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showOpenInBrowser = false,
    bool showToggleViewer = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Center(
                child: Icon(icon, size: 36, color: const Color(0xFF64748B)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showToggleViewer)
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _useGoogleDocsViewer = !_useGoogleDocsViewer;
                      });
                      _initWebView();
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: Text(
                      _useGoogleDocsViewer ? 'Direct Preview' : 'Try Docs Viewer',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      ),
                    ),
                  ),
                if (showToggleViewer && showOpenInBrowser) const SizedBox(width: 10),
                if (showOpenInBrowser)
                  ElevatedButton.icon(
                    onPressed: _openInExternalBrowser,
                    icon: const Icon(Icons.open_in_browser_rounded, size: 16, color: Colors.white),
                    label: const Text(
                      'Open in Browser',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00965E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      ),
                      elevation: 0,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomMetadataBar(DocumentModel doc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF3FB),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF003D99).withValues(alpha: 0.2)),
            ),
            child: Text(
              doc.fileExtension.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF003D99),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  doc.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Uploaded by ${doc.uploadedBy} • ${doc.fileSize}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 32,
            child: OutlinedButton.icon(
              onPressed: _openInExternalBrowser,
              icon: const Icon(Icons.launch_rounded, size: 14),
              label: const Text('Open', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF003D99),
                side: const BorderSide(color: Color(0xFF003D99)),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
