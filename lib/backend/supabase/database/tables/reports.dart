import '../database.dart';

class ReportsTable extends SupabaseTable<ReportsRow> {
  @override
  String get tableName => 'reports';

  @override
  ReportsRow createRow(Map<String, dynamic> data) => ReportsRow(data);
}

class ReportsRow extends SupabaseDataRow {
  ReportsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ReportsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String get reportedByUser => getField<String>('reported_by_user')!;
  set reportedByUser(String value) =>
      setField<String>('reported_by_user', value);

  String? get reportedUser => getField<String>('reported_user');
  set reportedUser(String? value) => setField<String>('reported_user', value);

  String get reason => getField<String>('reason')!;
  set reason(String value) => setField<String>('reason', value);

  String get reportType => getField<String>('report_type')!;
  set reportType(String value) => setField<String>('report_type', value);

  String? get postId => getField<String>('post_id');
  set postId(String? value) => setField<String>('post_id', value);

  String? get commentId => getField<String>('comment_id');
  set commentId(String? value) => setField<String>('comment_id', value);

  String? get groupId => getField<String>('group_id');
  set groupId(String? value) => setField<String>('group_id', value);

  String? get businessPageId => getField<String>('business_page_id');
  set businessPageId(String? value) =>
      setField<String>('business_page_id', value);

  String? get eventId => getField<String>('event_id');
  set eventId(String? value) => setField<String>('event_id', value);

  String? get saleId => getField<String>('sale_id');
  set saleId(String? value) => setField<String>('sale_id', value);

  String get reportStatus => getField<String>('report_status')!;
  set reportStatus(String value) => setField<String>('report_status', value);

  bool? get mailSent => getField<bool>('mail_sent');
  set mailSent(bool? value) => setField<bool>('mail_sent', value);
}
