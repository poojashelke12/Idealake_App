import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_response.dart';
import '../models/document_library_model.dart';
import '../models/document_model.dart';
import '../repository/documents_repository.dart';
import 'documents_event.dart';
import 'documents_state.dart';

/// ViewModel (BLoC) for Document Libraries and Media Files
class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  final DocumentsRepository _repository;

  DocumentsBloc(this._repository) : super(const DocumentsState()) {
    on<DocumentsFetchLibrariesEvent>(_onFetchLibraries);
    on<DocumentsSearchLibrariesEvent>(_onSearchLibraries);
    on<DocumentsFetchFilesInLibraryEvent>(_onFetchFilesInLibrary);
    on<DocumentsSearchFilesInLibraryEvent>(_onSearchFilesInLibrary);
    on<DocumentsToggleViewModeEvent>(_onToggleViewMode);
    on<DocumentsToggleOfflineFilterEvent>(_onToggleOfflineFilter);
    on<DocumentsToggleDownloadEvent>(_onToggleDownload);
    on<DocumentsCreateLibraryEvent>(_onCreateLibrary);
    on<DocumentsUploadFileEvent>(_onUploadFile);
  }

  Future<void> _onFetchLibraries(
      DocumentsFetchLibrariesEvent event, Emitter<DocumentsState> emit) async {
    if (!event.forceRefresh && state.librariesResponse.data != null && state.librariesResponse.data!.isNotEmpty) {
      // Keep cached libraries
    } else {
      emit(state.copyWith(librariesResponse: const ApiResponse.loading()));
    }

    try {
      final items = await _repository.fetchLibraries(
        forceRefresh: event.forceRefresh,
        searchQuery: state.searchQuery,
      );
      emit(state.copyWith(
        librariesResponse: ApiResponse.completed(items),
        isOffline: false,
      ));
    } catch (e) {
      final cached = await _repository.fetchLibraries(
        searchQuery: state.searchQuery,
      );
      emit(state.copyWith(
        librariesResponse: ApiResponse.completed(cached),
        isOffline: true,
      ));
    }
  }

  Future<void> _onSearchLibraries(
      DocumentsSearchLibrariesEvent event, Emitter<DocumentsState> emit) async {
    emit(state.copyWith(searchQuery: event.query));
    final items = await _repository.fetchLibraries(searchQuery: event.query);
    emit(state.copyWith(librariesResponse: ApiResponse.completed(items)));
  }

  Future<void> _onFetchFilesInLibrary(
      DocumentsFetchFilesInLibraryEvent event, Emitter<DocumentsState> emit) async {
    emit(state.copyWith(
      selectedLibrary: event.library,
      filesResponse: const ApiResponse.loading(),
    ));

    try {
      final files = await _repository.fetchDocumentsInLibrary(
        event.library.id,
        libraryTitle: event.library.title,
        forceRefresh: event.forceRefresh,
        offlineOnly: state.offlineOnly,
      );
      emit(state.copyWith(filesResponse: ApiResponse.completed(files)));
    } catch (e) {
      final cached = await _repository.fetchDocumentsInLibrary(
        event.library.id,
        libraryTitle: event.library.title,
        offlineOnly: state.offlineOnly,
      );
      emit(state.copyWith(filesResponse: ApiResponse.completed(cached)));
    }
  }

  Future<void> _onSearchFilesInLibrary(
      DocumentsSearchFilesInLibraryEvent event, Emitter<DocumentsState> emit) async {
    if (state.selectedLibrary == null) return;
    final files = await _repository.fetchDocumentsInLibrary(
      state.selectedLibrary!.id,
      libraryTitle: state.selectedLibrary!.title,
      searchQuery: event.query,
      offlineOnly: state.offlineOnly,
    );
    emit(state.copyWith(filesResponse: ApiResponse.completed(files)));
  }

  void _onToggleViewMode(DocumentsToggleViewModeEvent event, Emitter<DocumentsState> emit) {
    emit(state.copyWith(isGridView: !state.isGridView));
  }

  Future<void> _onToggleOfflineFilter(
      DocumentsToggleOfflineFilterEvent event, Emitter<DocumentsState> emit) async {
    emit(state.copyWith(offlineOnly: event.offlineOnly));
    if (state.selectedLibrary != null) {
      final files = await _repository.fetchDocumentsInLibrary(
        state.selectedLibrary!.id,
        libraryTitle: state.selectedLibrary!.title,
        offlineOnly: event.offlineOnly,
      );
      emit(state.copyWith(filesResponse: ApiResponse.completed(files)));
    }
  }

  Future<void> _onToggleDownload(
      DocumentsToggleDownloadEvent event, Emitter<DocumentsState> emit) async {
    await _repository.toggleDownload(event.documentId);
    if (state.selectedLibrary != null) {
      final files = await _repository.fetchDocumentsInLibrary(
        state.selectedLibrary!.id,
        libraryTitle: state.selectedLibrary!.title,
        offlineOnly: state.offlineOnly,
      );
      emit(state.copyWith(filesResponse: ApiResponse.completed(files)));
    }
  }

  Future<void> _onCreateLibrary(
      DocumentsCreateLibraryEvent event, Emitter<DocumentsState> emit) async {
    final newLib = DocumentLibraryModel(
      id: 'lib-${DateTime.now().millisecondsSinceEpoch}',
      title: event.title,
      storedIn: event.storedIn,
      documentCount: 0,
      description: event.description,
    );
    await _repository.createLibrary(newLib);
    final items = await _repository.fetchLibraries();
    emit(state.copyWith(librariesResponse: ApiResponse.completed(items)));
  }

  Future<void> _onUploadFile(
      DocumentsUploadFileEvent event, Emitter<DocumentsState> emit) async {
    final newDoc = DocumentModel(
      id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
      libraryId: event.libraryId,
      libraryTitle: event.libraryTitle,
      title: event.title,
      description: event.description,
      fileExtension: event.fileExtension,
      fileSize: event.fileSize,
      category: event.category,
      updatedDate: DateTime.now(),
      uploadedBy: 'Mobile Author',
    );
    await _repository.uploadDocument(newDoc);

    // Refresh files in current library
    final files = await _repository.fetchDocumentsInLibrary(
      event.libraryId,
      libraryTitle: event.libraryTitle,
    );
    final libraries = await _repository.fetchLibraries();
    emit(state.copyWith(
      filesResponse: ApiResponse.completed(files),
      librariesResponse: ApiResponse.completed(libraries),
    ));
  }
}
