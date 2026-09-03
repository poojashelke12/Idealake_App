import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
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
import '../widgets/documents_filter_sheet.dart';
import '../widgets/documents_settings_sheet.dart';
import '../widgets/library_card.dart';
import '../widgets/upload_document_sheet.dart';
import 'library_files_screen.dart';

/// Screen displaying Sitefinity Document Libraries matching Web Admin UI (Screenshot 1)
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedLibraryIds = {};

  @override
  void initState() {
    super.initState();
    context.read<DocumentsBloc>().add(const DocumentsFetchLibrariesEvent(forceRefresh: true));
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

              // Responsive Header Row 1: Title & Action Icons
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 10.0, 8.0, 4.0),
                child: Row(
                  children: [
                    Text(
                      'Documents',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 24,
                      ),
                    ),
                    const Spacer(),

                    // Hierarchy tree icon
                    IconButton(
                      icon: const Icon(Icons.account_tree_outlined, color: AppColors.textSecondary, size: 20),
                      tooltip: 'Hierarchy view',
                      onPressed: () => UIHelpers.showSnackBar(context, 'Hierarchy structure view'),
                    ),

                    // Filter icon
                    IconButton(
                      icon: const Icon(Icons.filter_alt_outlined, color: AppColors.textSecondary, size: 20),
                      tooltip: 'Filter documents',
                      onPressed: () => DocumentsFilterSheet.show(
                        context,
                        documents: state.filesResponse.data ?? [],
                      ),
                    ),

                    // Settings icon
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 20),
                      tooltip: 'Settings for documents',
                      onPressed: () => DocumentsSettingsSheet.show(context),
                    ),
                  ],
                ),
              ),

              // Responsive Header Row 2: Action Buttons (Create a library & Upload documents)
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
                          onPressed: () => UploadDocumentSheet.show(context, libraries),
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
                  context.read<DocumentsBloc>().add(DocumentsSearchLibrariesEvent(q));
                },
              ),

              // Multi-Selection Toolbar Banner
              if (_selectedLibraryIds.isNotEmpty)
                _buildSelectionBanner(context, libraries)
              else
                // Column Header row matching Screenshot 1 (DOCUMENTS LIBRARY / ACTIONS)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Text(
                        'DOCUMENTS LIBRARY',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'ACTIONS',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

              // Dynamic List of Document Libraries
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF00965E),
                  onRefresh: () async {
                    context.read<DocumentsBloc>().add(const DocumentsFetchLibrariesEvent(forceRefresh: true));
                  },
                  child: _buildLibrariesContent(state, libraries),
                ),
              ),

              // Sitefinity Bottom Footer matching Screenshot 1: "2 libraries"
              _buildSitefinityFooter(libraries.length),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectionBanner(BuildContext context, List<DocumentLibraryModel> libraries) {
    final allSelected = libraries.isNotEmpty && _selectedLibraryIds.length == libraries.length;

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
            '${_selectedLibraryIds.length} selected • ',
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
                  _selectedLibraryIds.clear();
                } else {
                  _selectedLibraryIds.addAll(libraries.map((e) => e.id));
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
              if (action == 'delete') {
                final count = _selectedLibraryIds.length;
                setState(() => _selectedLibraryIds.clear());
                UIHelpers.showSuccessSnackBar(context, 'Deleted $count selected library(s)');
              } else if (action == 'permissions') {
                UIHelpers.showSnackBar(context, 'Permissions for selected libraries');
              }
            },
            itemBuilder: (ctx) => [
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
            actionWidget: SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: () => CreateLibrarySheet.show(context),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Create a library', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00965E)),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 2, bottom: 16),
      itemCount: libraries.length,
      itemBuilder: (context, index) {
        final lib = libraries[index];
        final isSelected = _selectedLibraryIds.contains(lib.id);

        return LibraryCard(
          library: lib,
          isSelected: isSelected,
          onSelectChanged: (val) {
            setState(() {
              if (val == true) {
                _selectedLibraryIds.add(lib.id);
              } else {
                _selectedLibraryIds.remove(lib.id);
              }
            });
          },
          onTap: () => _navigateToLibrary(context, lib),
          onDelete: () {
            UIHelpers.showSuccessSnackBar(context, 'Deleted "${lib.title}"');
          },
        );
      },
    );
  }

  Widget _buildSitefinityFooter(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
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
                '$count ${count == 1 ? "library" : "libraries"}',
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
