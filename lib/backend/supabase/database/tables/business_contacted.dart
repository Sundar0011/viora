import '../database.dart';

class BusinessContactedTable extends SupabaseTable<BusinessContactedRow> {
  @override
  String get tableName => 'business_contacted';

  @override
  BusinessContactedRow createRow(Map<String, dynamic> data) =>
      BusinessContactedRow(data);
}

class BusinessContactedRow extends SupabaseDataRow {
  BusinessContactedRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BusinessContactedTable();

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String get businessPageId => getField<String>('business_page_id')!;
  set businessPageId(String value) =>
      setField<String>('business_page_id', value);

  String get contactedUser => getField<String>('contacted_user')!;
  set contactedUser(String value) => setField<String>('contacted_user', value);

  List<String> get lastContactLink =>
      getListField<String>('last_contact_link')!;
  set lastContactLink(List<String> value) =>
      setListField<String>('last_contact_link', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);
}
