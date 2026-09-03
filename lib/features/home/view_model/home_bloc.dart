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
    emit(state.copyWith(
      bannersResponse: const ApiResponse.loading(),
      servicesResponse: const ApiResponse.loading(),
      clientsResponse: const ApiResponse.loading(),
      awardsResponse: const ApiResponse.loading(),
      contentsResponse: const ApiResponse.loading(),
    ));

    try {
      final banners = await _repository.fetchHomeBanners();
      final services = await _repository.fetchServices();
      final clients = await _repository.fetchClientLogos();
      final awards = await _repository.fetchAwards();
      final contents = await _repository.fetchContents();

      emit(state.copyWith(
        bannersResponse: ApiResponse.completed(banners),
        servicesResponse: ApiResponse.completed(services),
        clientsResponse: ApiResponse.completed(clients),
        awardsResponse: ApiResponse.completed(awards),
        contentsResponse: ApiResponse.completed(contents),
      ));
    } catch (e) {
      emit(state.copyWith(
        bannersResponse: ApiResponse.error(e.toString()),
        servicesResponse: ApiResponse.error(e.toString()),
        clientsResponse: ApiResponse.error(e.toString()),
        awardsResponse: ApiResponse.error(e.toString()),
        contentsResponse: ApiResponse.error(e.toString()),
      ));
    }
  }

  Future<void> _onRefreshData(HomeRefreshDataEvent event, Emitter<HomeState> emit) async {
    try {
      final banners = await _repository.fetchHomeBanners();
      final services = await _repository.fetchServices();
      final clients = await _repository.fetchClientLogos();
      final awards = await _repository.fetchAwards();
      final contents = await _repository.fetchContents();

      emit(state.copyWith(
        bannersResponse: ApiResponse.completed(banners),
        servicesResponse: ApiResponse.completed(services),
        clientsResponse: ApiResponse.completed(clients),
        awardsResponse: ApiResponse.completed(awards),
        contentsResponse: ApiResponse.completed(contents),
      ));
    } catch (e) {
      emit(state.copyWith(
        bannersResponse: ApiResponse.error(e.toString()),
        servicesResponse: ApiResponse.error(e.toString()),
        clientsResponse: ApiResponse.error(e.toString()),
        awardsResponse: ApiResponse.error(e.toString()),
        contentsResponse: ApiResponse.error(e.toString()),
      ));
    }
  }

  void _onCategorySelected(HomeCategorySelectedEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(selectedCategory: event.category));
  }
}
