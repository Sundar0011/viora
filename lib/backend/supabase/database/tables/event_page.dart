import '../database.dart';

class EventPageTable extends SupabaseTable<EventPageRow> {
  @override
  String get tableName => 'event_page';

  @override
  EventPageRow createRow(Map<String, dynamic> data) => EventPageRow(data);
}

class EventPageRow extends SupabaseDataRow {
  EventPageRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EventPageTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String get adminUser => getField<String>('admin_user')!;
  set adminUser(String value) => setField<String>('admin_user', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  String get coverImage => getField<String>('cover_image')!;
  set coverImage(String value) => setField<String>('cover_image', value);

  String? get videoCallLink => getField<String>('video_call_link');
  set videoCallLink(String? value) =>
      setField<String>('video_call_link', value);

  String? get location => getField<String>('location');
  set location(String? value) => setField<String>('location', value);

  DateTime get startDateTime => getField<DateTime>('start_date_time')!;
  set startDateTime(DateTime value) =>
      setField<DateTime>('start_date_time', value);

  DateTime? get endDateTime => getField<DateTime>('end_date_time');
  set endDateTime(DateTime? value) =>
      setField<DateTime>('end_date_time', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  bool? get isDeleted => getField<bool>('is_deleted');
  set isDeleted(bool? value) => setField<bool>('is_deleted', value);

  int get attendeeCount => getField<int>('attendee_count')!;
  set attendeeCount(int value) => setField<int>('attendee_count', value);

  String? get address => getField<String>('Address');
  set address(String? value) => setField<String>('Address', value);

  double? get latitude => getField<double>('latitude');
  set latitude(double? value) => setField<double>('latitude', value);

  double? get logitude => getField<double>('logitude');
  set logitude(double? value) => setField<double>('logitude', value);

  String get eventStatus => getField<String>('event_status')!;
  set eventStatus(String value) => setField<String>('event_status', value);
}
