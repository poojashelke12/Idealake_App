import 'package:equatable/equatable.dart';
import '../../../core/network/api_response.dart';
import '../models/policy_model.dart';

class PoliciesState extends Equatable {
  final ApiResponse<List<PolicyModel>> response;
  final String searchQuery;
  final String selectedCategory;
  final bool isOffline;

  const PoliciesState({
    this.response = const ApiResponse.initial(),
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.isOffline = false,
  });

  PoliciesState copyWith({
    ApiResponse<List<PolicyModel>>? response,
    String? searchQuery,
    String? selectedCategory,
    bool? isOffline,
  }) {
    return PoliciesState(
      response: response ?? this.response,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [response, searchQuery, selectedCategory, isOffline];
}
