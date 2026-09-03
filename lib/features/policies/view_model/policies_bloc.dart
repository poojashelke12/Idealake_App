import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_response.dart';
import '../repository/policy_repository.dart';
import 'policies_event.dart';
import 'policies_state.dart';

/// ViewModel (BLoC) for Policies module
class PoliciesBloc extends Bloc<PoliciesEvent, PoliciesState> {
  final PolicyRepository _repository;

  PoliciesBloc(this._repository) : super(const PoliciesState()) {
    on<PoliciesFetchEvent>(_onFetch);
    on<PoliciesSearchEvent>(_onSearch);
    on<PoliciesCategoryFilterEvent>(_onCategoryFilter);
  }

  Future<void> _onFetch(PoliciesFetchEvent event, Emitter<PoliciesState> emit) async {
    if (!event.forceRefresh && state.response.data != null && state.response.data!.isNotEmpty) {
      // Keep cached data
    } else {
      emit(state.copyWith(response: const ApiResponse.loading()));
    }

    try {
      final items = await _repository.fetchPolicies(
        forceRefresh: event.forceRefresh,
        searchQuery: state.searchQuery,
        categoryFilter: state.selectedCategory,
      );
      emit(state.copyWith(
        response: ApiResponse.completed(items),
        isOffline: false,
      ));
    } catch (e) {
      final cached = await _repository.fetchPolicies(
        searchQuery: state.searchQuery,
        categoryFilter: state.selectedCategory,
      );
      emit(state.copyWith(
        response: ApiResponse.completed(cached),
        isOffline: true,
      ));
    }
  }

  Future<void> _onSearch(PoliciesSearchEvent event, Emitter<PoliciesState> emit) async {
    emit(state.copyWith(searchQuery: event.query));
    final items = await _repository.fetchPolicies(
      searchQuery: event.query,
      categoryFilter: state.selectedCategory,
    );
    emit(state.copyWith(response: ApiResponse.completed(items)));
  }

  Future<void> _onCategoryFilter(PoliciesCategoryFilterEvent event, Emitter<PoliciesState> emit) async {
    emit(state.copyWith(selectedCategory: event.category));
    final items = await _repository.fetchPolicies(
      searchQuery: state.searchQuery,
      categoryFilter: event.category,
    );
    emit(state.copyWith(response: ApiResponse.completed(items)));
  }
}
