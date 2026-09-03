import 'package:equatable/equatable.dart';

abstract class CareerEvent extends Equatable {
  const CareerEvent();

  @override
  List<Object?> get props => [];
}

class CareerFetchEvent extends CareerEvent {
  final bool forceRefresh;
  const CareerFetchEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class CareerSearchEvent extends CareerEvent {
  final String query;
  const CareerSearchEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class CareerDepartmentFilterEvent extends CareerEvent {
  final String department;
  const CareerDepartmentFilterEvent(this.department);

  @override
  List<Object?> get props => [department];
}
