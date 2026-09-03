import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_response.dart';
import '../repository/announcement_repository.dart';
import 'announcements_event.dart';
import 'announcements_state.dart';

/// ViewModel (BLoC) for Announcements Feed
class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  final AnnouncementRepository _repository;

  AnnouncementsBloc(this._repository) : super(const AnnouncementsState()) {
    on<AnnouncementsFetchEvent>(_onFetch);
    on<AnnouncementsSearchEvent>(_onSearch);
    on<AnnouncementsAudienceFilterEvent>(_onAudienceFilter);
    on<AnnouncementsMarkAsReadEvent>(_onMarkAsRead);
  }

  Future<void> _onFetch(AnnouncementsFetchEvent event, Emitter<AnnouncementsState> emit) async {
    if (!event.forceRefresh && state.response.data != null && state.response.data!.isNotEmpty) {
      // Don't show full-screen loader if cached data is already present
    } else {
      emit(state.copyWith(response: const ApiResponse.loading()));
    }

    try {
      final items = await _repository.fetchAnnouncements(
        forceRefresh: event.forceRefresh,
        searchQuery: state.searchQuery,
        audienceFilter: state.selectedAudience,
      );
      emit(state.copyWith(
        response: ApiResponse.completed(items),
        isOffline: false,
      ));
    } catch (e) {
      // If error occurs, try serving cached items
      final cached = await _repository.fetchAnnouncements(
        searchQuery: state.searchQuery,
        audienceFilter: state.selectedAudience,
      );
      emit(state.copyWith(
        response: ApiResponse.completed(cached),
        isOffline: true,
      ));
    }
  }

  Future<void> _onSearch(AnnouncementsSearchEvent event, Emitter<AnnouncementsState> emit) async {
    emit(state.copyWith(searchQuery: event.query));
    final items = await _repository.fetchAnnouncements(
      searchQuery: event.query,
      audienceFilter: state.selectedAudience,
    );
    emit(state.copyWith(response: ApiResponse.completed(items)));
  }

  Future<void> _onAudienceFilter(
      AnnouncementsAudienceFilterEvent event, Emitter<AnnouncementsState> emit) async {
    emit(state.copyWith(selectedAudience: event.audience));
    final items = await _repository.fetchAnnouncements(
      searchQuery: state.searchQuery,
      audienceFilter: event.audience,
    );
    emit(state.copyWith(response: ApiResponse.completed(items)));
  }

  Future<void> _onMarkAsRead(
      AnnouncementsMarkAsReadEvent event, Emitter<AnnouncementsState> emit) async {
    await _repository.markAsRead(event.id);
    final currentList = state.response.data ?? [];
    final updatedList = currentList.map((item) {
      if (item.id == event.id) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();
    emit(state.copyWith(response: ApiResponse.completed(updatedList)));
  }
}
