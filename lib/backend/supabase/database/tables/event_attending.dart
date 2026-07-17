import '../database.dart';

class EventAttendingTable extends SupabaseTable<EventAttendingRow> {
  @override
  String get tableName => 'event_attending';

  @override
  EventAttendingRow createRow(Map<String, dynamic> data) =>
      EventAttendingRow(data);
}

class EventAttendingRow extends SupabaseDataRow {
  EventAttendingRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EventAttendingTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String get eventId => getField<String>('event_id')!;
  set eventId(String value) => setField<String>('event_id', value);

  String get attendingId => getField<String>('attending_id')!;
  set attendingId(String value) => setField<String>('attending_id', value);

  bool get isInvited => getField<bool>('is_invited')!;
  set isInvited(bool value) => setField<bool>('is_invited', value);

  String? get invitedBy => getField<String>('invited_by');
  set invitedBy(String? value) => setField<String>('invited_by', value);

  bool? get isAttending => getField<bool>('is_attending');
  set isAttending(bool? value) => setField<bool>('is_attending', value);

  DateTime? get endDateTime => getField<DateTime>('end_date_time');
  set endDateTime(DateTime? value) =>
      setField<DateTime>('end_date_time', value);

  bool? get isGroupDeleted => getField<bool>('is_group_deleted');
  set isGroupDeleted(bool? value) => setField<bool>('is_group_deleted', value);
}
