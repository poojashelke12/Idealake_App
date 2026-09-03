import 'package:equatable/equatable.dart';

abstract class AnnouncementsEvent extends Equatable {
  const AnnouncementsEvent();

  @override
  List<Object?> get props => [];
}

class AnnouncementsFetchEvent extends AnnouncementsEvent {
  final bool forceRefresh;
  const AnnouncementsFetchEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class AnnouncementsSearchEvent extends AnnouncementsEvent {
  final String query;
  const AnnouncementsSearchEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class AnnouncementsAudienceFilterEvent extends AnnouncementsEvent {
  final String audience;
  const AnnouncementsAudienceFilterEvent(this.audience);

  @override
  List<Object?> get props => [audience];
}

class AnnouncementsMarkAsReadEvent extends AnnouncementsEvent {
  final String id;
  const AnnouncementsMarkAsReadEvent(this.id);

  @override
  List<Object?> get props => [id];
}
