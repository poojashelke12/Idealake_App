import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/offline_banner.dart';
import '../models/document_library_model.dart';
import '../models/document_model.dart';
import '../view_model/documents_bloc.dart';
import '../view_model/documents_event.dart';
import '../view_model/documents_state.dart';
import '../widgets/create_library_sheet.dart';
import '../widgets/document_file_card.dart';
import '../widgets/documents_filter_sheet.dart';
import '../widgets/documents_settings_sheet.dart';
import '../widgets/upload_document_sheet.dart';

/// Screen displaying all files inside a specific Document Library matching Sitefinity Web Admin UI (Screenshots 2, 3, 5)
class LibraryFilesScreen extends StatefulWidget {
  final DocumentLibraryModel library;

  const LibraryFilesScreen({super.key, required this.library});

  @override
  State<LibraryFilesScreen> createState() => _LibraryFilesScreenState();
}

class _LibraryFilesScreenState extends State<LibraryFilesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedDocIds = {};

  @override
  void initState() {
    super.initState();
    context.read<DocumentsBloc>().add(
          DocumentsFetchFilesInLibraryEvent(widget.library, forceRefresh: true),
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilePreview(BuildContext context, DocumentModel document) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.file_present_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title,
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${widget.library.title} • ${document.fileSize}',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Description', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              document.description.isNotEmpty ? document.description : 'Published Sitefinity document asset.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: document.isDownloaded ? 'Remove Offline' : 'Save Offline',
                    buttonType: ButtonType.outlined,
                    prefixIcon: Icon(
                      document.isDownloaded ? Icons.delete_outline_rounded : Icons.download_rounded,
                      size: 18,
                    ),
                    onPressed: () {
                      context.read<DocumentsBloc>().add(DocumentsToggleDownloadEvent(document.id));
                      Navigator.pop(context);
                      UIHelpers.showSuccessSnackBar(
                        context,
                        document.isDownloaded
                            ? 'Removed from offline storage'
                            : 'Saved for offline access',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Open File',
                    prefixIcon: const Icon(Icons.visibility_rounded, color: AppColors.textWhite, size: 18),
                    onPressed: () {
                      Navigator.pop(context);
                      UIHelpers.showSuccessSnackBar(context, 'Opening ${document.fileExtension.toUpperCase()} document...');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<DocumentsBloc, DocumentsState>(
          builder: (context, state) {
            final files = state.filesResponse.data ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Offline banner
                OfflineBanner(
                  isOffline: state.isOffline,
                  onRefresh: () {
                    context.read<DocumentsBloc>().add(
                          DocumentsFetchFilesInLibraryEvent(widget.library, forceRefresh: true),
                        );
                  },
                ),

                // Header Row 1: Back/Breadcrumb navigation + Action Icons (Padded below status bar)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 10.0, 8.0, 6.0),
                  child: Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF003D99)),
                              const SizedBox(width: 6),
                              Text(
                                'All documents',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: const Color(0xFF003D99),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.library.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Filter icon (Screenshot 3)
                      IconButton(
                        icon: const Icon(Icons.filter_alt_outlined, color: AppColors.textSecondary, size: 20),
                        tooltip: 'Filter documents',
                        onPressed: () => DocumentsFilterSheet.show(
                          context,
                          documents: files,
                        ),
                      ),

                      // Settings icon (Screenshot 2)
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 20),
                        tooltip: 'Settings for documents',
                        onPressed: () => DocumentsSettingsSheet.show(context),
                      ),
                    ],
                  ),
                ),

              // Header Row 2: Action buttons (Create a library & Upload documents)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    // Create a library button (Outlined)
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () => CreateLibrarySheet.show(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text(
                            'Create a library',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Upload documents button (Solid Green CTA #00965E)
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            final libs = state.librariesResponse.data ?? [widget.library];
                            UploadDocumentSheet.show(context, libs, defaultLibrary: widget.library);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00965E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Upload documents',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar matching Sitefinity Search... input
              CustomSearchBar(
                controller: _searchController,
                hintText: 'Search...',
                onChanged: (q) {
                  context.read<DocumentsBloc>().add(DocumentsSearchFilesInLibraryEvent(q));
                },
              ),

              // Multi-Selection Toolbar Banner
              if (_selectedDocIds.isNotEmpty)
                _buildSelectionBanner(context, files),

              const SizedBox(height: 4),

              // Dynamic List of Documents or Empty View
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF00965E),
                  onRefresh: () async {
                    context.read<DocumentsBloc>().add(
                          DocumentsFetchFilesInLibraryEvent(widget.library, forceRefresh: true),
                        );
                  },
                  child: _buildFilesContent(state, files),
                ),
              ),

              // Sitefinity Bottom Footer matching Screenshots: "45 documents" or "0 documents"
              _buildSitefinityFooter(files.length),
            ],
          );
        },
      ),
    ),
  );
}

  Widget _buildSelectionBanner(BuildContext context, List<DocumentModel> files) {
    final allSelected = files.isNotEmpty && _selectedDocIds.length == files.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF3FB),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(color: const Color(0xFF003D99).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedDocIds.length} selected • ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF003D99),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                if (allSelected) {
                  _selectedDocIds.clear();
                } else {
                  _selectedDocIds.addAll(files.map((e) => e.id));
                }
              });
            },
            child: Text(
              allSelected ? 'Deselect all' : 'Select all',
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xFF003D99),
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const Spacer(),

          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
            onSelected: (action) {
              if (action == 'download') {
                for (final id in _selectedDocIds) {
                  context.read<DocumentsBloc>().add(DocumentsToggleDownloadEvent(id));
                }
                UIHelpers.showSuccessSnackBar(context, 'Saved ${_selectedDocIds.length} document(s) offline');
              } else if (action == 'delete') {
                final count = _selectedDocIds.length;
                setState(() => _selectedDocIds.clear());
                UIHelpers.showSuccessSnackBar(context, 'Deleted $count document(s)');
              } else if (action == 'permissions') {
                UIHelpers.showSnackBar(context, 'Permissions for selected documents');
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'download',
                height: 36,
                child: Text('Save offline', style: TextStyle(fontSize: 13)),
              ),
              const PopupMenuItem(
                value: 'permissions',
                height: 36,
                child: Text('Set permissions', style: TextStyle(fontSize: 13)),
              ),
              const PopupMenuDivider(height: 1),
              const PopupMenuItem(
                value: 'delete',
                height: 36,
                child: Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF003D99).withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Actions', style: TextStyle(color: Color(0xFF111827), fontSize: 13, fontWeight: FontWeight.w600)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, color: Color(0xFF111827), size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesContent(DocumentsState state, List<DocumentModel> files) {
    if (state.filesResponse.isLoading && (state.filesResponse.data == null || state.filesResponse.data!.isEmpty)) {
      return const LoadingWidget(message: 'Loading Sitefinity documents...');
    }

    if (state.filesResponse.isError && (state.filesResponse.data == null || state.filesResponse.data!.isEmpty)) {
      return ErrorView(
        message: state.filesResponse.message,
        onRetry: () {
          context.read<DocumentsBloc>().add(
                DocumentsFetchFilesInLibraryEvent(widget.library, forceRefresh: true),
              );
        },
      );
    }

    // Empty Library View matching Screenshot 5 (media_1788437350098.png)
    if (files.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 60),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Empty state circular document illustration (Screenshot 5)
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.description_outlined,
                      size: 40,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No documents have been uploaded',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        onPressed: () => CreateLibrarySheet.show(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                        ),
                        child: const Text('Create a library', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          final libs = state.librariesResponse.data ?? [widget.library];
                          UploadDocumentSheet.show(context, libs, defaultLibrary: widget.library);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00965E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                          elevation: 0,
                        ),
                        child: const Text('Upload documents', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 2, bottom: 16),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final doc = files[index];
        final isSelected = _selectedDocIds.contains(doc.id);

        return DocumentFileCard(
          document: doc,
          isSelected: isSelected,
          onSelectChanged: (val) {
            setState(() {
              if (val == true) {
                _selectedDocIds.add(doc.id);
              } else {
                _selectedDocIds.remove(doc.id);
              }
            });
          },
          onTap: () => _showFilePreview(context, doc),
          onToggleDownload: () {
            context.read<DocumentsBloc>().add(DocumentsToggleDownloadEvent(doc.id));
            UIHelpers.showSuccessSnackBar(
              context,
              doc.isDownloaded
                  ? 'Removed "${doc.title}" from saved offline files'
                  : 'Saved "${doc.title}" for offline viewing',
            );
          },
          onDelete: () {
            UIHelpers.showSuccessSnackBar(context, 'Deleted "${doc.title}"');
          },
        );
      },
    );
  }

  Widget _buildSitefinityFooter(int count) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sitefinity CMS 14.1 | Headless API',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 11),
                  ),
                  Text(
                    '$count ${count == 1 ? "document" : "documents"}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildFooterLink('Documentation'),
                      const SizedBox(width: 8),
                      _buildFooterLink('Resources'),
                      const SizedBox(width: 8),
                      _buildFooterLink("What's new"),
                      const SizedBox(width: 8),
                      _buildFooterLink('Feedback'),
                    ],
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.divider,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('?', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(String label) {
    return InkWell(
      onTap: () {
        UIHelpers.showSnackBar(context, '$label link clicked');
      },
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: const Color(0xFF003D99),
          fontSize: 10,
        ),
      ),
    );
  }
}
