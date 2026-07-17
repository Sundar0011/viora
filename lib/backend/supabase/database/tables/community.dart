import '../database.dart';

class CommunityTable extends SupabaseTable<CommunityRow> {
  @override
  String get tableName => 'community';

  @override
  CommunityRow createRow(Map<String, dynamic> data) => CommunityRow(data);
}

class CommunityRow extends SupabaseDataRow {
  CommunityRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CommunityTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);
}
