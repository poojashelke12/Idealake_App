import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_response.dart';
import '../repository/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

/// ViewModel (BLoC) for managing Home Screen state and Sitefinity API data
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repository;

  HomeBloc(this._repository) : super(const HomeState()) {
    on<HomeFetchDataEvent>(_onFetchData);
    on<HomeRefreshDataEvent>(_onRefreshData);
    on<HomeCategorySelectedEvent>(_onCategorySelected);
  }

  Future<void> _onFetchData(HomeFetchDataEvent event, Emitter<HomeState> emit) async {
    // API calls removed as per user instruction; HomeScreen now runs on dummy data
    emit(state.copyWith(
      bannersResponse: const ApiResponse.completed([]),
      servicesResponse: const ApiResponse.completed([]),
      clientsResponse: const ApiResponse.completed([]),
      awardsResponse: const ApiResponse.completed([]),
      contentsResponse: const ApiResponse.completed([]),
    ));
  }

  Future<void> _onRefreshData(HomeRefreshDataEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
      bannersResponse: const ApiResponse.completed([]),
      servicesResponse: const ApiResponse.completed([]),
      clientsResponse: const ApiResponse.completed([]),
      awardsResponse: const ApiResponse.completed([]),
      contentsResponse: const ApiResponse.completed([]),
    ));
  }

  void _onCategorySelected(HomeCategorySelectedEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(selectedCategory: event.category));
  }
}
