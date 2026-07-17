import '../database.dart';

class TagTable extends SupabaseTable<TagRow> {
  @override
  String get tableName => 'tag';

  @override
  TagRow createRow(Map<String, dynamic> data) => TagRow(data);
}

class TagRow extends SupabaseDataRow {
  TagRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TagTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get postId => getField<String>('post_id');
  set postId(String? value) => setField<String>('post_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);
}
