import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

class NewsFetchEvent extends NewsEvent {
  final bool forceRefresh;
  const NewsFetchEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class NewsSearchEvent extends NewsEvent {
  final String query;
  const NewsSearchEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class NewsCategoryFilterEvent extends NewsEvent {
  final String category;
  const NewsCategoryFilterEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class NewsTagFilterEvent extends NewsEvent {
  final String tag;
  const NewsTagFilterEvent(this.tag);

  @override
  List<Object?> get props => [tag];
}
