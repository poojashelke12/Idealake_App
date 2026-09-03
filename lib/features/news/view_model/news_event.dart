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

class NewsCreateEvent extends NewsEvent {
  final dynamic newsItem;
  const NewsCreateEvent(this.newsItem);

  @override
  List<Object?> get props => [newsItem];
}

class NewsDeleteEvent extends NewsEvent {
  final String id;
  const NewsDeleteEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class NewsBulkDeleteEvent extends NewsEvent {
  final List<String> ids;
  const NewsBulkDeleteEvent(this.ids);

  @override
  List<Object?> get props => [ids];
}

class NewsDuplicateEvent extends NewsEvent {
  final dynamic item;
  const NewsDuplicateEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class NewsTogglePublishEvent extends NewsEvent {
  final String id;
  final bool publish;
  const NewsTogglePublishEvent(this.id, this.publish);

  @override
  List<Object?> get props => [id, publish];
}

class NewsStatusFilterEvent extends NewsEvent {
  final String status;
  const NewsStatusFilterEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class NewsSortChangeEvent extends NewsEvent {
  final String sortOption;
  const NewsSortChangeEvent(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}
