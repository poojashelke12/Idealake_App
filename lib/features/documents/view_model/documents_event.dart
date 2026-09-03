import 'package:equatable/equatable.dart';
import '../models/document_library_model.dart';

abstract class DocumentsEvent extends Equatable {
  const DocumentsEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch Document Libraries (Level 1)
class DocumentsFetchLibrariesEvent extends DocumentsEvent {
  final bool forceRefresh;
  const DocumentsFetchLibrariesEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Search Document Libraries
class DocumentsSearchLibrariesEvent extends DocumentsEvent {
  final String query;
  const DocumentsSearchLibrariesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Fetch Documents within a specific Library (Level 2)
class DocumentsFetchFilesInLibraryEvent extends DocumentsEvent {
  final DocumentLibraryModel library;
  final bool forceRefresh;

  const DocumentsFetchFilesInLibraryEvent(this.library, {this.forceRefresh = false});

  @override
  List<Object?> get props => [library, forceRefresh];
}

/// Search Documents within the active Library
class DocumentsSearchFilesInLibraryEvent extends DocumentsEvent {
  final String query;
  const DocumentsSearchFilesInLibraryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Toggle View Mode (List vs Grid)
class DocumentsToggleViewModeEvent extends DocumentsEvent {}

/// Toggle Offline-only Filter
class DocumentsToggleOfflineFilterEvent extends DocumentsEvent {
  final bool offlineOnly;
  const DocumentsToggleOfflineFilterEvent(this.offlineOnly);

  @override
  List<Object?> get props => [offlineOnly];
}

/// Toggle Download / Save File
class DocumentsToggleDownloadEvent extends DocumentsEvent {
  final String documentId;
  const DocumentsToggleDownloadEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

/// Create a new Library (matches "Create a library" web button)
class DocumentsCreateLibraryEvent extends DocumentsEvent {
  final String title;
  final String? description;
  final String storedIn;

  const DocumentsCreateLibraryEvent({
    required this.title,
    this.description,
    this.storedIn = 'Database',
  });

  @override
  List<Object?> get props => [title, description, storedIn];
}

/// Upload a new Document into active Library (matches "Upload documents" web button)
class DocumentsUploadFileEvent extends DocumentsEvent {
  final String title;
  final String libraryId;
  final String libraryTitle;
  final String description;
  final String fileExtension;
  final String fileSize;
  final String category;

  const DocumentsUploadFileEvent({
    required this.title,
    required this.libraryId,
    required this.libraryTitle,
    required this.description,
    required this.fileExtension,
    required this.fileSize,
    required this.category,
  });

  @override
  List<Object?> get props => [
        title,
        libraryId,
        libraryTitle,
        description,
        fileExtension,
        fileSize,
        category,
      ];
}

/// Legacy alias event
class DocumentsFetchEvent extends DocumentsFetchLibrariesEvent {
  const DocumentsFetchEvent({super.forceRefresh});
}

class DocumentsSearchEvent extends DocumentsSearchLibrariesEvent {
  const DocumentsSearchEvent(super.query);
}

class DocumentsCategoryFilterEvent extends DocumentsEvent {
  final String category;
  const DocumentsCategoryFilterEvent(this.category);

  @override
  List<Object?> get props => [category];
}
