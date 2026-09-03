import 'package:equatable/equatable.dart';
import '../../../core/network/api_response.dart';
import '../models/career_model.dart';

class CareerState extends Equatable {
  final ApiResponse<List<CareerModel>> response;
  final String searchQuery;
  final String selectedDepartment;
  final bool isOffline;

  const CareerState({
    this.response = const ApiResponse.initial(),
    this.searchQuery = '',
    this.selectedDepartment = 'All',
    this.isOffline = false,
  });

  /// Extracts unique departments dynamically for filter chips
  List<String> get availableDepartments {
    final list = response.data ?? [];
    final set = <String>{'All'};
    for (final item in list) {
      if (item.department.isNotEmpty) {
        set.add(item.department);
      }
    }
    return set.toList();
  }

  CareerState copyWith({
    ApiResponse<List<CareerModel>>? response,
    String? searchQuery,
    String? selectedDepartment,
    bool? isOffline,
  }) {
    return CareerState(
      response: response ?? this.response,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [response, searchQuery, selectedDepartment, isOffline];
}
