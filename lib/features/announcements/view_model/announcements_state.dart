import 'package:equatable/equatable.dart';
import '../../../core/network/api_response.dart';
import '../models/announcement_model.dart';

class AnnouncementsState extends Equatable {
  final ApiResponse<List<AnnouncementModel>> response;
  final String searchQuery;
  final String selectedAudience;
  final bool isOffline;

  const AnnouncementsState({
    this.response = const ApiResponse.initial(),
    this.searchQuery = '',
    this.selectedAudience = 'All',
    this.isOffline = false,
  });

  int get unreadCount {
    final list = response.data ?? [];
    return list.where((item) => !item.isRead).length;
  }

  AnnouncementsState copyWith({
    ApiResponse<List<AnnouncementModel>>? response,
    String? searchQuery,
    String? selectedAudience,
    bool? isOffline,
  }) {
    return AnnouncementsState(
      response: response ?? this.response,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedAudience: selectedAudience ?? this.selectedAudience,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [response, searchQuery, selectedAudience, isOffline];
}
