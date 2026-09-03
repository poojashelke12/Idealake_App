import 'package:equatable/equatable.dart';

abstract class PoliciesEvent extends Equatable {
  const PoliciesEvent();

  @override
  List<Object?> get props => [];
}

class PoliciesFetchEvent extends PoliciesEvent {
  final bool forceRefresh;
  const PoliciesFetchEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class PoliciesSearchEvent extends PoliciesEvent {
  final String query;
  const PoliciesSearchEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class PoliciesCategoryFilterEvent extends PoliciesEvent {
  final String category;
  const PoliciesCategoryFilterEvent(this.category);

  @override
  List<Object?> get props => [category];
}
