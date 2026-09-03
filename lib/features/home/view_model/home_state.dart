import 'package:equatable/equatable.dart';
import '../../../core/network/api_response.dart';
import '../models/idealake_content_model.dart';
import '../models/idealake_image_model.dart';
import '../models/service_item_model.dart';

class HomeState extends Equatable {
  final ApiResponse<List<IdealakeImageModel>> bannersResponse;
  final ApiResponse<List<ServiceItemModel>> servicesResponse;
  final ApiResponse<List<IdealakeImageModel>> clientsResponse;
  final ApiResponse<List<IdealakeImageModel>> awardsResponse;
  final ApiResponse<List<IdealakeContentModel>> contentsResponse;
  final String selectedCategory;

  const HomeState({
    this.bannersResponse = const ApiResponse.initial(),
    this.servicesResponse = const ApiResponse.initial(),
    this.clientsResponse = const ApiResponse.initial(),
    this.awardsResponse = const ApiResponse.initial(),
    this.contentsResponse = const ApiResponse.initial(),
    this.selectedCategory = 'All',
  });

  HomeState copyWith({
    ApiResponse<List<IdealakeImageModel>>? bannersResponse,
    ApiResponse<List<ServiceItemModel>>? servicesResponse,
    ApiResponse<List<IdealakeImageModel>>? clientsResponse,
    ApiResponse<List<IdealakeImageModel>>? awardsResponse,
    ApiResponse<List<IdealakeContentModel>>? contentsResponse,
    String? selectedCategory,
  }) {
    return HomeState(
      bannersResponse: bannersResponse ?? this.bannersResponse,
      servicesResponse: servicesResponse ?? this.servicesResponse,
      clientsResponse: clientsResponse ?? this.clientsResponse,
      awardsResponse: awardsResponse ?? this.awardsResponse,
      contentsResponse: contentsResponse ?? this.contentsResponse,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [
        bannersResponse,
        servicesResponse,
        clientsResponse,
        awardsResponse,
        contentsResponse,
        selectedCategory,
      ];
}
