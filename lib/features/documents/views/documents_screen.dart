import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/offline_banner.dart';
import '../models/document_library_model.dart';
import '../view_model/documents_bloc.dart';
import '../view_model/documents_event.dart';
import '../view_model/documents_state.dart';
import '../widgets/create_library_sheet.dart';
import '../widgets/library_card.dart';
import '../widgets/upload_document_sheet.dart';
import 'library_files_screen.dart';

/// Screen displaying the Sitefinity Document Libraries (matches Sitefinity Web Documents UI)
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DocumentsBloc>().add(const DocumentsFetchLibrariesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToLibrary(BuildContext context, DocumentLibraryModel library) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LibraryFilesScreen(library: library),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<DocumentsBloc, DocumentsState>(
        builder: (context, state) {
          final libraries = state.librariesResponse.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Offline banner
              OfflineBanner(
                isOffline: state.isOffline,
                onRefresh: () {
                  context.read<DocumentsBloc>().add(const DocumentsFetchLibrariesEvent(forceRefresh: true));
                },
              ),

              // Search Bar (matches web search)
              CustomSearchBar(
                controller: _searchController,
                hintText: 'Search libraries, storage, authors...',
                onChanged: (q) {
                  context.read<DocumentsBloc>().add(DocumentsSearchLibrariesEvent(q));
                },
              ),

              // Web Action Bar: "Create a library" & "Upload documents" buttons + List/Grid toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    // Create a library button (outlined)
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: () => CreateLibrarySheet.show(context),
                          icon: const Icon(Icons.create_new_folder_outlined, size: 16),
                          label: const Text('Create a library', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Upload documents button (solid green CTA matching screenshot)
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: () => UploadDocumentSheet.show(context, libraries),
                          icon: const Icon(Icons.upload_rounded, size: 16, color: Colors.white),
                          label: const Text('Upload documents', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00965E), // Sitefinity CMS Green Button
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // View Mode Switcher (List vs Grid)
                    IconButton(
                      tooltip: state.isGridView ? 'Switch to List View' : 'Switch to Grid View',
                      icon: Icon(
                        state.isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                      onPressed: () {
                        context.read<DocumentsBloc>().add(DocumentsToggleViewModeEvent());
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Section Header: DOCUMENTS LIBRARY (matching web table headers)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DOCUMENTS LIBRARY',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      '${libraries.length} ${libraries.length == 1 ? 'library' : 'libraries'}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Libraries List / Grid
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    context.read<DocumentsBloc>().add(const DocumentsFetchLibrariesEvent(forceRefresh: true));
                  },
                  child: _buildLibrariesContent(state, libraries),
                ),
              ),

              // Footer Counter matching bottom-right of web screenshot: "2 libraries"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.dns_rounded, size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 6),
                        Text(
                          'Sitefinity Media Provider: Database',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                    Text(
                      '${libraries.length} ${libraries.length == 1 ? 'library' : 'libraries'}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLibrariesContent(DocumentsState state, List<DocumentLibraryModel> libraries) {
    if (state.librariesResponse.isLoading && (state.librariesResponse.data == null || state.librariesResponse.data!.isEmpty)) {
      return const LoadingWidget(message: 'Loading Sitefinity Document Libraries...');
    }

    if (state.librariesResponse.isError && (state.librariesResponse.data == null || state.librariesResponse.data!.isEmpty)) {
      return ErrorView(
        message: state.librariesResponse.message,
        onRetry: () {
          context.read<DocumentsBloc>().add(const DocumentsFetchLibrariesEvent(forceRefresh: true));
        },
      );
    }

    if (libraries.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 60),
          EmptyStateView(
            title: 'No Libraries Found',
            message: 'No document libraries match your search term.',
            icon: Icons.folder_open_outlined,
            actionWidget: CustomButton(
              text: 'Create a Library',
              width: 180,
              height: 40,
              prefixIcon: const Icon(Icons.create_new_folder_outlined, color: AppColors.textWhite, size: 16),
              onPressed: () => CreateLibrarySheet.show(context),
            ),
          ),
        ],
      );
    }

    if (state.isGridView) {
      return GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: libraries.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (context, index) {
          final lib = libraries[index];
          return LibraryCard(
            library: lib,
            isGrid: true,
            onTap: () => _navigateToLibrary(context, lib),
          );
        },
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      itemCount: libraries.length,
      itemBuilder: (context, index) {
        final lib = libraries[index];
        return LibraryCard(
          library: lib,
          isGrid: false,
          onTap: () => _navigateToLibrary(context, lib),
        );
      },
    );
  }
}
