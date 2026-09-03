import 'package:equatable/equatable.dart';
import '../../../core/network/api_response.dart';
import '../models/document_library_model.dart';
import '../models/document_model.dart';

class DocumentsState extends Equatable {
  final ApiResponse<List<DocumentLibraryModel>> librariesResponse;
  final ApiResponse<List<DocumentModel>> filesResponse;
  final DocumentLibraryModel? selectedLibrary;
  final String searchQuery;
  final String selectedCategory;
  final bool isGridView;
  final bool offlineOnly;
  final bool isOffline;

  const DocumentsState({
    this.librariesResponse = const ApiResponse.initial(),
    this.filesResponse = const ApiResponse.initial(),
    this.selectedLibrary,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.isGridView = false,
    this.offlineOnly = false,
    this.isOffline = false,
  });

  // Legacy accessor for compatibility
  ApiResponse<List<DocumentModel>> get response => filesResponse;

  int get totalLibrariesCount => librariesResponse.data?.length ?? 0;

  DocumentsState copyWith({
    ApiResponse<List<DocumentLibraryModel>>? librariesResponse,
    ApiResponse<List<DocumentModel>>? filesResponse,
    DocumentLibraryModel? selectedLibrary,
    String? searchQuery,
    String? selectedCategory,
    bool? isGridView,
    bool? offlineOnly,
    bool? isOffline,
  }) {
    return DocumentsState(
      librariesResponse: librariesResponse ?? this.librariesResponse,
      filesResponse: filesResponse ?? this.filesResponse,
      selectedLibrary: selectedLibrary ?? this.selectedLibrary,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isGridView: isGridView ?? this.isGridView,
      offlineOnly: offlineOnly ?? this.offlineOnly,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
        librariesResponse,
        filesResponse,
        selectedLibrary,
        searchQuery,
        selectedCategory,
        isGridView,
        offlineOnly,
        isOffline,
      ];
}
