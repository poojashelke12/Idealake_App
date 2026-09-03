import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_response.dart';
import '../models/career_model.dart';
import '../repository/career_repository.dart';
import 'career_event.dart';
import 'career_state.dart';

/// ViewModel (BLoC) for Sitefinity Career Opportunities
class CareerBloc extends Bloc<CareerEvent, CareerState> {
  final CareerRepository _repository;
  CareerRepository get repository => _repository;

  List<CareerModel> _unfilteredCache = [];

  CareerBloc(this._repository) : super(const CareerState()) {
    on<CareerFetchEvent>(_onFetch);
    on<CareerSearchEvent>(_onSearch);
    on<CareerDepartmentFilterEvent>(_onDepartmentFilter);
  }

  Future<void> _onFetch(CareerFetchEvent event, Emitter<CareerState> emit) async {
    if (!event.forceRefresh && state.response.data != null && state.response.data!.isNotEmpty) {
      // Retain already loaded items during background refresh
    } else {
      emit(state.copyWith(response: const ApiResponse.loading()));
    }

    try {
      final items = await _repository.fetchCareers(
        forceRefresh: event.forceRefresh,
      );
      _unfilteredCache = items;

      final filtered = _applyFilters(_unfilteredCache, state.searchQuery, state.selectedDepartment);
      emit(state.copyWith(
        response: ApiResponse.completed(filtered),
        isOffline: false,
      ));
    } catch (_) {
      final cached = await _repository.fetchCareers();
      _unfilteredCache = cached;

      final filtered = _applyFilters(_unfilteredCache, state.searchQuery, state.selectedDepartment);
      emit(state.copyWith(
        response: ApiResponse.completed(filtered),
        isOffline: true,
      ));
    }
  }

  void _onSearch(CareerSearchEvent event, Emitter<CareerState> emit) {
    emit(state.copyWith(searchQuery: event.query));
    final filtered = _applyFilters(_unfilteredCache, event.query, state.selectedDepartment);
    emit(state.copyWith(response: ApiResponse.completed(filtered)));
  }

  void _onDepartmentFilter(CareerDepartmentFilterEvent event, Emitter<CareerState> emit) {
    emit(state.copyWith(selectedDepartment: event.department));
    final filtered = _applyFilters(_unfilteredCache, state.searchQuery, event.department);
    emit(state.copyWith(response: ApiResponse.completed(filtered)));
  }

  List<CareerModel> _applyFilters(List<CareerModel> source, String query, String department) {
    var result = source;

    if (department.isNotEmpty && department.toLowerCase() != 'all') {
      result = result.where((e) => e.department.toLowerCase() == department.toLowerCase()).toList();
    }

    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((item) {
        return item.jobTitle.toLowerCase().contains(q) ||
            item.department.toLowerCase().contains(q) ||
            item.jobLocation.toLowerCase().contains(q) ||
            item.jobExperience.toLowerCase().contains(q) ||
            item.jobResponsibilities.toLowerCase().contains(q) ||
            item.jobRequirements.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }
}
