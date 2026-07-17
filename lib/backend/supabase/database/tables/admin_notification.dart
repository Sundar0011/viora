import '../database.dart';

class AdminNotificationTable extends SupabaseTable<AdminNotificationRow> {
  @override
  String get tableName => 'admin_notification';

  @override
  AdminNotificationRow createRow(Map<String, dynamic> data) =>
      AdminNotificationRow(data);
}

class AdminNotificationRow extends SupabaseDataRow {
  AdminNotificationRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AdminNotificationTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get content => getField<String>('content');
  set content(String? value) => setField<String>('content', value);

  DateTime? get sentOn => getField<DateTime>('sent_on');
  set sentOn(DateTime? value) => setField<DateTime>('sent_on', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get audienceType => getField<String>('audience_type');
  set audienceType(String? value) => setField<String>('audience_type', value);
}
