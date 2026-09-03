import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeFetchDataEvent extends HomeEvent {}

class HomeRefreshDataEvent extends HomeEvent {}

class HomeCategorySelectedEvent extends HomeEvent {
  final String category;

  const HomeCategorySelectedEvent(this.category);

  @override
  List<Object?> get props => [category];
}
