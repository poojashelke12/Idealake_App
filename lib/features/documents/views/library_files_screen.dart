import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_widget.dart';
import '../models/document_library_model.dart';
import '../models/document_model.dart';
import '../view_model/documents_bloc.dart';
import '../view_model/documents_event.dart';
import '../view_model/documents_state.dart';
import '../widgets/document_file_card.dart';
import '../widgets/upload_document_sheet.dart';

/// Screen displaying all files inside a specific Sitefinity Document Library
class LibraryFilesScreen extends StatefulWidget {
  final DocumentLibraryModel library;

  const LibraryFilesScreen({super.key, required this.library});

  @override
  State<LibraryFilesScreen> createState() => _LibraryFilesScreenState();
}

class _LibraryFilesScreenState extends State<LibraryFilesScreen> {
  final TextEditingController _searchController = TextEditingController();

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
            Text(document.description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
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
                      UIHelpers.showSuccessSnackBar(context, 'Opening ${document.fileExtension.toUpperCase()} preview...');
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
      appBar: CustomAppBar(
        title: widget.library.title,
        actions: [
          IconButton(
            tooltip: 'Upload Document',
            icon: const Icon(Icons.upload_file_rounded, color: AppColors.primary),
            onPressed: () {
              final state = context.read<DocumentsBloc>().state;
              final libs = state.librariesResponse.data ?? [widget.library];
              UploadDocumentSheet.show(context, libs, defaultLibrary: widget.library);
            },
          ),
        ],
      ),
      body: BlocBuilder<DocumentsBloc, DocumentsState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search in Library
              CustomSearchBar(
                controller: _searchController,
                hintText: 'Search files in ${widget.library.title}...',
                onChanged: (q) {
                  context.read<DocumentsBloc>().add(DocumentsSearchFilesInLibraryEvent(q));
                },
              ),

              // Library Metadata Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Stored in: ${widget.library.storedIn}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.offline_pin_rounded,
                            size: 14,
                            color: state.offlineOnly ? AppColors.textWhite : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Saved Only',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: state.offlineOnly ? AppColors.textWhite : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      selected: state.offlineOnly,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: state.offlineOnly ? AppColors.primary : AppColors.divider),
                      ),
                      onSelected: (val) {
                        context.read<DocumentsBloc>().add(DocumentsToggleOfflineFilterEvent(val));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    context.read<DocumentsBloc>().add(
                          DocumentsFetchFilesInLibraryEvent(widget.library, forceRefresh: true),
                        );
                  },
                  child: _buildFilesList(state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilesList(DocumentsState state) {
    if (state.filesResponse.isLoading && (state.filesResponse.data == null || state.filesResponse.data!.isEmpty)) {
      return const LoadingWidget(message: 'Loading files...');
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

    final files = state.filesResponse.data ?? [];

    if (files.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 60),
          EmptyStateView(
            title: state.offlineOnly ? 'No Saved Files' : 'No Documents in this Library',
            message: state.offlineOnly
                ? 'No documents in this library have been saved offline.'
                : 'Upload a document or publish from Sitefinity CMS to populate this library.',
            icon: Icons.folder_open_outlined,
            actionWidget: CustomButton(
              text: 'Upload Document',
              width: 180,
              height: 40,
              prefixIcon: const Icon(Icons.upload_file_rounded, color: AppColors.textWhite, size: 16),
              onPressed: () {
                final libs = state.librariesResponse.data ?? [widget.library];
                UploadDocumentSheet.show(context, libs, defaultLibrary: widget.library);
              },
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final doc = files[index];
        return DocumentFileCard(
          document: doc,
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
        );
      },
    );
  }
}
